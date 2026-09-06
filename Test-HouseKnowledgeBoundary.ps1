$ErrorActionPreference='Stop';Import-Module (Join-Path $PSScriptRoot 'src/HousePrototype.psm1') -Force -DisableNameChecking;Import-Module (Join-Path $PSScriptRoot 'src/Notebook.psm1') -Force -DisableNameChecking
$s=New-HouseSession $PSScriptRoot 6001;$s.State.Player.Location='cellar';$room=$s.HouseContent.rooms|Where-Object id -eq 'cellar'|Select-Object -First 1
$unobserved=Get-HouseMundaneResponse $s $room rope_coil;if($unobserved-match'missing rope|upstairs'){throw 'Unobserved upstairs fact leaked through mundane response selection.'};if($unobserved-notmatch'coarse hemp|dust settled|nothing has been cut'){throw 'Safe observable rope detail was not selected.'}
$s.State.Clues.rope_fibers.Discovered=$true;Sync-NotebookClue $s.State rope_fibers 'Rope fibers' @('writing_desk')|Out-Null
$observed=Get-HouseMundaneResponse $s $room rope_coil;if($observed-notmatch'matches the fibres Armand observed'){throw 'Observed-fact response variant was not selected.'}
$result=Invoke-HouseTurn (New-HouseSession $PSScriptRoot 6001) 'look around';$result=Invoke-HouseTurn $s 'look at the rope';if((@($result.narration_packet.observed_facts)-join' ')-match'missing rope'){throw 'Narration packet contains an unobserved fact.'}
Write-Host 'House knowledge-boundary tests passed.'
