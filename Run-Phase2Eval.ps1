[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('diagnostic','gate1','regression')][string]$Suite,
    [ValidateSet('A','B','C','D')][string[]]$Condition = @('A','B','C','D'),
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Import-Module (Join-Path $root 'src/CommaHarness.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationPrompt.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationPacket.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationValidation.psm1') -Force

$phase = Get-Content -Raw (Join-Path $root 'phase2_config.json') | ConvertFrom-Json
$base = Get-Content -Raw (Join-Path $root 'config.json') | ConvertFrom-Json
$exemplars = @(Read-NarrationExemplars (Join-Path $root 'exemplars/narration_exemplars.json'))
$work = Join-Path $root 'eval/.work'
New-Item -ItemType Directory -Force $work | Out-Null

$conditions = @{
    A = @{ format='facts'; exemplar_count=0 }
    B = @{ format='facts'; exemplar_count=8 }
    C = @{ format='literary'; exemplar_count=0 }
    D = @{ format='literary'; exemplar_count=8 }
}

if ($Suite -eq 'diagnostic') {
    $cases = @(Get-Content -Raw (Join-Path $root 'eval/diagnostic_cases.json') | ConvertFrom-Json)
    $selected = @($Condition)
} elseif ($Suite -eq 'gate1') {
    $cases = @(Get-Content -Raw (Join-Path $root 'eval/gate1_cases.json') | ConvertFrom-Json)
    $selected = @('B')
} else {
    $cases = @(Get-Content -Raw (Join-Path $root 'eval/baseline_50.json') | ConvertFrom-Json)
    $selected = @('B')
}

foreach ($conditionName in $selected) {
    $spec = $conditions[$conditionName]
    $format = if ($Suite -eq 'diagnostic') { $spec.format } else { [string]$phase.packet_format }
    $exampleSet = if (($Suite -ne 'diagnostic') -or $spec.exemplar_count -eq 8) { $exemplars } else { @() }
    $logPath = Join-Path $root "eval/${Suite}_${conditionName}_raw.jsonl"
    if ($Force -and (Test-Path $logPath)) { Remove-Item -LiteralPath $logPath }
    $done = @{}
    if (Test-Path $logPath) {
        Get-Content $logPath | ForEach-Object { if ($_){ $row = $_ | ConvertFrom-Json; $done[[string]$row.case_id] = $true } }
    }

    $runConfig = $base.PSObject.Copy()
    $runConfig.temperature = [double]$phase.temperature
    $runConfig.top_p = [double]$phase.top_p
    $runConfig.top_k = [int]$phase.top_k
    $runConfig.repeat_penalty = [double]$phase.repeat_penalty
    $runConfig.max_tokens = [int]$phase.max_tokens
    $runConfig.stop_sequence = if ($format -eq 'facts') { "`nFACTS" } else { "`nSCENE NOTES" }
    $configPath = Join-Path $work "config_${Suite}_${conditionName}.json"
    $runConfig | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 $configPath

    foreach ($case in $cases) {
        if ($done.ContainsKey([string]$case.id)) { Write-Host "SKIP $Suite/$conditionName/$($case.id)"; continue }
        $packet = ConvertTo-NarrationPacket $case
        $prompt = Build-NarrationPrompt -Packet $packet -Format $format -Exemplars $exampleSet
        $promptPath = Join-Path $work "prompt_${Suite}_${conditionName}_$($case.id).txt"
        $prompt | Set-Content -NoNewline -Encoding utf8 $promptPath
        Write-Host "RUN $Suite/$conditionName/$($case.id)"
        $result = Invoke-CommaGeneration -PromptPath $promptPath -ConfigPath $configPath -Seed ([int]$case.seed) -Temperature ([double]$phase.temperature) -MaxTokens ([int]$phase.max_tokens)
        $trimmedCompletion = $result.Text -replace '(?s)\s*(?:FACTS|SCENE NOTES)\s*$', ''
        $assembled = 'You ' + $trimmedCompletion.TrimStart()
        $validation = Test-NarrationOutput -Text $assembled -ForbiddenTerms @($case.forbidden_terms) -MaxWords ([int]$phase.max_words) -Actor ([string]$case.actor)
        [ordered]@{
            suite = $Suite; condition = $conditionName; case_id = $case.id; category = $case.category
            seed = [int]$case.seed; packet_format = $format; exemplar_count = $exampleSet.Count
            input_packet = $packet
            raw_completion = $result.Text; trimmed_completion = $trimmedCompletion; assembled_narration = $assembled
            validated_output = $validation.ValidatedOutput
            validator_passed = $validation.Passed; lexical = $validation.Lexical; structural = $validation.Structural
            prompt_characters = $result.Prompt.Length; generated_tokens = $result.TokenCount
            elapsed_seconds = [math]::Round($result.ElapsedSeconds,3); tokens_per_second = $result.TokensPerSecond
            gpu_active = $result.GpuActive; settings = $result.Settings
        } | ConvertTo-Json -Depth 12 -Compress | Add-Content -Encoding utf8 $logPath
    }
}

Write-Host "Completed $Suite. Raw JSONL logs are under eval/."
