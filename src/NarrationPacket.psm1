Set-StrictMode -Version Latest

function New-NarrationPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Location,
        [Parameter(Mandatory)][string]$Time,
        [Parameter(Mandatory)][string]$Weather,
        [Parameter(Mandatory)][ValidateSet('Armand','Guillermo')][string]$Actor,
        [Parameter(Mandatory)][string]$ActionType,
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][ValidateSet('exceptional success','success','setback','failure','severe failure','resolved')][string]$Degree,
        [Parameter(Mandatory)][string[]]$Facts,
        [Parameter(Mandatory)][string[]]$Visible,
        [string[]]$NotebookEntries = @(),
        [string[]]$RecentHistory = @(),
        [string]$GuillermoStageDirection,
        [string[]]$NpcDisclosure = @(),
        [object]$PostActionState,
        [object]$EventState,
        [string[]]$NpcDiscloses = @(),
        [string[]]$NpcWithholds = @()
    )
    if ($Facts.Count -eq 0) { throw 'A narration packet requires at least one resolved fact.' }
    if ($Visible.Count -eq 0) { throw 'A narration packet requires at least one visible item.' }
    if ($Actor -eq 'Guillermo' -and [string]::IsNullOrWhiteSpace($GuillermoStageDirection)) {
        throw 'A Guillermo packet requires an explicit stage direction.'
    }
    [pscustomobject]@{
        Scene = [pscustomobject]@{ Location=$Location; Time=$Time; Weather=$Weather }
        Actor = [pscustomobject]@{
            Name=$Actor
            Identity=$(if ($Actor -eq 'Armand') { @('adult male tiefling','occult investigator') } else { @('small capuchin monkey',"Armand's familiar",'communicates only through gestures') })
        }
        Action = [pscustomobject]@{ Type=$ActionType; Target=$Target }
        Resolution = [pscustomobject]@{ Degree=$Degree; Facts=@($Facts) }
        Visible = @($Visible)
        NotebookEntries = @($NotebookEntries)
        RecentHistory = @($RecentHistory)
        GuillermoStageDirection = $GuillermoStageDirection
        PostActionState = $PostActionState
        EventState = $EventState
        NpcDisclosure = [pscustomobject]@{
            Discloses = @(if ($NpcDiscloses.Count) { $NpcDiscloses } else { $NpcDisclosure })
            Withholds = @($NpcWithholds)
        }
    }
}

function Add-StateFields {
    param([Text.StringBuilder]$Builder,[string]$Heading,[object]$State)
    if ($null -eq $State) { return }
    $properties = @($State.PSObject.Properties)
    if ($properties.Count -eq 0) { return }
    [void]$Builder.AppendLine($Heading)
    foreach ($property in $properties) {
        $value = if ($property.Value -is [bool]) { $property.Value.ToString().ToLowerInvariant() } else { [string]$property.Value }
        [void]$Builder.AppendLine("$($property.Name): $value")
    }
    [void]$Builder.AppendLine()
}

function Add-Lines {
    param([Text.StringBuilder]$Builder,[string]$Heading,[object[]]$Values)
    if ($null -eq $Values -or $Values.Count -eq 0) { return }
    [void]$Builder.AppendLine($Heading)
    foreach ($value in $Values) { [void]$Builder.AppendLine("- $value") }
    [void]$Builder.AppendLine()
}

