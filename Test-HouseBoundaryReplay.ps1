param([switch]$AllowRed)
$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSScriptRoot 'src/HousePrototype.psm1') -Force -DisableNameChecking

$session=New-HouseSession $PSScriptRoot 6001
$inputs=@('look around','open mailbox','look at the mail','walk around house and find a window','go into the cellar','look at the rope','walk up the stairs')
$backend={param($prompt,$attempt)[pscustomobject]@{Text='You notice the missing rope upstairs while the resolved action settles.'}}
$turns=@($inputs|ForEach-Object{[pscustomobject]@{input=$_;result=Invoke-HouseTurn $session $_ -Narrate -NarratorBackend $backend}})
$cellarTurn=$turns|Where-Object input -eq 'go into the cellar'|Select-Object -First 1
$ropeTurn=$turns|Where-Object input -eq 'look at the rope'|Select-Object -First 1
$stairsTurn=$turns|Where-Object input -eq 'walk up the stairs'|Select-Object -First 1

$checks=[ordered]@{
    'movement noun changes room'=($stairsTurn.result.state.location.id -ne 'cellar')
    'packet excludes unobserved upstairs fact'=($ropeTurn.result.PSObject.Properties['narration_packet'] -and (@($ropeTurn.result.narration_packet.observed_facts)-join' ') -notmatch 'missing rope')
    'ambient is a separate packet channel'=($cellarTurn.result.PSObject.Properties['narration_packet'] -and $cellarTurn.result.narration_packet.PSObject.Properties['ambient'] -and $cellarTurn.result.narration_packet.PSObject.Properties['events'])
    'visible noun table reaches packet'=($cellarTurn.result.PSObject.Properties['narration_packet'] -and @($cellarTurn.result.narration_packet.visible_referents).Count -gt 0)
    'house response is narrator-routed'=($cellarTurn.result.PSObject.Properties['narration_source'] -and $cellarTurn.result.narration_source -eq 'comma')
    'output smoke excludes leaked upstairs fact'=($ropeTurn.result.narration -notmatch 'missing rope')
    'output contains no raw room id'=($cellarTurn.result.PSObject.Properties['narration_source'] -and -not@($turns|Where-Object{$_.result.narration-match '\b(?:living_room|callum_study)\b|\bArmand enters Cellar\b'}).Count)
    'output contains no parser route wording'=(-not@($turns|Where-Object{$_.result.narration-match '\broute\b|Which connected room|visible route'}).Count)
}

$failed=@($checks.GetEnumerator()|Where-Object{-not$_.Value})
foreach($check in $checks.GetEnumerator()){Write-Host "$(if($check.Value){'PASS'}else{'FAIL'}) $($check.Key)"}
Write-Host "House boundary replay: $($checks.Count-$failed.Count) passed, $($failed.Count) failed"
if($failed.Count-and-not$AllowRed){exit 1}
