$ErrorActionPreference='Stop';Import-Module (Join-Path $PSScriptRoot 'src/CombatPrototype.psm1') -Force -DisableNameChecking
$script:passed=0;$script:failed=0
function Check([string]$Name,[bool]$Condition){if($Condition){$script:passed++;Write-Host "PASS $Name"}else{$script:failed++;Write-Host "FAIL $Name" -ForegroundColor Red}}
function New-C([string]$Id='benchmark_a',[int]$Seed=10){$c=New-CombatSession $PSScriptRoot $Id $Seed;while($c.active_combatant-ne'armand'-and-not$c.reaction_prompt){$null=Invoke-EnemyTurn $c $c.active_combatant};$c.active_combatant='armand';$c.initiative_index=[array]::IndexOf($c.initiative_order,'armand');$c}

$c=New-C;Check '1 Combat starts' $c.active;Check '2 Initiative order created' ($c.initiative_order.Count-eq2)
$p=ConvertFrom-CombatCommand 'Move behind the desk and cast Eldritch Blast at the initiate.';Check '3 Movement plus Action accepted' ((Test-CombatCommand $p).valid);Check '6 Natural compound parsed' ($p.movements.Count-eq1-and$p.actions.Count-eq1)
Check '4 Two Actions clarify' (-not(Test-CombatCommand (ConvertFrom-CombatCommand 'Blast him and search the desk.')).valid)
Check '5 Two Movements clarify' (-not(Test-CombatCommand (ConvertFrom-CombatCommand 'Run to the desk and move behind the door.')).valid)
$c=New-C;$hp=$c.combatants.enemy_1.hp;$r=Invoke-CombatCommand $c 'Eldritch Blast the initiate.' -FixedAttackRoll 15 -FixedDamageRoll 3;Check '7 Eldritch Blast attacks AC' ($r.telemetry.rolls[0].ac-eq11);Check '8 Damage reduces HP' ($c.combatants.enemy_1.hp-eq($hp-3));Check '9 Enemy acts after Armand' ($c.turn_number-ge2-or$c.reaction_prompt)
$c=New-C benchmark_b;Check '10 Multiple enemies in initiative' ($c.initiative_order.Count-eq3)
$c=New-C;$r=Invoke-CombatCommand $c 'Tell Guillermo to reposition nearby.';Check '11 Guillermo minor uses Bonus Action' ($r.telemetry.guillermo_command_type-eq'minor'-and$c.combatants.armand.bonus_action_used-eq$false)
$c=New-C;$r=Invoke-CombatCommand $c 'Tell Guillermo to knock the lamp onto the enemy.';Check '12 Guillermo consequential consumes Action' ($r.telemetry.guillermo_command_type-eq'consequential')
$c=New-C;$r=Invoke-CombatCommand $c 'Flee into the next room and hide.' -FixedHideRoll 20;Check '13 Opportunity attack on flee' (@($r.telemetry.rolls.label)-contains'Opportunity Attack');Check '14 Hide uses Action after flee' ($r.parsed.actions[0].kind-eq'hide');Check '15 Hide restores stealth layer' ($c.layer-eq'stealth'-and-not$c.active)
$c=New-C benchmark_c;$r=Invoke-CombatCommand $c 'Flee through the doorway.';Check '16 Per-enemy pursuit authored' (@($c.combatants.enemy_1.pursuit,$c.combatants.enemy_2.pursuit)-contains'orders_pursuit')
$c=New-C benchmark_b;$r=Invoke-CombatCommand $c 'Cast Darkness.';Check '17 Darkness authoritative and gives Devil Sight' ($c.darkness.active-and$c.combatants.armand.effects.Contains('devils_sight'));Check '18 Enemy can leave Darkness' ($r.narration-match'withdraws from the magical darkness')
$c=New-C;$r=Invoke-CombatCommand $c 'Misty Step beside the doorway and blast the initiate.' -FixedAttackRoll 15 -FixedDamageRoll 1;Check '19 Misty Step is Movement' ($r.parsed.movements[0].method-eq'misty step')
$c=New-C;$c.reaction_prompt=[pscustomobject]@{type='hellish_rebuke';source='enemy_1';message='Use Hellish Rebuke?'};$r=Invoke-CombatReaction $c $true 1;Check '20 Hellish Rebuke uses Reaction' (-not$c.combatants.armand.reaction_available);Check '21 Reaction does not consume Action' (-not$c.combatants.armand.action_used)
$c=New-C;$r=Invoke-CombatCommand $c 'Eldritch Blast the initiate.' -FixedAttackRoll 15 -FixedDamageRoll 6;Check '22 Blessing grants six temp HP' ($c.combatants.armand.temp_hp-eq6)
$c=New-C;Resolve-EnemyDefeat $c $c.combatants.enemy_1 surrendered;Check '23 Nonlethal defeat triggers Blessing' ($c.combatants.armand.temp_hp-eq6)
$c=New-C;$r=Invoke-CombatCommand $c 'Kick the chair into his legs.' -FixedCreativeRoll 14;Check '24 Creative maneuver uses margin degree' ($r.telemetry.rolls[0].degree-in@('Success','Exceptional Success'))
$c=New-C;$r1=Invoke-CombatCommand $c 'Eldritch Blast the initiate.' -FixedAttackRoll 2;$c.active_combatant='armand';$c.combatants.armand.action_used=$false;$c.combatants.armand.movement_used=$false;$r2=Invoke-CombatCommand $c 'Eldritch Blast the initiate.' -FixedAttackRoll 2;Check '25 Attacks may repeat' ($r2.narration-notmatch'free reroll')
$c=New-C;Apply-CombatDamage $c.combatants.guillermo 12|Out-Null;Check '26 Guillermo can die' (-not$c.combatants.guillermo.alive)
$c=New-C;Resolve-EnemyDefeat $c $c.combatants.enemy_1 surrendered;Check '27 Surrender ends combat' ($c.end_reason-eq'surrender')
$c=New-C;$c.combatants.enemy_1.hp=1;$null=Invoke-EnemyTurn $c enemy_1;Check '28 Enemy flee ends combat' ($c.end_reason-eq'enemy_fled')
$c=New-C benchmark_c;$r=Invoke-CombatCommand $c 'Flee through the doorway and hide.' -FixedHideRoll 20;Check '29 Adept encounter escape route' ($c.layer-eq'stealth')
$c=New-C;$before=$c.combatants.armand.hp;$r=Invoke-CombatCommand $c 'Move behind the desk.';Check '30 Narration cannot mutate HP' ($c.combatants.armand.hp-le$before)
$public=Get-CombatPlayerState $c;$json=$public|ConvertTo-Json -Depth 10;Check '31 Public state hides RNG internals' ($json-notmatch'RollIndex|Seed|priorities|attack_bonus')
$cfg=Get-Content -Raw (Join-Path $PSScriptRoot 'content/combat_prototype.json')|ConvertFrom-Json;Check '32 Exactly three tiers and encounters' (@($cfg.tiers.PSObject.Properties).Count-eq3-and@($cfg.encounters.PSObject.Properties).Count-eq3)
Check '33 Tutorial starts required' ((New-C).tutorial_required);$c=New-C;Dismiss-CombatTutorial $c;Check '34 Tutorial dismisses' (-not$c.tutorial_required)
$c=New-C benchmark_c;Check '35 Adept authored minor magic exists' ($c.combatants.enemy_1.minor_magic-eq'shadow_bind')
$c=New-C;$r=Invoke-CombatCommand $c 'Trip the initiate.' -FixedCreativeRoll 1;$c.active_combatant='armand';$r2=Invoke-CombatCommand $c 'Trip the initiate.' -FixedCreativeRoll 20;Check '36 Creative anti-reroll works' ($r2.narration-match'no free reroll')
Write-Host "Combat prototype: $script:passed passed, $script:failed failed";if($script:failed){exit 1}
