Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot 'Characters.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'GameState.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'Resolution.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'NarratorHandoff.psm1') -Force

function Get-EngineActor { param($State,[string]$Actor) if($Actor-eq'Armand'){$State.Player}elseif($Actor-eq'Guillermo'){$State.Guillermo}else{throw "Unsupported actor: $Actor"} }
function Get-EngineTargetDescription {param($State,[string]$Target,[string]$Action)if($State.Items.Contains($Target)){$item=$State.Items[$Target];if($Action-in@('take','steal')-and$item.Location-and$item.Location-ne'inventory'){return "$($item.DisplayName) from the $($item.Location)"};return $item.DisplayName};if($State.NPCs.Contains($Target)){return $State.NPCs[$Target].DisplayName};if($State.Locations.Contains($Target)){return $State.Locations[$Target].DisplayName};$Target}
function Invoke-StateMutations {
 param($State,[object[]]$Mutations,[string]$Degree)
 foreach($m in $Mutations){$hasApply=$null-ne$m.PSObject.Properties['apply_on'];if($hasApply-and$Degree-notin@($m.apply_on)){continue};switch($m.type){
  'transfer_item' {Move-InventoryItem $State $m.item_id $m.to}
  'set_item_state' {Set-ItemProperty $State $m.item_id $m.name $m.value}
  'move_npc' {Move-Npc $State $m.npc_id $m.location}
  'spend_spell_slot' {Invoke-SpellSlotUse $State}
  'advance_time' {$turns=if($null-ne$m.PSObject.Properties['turns']){[int]$m.turns}else{1};Add-GameTime $State ([int]$m.minutes) $turns}
  default {throw "Unsupported mutation type: $($m.type)"}
 }}
}
function Resolve-StructuredIntent {
 [CmdletBinding()]param(
  [Parameter(Mandatory)]$State,[Parameter(Mandatory)]$Intent,[ValidateSet('active','passive','auto')][string]$Mode='active',
  [int]$DC=10,[string]$Skill='Investigation',[int]$SituationalModifier=0,[ValidateSet('normal','advantage','disadvantage')][string]$RollMode='normal',
  [Nullable[int]]$FixedRoll,[int[]]$FixedRolls=@(),[Nullable[int]]$Seed,[bool]$Possible=$true,[object[]]$Mutations=@(),[object]$PostActionState=[pscustomobject]@{},
  [string[]]$Events=@(),[string[]]$Visible=@(),[string[]]$NpcDiscloses=@(),[string[]]$NpcWithholds=@(),[int]$Minutes=0
 )
 $actor=Get-EngineActor $State $Intent.Actor;$modifier=Get-ActorSkillModifier $actor $Skill
 $passive=$null;if($Mode-eq'passive'-and$actor.Passive.Contains($Skill)){$passive=[int]$actor.Passive[$Skill]}
 $resolution=Resolve-Check -Mode $Mode -DC $DC -SkillModifier $modifier -SituationalModifier $SituationalModifier -RollMode $RollMode -FixedRoll $FixedRoll -FixedRolls $FixedRolls -Seed $Seed -PassiveScore $passive -Possible $Possible
 Invoke-StateMutations $State $Mutations $resolution.Degree
 if($Minutes-gt0){Add-GameTime $State $Minutes 1}
 $handoffIntent=[pscustomobject]@{Actor=$Intent.Actor;Action=$Intent.Action;Target=(Get-EngineTargetDescription $State $Intent.Target $Intent.Action);Method=$Intent.Method}
 $handoff=New-NarratorHandoff -Intent $handoffIntent -Resolution $resolution -PostActionState $PostActionState -Events $Events -Visible $Visible -NpcDiscloses $NpcDiscloses -NpcWithholds $NpcWithholds
 [pscustomobject]@{Intent=$Intent;Resolution=$resolution;Handoff=$handoff}
}

Export-ModuleMember -Function Resolve-StructuredIntent,Get-EngineTargetDescription
