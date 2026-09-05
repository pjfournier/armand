Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot 'InferenceService.psm1') -Force

function Resolve-ProjectPath {
    param([Parameter(Mandatory)][string]$Value, [Parameter(Mandatory)][string]$ProjectRoot)
    if ([System.IO.Path]::IsPathRooted($Value)) { return [System.IO.Path]::GetFullPath($Value) }
    return [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $Value))
}

function Read-CommaConfig {
    param([Parameter(Mandatory)][string]$ConfigPath, [Parameter(Mandatory)][string]$ProjectRoot)
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        throw "Configuration file not found: $ConfigPath. Copy or restore config.json, then try again."
    }
    try { $config = Get-Content -Raw -LiteralPath $ConfigPath | ConvertFrom-Json }
    catch { throw "Malformed JSON configuration at ${ConfigPath}: $($_.Exception.Message)" }

    $required = @('runtime_path','model_path','context_size','temperature','top_p','top_k','repeat_penalty','max_tokens','seed','stop_sequence','gpu_layers')
    foreach ($name in $required) {
        if ($null -eq $config.PSObject.Properties[$name]) { throw "Configuration is missing required setting '$name': $ConfigPath" }
    }
    $config.runtime_path = Resolve-ProjectPath $config.runtime_path $ProjectRoot
    $config.model_path = Resolve-ProjectPath $config.model_path $ProjectRoot
    if ([int]$config.context_size -lt 128) { throw 'context_size must be at least 128.' }
    if ([int]$config.max_tokens -lt 1) { throw 'max_tokens must be at least 1.' }
    if ([double]$config.temperature -lt 0) { throw 'temperature cannot be negative.' }
    if ([double]$config.top_p -le 0 -or [double]$config.top_p -gt 1) { throw 'top_p must be greater than 0 and at most 1.' }
    if ([int]$config.top_k -lt 0) { throw 'top_k cannot be negative.' }
    if ([double]$config.repeat_penalty -le 0) { throw 'repeat_penalty must be greater than 0.' }
    return $config
}

