Set-StrictMode -Version Latest

function Resolve-InferencePath {
    param([Parameter(Mandatory)][string]$Value,[Parameter(Mandatory)][string]$Root)
    if ([IO.Path]::IsPathRooted($Value)) { return [IO.Path]::GetFullPath($Value) }
    return [IO.Path]::GetFullPath((Join-Path $Root $Value))
}

function Read-InferenceServiceConfig {
    param([string]$ConfigPath=(Join-Path (Split-Path -Parent $PSScriptRoot) 'inference_service.json'))
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) { throw "Inference service configuration not found: $ConfigPath" }
    try { $config=Get-Content -Raw -LiteralPath $ConfigPath|ConvertFrom-Json }
    catch { throw "Malformed inference service configuration at ${ConfigPath}: $($_.Exception.Message)" }
    foreach ($name in @('inference_backend','runtime_path','model_path','host','port','context_size','gpu_layers','health_timeout_seconds','timeout_seconds','startup_timeout_seconds')) {
        if ($null-eq$config.PSObject.Properties[$name]) { throw "Inference service configuration is missing '$name'." }
    }
    if ($config.inference_backend-ne'server') { throw "Unsupported inference_backend '$($config.inference_backend)'." }
    if ([int]$config.port-lt1-or[int]$config.port-gt65535) { throw 'Inference service port must be between 1 and 65535.' }
    $config
}

function Get-InferenceServiceUri {
    param($Config,[string]$Path='')
    "http://$($Config.host):$($Config.port)$Path"
}

function Test-InferenceService {
    param([string]$ConfigPath=(Join-Path (Split-Path -Parent $PSScriptRoot) 'inference_service.json'),[switch]$ThrowOnFailure)
    $config=Read-InferenceServiceConfig $ConfigPath;$uri=Get-InferenceServiceUri $config '/health'
    try {
        $response=Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec ([int]$config.health_timeout_seconds)
        $ready=($response.status-eq'ok')
        if(-not$ready-and$ThrowOnFailure){throw "Inference service is not ready at $($config.host):$($config.port)"}
        return $ready
    } catch {
        if($ThrowOnFailure){throw "Inference service unavailable at $($config.host):$($config.port)"}
        return $false
    }
}

function Invoke-PersistentInference {
    [CmdletBinding()]param(
        [Parameter(Mandatory)][string]$Prompt,
        [Parameter(Mandatory)]$GenerationConfig,
        $JsonSchema,
        [Nullable[int]]$Seed,
        [Nullable[double]]$Temperature,
        [Nullable[int]]$MaxTokens,
        [string]$ServiceConfigPath=(Join-Path (Split-Path -Parent $PSScriptRoot) 'inference_service.json')
    )
    $service=Read-InferenceServiceConfig $ServiceConfigPath
    Test-InferenceService $ServiceConfigPath -ThrowOnFailure|Out-Null
    $body=[ordered]@{
        prompt=$Prompt
        n_predict=[int]$(if($null-ne$MaxTokens){$MaxTokens}else{$GenerationConfig.max_tokens})
        temperature=[double]$(if($null-ne$Temperature){$Temperature}else{$GenerationConfig.temperature})
        top_p=[double]$GenerationConfig.top_p
        top_k=[int]$GenerationConfig.top_k
        repeat_penalty=[double]$GenerationConfig.repeat_penalty
        seed=[int]$(if($null-ne$Seed){$Seed}else{$GenerationConfig.seed})
        cache_prompt=$true
        stream=$false
    }
    if($GenerationConfig.PSObject.Properties['stop_sequence']-and-not[string]::IsNullOrEmpty([string]$GenerationConfig.stop_sequence)){$body.stop=@([string]$GenerationConfig.stop_sequence)}
    if($null-ne$JsonSchema){$body.json_schema=$JsonSchema}
    $watch=[Diagnostics.Stopwatch]::StartNew()
    try{$response=Invoke-RestMethod -Uri (Get-InferenceServiceUri $service '/completion') -Method Post -ContentType 'application/json' -Body ($body|ConvertTo-Json -Depth 20 -Compress) -TimeoutSec ([int]$service.timeout_seconds)}
    catch{throw "Inference request failed at $($service.host):$($service.port): $($_.Exception.Message)"}
    finally{$watch.Stop()}
    if($null-eq$response.PSObject.Properties['content']){throw 'Inference service returned no completion content.'}
    [pscustomobject]@{RawOutput=[string]$response.content;Text=[string]$response.content;ElapsedSeconds=$watch.Elapsed.TotalSeconds;TokensPerSecond=$(if($response.timings){$response.timings.predicted_per_second}else{$null});GpuActive=$true;RuntimeLog='';Response=$response}
}

Export-ModuleMember -Function Read-InferenceServiceConfig,Resolve-InferencePath,Get-InferenceServiceUri,Test-InferenceService,Invoke-PersistentInference
