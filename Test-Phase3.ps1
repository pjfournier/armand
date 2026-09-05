$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/CoreEngine.psm1') -Force
Import-Module (Join-Path $root 'src/GameState.psm1') -Force
Import-Module (Join-Path $root 'src/Characters.psm1') -Force
Import-Module (Join-Path $root 'src/Resolution.psm1') -Force
Import-Module (Join-Path $root 'src/Clues.psm1') -Force
Import-Module (Join-Path $root 'src/NarratorHandoff.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationPacket.psm1') -Force
function Assert($Condition,[string]$Message){if(-not$Condition){throw "FAILED: $Message"}}

Assert ((Resolve-Check -DC 15 -SkillModifier 4 -FixedRoll 11).Degree-eq'Success') 'success degree'
Assert ((Resolve-Check -DC 15 -SkillModifier 0 -FixedRoll 20).Degree-eq'Exceptional Success') 'exceptional success'
Assert ((Resolve-Check -DC 15 -FixedRoll 14).Degree-eq'Setback') 'setback degree'
Assert ((Resolve-Check -DC 15 -FixedRoll 9).Degree-eq'Failure') 'failure degree'
Assert ((Resolve-Check -DC 15 -FixedRoll 5).Degree-eq'Severe Failure') 'severe failure degree'
Assert ((Resolve-Check -DC 30 -FixedRoll 20).Degree-eq'Failure') 'natural 20 upgrades one degree'
Assert ((Resolve-Check -DC 15 -SkillModifier 20 -FixedRoll 1).Degree-eq'Setback') 'natural 1 downgrades only one degree'
Assert ((Resolve-Check -DC 15 -RollMode advantage -FixedRolls 3,17).NaturalRoll-eq17) 'advantage takes higher'
Assert ((Resolve-Check -DC 15 -RollMode disadvantage -FixedRolls 3,17).NaturalRoll-eq3) 'disadvantage takes lower'
Assert ((Resolve-Check -DC 30 -Possible $false).Degree-eq'Severe Failure') 'impossible action remains impossible'
Assert ((Resolve-Check -Mode auto -DC 30).Degree-eq'Success') 'explicit auto success'
Assert ((Resolve-Check -Mode passive -DC 10 -PassiveScore 13).Degree-eq'Success') 'passive resolution'
Assert (Test-RollRequired $true $true $true $true) 'meaningful uncertainty requires roll'
Assert (-not(Test-RollRequired $true $false $true $true)) 'routine or inconsequential action avoids roll'
$seedA=Resolve-Check -DC 15 -Seed 77;$seedB=Resolve-Check -DC 15 -Seed 77;Assert ($seedA.NaturalRoll-eq$seedB.NaturalRoll) 'seeded rolls deterministic'

$state=New-GameState;Assert ($state.Player.Skills.Investigation-eq4-and$state.Player.Passive.Investigation-eq14) 'Armand profile'
Assert ($state.Guillermo.HP-eq12-and$state.Guillermo.Skills.Investigation-eq6-and$state.Guillermo.CommunicationTier-eq'Early') 'Guillermo profile'
$public=Get-PlayerFacingCharacterState $state;$publicJson=$public|ConvertTo-Json -Depth 8
Assert ($publicJson-notmatch'Abilities|Investigation|Darkvision|Nerve') 'Guillermo stats hidden from player serializer'

Add-ClueState $state blood_trace lobby @([pscustomobject]@{DC=10;Skill='Awareness';Fact='dark discoloration exists'},[pscustomobject]@{DC=15;Skill='Investigation';Fact='it is dried blood'},[pscustomobject]@{DC=20;Skill='Investigation';Fact='too little blood for a death here'})
$passive=Resolve-ClueInterpretation $state blood_trace Awareness $state.Player.Passive.Awareness
Assert ($passive.Discovered-and$passive.HighestTier-eq10) 'passive clue discovery'
$advanced=Resolve-ClueInterpretation $state blood_trace Investigation 20
Assert ($advanced.HighestTier-eq20-and$state.Clues.blood_trace.KnownFacts.Count-eq3) 'clue tier advancement preserves earlier facts'

Add-LocationState $state study @('desk','window') @('hall');Add-ItemState $state envelope study $null @{seal='intact'} @('document')
Add-ObjectiveState $state inspect_study active;Assert ($state.Objectives.inspect_study.Status-eq'active') 'objective state'
Move-InventoryItem $state envelope Armand;Assert ($state.Items.envelope.Owner-eq'Armand'-and$state.Player.Inventory.Contains('envelope')) 'inventory transfer'
Set-ItemProperty $state envelope seal broken;Assert ($state.Items.envelope.State.seal-eq'broken') 'item state mutation'
Add-NpcState $state porter lobby 3 0 idle 'watch desk' @('key_log') '';Move-Npc $state porter hall;Assert ($state.NPCs.porter.CurrentLocation-eq'hall') 'NPC movement'
Add-GameTime $state 10 1;Assert ($state.Time.ElapsedMinutes-eq10-and$state.Time.Turn-eq1) 'time advancement'
$slots=$state.Player.Magic.PactSlots.Current;Invoke-SpellSlotUse $state;Assert ($state.Player.Magic.PactSlots.Current-eq($slots-1)) 'spell slot mutation'

