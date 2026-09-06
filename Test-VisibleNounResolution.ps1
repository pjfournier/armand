$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSScriptRoot 'src/HousePrototype.psm1') -Force -DisableNameChecking
$passed=0
function Check([string]$Name,[bool]$Condition){if(-not$Condition){throw "FAIL: $Name"};$script:passed++;Write-Host "PASS $Name"}

$session=New-HouseSession $PSScriptRoot 6001
foreach($room in $session.HouseContent.rooms){
    $session.State.Player.Location=$room.id
    foreach($id in @(Get-HouseVisibleIds $session)){
        $item=$session.State.Items[$id]
        $result=Resolve-HouseTarget $session "inspect $($item.DisplayName)"
        Check "display noun round trip: $($room.id)/$id" ($result.status-eq'resolved'-and$result.target-eq$id)
        foreach($alias in @($item.Aliases|Where-Object{-not[string]::IsNullOrWhiteSpace([string]$_)}|Select-Object -Unique)){
            $aliasResult=Resolve-HouseTarget $session "inspect $alias"
            Check "authored alias retained: $($room.id)/$id/$alias" (($aliasResult.status-eq'resolved'-and$aliasResult.target-eq$id)-or($aliasResult.status-eq'ambiguous'-and@($aliasResult.candidates)-contains$id))
        }
    }
    Check "noun contract: $($room.id)" (@(Test-HouseNounContract $session).Count-eq0)
}

$session.State.Player.Location='exterior'
$aliases=[ordered]@{
    'open the mail box'='mailbox';'check the post box'='mailbox';'inspect the letter box'='mailbox'
    'look at the woodpile'='woodpile';'inspect the covered woodpile'='woodpile'
    'inspect the gate'='broken_gate';'look at the window'='front_window';'open the front door'='front_door'
}
foreach($input in $aliases.Keys){$result=Resolve-HouseTarget $session $input;Check "alias: $input" ($result.status-eq'resolved'-and$result.target-eq$aliases[$input])}

$duplicate=[pscustomobject]@{Id='test_cellar_door';DisplayName='cellar door';Aliases=@('door');Location='exterior';Owner=$null;State=[ordered]@{};Tags=@('test');InteractableParts=@();RenderClass='static-renderable'}
$session.State.Items[$duplicate.Id]=$duplicate;$session.State.Locations.exterior.VisibleObjects+=@($duplicate.Id)
$ambiguous=Resolve-HouseTarget $session 'open the door'
Check 'generic duplicate alias requests clarification' ($ambiguous.status -eq 'ambiguous' -and @($ambiguous.candidates).Count -eq 2)
$specific=Resolve-HouseTarget $session 'open the front door'
Check 'specific noun remains deterministic' ($specific.target -eq 'front_door')

$session=New-HouseSession $PSScriptRoot 6001
$first=Invoke-HouseTurn $session 'look around';$second=Invoke-HouseTurn $session 'check mailbox';$third=Invoke-HouseTurn $session 'open the mailbox'
Check 'outside overview exposes mailbox' ($first.narration-match'\bmailbox\b')
Check 'check mailbox resolves' ($second.status-eq'resolved'-and$second.narration-notmatch'cannot identify')
Check 'open mailbox resolves' ($third.status-eq'resolved'-and$third.narration-notmatch'cannot identify')

Write-Host "Visible noun resolution: $passed passed, 0 failed"
