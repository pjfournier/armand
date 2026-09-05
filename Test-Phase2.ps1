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

Write-Host 'Phase 2 tests passed.'
