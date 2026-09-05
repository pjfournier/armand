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
        [string[]]$NpcDisclosure = @()
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
        NpcDisclosure = @($NpcDisclosure)
    }
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
        Add-Lines $builder 'visible:' $Packet.Visible
        Add-Lines $builder 'known notebook entries:' $Packet.NotebookEntries
        Add-Lines $builder 'recent narration:' $Packet.RecentHistory
        if (-not [string]::IsNullOrWhiteSpace($Packet.GuillermoStageDirection)) { [void]$builder.AppendLine("Guillermo stage direction: $($Packet.GuillermoStageDirection)") }
        Add-Lines $builder 'NPC disclosure:' $Packet.NpcDisclosure
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
        Add-Lines $builder 'Visible:' $Packet.Visible
        Add-Lines $builder 'Known notebook entries:' $Packet.NotebookEntries
        Add-Lines $builder 'Recent narration:' $Packet.RecentHistory
        if (-not [string]::IsNullOrWhiteSpace($Packet.GuillermoStageDirection)) { [void]$builder.AppendLine("Guillermo: $($Packet.GuillermoStageDirection)") }
        Add-Lines $builder 'NPC disclosure:' $Packet.NpcDisclosure
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
    New-NarrationPacket @args
}

Export-ModuleMember -Function New-NarrationPacket,Format-NarrationPacket,ConvertTo-NarrationPacket