function Format-NarrationPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Packet,
        [Parameter(Mandatory)][ValidateSet('facts','literary')][string]$Format
    )
    $builder = [Text.StringBuilder]::new()
    if ($Format -eq 'facts') {
        [void]$builder.AppendLine('FACTS')
        [void]$builder.AppendLine("location: $($Packet.Scene.Location)")
        [void]$builder.AppendLine("time: $($Packet.Scene.Time)")
        [void]$builder.AppendLine("weather: $($Packet.Scene.Weather)")
        [void]$builder.AppendLine("actor: $($Packet.Actor.Name)")
        [void]$builder.AppendLine('identity:')
        foreach ($identity in $Packet.Actor.Identity) { [void]$builder.AppendLine("- $identity") }
        [void]$builder.AppendLine("action: $($Packet.Action.Type)")
        [void]$builder.AppendLine("target: $($Packet.Action.Target)")
        [void]$builder.AppendLine("degree: $($Packet.Resolution.Degree)")
        Add-Lines $builder 'resolved:' $Packet.Resolution.Facts
        Add-StateFields $builder 'POST_ACTION_STATE' $Packet.PostActionState
        Add-StateFields $builder 'EVENT_STATE' $Packet.EventState
        Add-Lines $builder 'visible:' $Packet.Visible
        Add-Lines $builder 'known notebook entries:' $Packet.NotebookEntries
        Add-Lines $builder 'recent narration:' $Packet.RecentHistory
        if (-not [string]::IsNullOrWhiteSpace($Packet.GuillermoStageDirection)) { [void]$builder.AppendLine("Guillermo stage direction: $($Packet.GuillermoStageDirection)") }
        if ($Packet.NpcDisclosure.Discloses.Count -or $Packet.NpcDisclosure.Withholds.Count) {
            [void]$builder.AppendLine('NPC_DISCLOSURE')
            Add-Lines $builder 'discloses:' $Packet.NpcDisclosure.Discloses
            Add-Lines $builder 'withholds:' $Packet.NpcDisclosure.Withholds
        }
        [void]$builder.AppendLine('NARRATION')
        [void]$builder.Append('You ')
    }
    else {
        [void]$builder.AppendLine('SCENE NOTES')
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("Location: $($Packet.Scene.Location)")
        [void]$builder.AppendLine("Time: $($Packet.Scene.Time)")
        [void]$builder.AppendLine("Weather: $($Packet.Scene.Weather)")
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("$($Packet.Actor.Name):")
        foreach ($identity in $Packet.Actor.Identity) { [void]$builder.AppendLine("- $identity") }
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("$($Packet.Actor.Name) $($Packet.Action.Type) $($Packet.Action.Target).")
        [void]$builder.AppendLine("The result is $($Packet.Resolution.Degree).")
        foreach ($fact in $Packet.Resolution.Facts) { [void]$builder.AppendLine("$fact.") }
        [void]$builder.AppendLine()
        Add-StateFields $builder 'Post-action state:' $Packet.PostActionState
        Add-StateFields $builder 'Event state:' $Packet.EventState
        Add-Lines $builder 'Visible:' $Packet.Visible
        Add-Lines $builder 'Known notebook entries:' $Packet.NotebookEntries
        Add-Lines $builder 'Recent narration:' $Packet.RecentHistory
        if (-not [string]::IsNullOrWhiteSpace($Packet.GuillermoStageDirection)) { [void]$builder.AppendLine("Guillermo: $($Packet.GuillermoStageDirection)") }
        Add-Lines $builder 'NPC discloses:' $Packet.NpcDisclosure.Discloses
        Add-Lines $builder 'NPC withholds:' $Packet.NpcDisclosure.Withholds
        [void]$builder.AppendLine('SCENE:')
        [void]$builder.Append('You ')
    }
    $builder.ToString()
}

function ConvertTo-NarrationPacket {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Case)
    $args = @{
        Location=$Case.location; Time=$Case.time; Weather=$Case.weather; Actor=$Case.actor
        ActionType=$Case.action_type; Target=$Case.target; Degree=$Case.degree
        Facts=@($Case.facts); Visible=@($Case.visible)
    }
    if ($Case.PSObject.Properties['notebook_entries']) { $args.NotebookEntries=@($Case.notebook_entries) }
    if ($Case.PSObject.Properties['recent_history']) { $args.RecentHistory=@($Case.recent_history) }
    if ($Case.PSObject.Properties['guillermo_stage_direction']) { $args.GuillermoStageDirection=$Case.guillermo_stage_direction }
    if ($Case.PSObject.Properties['npc_disclosure']) { $args.NpcDisclosure=@($Case.npc_disclosure) }
    if ($Case.PSObject.Properties['post_action_state']) { $args.PostActionState=$Case.post_action_state }
    if ($Case.PSObject.Properties['event_state']) { $args.EventState=$Case.event_state }
    if ($Case.PSObject.Properties['npc_discloses']) { $args.NpcDiscloses=@($Case.npc_discloses) }
    if ($Case.PSObject.Properties['npc_withholds']) { $args.NpcWithholds=@($Case.npc_withholds) }
    New-NarrationPacket @args
}

Export-ModuleMember -Function New-NarrationPacket,Format-NarrationPacket,ConvertTo-NarrationPacket
