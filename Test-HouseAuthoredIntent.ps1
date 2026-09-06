$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSScriptRoot 'src/HousePrototype.psm1') -Force -DisableNameChecking
$session=New-HouseSession $PSScriptRoot 6001
$backend={param($prompt,$attempt)[pscustomobject]@{Text='You take in the rain-dark frontage without drawing a conclusion.'}}
$result=Invoke-HouseTurn $session 'look around' -Narrate -NarratorBackend $backend
if($result.narration_source-ne'comma'){throw 'House narration did not use the model-required path.'}
if($result.narration_prompt-notmatch'AUTHORIAL_INTENT: Rain falls over a dark house'){throw 'Authored overview was not repurposed as prompt input.'}
if($result.narration-eq$result.narration_packet.authorial_intent){throw 'Authored overview was used as a competing rendered fallback.'}
Write-Host 'House authored-intent policy tests passed.'
