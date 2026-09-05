Set-StrictMode -Version Latest

function Test-LexicalLeaks {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Text,[string[]]$ForbiddenTerms=@())
    $hits = [Collections.Generic.List[string]]::new()
    foreach ($term in $ForbiddenTerms) {
        if ([string]::IsNullOrWhiteSpace($term)) { continue }
        if ($Text -match ('(?i)(?<![\p{L}\p{N}])' + [regex]::Escape($term) + '(?![\p{L}\p{N}])')) { $hits.Add($term) }
    }
    [pscustomobject]@{ Passed=($hits.Count -eq 0); Hits=@($hits) }
}

function Test-NarrationStructure {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Text,[int]$MaxWords=180,[string]$Actor='Armand')
    $words = @([regex]::Matches($Text,"\b[\p{L}\p{N}'’-]+\b"))
    $firstPerson = @([regex]::Matches($Text,'(?i)\b(I|me|my|mine|myself)\b') | ForEach-Object Value | Select-Object -Unique)
    $agencyPatterns = @('you feel','you realize','you decide','you think','you remember','you choose','you want','you believe','you know','you wonder')
    $agencyHits = @($agencyPatterns | Where-Object { $Text -match ('(?i)\b' + [regex]::Escape($_) + '\b') })
    $datasetPatterns = @('(?im)^\s*(QUESTION|PROBLEMS?|ACTION|ANSWER|RESPONSE)\s*:?', '(?im)^\s*(FACTS|NARRATION|SCENE NOTES|SCENE:)\s*$')
    $datasetHits = @($datasetPatterns | Where-Object { $Text -match $_ })
    $secondPerson = $Text -match '(?i)\b(you|your|yours|yourself)\b'
    $thirdPersonActor = $Actor -eq 'Armand' -and $Text -match '(?i)\bArmand\s+(?:is|was|has|had|goes|went|looks|looked|feels|felt|thinks|thought|decides|decided|walks|walked|takes|took|opens|opened)\b'
    $pastMarkers = @([regex]::Matches($Text,'(?i)\b(was|were|had|went|looked|walked|opened|found|felt|thought|decided|said|saw|heard)\b') | ForEach-Object Value)
    [pscustomobject]@{
        Passed=($secondPerson -and $firstPerson.Count -eq 0 -and -not $thirdPersonActor -and $agencyHits.Count -eq 0 -and $datasetHits.Count -eq 0 -and $words.Count -le $MaxWords)
        WordCount=$words.Count; HasSecondPerson=$secondPerson; FirstPersonHits=$firstPerson
        ThirdPersonActorDrift=$thirdPersonActor; PastTenseRiskHits=$pastMarkers
        AgencyRiskHits=$agencyHits; DatasetFormHits=$datasetHits; ExcessiveLength=($words.Count -gt $MaxWords)
    }
}

function Test-NarrationOutput {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Text,[string[]]$ForbiddenTerms=@(),[int]$MaxWords=180,[string]$Actor='Armand')
    $lexical = Test-LexicalLeaks $Text $ForbiddenTerms
    $structural = Test-NarrationStructure $Text $MaxWords $Actor
    [pscustomobject]@{
        Passed=($lexical.Passed -and $structural.Passed)
        Lexical=$lexical
        Structural=$structural
        RawOutput=$Text
        ValidatedOutput=$(if ($lexical.Passed -and $structural.Passed) { $Text } else { $null })
    }
}

Export-ModuleMember -Function Test-LexicalLeaks,Test-NarrationStructure,Test-NarrationOutput
