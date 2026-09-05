Set-StrictMode -Version Latest
function New-GuillermoIncidentLedger {,([Collections.Generic.List[object]]::new())}
function Add-GuillermoIncident {
 param($State,[string]$IncidentId,[ValidateSet('failure','clever_solution','embarrassment','guillermo_death','guillermo_resummon','player_saved_guillermo','unusual_success','reckless_action','memorable_social_event')][string]$EventType,[string]$Description,[ValidateRange(1,5)][int]$Memorability=1,[string]$NicknameSeed,[bool]$PersistentAcrossDeath=$true,[ValidateSet('engine')][string]$Source='engine')
 $existing=@($State.GuillermoIncidentLedger|Where-Object incident_id -eq $IncidentId)|Select-Object -First 1;if($existing){return $existing}
 $entry=[pscustomobject]@{incident_id=$IncidentId;event_type=$EventType;description=$Description;turn=[int]$State.Time.Turn;case_time=$State.Time.CurrentCaseTime;memorability=$Memorability;nickname_seed=$NicknameSeed;persistent_across_death=$PersistentAcrossDeath};$State.GuillermoIncidentLedger.Add($entry);$entry
}
function Get-GuillermoIncidentLedger {param($State)@($State.GuillermoIncidentLedger|ForEach-Object{$_|ConvertTo-Json -Depth 5|ConvertFrom-Json})}
Export-ModuleMember -Function New-GuillermoIncidentLedger,Add-GuillermoIncident,Get-GuillermoIncidentLedger
