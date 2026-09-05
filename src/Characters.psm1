Set-StrictMode -Version Latest

function New-ArmandProfile {
    [pscustomobject]@{
        Id='Armand'; Level=3; Class='Warlock, Fiend'; Background='Charlatan'; Role='Occult investigator'
        HP=18; MaxHP=18; AC=11; Gold=50; Location=$null
        Skills=[ordered]@{Influence=5;Deception=5;Investigation=4;Acrobatics=3;Finesse=3;Awareness=3;Occult=3;Knowledge=2;Athletics=0}
        Passive=[ordered]@{Awareness=13;Investigation=14}
        Inventory=[Collections.Generic.List[string]]::new()
        Magic=[pscustomobject]@{
            Cantrips=@('Eldritch Blast','Fire Bolt','Minor Illusion','Thaumaturgy')
            Spells=@('Hex','Detect Magic','Hellish Rebuke','Find Familiar','Darkness','Misty Step')
            PactSlots=[pscustomobject]@{Current=2;Maximum=2;Level=2};SpellAttack=5;SaveDC=13
        }
    }
}

function New-GuillermoProfile {
    param([int]$ArmandLevel=3)
    [pscustomobject]@{
        Id='Guillermo';Size='Tiny';HP=(4*$ArmandLevel);MaxHP=(4*$ArmandLevel);AC=14;Speed=30;ClimbSpeed=30;Darkvision=60
        Abilities=[ordered]@{STR=3;DEX=15;CON=10;INT=18;WIS=12;CHA=6}
        Skills=[ordered]@{Acrobatics=5;Finesse=5;Awareness=5;Sneak=5;Investigation=6;Trickery=3;Nerve=2}
        SkillAdvantages=@('Acrobatics','Athletics');Passive=[ordered]@{Awareness=15}
        Traits=@('Agility');CommunicationTier='Early';Alive=$true;Available=$true;DistractionTags=[Collections.Generic.List[string]]::new()
        Location=$null;Inventory=[Collections.Generic.List[string]]::new()
    }
}

function Get-ActorSkillModifier {
    param([Parameter(Mandatory)]$Actor,[Parameter(Mandatory)][string]$Skill)
    if(-not$Actor.Skills.Contains($Skill)){throw "Actor '$($Actor.Id)' has no skill '$Skill'."}
    [int]$Actor.Skills[$Skill]
}

function Get-PlayerFacingCharacterState {
    param([Parameter(Mandatory)]$State)
    [pscustomobject]@{
        Player=[pscustomobject]@{Id=$State.Player.Id;Level=$State.Player.Level;Role=$State.Player.Role;HP=$State.Player.HP;MaxHP=$State.Player.MaxHP;AC=$State.Player.AC;Gold=$State.Player.Gold;Location=$State.Player.Location;Inventory=@($State.Player.Inventory);SpellSlots=$State.Player.Magic.PactSlots.Current}
        Guillermo=[pscustomobject]@{Id='Guillermo';Alive=$State.Guillermo.Alive;Available=$State.Guillermo.Available;Location=$State.Guillermo.Location;CommunicationTier=$State.Guillermo.CommunicationTier}
    }
}

Export-ModuleMember -Function New-ArmandProfile,New-GuillermoProfile,Get-ActorSkillModifier,Get-PlayerFacingCharacterState
