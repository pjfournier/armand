$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Import-Module (Join-Path $root 'src/NarrationPrompt.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationPacket.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationValidation.psm1') -Force

function Assert-True([bool]$Condition,[string]$Message) {
    if (-not $Condition) { throw "FAILED: $Message" }
}

$case = [pscustomobject]@{
    location='study'; time='midnight'; weather='rain'; actor='Armand'
    action_type='investigates'; target='desk'; degree='success'
    facts=@('the drawer remains closed'); visible=@('desk'); forbidden_terms=@('murder')
}
$packet = ConvertTo-NarrationPacket $case
Assert-True ($packet.PSObject.Properties.Name -notcontains 'CaseTruth') 'Packet must not expose hidden truth.'
Assert-True ($packet.Actor.Identity -contains 'adult male tiefling') 'Armand identity anchor is absent.'

$examples = @(Read-NarrationExemplars (Join-Path $root 'exemplars/narration_exemplars.json'))
Assert-True ($examples.Count -eq 8) 'Exactly eight exemplars must load.'
$prompt = Build-NarrationPrompt -Packet $packet -Format facts -Exemplars $examples
Assert-True ($prompt.EndsWith('You ')) 'Completion prompt must end with a spaced second-person seed.'

$good = Test-NarrationOutput -Text 'You inspect the desk. The drawer remains closed.' -ForbiddenTerms @('murder')
Assert-True $good.Passed 'A conforming narration should pass validation.'
$leak = Test-NarrationOutput -Text 'You find the murder weapon.' -ForbiddenTerms @('murder')
Assert-True (-not $leak.Passed) 'A forbidden lexical term must fail validation.'
Assert-True ($leak.RawOutput -eq 'You find the murder weapon.') 'Raw failed output must be preserved.'
$agency = Test-NarrationOutput -Text 'You decide to open the drawer.'
Assert-True (-not $agency.Passed) 'An obvious player-agency phrase must fail validation.'
$dataset = Test-NarrationOutput -Text "You inspect the desk.`nACTION: open drawer"
Assert-True (-not $dataset.Passed) 'Dataset-form leakage must fail validation.'

$targeted = @(Read-NarrationExemplars (Join-Path $root 'exemplars/grounding_retry_exemplars.json') -ExpectedCount 3)
$allExamples = @($examples) + @($targeted)
Assert-True ($allExamples.Count -eq 11) 'The retry must load exactly eleven exemplars.'
Assert-True (@($allExamples.id | Select-Object -Unique).Count -eq 11) 'Each retry exemplar must load exactly once.'
$retryCase = [pscustomobject]@{
    location='archive';time='midnight';weather='rain';actor='Armand';action_type='asks';target='clerk';degree='success'
    facts=@('Armand asks about the key');visible=@('desk')
    post_action_state=[pscustomobject]@{drawer='closed';contents_access='none'}
    event_state=[pscustomobject]@{bell='rang once'}
    npc_discloses=@('the key was left at midnight');npc_withholds=@('the woman identity')
}
$retryPacket = ConvertTo-NarrationPacket $retryCase
$retryText = Format-NarrationPacket $retryPacket facts
Assert-True ($retryText -match 'POST_ACTION_STATE[\s\S]*drawer: closed') 'Affirmative post-action state must render.'
Assert-True ($retryText -match 'EVENT_STATE[\s\S]*bell: rang once') 'Affirmative event state must render.'
Assert-True ($retryText -match 'NPC_DISCLOSURE[\s\S]*discloses:[\s\S]*withholds:') 'Bounded disclosure must render.'
Assert-True ($retryText -notmatch '(?i)<\|system\|>|<\|assistant\|>|ChatML') 'No chat template may be introduced.'
$stageA = @(Get-Content -Raw (Join-Path $root 'eval/grounding_retry_stageA_cases.json') | ConvertFrom-Json)
$stageB = @(Get-Content -Raw (Join-Path $root 'eval/grounding_retry_stageB_cases.json') | ConvertFrom-Json)
Assert-True ($stageA.Count -eq 20 -and $stageB.Count -eq 20) 'Retry stages must contain twenty cases each.'
Assert-True (@(Compare-Object $stageA.id $stageB.id -IncludeEqual -ExcludeDifferent).Count -eq 0) 'Stage A and B case IDs must remain distinct.'
$runnerText = Get-Content -Raw (Join-Path $root 'Run-GroundingRetry.ps1')
Assert-True ($runnerText -match "0\.15" -and $runnerText -match "0\.20") 'Retry temperature selection must remain configurable.'

Write-Host 'Phase 2 tests passed.'
