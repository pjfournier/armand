$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Import-Module (Join-Path $root 'src/VerticalSlice.psm1') -Force -DisableNameChecking

$actions = @(
    'look down at the floor',
    'move the rug to examine beneath',
    'misty step to the desk',
    'look at the desk',
    'read correspondence',
    'look at the painting',
    'smell the rug',
    'touch the writing desk',
    'stare at the bookshelves',
    'knock on the paneled wall',
    'look under the writing desk',
    'read the receipt',
    'look at the window latch',
    'touch the chair',
    'ask Guillermo about the room',
    'look at the fireplace',
    'detect magic on the fireplace',
    'look at the rug',
    'look at the writing desk',
    'look at the bookshelves',
    'smell the correspondence',
    'touch the receipt',
    'stare at the painting',
    'knock on the desk',
    'look under the rug',
    'read correspondence',
    'look at the window latch',
    'touch the chair',
    'ask Guillermo about the painting',
    'look at the fireplace'
)

function Get-FailureCategories($validation) {
    $categories = [Collections.Generic.List[string]]::new()
    foreach ($errorText in @($validation.GroundingErrors)) {
        if ($errorText -match 'known context') { $categories.Add('known_context_restatement') }
        elseif ($errorText -match 'unsupported physical affordance') { $categories.Add('unsupported_object') }
        elseif ($errorText -match 'unsupported consequential detail') { $categories.Add('unsupported_detail') }
        elseif ($errorText -match 'knowledge or belief') { $categories.Add('agency_violation') }
        else { $categories.Add('state_contradiction') }
    }
    if (-not $validation.Lexical.Passed) { $categories.Add('lexical_leak') }
    if ($validation.Structural.AgencyRiskHits.Count -or $validation.Structural.FirstPersonHits.Count) { $categories.Add('agency_violation') }
    if ($validation.Structural.DatasetFormHits.Count) { $categories.Add('dataset_form') }
    if ($validation.Structural.ExcessiveLength) { $categories.Add('excessive_length') }
    if (-not $validation.Structural.HasSecondPerson -or $validation.Structural.ThirdPersonActorDrift) { $categories.Add('person_or_viewpoint') }
    @($categories | Select-Object -Unique)
}

$outPath = Join-Path $root 'eval/slice_polish_diagnostic_raw.jsonl'
$summaryPath = Join-Path $root 'eval/slice_polish_diagnostic_summary.json'
if (Test-Path -LiteralPath $outPath) { Remove-Item -LiteralPath $outPath }
$session = New-CallumStudySession $root
$turns = [Collections.Generic.List[object]]::new()
$categoryCounts = [ordered]@{}

for ($index = 0; $index -lt $actions.Count; $index++) {
    if ($index -in @(10,20)) { $session = New-CallumStudySession $root }
    $turnWatch = [Diagnostics.Stopwatch]::StartNew()
    $interpretation = Invoke-SliceInterpretation $session $actions[$index] -DebugLogPath (Join-Path $root 'eval/slice_polish_interpreter_debug.jsonl') -Seed (24000 + $index)
    $resolution = if ($interpretation.Status -eq 'RESOLVED') { Resolve-SliceIntent $session $interpretation.Intent } else { $null }
    $narration = if ($null -ne $resolution -and $resolution.Accepted) { Invoke-SliceNarration $session $resolution $null 2 $root } else { $null }
    $turnWatch.Stop()
    $attempts = @()
    if ($null -ne $narration) {
        for ($attemptIndex = 0; $attemptIndex -lt $narration.RawOutputs.Count; $attemptIndex++) {
            $validation = $narration.Validations[$attemptIndex]
            $categories = @(Get-FailureCategories $validation)
            foreach ($category in $categories) {
                if (-not $categoryCounts.Contains($category)) { $categoryCounts[$category] = 0 }
                $categoryCounts[$category]++
            }
            $attempts += [pscustomobject]@{attempt=($attemptIndex+1);raw=$narration.RawOutputs[$attemptIndex];passed=$validation.Passed;categories=$categories;validation=$validation}
        }
    }
    $row = [ordered]@{
        turn=($index+1); input=$actions[$index]; interpretation_status=$interpretation.Status
        intent=$interpretation.Intent; accepted=$(if ($resolution) {$resolution.Accepted} else {$false})
        classification=$(if ($resolution) {$resolution.Classification} else {$null})
        engine_events=$(if ($resolution) {@($resolution.Events)} else {@()})
        attempts=$attempts; displayed_narration=$(if ($narration) {$narration.Text} else {$resolution.Reason})
        first_pass=$(if ($narration) {-not $narration.RetryOccurred} else {$false})
        retry=$(if ($narration) {$narration.RetryOccurred} else {$false})
        fallback=$(if ($narration) {$narration.FallbackUsed} else {$false})
        interpreter_latency_seconds=[math]::Round([double]$interpretation.ElapsedSeconds,4)
        narrator_latency_seconds=$(if ($narration) {[math]::Round([double]$narration.ElapsedSeconds,4)} else {0})
        total_latency_seconds=[math]::Round($turnWatch.Elapsed.TotalSeconds,4)
    }
    $turns.Add([pscustomobject]$row)
    $row | ConvertTo-Json -Depth 18 -Compress | Add-Content -Encoding utf8 $outPath
    Write-Host ("Turn {0}/30: {1} ({2:N2}s)" -f ($index+1), $actions[$index], $turnWatch.Elapsed.TotalSeconds)
}

$latencies = @($turns | ForEach-Object total_latency_seconds | Sort-Object)
$summary = [ordered]@{
    generated_utc=[datetime]::UtcNow.ToString('o'); turns=$turns.Count
    accepted=@($turns | Where-Object accepted).Count
    meaningful=@($turns | Where-Object classification -eq 'MEANINGFUL').Count
    mundane=@($turns | Where-Object classification -eq 'MUNDANE').Count
    first_pass=@($turns | Where-Object first_pass).Count
    retries=@($turns | Where-Object retry).Count
    fallbacks=@($turns | Where-Object fallback).Count
    generation_attempts=(@($turns | ForEach-Object attempts).Count)
    failure_categories=$categoryCounts
    latency_seconds=[ordered]@{
        average=[math]::Round((($latencies | Measure-Object -Average).Average),4)
        median=[math]::Round([double]$latencies[[math]::Floor(($latencies.Count-1)/2)],4)
        maximum=[math]::Round((($latencies | Measure-Object -Maximum).Maximum),4)
    }
}
$summary | ConvertTo-Json -Depth 12 | Set-Content -Encoding utf8 $summaryPath
$summary | ConvertTo-Json -Depth 12
