$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/InferenceService.psm1') -Force
function Assert($Condition,[string]$Message){if(-not$Condition){throw "FAILED: $Message"}}
$service=Get-Content -Raw (Join-Path $root 'inference_service.json')|ConvertFrom-Json
$interpreter=Get-Content -Raw (Join-Path $root 'interpreter_config.json')|ConvertFrom-Json
$narrator=Get-Content -Raw (Join-Path $root 'config.json')|ConvertFrom-Json
Assert ($service.inference_backend-eq'server') 'persistent service backend configured'
Assert ($service.runtime_path-like'*llama-server.exe') 'llama-server runtime configured'
Assert ($interpreter.inference_backend-eq'server'-and$narrator.inference_backend-eq'server') 'both model paths use persistent service'
foreach($field in @('host','port','model_path','context_size','gpu_layers','health_timeout_seconds','timeout_seconds')){Assert ($null-ne$service.PSObject.Properties[$field]) "service config field $field"}
$interpreterSource=Get-Content -Raw (Join-Path $root 'src/InterpreterModel.psm1')
$narratorSource=Get-Content -Raw (Join-Path $root 'src/CommaHarness.psm1')
Assert ($interpreterSource-match'Invoke-PersistentInference.+-JsonSchema') 'interpreter forwards dynamic JSON Schema'
Assert ($narratorSource-match'Invoke-PersistentInference') 'narrator uses persistent service'
$unavailable=Join-Path $root 'eval/.work/unavailable-service.json';$bad=$service.PSObject.Copy();$bad.port=65534;$bad|ConvertTo-Json|Set-Content -Encoding utf8 $unavailable
$message='';try{Test-InferenceService $unavailable -ThrowOnFailure|Out-Null}catch{$message=$_.Exception.Message}
Assert ($message-match'Inference service unavailable at 127.0.0.1:65534') 'unavailable service fails clearly'
Write-Host 'Phase 4.5 infrastructure tests passed.'
