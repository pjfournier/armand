$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/InferenceService.psm1') -Force
$configPath=Join-Path $root 'inference_service.json';$cfg=Read-InferenceServiceConfig $configPath
if(Test-InferenceService $configPath){Write-Host "Inference service already ready at $($cfg.host):$($cfg.port).";exit 0}
$runtime=Resolve-InferencePath $cfg.runtime_path $root;$model=Resolve-InferencePath $cfg.model_path $root
if(-not(Test-Path -LiteralPath $runtime -PathType Leaf)){throw "llama.cpp server runtime not found: $runtime"}
if(-not(Test-Path -LiteralPath $model -PathType Leaf)){throw "Comma model not found: $model"}
$logDir=Join-Path $root 'eval/.work';New-Item -ItemType Directory -Force $logDir|Out-Null
$stdout=Join-Path $logDir 'llama-server.stdout.log';$stderr=Join-Path $logDir 'llama-server.stderr.log';$pidPath=Join-Path $logDir 'llama-server.pid'
$args=@('--model',$model,'--host',[string]$cfg.host,'--port',[string]$cfg.port,'--ctx-size',[string]$cfg.context_size,'--gpu-layers',[string]$cfg.gpu_layers,'--timeout',[string]$cfg.timeout_seconds)
$watch=[Diagnostics.Stopwatch]::StartNew();$process=Start-Process -FilePath $runtime -ArgumentList $args -RedirectStandardOutput $stdout -RedirectStandardError $stderr -WindowStyle Hidden -PassThru
$process.Id|Set-Content -Encoding ascii $pidPath
while($watch.Elapsed.TotalSeconds-lt[int]$cfg.startup_timeout_seconds){if(Test-InferenceService $configPath){$watch.Stop();$seconds=[math]::Round($watch.Elapsed.TotalSeconds,3);[ordered]@{pid=$process.Id;started_utc=[datetime]::UtcNow.ToString('o');startup_seconds=$seconds;endpoint="http://$($cfg.host):$($cfg.port)"}|ConvertTo-Json|Set-Content -Encoding utf8 (Join-Path $logDir 'llama-server-state.json');Write-Host "Inference service ready at $($cfg.host):$($cfg.port) in $seconds seconds (PID $($process.Id)).";exit 0};if($process.HasExited){throw "Inference service exited during startup. See $stderr"};Start-Sleep -Milliseconds 250}
throw "Inference service did not become ready within $($cfg.startup_timeout_seconds) seconds. See $stderr"
