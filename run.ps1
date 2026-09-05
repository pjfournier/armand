[CmdletBinding()]
param(
    [Parameter(Position=0)][string]$Prompt = 'prompts/smoke_test.txt',
    [string]$Config = 'config.json',
    [Nullable[int]]$Seed,
    [Nullable[double]]$Temperature,
    [Nullable[int]]$MaxTokens,
    [switch]$SmokeTest
)

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
Import-Module (Join-Path $projectRoot 'src/CommaHarness.psm1') -Force

try {
    Write-Host 'Loading Comma...'
    $result = Invoke-CommaGeneration -PromptPath $Prompt -ConfigPath (Join-Path $projectRoot $Config) -Seed $Seed -Temperature $Temperature -MaxTokens $MaxTokens
    Write-Host 'Model ready.'
    Write-Host "`nPROMPT`n------"
    Write-Host $result.Prompt.TrimEnd()
    Write-Host "`nGENERATED COMPLETION`n--------------------"
    Write-Output $result.Text
    Write-Host "`nGENERATION METRICS`n------------------"
    Write-Host ('Model load: {0}' -f $(if ($null -eq $result.LoadSeconds) { 'unavailable' } else { '{0:N2} sec' -f $result.LoadSeconds }))
    Write-Host ('Generation: {0}' -f $(if ($null -eq $result.GenerationSeconds) { 'unavailable' } else { '{0:N2} sec' -f $result.GenerationSeconds }))
    Write-Host ('End-to-end: {0:N2} sec' -f $result.ElapsedSeconds)
    Write-Host ('Tokens: {0}' -f $(if ($null -eq $result.TokenCount) { 'unavailable' } else { $result.TokenCount }))
    Write-Host ('Speed: {0}' -f $(if ($null -eq $result.TokensPerSecond) { 'unavailable' } else { '{0:N2} tok/s' -f $result.TokensPerSecond }))
    Write-Host ('Acceleration: {0}' -f $(if ($result.GpuActive) { 'GPU (CUDA)' } else { 'CPU fallback (CUDA offload was not detected)' }))

    if ($SmokeTest) {
        if ([string]::IsNullOrWhiteSpace($result.Text)) { throw 'Smoke test failed: completion was empty.' }
        if ($result.Text.Contains($result.Prompt.Trim())) { throw 'Smoke test failed: completion echoed the entire prompt.' }
        Write-Host "`nSMOKE TEST: PASS"
    }
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
