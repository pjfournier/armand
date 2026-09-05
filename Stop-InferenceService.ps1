$ErrorActionPreference='Stop';$root=$PSScriptRoot;$pidPath=Join-Path $root 'eval/.work/llama-server.pid'
if(-not(Test-Path -LiteralPath $pidPath)){Write-Host 'No managed inference service PID file was found.';exit 0}
$servicePid=[int](Get-Content -Raw -LiteralPath $pidPath)
$process=Get-Process -Id $servicePid -ErrorAction SilentlyContinue
if($null-ne$process-and$process.ProcessName-like'llama-server*'){Stop-Process -Id $servicePid;Wait-Process -Id $servicePid -ErrorAction SilentlyContinue;Write-Host "Inference service stopped (PID $servicePid)."}else{Write-Host 'Managed inference service is not running.'}
Remove-Item -LiteralPath $pidPath -Force