function Invoke-CommaGeneration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$PromptPath,
        [Parameter(Mandatory)][string]$ConfigPath,
        [Nullable[int]]$Seed,
        [Nullable[double]]$Temperature,
        [Nullable[int]]$MaxTokens
    )
    $projectRoot = Split-Path -Parent $PSScriptRoot
    $config = Read-CommaConfig $ConfigPath $projectRoot
    if ($null -ne $Seed) { $config.seed = [int]$Seed }
    if ($null -ne $Temperature) { $config.temperature = [double]$Temperature }
    if ($null -ne $MaxTokens) { $config.max_tokens = [int]$MaxTokens }

    $resolvedPrompt = Resolve-ProjectPath $PromptPath $projectRoot
    if (-not (Test-Path -LiteralPath $resolvedPrompt -PathType Leaf)) {
        throw "Prompt file not found: $resolvedPrompt. Pass a valid plain-text prompt path."
    }
    if (-not (Test-Path -LiteralPath $config.runtime_path -PathType Leaf)) {
        throw "llama.cpp completion runtime not found: $($config.runtime_path). Run .\setup.ps1 first or update runtime_path."
    }
    if (-not (Test-Path -LiteralPath $config.model_path -PathType Leaf)) {
        throw "Comma model not found: $($config.model_path). Run .\setup.ps1 first or update model_path."
    }

    $prompt = Get-Content -Raw -LiteralPath $resolvedPrompt
    if ([string]::IsNullOrWhiteSpace($prompt)) { throw "Prompt file is empty: $resolvedPrompt" }

    if ($config.PSObject.Properties['inference_backend'] -and $config.inference_backend -eq 'server') {
        $result=Invoke-PersistentInference -Prompt $prompt -GenerationConfig $config -Seed $Seed -Temperature $Temperature -MaxTokens $MaxTokens
        return [pscustomobject]@{
            Text=$result.Text;TokenCount=$null;ElapsedSeconds=$result.ElapsedSeconds;LoadSeconds=0.0
            GenerationSeconds=$result.ElapsedSeconds;TokensPerSecond=$result.TokensPerSecond;GpuActive=$result.GpuActive
            CpuFallback=$false;RuntimeLog=$result.RuntimeLog;Settings=$config;Prompt=$prompt
        }
    }

    $arguments = @(
            '--model', $config.model_path,
            '--file', $resolvedPrompt,
            '--ctx-size', [string]$config.context_size,
            '--temp', ([double]$config.temperature).ToString([Globalization.CultureInfo]::InvariantCulture),
            '--top-p', ([double]$config.top_p).ToString([Globalization.CultureInfo]::InvariantCulture),
            '--top-k', [string]$config.top_k,
            '--repeat-penalty', ([double]$config.repeat_penalty).ToString([Globalization.CultureInfo]::InvariantCulture),
            '--predict', [string]$config.max_tokens,
            '--seed', [string]$config.seed,
            '--reverse-prompt', [string]$config.stop_sequence,
            '--gpu-layers', [string]$config.gpu_layers,
            '--no-conversation', '--no-display-prompt', '--color', 'off', '--simple-io', '--perf', '--fit', 'off', '--verbose'
    )
    $process = $null
    try {
        $startInfo = [Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $config.runtime_path
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        foreach ($argument in $arguments) { [void]$startInfo.ArgumentList.Add([string]$argument) }

        $process = [Diagnostics.Process]::new()
        $process.StartInfo = $startInfo
        $watch = [Diagnostics.Stopwatch]::StartNew()
        if (-not $process.Start()) { throw 'Failed to start the llama.cpp completion runtime.' }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        $watch.Stop()
        $completion = $stdoutTask.GetAwaiter().GetResult().Trim()
        $runtimeLog = $stderrTask.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0) {
            $hint = if ($runtimeLog -match '(?i)cuda|gpu') { ' Check the NVIDIA driver/CUDA runtime, or set gpu_layers to 0 for an explicit CPU test.' } else { '' }
            throw "Generation failed with exit code $($process.ExitCode).$hint`n$runtimeLog"
        }
        if ([string]::IsNullOrWhiteSpace($completion)) { throw "Generation completed but returned no text.`n$runtimeLog" }

        $tokenCount = $null
        $promptTokenCount = $null
        $sampledTokenCount = $null
        if ($runtimeLog -match '(?m)^.*common_perf_print:\s+prompt eval time\s*=.*?/\s*([0-9]+) tokens') { $promptTokenCount = [int]$Matches[1] }
        if ($runtimeLog -match '(?m)^.*common_perf_print:\s+samplers time\s*=.*?/\s*([0-9]+) tokens') { $sampledTokenCount = [int]$Matches[1] }
        if ($null -ne $promptTokenCount -and $null -ne $sampledTokenCount) { $tokenCount = $sampledTokenCount - $promptTokenCount }
        elseif ($runtimeLog -match '(?m)^.*common_perf_print:\s+eval time\s*=.*?/\s*([0-9]+) (?:runs|tokens)') { $tokenCount = [int]$Matches[1] }
        $speed = $null
        if ($runtimeLog -match '(?m)^.*common_perf_print:\s+eval time\s*=.*?([0-9]+(?:\.[0-9]+)?) tokens per second') { $speed = [double]$Matches[1] }
        $loadSeconds = $null
        if ($runtimeLog -match '(?m)^.*common_perf_print:\s+load time\s*=\s*([0-9]+(?:\.[0-9]+)?) ms') { $loadSeconds = [double]$Matches[1] / 1000 }
        $generationSeconds = $null
        if ($runtimeLog -match '(?m)^.*common_perf_print:\s+total time\s*=\s*([0-9]+(?:\.[0-9]+)?) ms') { $generationSeconds = [double]$Matches[1] / 1000 }
        $gpuActive = $runtimeLog -match '(?im)offloaded\s+[1-9][0-9]*\/\s*[0-9]+\s+layers?\s+to GPU'
        $cpuFallback = -not $gpuActive

        [pscustomobject]@{
            Text = $completion
            TokenCount = $tokenCount
            ElapsedSeconds = $watch.Elapsed.TotalSeconds
            LoadSeconds = $loadSeconds
            GenerationSeconds = $generationSeconds
            TokensPerSecond = $speed
            GpuActive = $gpuActive
            CpuFallback = $cpuFallback
            RuntimeLog = $runtimeLog
            Settings = $config
            Prompt = $prompt
        }
    }
    finally {
        if ($null -ne $process) { $process.Dispose() }
    }
}

Export-ModuleMember -Function Invoke-CommaGeneration
