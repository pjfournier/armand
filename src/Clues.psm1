Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot 'Notebook.psm1') -Force -DisableNameChecking

function Add-ClueState {
 param($State,[string]$Id,[string]$Location,[object[]]$Tiers,[string]$DisplayName=$Id,[string[]]$RelatedEntityIds=@())
 if($Tiers.Count-eq0){throw 'A clue needs at least one interpretation tier.'}
 $State.Clues[$Id]=[pscustomobject]@{Id=$Id;DisplayName=$DisplayName;Location=$Location;RelatedEntityIds=@($RelatedEntityIds);Tiers=@($Tiers|Sort-Object DC);Discovered=$false;HighestTierReached=$null;KnownFacts=[Collections.Generic.List[string]]::new()}
}
function Resolve-ClueInterpretation {
 param($State,[string]$ClueId,[string]$Skill,[int]$Score)
 if(-not$State.Clues.Contains($ClueId)){throw "Unknown clue: $ClueId"};$clue=$State.Clues[$ClueId]
 $reached=@($clue.Tiers|Where-Object{$_.Skill-eq$Skill-and[int]$_.DC-le$Score}|Sort-Object DC)
 if($reached.Count-eq0){return [pscustomobject]@{ClueId=$ClueId;Discovered=$clue.Discovered;HighestTier=$clue.HighestTierReached;NewFacts=@()}}
 $clue.Discovered=$true;$new=[Collections.Generic.List[string]]::new()
 foreach($tier in $reached){if(-not$clue.KnownFacts.Contains([string]$tier.Fact)){$clue.KnownFacts.Add([string]$tier.Fact);$new.Add([string]$tier.Fact)}}
 $clue.HighestTierReached=($reached|Measure-Object DC -Maximum).Maximum
 Sync-NotebookClue -State $State -ClueId $ClueId -DisplayName $clue.DisplayName -RelatedEntityIds $clue.RelatedEntityIds|Out-Null
 [pscustomobject]@{ClueId=$ClueId;Discovered=$true;HighestTier=$clue.HighestTierReached;NewFacts=@($new);KnownFacts=@($clue.KnownFacts)}
}

Export-ModuleMember -Function Add-ClueState,Resolve-ClueInterpretation