Add-ItemState $state iron_box study $null @{door='closed'} @()
$openIntent=[pscustomobject]@{Actor='Armand';Action='open';Target='iron box';Method=$null}
$failedOpen=Resolve-StructuredIntent -State $state -Intent $openIntent -Skill Athletics -DC 15 -FixedRoll 5 -Mutations @([pscustomobject]@{type='set_item_state';item_id='iron_box';name='door';value='open';apply_on=@('Success','Exceptional Success')}) -PostActionState ([pscustomobject]@{iron_box='closed'})
Assert ($state.Items.iron_box.State.door-eq'closed'-and$failedOpen.Handoff.Attempt.Description-notmatch'Armand opens') 'failed action leaves state unchanged and handoff safe'
Add-ItemState $state coin study $null @{} @()
$takeIntent=[pscustomobject]@{Actor='Armand';Action='take';Target='coin';Method=$null}
$successfulTake=Resolve-StructuredIntent -State $state -Intent $takeIntent -Skill Finesse -DC 10 -FixedRoll 12 -Mutations @([pscustomobject]@{type='transfer_item';item_id='coin';to='Armand';apply_on=@('Success','Exceptional Success')}) -PostActionState ([pscustomobject]@{coin_owner='Armand'})
Assert ($state.Items.coin.Owner-eq'Armand') 'successful action changes authoritative state'
Add-ItemState $state chest study $null @{door='closed';crowbar='straight'} @()
$forceIntent=[pscustomobject]@{Actor='Armand';Action='open';Target='chest with crowbar';Method='crowbar'}
$setback=Resolve-StructuredIntent -State $state -Intent $forceIntent -Skill Athletics -DC 10 -FixedRoll 8 -Mutations @([pscustomobject]@{type='set_item_state';item_id='chest';name='door';value='open';apply_on=@('Setback')},[pscustomobject]@{type='set_item_state';item_id='chest';name='crowbar';value='bent';apply_on=@('Setback')}) -PostActionState ([pscustomobject]@{chest='open';crowbar='bent'}) -Events @('hinge breaks loudly')
Assert ($setback.Resolution.Degree-eq'Setback'-and$state.Items.chest.State.door-eq'open'-and$state.Items.chest.State.crowbar-eq'bent') 'setback mutates state with consequence'

$failedIntent=[pscustomobject]@{Actor='Guillermo';Action='steal';Target='brass key from the hook';Method=$null}
$failedResolution=[pscustomobject]@{Degree='Failure'}
$post=[pscustomobject]@{brass_key_location='hook';Guillermo_has_key=$false}
$handoff=New-NarratorHandoff $failedIntent $failedResolution $post @('brass key rattles','Guillermo retreats') @('brick arch','standing water','chalk mark')
Assert ($handoff.Attempt.Description-eq'Guillermo tries to take brass key from the hook.') 'failed theft uses attempted semantics'
Assert (($handoff|ConvertTo-Json -Depth 8)-notmatch'Guillermo steals|Skills|Abilities') 'failed theft and stats absent'
Assert ($handoff.Events.Count-eq2-and$handoff.Visible.Count-eq3) 'events and visible remain distinct'
$handoff.PostActionState.brass_key_location='pocket';Assert ($post.brass_key_location-eq'hook') 'narrator handoff cannot mutate source state'
$disclosure=New-NarratorHandoff ([pscustomobject]@{Actor='Armand';Action='investigate';Target='clerk';Method=$null}) ([pscustomobject]@{Degree='Success'}) ([pscustomobject]@{}) @() @('desk') @('key was left at midnight') @('identity of the woman')
Assert ($disclosure.NpcDisclosure.Discloses.Count-eq1-and$disclosure.NpcDisclosure.Withholds.Count-eq1) 'bounded NPC disclosure'
$case=Convert-HandoffToNarrationCase $handoff cellar midnight rain;$packet=ConvertTo-NarrationPacket $case;$packetText=Format-NarrationPacket $packet facts
Assert ($packetText-match'ATTEMPT[\s\S]*tries to take'-and$packetText-notmatch'action: steal') 'safe Phase 2 packet adapter'

$regressions=Get-Content -Raw (Join-Path $root 'tests/handoff_regression_cases.json')|ConvertFrom-Json
foreach($r in $regressions){$h=New-NarratorHandoff $r.intent $r.resolution $r.post_action_state @($r.events) @($r.visible) @($r.npc_discloses) @($r.npc_withholds);$j=$h|ConvertTo-Json -Depth 10;Assert ($h.Attempt.Description-eq$r.expected_attempt) "handoff regression $($r.id) attempt";foreach($term in @($r.forbidden)) {Assert ($j-notmatch[regex]::Escape($term)) "handoff regression $($r.id) forbidden $term"};Assert ($h.Events.Count-eq@($r.events).Count) "handoff regression $($r.id) events"}
Assert ($regressions.Count-eq15) '15 permanent grounding handoff cases'
Write-Host "Phase 3 tests passed: core rules, state, clues, handoff, and $($regressions.Count) grounding regressions."
