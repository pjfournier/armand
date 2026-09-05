$ErrorActionPreference='Continue';$root=$PSScriptRoot;& (Join-Path $root 'Stop-GameBridge.ps1');& (Join-Path $root 'Stop-InferenceService.ps1')
