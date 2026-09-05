Set-StrictMode -Version Latest

function Get-AttemptDescription {
 param([string]$Actor,[string]$Action,[string]$Target,[string]$Method)
 $subject=$Actor
 switch($Action.ToLowerInvariant()){
  'steal' {"$subject tries to take $Target."}
  'take' {"$subject reaches for $Target."}
  'open' {"$subject attempts to open $Target."}
  'unlock' {"$subject tries to unlock $Target."}
  'climb' {"$subject tries to climb $Target."}
  'persuade' {"$subject attempts to persuade $Target."}
  'investigate' {"$subject examines $Target."}
  'cast' {"$subject invokes $Target."}
  default {"$subject attempts to $Action $Target$(if($Method){" using $Method"})."}
 }
}

function New-NarratorHandoff {
 [CmdletBinding()]param(
  [Parameter(Mandatory)]$Intent,[Parameter(Mandatory)]$Resolution,[Parameter(Mandatory)][object]$PostActionState,
  [string[]]$Events=@(),[string[]]$Visible=@(),[string[]]$NpcDiscloses=@(),[string[]]$NpcWithholds=@(),[string[]]$NotebookEntries=@(),[string[]]$NewThisTurn=@(),[string[]]$KnownContext=@(),[string]$MundaneResult,[ValidateSet('neutral','tense','dry_humor_allowed','guillermo_comic','serious')][string]$Tone='neutral',[string[]]$SupportedAffordances=@()
 )
 $attempt=Get-AttemptDescription -Actor $Intent.Actor -Action $Intent.Action -Target $Intent.Target -Method $Intent.Method
 $handoff=[ordered]@{
  Attempt=[pscustomobject]@{Actor=$Intent.Actor;Description=$attempt}
  Outcome=[pscustomobject]@{Degree=$Resolution.Degree}
  PostActionState=$PostActionState
  Events=@($Events)
  Visible=@($Visible)
  NpcDisclosure=[pscustomobject]@{Discloses=@($NpcDiscloses);Withholds=@($NpcWithholds)}
  NotebookEntries=@($NotebookEntries)
  NewThisTurn=@($(if($NewThisTurn.Count){$NewThisTurn}else{$Events}))
  KnownContext=@($KnownContext)
  MundaneResult=$MundaneResult
  Tone=$Tone
  SupportedAffordances=@($SupportedAffordances)
 }
 # JSON round-trip guarantees no reference into authoritative state survives.
 $handoff|ConvertTo-Json -Depth 12|ConvertFrom-Json
}

function Convert-HandoffToNarrationCase {
 param([Parameter(Mandatory)]$Handoff,[Parameter(Mandatory)][string]$Location,[string]$Time='current case time',[string]$Weather='unknown')
 $case=[pscustomobject]@{
  location=$Location;time=$Time;weather=$Weather;actor=$Handoff.Attempt.Actor
  action_type='attempt';target='resolved target';attempt_description=$Handoff.Attempt.Description
  degree=$Handoff.Outcome.Degree.ToLowerInvariant();facts=@($Handoff.Events);visible=@($Handoff.Visible)
  post_action_state=$Handoff.PostActionState;event_state=$null
  npc_discloses=@($Handoff.NpcDisclosure.Discloses);npc_withholds=@($Handoff.NpcDisclosure.Withholds)
  notebook_entries=@($(if($Handoff.PSObject.Properties['NotebookEntries']){$Handoff.NotebookEntries}else{@()}))
  new_this_turn=@($(if($Handoff.PSObject.Properties['NewThisTurn']){$Handoff.NewThisTurn}else{$Handoff.Events}))
  known_context=@($(if($Handoff.PSObject.Properties['KnownContext']){$Handoff.KnownContext}else{@()}))
  mundane_result=$(if($Handoff.PSObject.Properties['MundaneResult']){$Handoff.MundaneResult}else{$null})
  tone=$(if($Handoff.PSObject.Properties['Tone']){$Handoff.Tone}else{'neutral'})
  supported_affordances=@($(if($Handoff.PSObject.Properties['SupportedAffordances']){$Handoff.SupportedAffordances}else{@()}))
 }
 if($Handoff.Attempt.Actor-eq'Guillermo'){$case|Add-Member -NotePropertyName guillermo_stage_direction -NotePropertyValue ((@($Handoff.Events)+@($Handoff.Attempt.Description))-join' ')}
 $case
}

Export-ModuleMember -Function Get-AttemptDescription,New-NarratorHandoff,Convert-HandoffToNarrationCase
