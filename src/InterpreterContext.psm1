Set-StrictMode -Version Latest

function ConvertTo-StableId { param([string]$Text) (($Text.ToLowerInvariant()-replace'[^a-z0-9]+','_').Trim('_')) }
function New-EntityReference { param([string]$Id,[string]$Kind,[string]$DisplayName,[string[]]$Aliases=@(),[string[]]$Parts=@(),[string[]]$Capabilities=@(),[string]$ParentId,[string]$Lifecycle='visible') [pscustomobject]@{Id=$Id;Kind=$Kind;DisplayName=$DisplayName;Aliases=@($Aliases);Parts=@($Parts);Capabilities=@($Capabilities);ParentId=$ParentId;Lifecycle=$Lifecycle} }
function New-InterpretationContext {
 param([Parameter(Mandatory)]$State,[string[]]$RecentReferents=@())
 $locationId=[string]$State.Player.Location;if([string]::IsNullOrWhiteSpace($locationId)-or-not$State.Locations.Contains($locationId)){throw 'Player must have a valid current location.'}
 $location=$State.Locations[$locationId];$entities=[Collections.Generic.List[object]]::new()
 foreach($id in @($location.VisibleObjects)){
  if($State.Items.Contains($id)){$item=$State.Items[$id];$entities.Add((New-EntityReference $item.Id item $item.DisplayName (@($item.Aliases)+@($item.DisplayName)) $item.InteractableParts))}
  else{$entities.Add((New-EntityReference $id object ($id-replace'_',' ') @(($id-replace'_',' ')) @()))}
 }
 foreach($item in $State.Items.Values){if($item.Owner-eq'Armand'-and-not@($entities.Id).Contains($item.Id)){$entities.Add((New-EntityReference $item.Id inventory_item $item.DisplayName (@($item.Aliases)+@($item.DisplayName)) $item.InteractableParts))}}
 foreach($npc in $State.NPCs.Values){if($npc.CurrentLocation-eq$locationId){$entities.Add((New-EntityReference $npc.Id npc $npc.DisplayName (@($npc.Aliases)+@($npc.DisplayName)) @()))}}
 foreach($exit in @($location.Exits)){$name=if($State.Locations.Contains($exit)){$State.Locations[$exit].DisplayName}else{$exit-replace'_',' '};$entities.Add((New-EntityReference $exit exit $name @($name) @()))}
 if($State.Guillermo.Available-and$State.Guillermo.Alive){$entities.Add((New-EntityReference 'guillermo' companion Guillermo @('Guillermo','monkey','familiar') @()))}
 $spells=@($State.Player.Magic.Cantrips+$State.Player.Magic.Spells|ForEach-Object{[pscustomobject]@{Id=(ConvertTo-StableId $_);Name=$_}})
 [pscustomobject]@{CurrentLocation=[pscustomobject]@{Id=$location.Id;Name=$location.DisplayName};Entities=@($entities);Spells=$spells;RecentReferents=@($RecentReferents|Where-Object{@($entities.Id)-contains$_});SupportedActions=@('examine','search','move','manipulate','read','take','use','cast','speak','give_command','wait','open','unlock','climb','persuade','steal','investigate')}
}
function Get-InterpreterContextSummary { param($Context) [pscustomobject]@{location=$Context.CurrentLocation;entities=@($Context.Entities|ForEach-Object{[pscustomobject]@{id=$_.Id;kind=$_.Kind;name=$_.DisplayName;aliases=$_.Aliases;parts=$_.Parts;capabilities=$_.Capabilities;parent=$_.ParentId;lifecycle=$_.Lifecycle}});spells=$Context.Spells;supported_actions=$Context.SupportedActions;recent_referents=$Context.RecentReferents} }

Export-ModuleMember -Function ConvertTo-StableId,New-EntityReference,New-InterpretationContext,Get-InterpreterContextSummary
