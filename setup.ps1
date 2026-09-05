[CmdletBinding()]
param([switch]$KeepF16)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$runtimeDir = Join-Path $root '.runtime/llama.cpp'
$modelsDir = Join-Path $root 'models'
$release = 'b10816'
$releaseBase = "https://github.com/ggml-org/llama.cpp/releases/download/$release"
$runtimeZip = Join-Path $runtimeDir 'llama-cuda.zip'
$cudaZip = Join-Path $runtimeDir 'cudart.zip'
$f16 = Join-Path $modelsDir 'comma-v0.1-2t-f16.gguf'
$q4 = Join-Path $modelsDir 'comma-v0.1-2t-q4_k_m.gguf'
$runtimeSha256 = 'f567f273ef0cad7aa1835c94426aa38577df16ddd1d32f5085e1a503ae106697'
$cudaSha256 = '8c79a9b226de4b3cacfd1f83d24f962d0773be79f1e7b75c6af4ded7e32ae1d6'
$f16Sha256 = '734876378b51571313ea6b504ff31745aaa3c32766d9c6b6e55c5b742d149010'

New-Item -ItemType Directory -Force -Path $runtimeDir,$modelsDir | Out-Null
function Download-File([string]$Url, [string]$Destination) {
    Write-Host "Downloading $([IO.Path]::GetFileName($Destination))..."
    $aria = Get-Command aria2c.exe -ErrorAction SilentlyContinue
    if ($aria) {
        & $aria.Source -x 16 -s 16 -k 4M --file-allocation=none --auto-file-renaming=false --allow-overwrite=true --continue=true --dir (Split-Path -Parent $Destination) --out (Split-Path -Leaf $Destination) $Url
    }
    else {
        & curl.exe -L --fail --retry 5 --retry-delay 5 -C - -o $Destination $Url
    }
    if ($LASTEXITCODE -ne 0) { throw "Download failed: $Url" }
}

function Assert-Sha256([string]$Path, [string]$Expected) {
    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
    if ($actual -ne $Expected) { throw "SHA-256 verification failed for $Path. Expected $Expected but got $actual." }
}

if (-not (Test-Path (Join-Path $runtimeDir 'llama-completion.exe'))) {
    Download-File "$releaseBase/llama-$release-bin-win-cuda-12.4-x64.zip" $runtimeZip
    Download-File "$releaseBase/cudart-llama-bin-win-cuda-12.4-x64.zip" $cudaZip
    Assert-Sha256 $runtimeZip $runtimeSha256
    Assert-Sha256 $cudaZip $cudaSha256
    Expand-Archive -Force $runtimeZip $runtimeDir
    Expand-Archive -Force $cudaZip $runtimeDir
}
if (-not (Test-Path $q4)) {
    if (-not (Test-Path $f16)) {
        Download-File 'https://huggingface.co/jadael/comma-v0.1-2t-GGUF/resolve/main/comma-v0.1-2t-f16.gguf?download=true' $f16
    }
    Assert-Sha256 $f16 $f16Sha256
    Write-Host 'Quantizing the verified F16 GGUF to Q4_K_M...'
    & (Join-Path $runtimeDir 'llama-quantize.exe') $f16 $q4 Q4_K_M
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $q4)) { throw 'Q4_K_M quantization failed.' }
}
if (-not $KeepF16 -and (Test-Path $f16) -and (Test-Path $q4)) {
    Remove-Item -LiteralPath $f16 -Force
    Write-Host 'Removed the intermediate F16 model. Use -KeepF16 to retain it.'
}
Write-Host "Setup complete. Run: .\run.ps1 -SmokeTest"
