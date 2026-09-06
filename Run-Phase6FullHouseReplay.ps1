param(
    [string]$BaseUri = 'http://127.0.0.1:8090',
    [string]$OutputPath = (Join-Path $PSScriptRoot 'eval/phase6_full_house_replay.json')
)

$ErrorActionPreference = 'Stop'
$commands = @(
    'look around',
    'ask Guillermo to inspect the mailbox',
    'circle the house',
    'go to kitchen',
    'investigate the unfinished meal',
    'go to living room',
    'go to bedroom',
    'examine the family photograph',
    'go to living room',
    'go to Callum study',
    'sneak out through the living room',
    'go to living room',
    'go to Callum study',
    'examine the large painting',
    'use 08-10-83 on the safe',
    'take the burned note'
)

Invoke-RestMethod -Method Post -Uri "$BaseUri/session/reset" | Out-Null
$turns = foreach ($command in $commands) {
    $response = Invoke-RestMethod -Method Post -ContentType 'application/json' -Uri "$BaseUri/action" -Body (@{ text = $command } | ConvertTo-Json)
    [ordered]@{
        prompt = $command
        response = $response.narration
        status = $response.status
        location = $response.state.location.id
        clues = $response.state.house_state.clues_discovered
        encounter_outcome = $response.state.house_state.encounter.outcome
        ending_reached = $response.state.house_state.ending_reached
    }
}

$artifact = [ordered]@{ seed = 6001; endpoint = $BaseUri; turns = @($turns) }
$artifact | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding utf8
if (-not $turns[-1].ending_reached) { throw 'The Phase 6 replay did not reach the ending lead.' }
Write-Host "Phase 6 live replay passed: $($turns.Count) turns; output $OutputPath"
