Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot 'Characters.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'Notebook.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot 'IncidentLedger.psm1') -Force

function New-GameState {
    param([datetime]$CaseTime=[datetime]'1890-01-01T20:00:00')
    [pscustomobject]@{
        Player=New-ArmandProfile;Guillermo=New-GuillermoProfile
        NPCs=[ordered]@{};Locations=[ordered]@{};Items=[ordered]@{};Clues=[ordered]@{};Objectives=[ordered]@{}
        Time=[pscustomobject]@{Turn=0;ElapsedMinutes=0;CurrentCaseTime=$CaseTime}
        WorldChanges=[Collections.Generic.List[object]]::new()
        Notebook=New-NotebookState
        GuillermoIncidentLedger=New-GuillermoIncidentLedger
    }
}

function Add-LocationState { param($State,[string]$Id,[string[]]$VisibleObjects=@(),[string[]]$Exits=@(),[string]$DisplayName=$Id,[string[]]$Aliases=@()) $State.Locations[$Id]=[pscustomobject]@{Id=$Id;DisplayName=$DisplayName;Aliases=@($Aliases);VisibleObjects=@($VisibleObjects);PersistentState=[ordered]@{};NPCsPresent=[Collections.Generic.List[string]]::new();Exits=@($Exits)} }
function Add-ItemState { param($State,[string]$Id,[string]$Location,[string]$Owner,[hashtable]$ItemState=@{},[string[]]$Tags=@(),[string]$DisplayName=$Id,[string[]]$Aliases=@(),[string[]]$InteractableParts=@(),[ValidateSet('static-renderable','animate-excluded')][string]$RenderClass='static-renderable',[ValidateSet('dominant','notable','texture')][string]$Salience='notable') $State.Items[$Id]=[pscustomobject]@{Id=$Id;DisplayName=$DisplayName;Aliases=@($Aliases);Location=$Location;Owner=$Owner;State=[ordered]@{};Tags=@($Tags);InteractableParts=@($InteractableParts);RenderClass=$RenderClass;Salience=$Salience};foreach($key in $ItemState.Keys){$State.Items[$Id].State[$key]=$ItemState[$key]} }
function ConvertTo-StableStateJson {param($Value,[int]$Depth=20)function Normalize($x){if($null-eq$x){return $null};if($x-is[float]-or$x-is[double]-or$x-is[decimal]){return [double]::Parse(([double]$x).ToString('F4',[Globalization.CultureInfo]::InvariantCulture),[Globalization.CultureInfo]::InvariantCulture)};if($x-is[Collections.IDictionary]){$o=[ordered]@{};foreach($k in @($x.Keys|Sort-Object)){$o[[string]$k]=Normalize $x[$k]};return $o};if($x-is[psobject]-and$x-isnot[string]-and@($x.PSObject.Properties).Count){$o=[ordered]@{};foreach($p in @($x.PSObject.Properties|Sort-Object Name)){$o[$p.Name]=Normalize $p.Value};return $o};if($x-is[Collections.IEnumerable]-and$x-isnot[string]){return @($x|ForEach-Object{Normalize $_})};$x};Normalize $Value|ConvertTo-Json -Depth $Depth -Compress}
function Add-NpcState { param($State,[string]$Id,[string]$Location,[int]$Awareness=0,[int]$Suspicion=0,[string]$SearchState='idle',[string]$Goal='',[string[]]$KnowledgeReferences=@(),[string]$Target='',[string]$DisplayName=$Id,[string[]]$Aliases=@()) $State.NPCs[$Id]=[pscustomobject]@{Id=$Id;DisplayName=$DisplayName;Aliases=@($Aliases);CurrentLocation=$Location;Awareness=$Awareness;Suspicion=$Suspicion;SearchState=$SearchState;Goal=$Goal;KnowledgeReferences=@($KnowledgeReferences);Target=$Target} }
function Add-ObjectiveState { param($State,[string]$Id,[string]$Status='inactive') $State.Objectives[$Id]=[pscustomobject]@{Id=$Id;Status=$Status} }
function Set-ItemProperty { param($State,[string]$ItemId,[string]$Name,$Value) if(-not$State.Items.Contains($ItemId)){throw "Unknown item: $ItemId"};$State.Items[$ItemId].State[$Name]=$Value;$State.WorldChanges.Add([pscustomobject]@{Type='item_state';Id=$ItemId;Name=$Name;Value=$Value}) }
function Move-Npc { param($State,[string]$NpcId,[string]$Location) if(-not$State.NPCs.Contains($NpcId)){throw "Unknown NPC: $NpcId"};$State.NPCs[$NpcId].CurrentLocation=$Location;$State.WorldChanges.Add([pscustomobject]@{Type='npc_move';Id=$NpcId;Location=$Location}) }
function Add-GameTime { param($State,[int]$Minutes=0,[int]$Turns=1) if($Minutes-lt0-or$Turns-lt0){throw 'Time cannot move backward.'};$State.Time.Turn+=$Turns;$State.Time.ElapsedMinutes+=$Minutes;$State.Time.CurrentCaseTime=$State.Time.CurrentCaseTime.AddMinutes($Minutes) }
function Move-InventoryItem {
    param($State,[string]$ItemId,[ValidateSet('Armand','Guillermo','none')][string]$To)
    if(-not$State.Items.Contains($ItemId)){throw "Unknown item: $ItemId"};$item=$State.Items[$ItemId]
    $State.Player.Inventory.Remove($ItemId)|Out-Null;$State.Guillermo.Inventory.Remove($ItemId)|Out-Null
    $item.Owner=$(if($To-eq'none'){$null}else{$To});$item.Location=$(if($To-eq'none'){$item.Location}else{'inventory'})
    if($To-eq'Armand'){$State.Player.Inventory.Add($ItemId)}elseif($To-eq'Guillermo'){$State.Guillermo.Inventory.Add($ItemId)}
    $State.WorldChanges.Add([pscustomobject]@{Type='inventory_transfer';Id=$ItemId;Owner=$item.Owner})
}
function Invoke-SpellSlotUse { param($State) if($State.Player.Magic.PactSlots.Current-le0){throw 'No pact slots remain.'};$State.Player.Magic.PactSlots.Current--; $State.WorldChanges.Add([pscustomobject]@{Type='spell_slot';Current=$State.Player.Magic.PactSlots.Current}) }

Export-ModuleMember -Function New-GameState,Add-LocationState,Add-ItemState,Add-NpcState,Add-ObjectiveState,Set-ItemProperty,Move-Npc,Add-GameTime,Move-InventoryItem,Invoke-SpellSlotUse,ConvertTo-StableStateJson
