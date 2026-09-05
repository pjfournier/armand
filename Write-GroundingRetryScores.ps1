$ErrorActionPreference='Stop';$root=$PSScriptRoot
function New-Scores([string]$LogPath,[hashtable]$GroundFailures,[hashtable]$AgencyFailures,[hashtable]$IdentityFailures){
 @(Get-Content $LogPath|ForEach-Object{
  $x=$_|ConvertFrom-Json;$id=[string]$x.case_id;$notes=@()
  if($GroundFailures.ContainsKey($id)){$notes+=$GroundFailures[$id]}
  if($AgencyFailures.ContainsKey($id)){$notes+=$AgencyFailures[$id]}
  if($IdentityFailures.ContainsKey($id)){$notes+=$IdentityFailures[$id]}
  [pscustomobject][ordered]@{case_id=$id;grounded=(-not $GroundFailures.ContainsKey($id));form=$true;agency=(-not $AgencyFailures.ContainsKey($id));register=$true;identity=(-not $IdentityFailures.ContainsKey($id));notes=($notes-join' ')}
 })
}
$r1Ground=@{
 'gate-04'='Changes fresh blue ink into an unsupported ink trail.'
 'gate-13'='Addresses Armand as the returning scout although Guillermo performed the action.'
 'gate-16'='Omits the constables and the specifically withheld ward, losing the disclosure boundary.'
 'gate-17'='Omits the specifically withheld consignee, losing the disclosure boundary.'
 'gate-19'='Incorrectly calls all three observed states changes although the proof sheets are unchanged.'
}
$r2Ground=$r1Ground.Clone()
$stageAgency=@{'gate-13'='Assigns Guillermo scouting action to the player.'}
$r2Agency=$stageAgency.Clone();$r2Agency['gate-19']='Assigns the player a memory.'
$stageIdentity=@{'gate-13'='Collapses Guillermo action into player/Armand action.'}
$bGround=@{
 'confirm-04'='Ambiguous pronoun makes the obtained receipt contents, rather than the escritoire contents, inaccessible.'
 'confirm-13'='Changes a closed reliquary state into a new lid-closing event.'
 'confirm-19'='Invents an attempt to open a door and omits the actual event that door three opened.'
}
$bAgency=@{'confirm-19'='Invents a player attempt to open a door.'}
$r1=New-Scores (Join-Path $root 'eval/grounding_retry_stageA_R1_raw.jsonl') $r1Ground $stageAgency $stageIdentity
$r2=New-Scores (Join-Path $root 'eval/grounding_retry_stageA_R2_raw.jsonl') $r2Ground $r2Agency $stageIdentity
$b=New-Scores (Join-Path $root 'eval/grounding_retry_stageB_selected_raw.jsonl') $bGround $bAgency @{}
$r1|ConvertTo-Json -Depth 6|Set-Content -Encoding utf8 (Join-Path $root 'eval/grounding_retry_stageA_R1_scores.json')
$r2|ConvertTo-Json -Depth 6|Set-Content -Encoding utf8 (Join-Path $root 'eval/grounding_retry_stageA_R2_scores.json')
$b|ConvertTo-Json -Depth 6|Set-Content -Encoding utf8 (Join-Path $root 'eval/grounding_retry_stageB_scores.json')
Write-Host 'Grounding retry score files written.'
