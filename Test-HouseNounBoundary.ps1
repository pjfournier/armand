$ErrorActionPreference='Stop';Import-Module (Join-Path $PSScriptRoot 'src/HousePrototype.psm1') -Force -DisableNameChecking
$s=New-HouseSession $PSScriptRoot 6001;$s.State.Player.Location='cellar'
foreach($text in 'up','upstairs','go up the stairs','walk up the stairs','climb the stairs'){$copy=Import-HouseSave $PSScriptRoot (Export-HouseSave $s);$r=Invoke-HouseTurn $copy $text;if($r.state.location.id-eq'cellar'){throw "Exit alias failed: $text"}}
$lint=@(Test-HouseOverviewNounLint $s);if($lint.Count){Write-Host 'Additional authored-overview noun findings:';$lint|Format-Table;throw 'House overview noun lint failed.'}
$bad=Test-HouseNarrationVocabulary $s 'You cross the bedroom and open its wardrobe.';if(-not$bad.Count){throw 'Runtime vocabulary validation missed an out-of-room referent.'}
$good=Test-HouseNarrationVocabulary $s 'You climb the cellar stairs beside the coil of rope.';if($good.Count){throw "Runtime vocabulary rejected current referents: $($good-join', ')"}
Write-Host 'House noun-boundary tests passed.'
