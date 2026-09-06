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
        [string[]]$NewThisTurn = @(),
        [string[]]$KnownContext = @(),
        [string]$MundaneResult,
        [ValidateSet('neutral','tense','dry_humor_allowed','guillermo_comic','serious')][string]$Tone='neutral',
        [string[]]$SupportedAffordances=@(),
        [object[]]$VisibleReferents=@(),
        [string[]]$Ambient=@(),
        [string[]]$Events=@(),
        [string[]]$ObservedFacts=@(),
        [string]$AuthorialIntent,
        [string[]]$RecentHistory = @(),
        [string]$GuillermoStageDirection,
        [string[]]$NpcDisclosure = @(),
        [object]$PostActionState,
        [object]$EventState,
        [string[]]$NpcDiscloses = @(),
        [string[]]$NpcWithholds = @(),
        [string]$AttemptDescription
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
        Attempt = $AttemptDescription
        Resolution = [pscustomobject]@{ Degree=$Degree; Facts=@($Facts) }
        Visible = @($Visible)
        NotebookEntries = @($NotebookEntries)
        NewThisTurn = @($NewThisTurn)
        KnownContext = @($(if($KnownContext.Count){$KnownContext}else{$NotebookEntries}))
        MundaneResult = $MundaneResult
        Tone = $Tone
        SupportedAffordances = @($SupportedAffordances)
        VisibleReferents = @($VisibleReferents)
        Ambient = @($Ambient)
        Events = @($Events)
        ObservedFacts = @($ObservedFacts)
        AuthorialIntent = $AuthorialIntent
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
        if([string]::IsNullOrWhiteSpace($Packet.Attempt)){
            [void]$builder.AppendLine("action: $($Packet.Action.Type)")
            [void]$builder.AppendLine("target: $($Packet.Action.Target)")
        } else {
            [void]$builder.AppendLine('ATTEMPT')
            [void]$builder.AppendLine("description: $($Packet.Attempt)")
        }
        [void]$builder.AppendLine("degree: $($Packet.Resolution.Degree)")
        Add-Lines $builder 'resolved:' $Packet.Resolution.Facts
        Add-StateFields $builder 'POST_ACTION_STATE' $Packet.PostActionState
        Add-StateFields $builder 'EVENT_STATE' $Packet.EventState
        Add-Lines $builder 'visible:' $Packet.Visible
        Add-Lines $builder 'NEW_THIS_TURN' $Packet.NewThisTurn
        Add-Lines $builder 'KNOWN_CONTEXT (do not restate unless directly compared)' $Packet.KnownContext
        if(-not[string]::IsNullOrWhiteSpace($Packet.MundaneResult)){[void]$builder.AppendLine("MUNDANE_RESULT: $($Packet.MundaneResult)")}
        [void]$builder.AppendLine("TONE: $($Packet.Tone)")
        Add-Lines $builder 'SUPPORTED_AFFORDANCES' $Packet.SupportedAffordances
        if(-not[string]::IsNullOrWhiteSpace($Packet.AuthorialIntent)){[void]$builder.AppendLine("AUTHORIAL_INTENT: $($Packet.AuthorialIntent)")}
        Add-Lines $builder 'OBSERVED_FACTS' $Packet.ObservedFacts
        Add-Lines $builder 'EVENTS' $Packet.Events
        Add-Lines $builder 'AMBIENT' $Packet.Ambient
        if($Packet.VisibleReferents.Count){[void]$builder.AppendLine('VISIBLE_REFERENTS');[void]$builder.AppendLine('Use only these display names or aliases for concrete referents. Never print canonical IDs. Compose by salience: establish dominant details first, give notable details a clause when useful, and use texture sparingly. Salience is perceptual emphasis, not clue status.');foreach($referent in $Packet.VisibleReferents){[void]$builder.AppendLine("- [$($referent.salience)] $($referent.display_name) | aliases: $(@($referent.aliases)-join', ')")};[void]$builder.AppendLine()}
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
        if([string]::IsNullOrWhiteSpace($Packet.Attempt)){[void]$builder.AppendLine("$($Packet.Actor.Name) $($Packet.Action.Type) $($Packet.Action.Target).")}
        else{[void]$builder.AppendLine("Attempt: $($Packet.Attempt)")}
        [void]$builder.AppendLine("The result is $($Packet.Resolution.Degree).")
        foreach ($fact in $Packet.Resolution.Facts) { [void]$builder.AppendLine("$fact.") }
        [void]$builder.AppendLine()
        Add-StateFields $builder 'Post-action state:' $Packet.PostActionState
        Add-StateFields $builder 'Event state:' $Packet.EventState
        Add-Lines $builder 'Visible:' $Packet.Visible
        Add-Lines $builder 'New this turn:' $Packet.NewThisTurn
        Add-Lines $builder 'Known context (do not restate unless directly compared):' $Packet.KnownContext
        if(-not[string]::IsNullOrWhiteSpace($Packet.MundaneResult)){[void]$builder.AppendLine("Mundane result: $($Packet.MundaneResult)")}
        [void]$builder.AppendLine("Tone: $($Packet.Tone)")
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
    if ($Case.PSObject.Properties['new_this_turn']) { $args.NewThisTurn=@($Case.new_this_turn) }
    if ($Case.PSObject.Properties['known_context']) { $args.KnownContext=@($Case.known_context) }
    if ($Case.PSObject.Properties['mundane_result']) { $args.MundaneResult=$Case.mundane_result }
    if ($Case.PSObject.Properties['tone']) { $args.Tone=$Case.tone }
    if ($Case.PSObject.Properties['supported_affordances']) { $args.SupportedAffordances=@($Case.supported_affordances) }
    if ($Case.PSObject.Properties['visible_referents']) { $args.VisibleReferents=@($Case.visible_referents) }
    if ($Case.PSObject.Properties['ambient']) { $args.Ambient=@($Case.ambient) }
    if ($Case.PSObject.Properties['events']) { $args.Events=@($Case.events) }
    if ($Case.PSObject.Properties['observed_facts']) { $args.ObservedFacts=@($Case.observed_facts) }
    if ($Case.PSObject.Properties['authorial_intent']) { $args.AuthorialIntent=[string]$Case.authorial_intent }
    if ($Case.PSObject.Properties['recent_history']) { $args.RecentHistory=@($Case.recent_history) }
    if ($Case.PSObject.Properties['guillermo_stage_direction']) { $args.GuillermoStageDirection=$Case.guillermo_stage_direction }
    if ($Case.PSObject.Properties['npc_disclosure']) { $args.NpcDisclosure=@($Case.npc_disclosure) }
    if ($Case.PSObject.Properties['post_action_state']) { $args.PostActionState=$Case.post_action_state }
    if ($Case.PSObject.Properties['event_state']) { $args.EventState=$Case.event_state }
    if ($Case.PSObject.Properties['npc_discloses']) { $args.NpcDiscloses=@($Case.npc_discloses) }
    if ($Case.PSObject.Properties['npc_withholds']) { $args.NpcWithholds=@($Case.npc_withholds) }
    if ($Case.PSObject.Properties['attempt_description']) { $args.AttemptDescription=$Case.attempt_description }
    New-NarrationPacket @args
}

Export-ModuleMember -Function New-NarrationPacket,Format-NarrationPacket,ConvertTo-NarrationPacket
