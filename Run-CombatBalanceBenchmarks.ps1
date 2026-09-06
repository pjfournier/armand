$ErrorActionPreference='Stop';Import-Module (Join-Path $PSScriptRoot 'src/CombatPrototype.psm1') -Force -DisableNameChecking
function New-Scenario([string]$Name,[int]$Seed){
 $map=@{A=@('benchmark_a',$null);B=@('benchmark_b','enemy_2');C=@('benchmark_b',$null);D=@('benchmark_c','enemy_2');E=@('benchmark_c',$null)};$spec=$map[$Name];$c=New-CombatSession $PSScriptRoot $spec[0] $Seed
 if($spec[1]){$c.combatants.Remove($spec[1]);$c.initiative_order=@($c.initiative_order|Where-Object{$_-ne$spec[1]});if($c.initiative_index-ge$c.initiative_order.Count){$c.initiative_index=0};$c.active_combatant=$c.initiative_order[$c.initiative_index]}
 $c.reaction_prompt=$null;$c.pending_enemy_sequence=$false;$c.active_combatant='armand';$c.initiative_index=[array]::IndexOf($c.initiative_order,'armand')
 $c
}
function Invoke-Strategy([string]$Scenario,[string]$Strategy,[int]$Seed){
 $c=New-Scenario $Scenario $Seed;$turns=0;$usedSetup=$false
 while($c.active-and$c.combatants.armand.alive-and$turns-lt30){
  if($c.reaction_prompt){$null=Invoke-CombatReaction $c $false;continue}
  if($c.active_combatant-ne'armand'){$c.active_combatant='armand';$c.initiative_index=[array]::IndexOf($c.initiative_order,'armand')}
  $turns++;$cmd=switch($Strategy){'straight'{'Eldritch Blast the enemy.'}'darkness'{if(-not$usedSetup){$usedSetup=$true;'Cast Darkness.'}else{'Eldritch Blast the enemy.'}}'flee'{'Flee into the adjacent room and hide.'}'guillermo'{'Tell Guillermo to reposition nearby and Eldritch Blast the enemy.'}'creative'{if(-not$usedSetup){$usedSetup=$true;'Trip the enemy.'}else{'Eldritch Blast the enemy.'}}}
  $null=Invoke-CombatCommand $c $cmd
 }
 [pscustomobject]@{scenario=$Scenario;strategy=$Strategy;seed=$Seed;survived=$c.combatants.armand.alive;won=($c.end_reason-in@('all_hostiles_defeated','surrender','enemy_fled'));escaped=($c.end_reason-eq'escaped_and_hidden');rounds=$turns;end_reason=$(if($c.end_reason){$c.end_reason}elseif(-not$c.combatants.armand.alive){'armand_defeated'}else{'round_cap'})}
}
$runs=@();foreach($scenario in 'A','B','C','D','E'){foreach($strategy in 'straight','darkness','flee','guillermo','creative'){foreach($seed in 1..20){$runs+=Invoke-Strategy $scenario $strategy $seed}}}
$summary=@($runs|Group-Object scenario,strategy|ForEach-Object{$g=$_.Group;[pscustomobject]@{scenario=$g[0].scenario;strategy=$g[0].strategy;runs=$g.Count;survival_rate=[Math]::Round(100*(@($g|Where-Object survived).Count/$g.Count),1);win_rate=[Math]::Round(100*(@($g|Where-Object won).Count/$g.Count),1);escape_rate=[Math]::Round(100*(@($g|Where-Object escaped).Count/$g.Count),1);average_rounds=[Math]::Round(($g|Measure-Object rounds -Average).Average,2)}})
$artifact=[pscustomobject]@{generated_utc=[datetime]::UtcNow.ToString('o');seed_count=20;scenarios=[ordered]@{A='Armand vs 1 Initiate';B='Armand vs 1 Cultist';C='Armand vs 2 Cultists';D='Armand vs Adept';E='Armand vs Adept + Initiate'};summary=$summary;runs=$runs};$artifact|ConvertTo-Json -Depth 6|Set-Content -Encoding utf8 (Join-Path $PSScriptRoot 'eval/combat_balance_results.json');$summary|Format-Table -AutoSize
