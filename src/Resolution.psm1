Set-StrictMode -Version Latest

function Get-DegreeFromMargin {
    param([Parameter(Mandatory)][int]$Margin)
    if($Margin-ge10){'Exceptional Success'}elseif($Margin-ge0){'Success'}elseif($Margin-ge-4){'Setback'}elseif($Margin-ge-9){'Failure'}else{'Severe Failure'}
}
function Step-Degree { param([string]$Degree,[ValidateSet(-1,1)][int]$Direction) $order=@('Severe Failure','Failure','Setback','Success','Exceptional Success');$i=[array]::IndexOf($order,$Degree);if($i-lt0){throw "Unknown degree: $Degree"};$order[[math]::Max(0,[math]::Min(4,$i+$Direction))] }
function Get-SeededRolls { param([int]$Seed,[int]$Count=1) $random=[Random]::new($Seed);@((1..$Count)|ForEach-Object{$random.Next(1,21)}) }

function Resolve-Check {
 [CmdletBinding()]param(
  [ValidateSet('active','passive','auto')][string]$Mode='active',[int]$DC=10,[int]$SkillModifier=0,[int]$SituationalModifier=0,
  [ValidateSet('normal','advantage','disadvantage')][string]$RollMode='normal',[Nullable[int]]$FixedRoll,[int[]]$FixedRolls=@(),[Nullable[int]]$Seed,
  [Nullable[int]]$PassiveScore,[bool]$Possible=$true
 )
 if($DC-notin@(5,10,15,20,25,30)){throw 'DC must use the 5, 10, 15, 20, 25, or 30 ladder.'}
 if(-not$Possible){return [pscustomobject]@{Mode=$Mode;DC=$DC;Rolls=@();NaturalRoll=$null;SkillModifier=$SkillModifier;SituationalModifier=$SituationalModifier;Total=$null;Margin=$null;Degree='Severe Failure';Possible=$false}}
 if($Mode-eq'auto'){return [pscustomobject]@{Mode='auto';DC=$DC;Rolls=@();NaturalRoll=$null;SkillModifier=$SkillModifier;SituationalModifier=$SituationalModifier;Total=$null;Margin=$null;Degree='Success';Possible=$true}}
 if($Mode-eq'passive'){
  $score=if($null-ne$PassiveScore){[int]$PassiveScore}else{10+$SkillModifier};$margin=$score+$SituationalModifier-$DC
  return [pscustomobject]@{Mode='passive';DC=$DC;Rolls=@();NaturalRoll=$null;SkillModifier=$SkillModifier;SituationalModifier=$SituationalModifier;Total=($score+$SituationalModifier);Margin=$margin;Degree=(Get-DegreeFromMargin $margin);Possible=$true}
 }
 $count=if($RollMode-eq'normal'){1}else{2}
 if($FixedRolls.Count){if($FixedRolls.Count-ne$count-or@($FixedRolls|Where-Object{$_-lt1-or$_-gt20}).Count){throw "FixedRolls must contain $count values from 1 through 20."};$rolls=@($FixedRolls)}
 elseif($null-ne$FixedRoll){if([int]$FixedRoll-lt1-or[int]$FixedRoll-gt20){throw 'FixedRoll must be 1 through 20.'};$rolls=@([int]$FixedRoll)*$count}
 elseif($null-ne$Seed){$rolls=@(Get-SeededRolls ([int]$Seed) $count)}else{$random=[Random]::new();$rolls=@((1..$count)|ForEach-Object{$random.Next(1,21)})}
 $natural=if($RollMode-eq'advantage'){($rolls|Measure-Object -Maximum).Maximum}elseif($RollMode-eq'disadvantage'){($rolls|Measure-Object -Minimum).Minimum}else{$rolls[0]}
 $total=$natural+$SkillModifier+$SituationalModifier;$margin=$total-$DC;$degree=Get-DegreeFromMargin $margin
 if($natural-eq20){$degree=Step-Degree $degree 1}elseif($natural-eq1){$degree=Step-Degree $degree -1}
 [pscustomobject]@{Mode='active';DC=$DC;RollMode=$RollMode;Rolls=@($rolls);NaturalRoll=$natural;SkillModifier=$SkillModifier;SituationalModifier=$SituationalModifier;Total=$total;Margin=$margin;Degree=$degree;Possible=$true}
}

function Test-RollRequired { param([bool]$FailurePlausible,[bool]$FailureMatters,[bool]$SkillAffectsOutcome,[bool]$DangerOrOpposition) ($FailurePlausible-and$FailureMatters-and$SkillAffectsOutcome-and$DangerOrOpposition) }

Export-ModuleMember -Function Get-DegreeFromMargin,Step-Degree,Get-SeededRolls,Resolve-Check,Test-RollRequired
