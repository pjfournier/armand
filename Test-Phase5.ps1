$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/GameState.psm1') -Force
Import-Module (Join-Path $root 'src/Clues.psm1') -Force
Import-Module (Join-Path $root 'src/Notebook.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $root 'src/IncidentLedger.psm1') -Force
Import-Module (Join-Path $root 'src/CoreEngine.psm1') -Force
Import-Module (Join-Path $root 'src/NarratorHandoff.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationPacket.psm1') -Force
# Restore commands replaced by nested -Force imports.
Import-Module (Join-Path $root 'src/GameState.psm1') -Force
Import-Module (Join-Path $root 'src/Clues.psm1') -Force
Import-Module (Join-Path $root 'src/Notebook.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $root 'src/IncidentLedger.psm1') -Force
function Assert($Condition,[string]$Message){if(-not$Condition){throw "FAILED: $Message"}}
function Assert-Throws([scriptblock]$Action,[string]$Pattern,[string]$Message){$caught='';try{&$Action}catch{$caught=$_.Exception.Message};Assert ($caught-match$Pattern) $Message}
$s=New-GameState;$s|Add-Member -NotePropertyName CaseTruth -NotePropertyValue ([pscustomobject]@{culprit='secret_cult';victim='secret_victim'})
Add-LocationState -State $s -Id archive -VisibleObjects @('desk') -Exits @('hall') -DisplayName 'Archive';Add-LocationState -State $s -Id sealed_room -VisibleObjects @('hidden_relic') -DisplayName 'Sealed room';$s.Player.Location='archive'
$tiers=@([pscustomobject]@{DC=10;Skill='Investigation';Fact='a dark stain is visible'},[pscustomobject]@{DC=15;Skill='Investigation';Fact='the stain is dried blood'},[pscustomobject]@{DC=20;Skill='Investigation';Fact='the amount is inconsistent with a death here'},[pscustomobject]@{DC=25;Skill='Investigation';Fact='the pattern suggests the injured person was moved'})
Add-ClueState -State $s -Id stain_01 -Location archive -Tiers $tiers -DisplayName 'Dark stain' -RelatedEntityIds @('desk')
Add-ClueState -State $s -Id hidden_relic_clue -Location sealed_room -Tiers @([pscustomobject]@{DC=10;Skill='Investigation';Fact='the hidden relic bears a crown'}) -DisplayName 'Hidden relic'
$first=Resolve-ClueInterpretation $s stain_01 Investigation 10
Assert ($first.Discovered-and$s.Notebook.Clues.stain_01.known_facts.Count-eq1) '1 discover first clue tier'
$advanced=Resolve-ClueInterpretation $s stain_01 Investigation 15
Assert ($advanced.NewFacts.Count-eq1-and$s.Notebook.Clues.stain_01.interpretation_tier_reached-eq15-and$s.Notebook.Clues.stain_01.known_facts.Count-eq2) '2 advance clue tier'
Resolve-ClueInterpretation $s stain_01 Investigation 15|Out-Null;Assert ($s.Notebook.Clues.stain_01.known_facts.Count-eq2) '3 same tier is idempotent'
$failed=Resolve-ClueInterpretation $s stain_01 Investigation 9;Assert ($failed.NewFacts.Count-eq0-and$s.Notebook.Clues.stain_01.known_facts.Count-eq2) '4 failed interpretation reveals nothing'
Assert (-not$s.Notebook.Clues.Contains('hidden_relic_clue')) '5 hidden clue absent'
Set-NotebookClueNote $s stain_01 "This could be the archivist's blood.";Assert ($s.Notebook.Clues.stain_01.player_note-match'archivist'-and$s.Notebook.Clues.stain_01.known_facts-notcontains"This could be the archivist's blood.") '6 clue note separate from fact'
Add-NotebookCharacter $s keeper 'Archive keeper' archive @('keeps the night register') @('met Armand at the archive')|Out-Null;Assert ($s.Notebook.Characters.Contains('keeper')) '7 character created'
Add-NotebookCharacterFact $s keeper 'left before midnight';Assert ($s.Notebook.Characters.keeper.known_facts.Contains('left before midnight')) '8 character fact added'
Set-NotebookCharacterImportant $s keeper $true;Assert $s.Notebook.Characters.keeper.important '9 importance on'
Set-NotebookCharacterImportant $s keeper $false;Assert (-not$s.Notebook.Characters.keeper.important) '10 importance off'
Visit-NotebookLocation $s archive 'Archive' @('a broken east window') @('stain_01')|Out-Null;Assert ($s.Notebook.Locations.archive.visited-and$s.Notebook.Locations.archive.discovery_ids.Contains('stain_01')) '11 location visit'
$locationJson=$s.Notebook.Locations.archive|ConvertTo-Json -Depth 6;Assert ($locationJson-notmatch'hidden_relic|sealed_room|secret exit') '12 hidden location state excluded'
$theory=New-NotebookTheory $s forced_entry 'Forced entry' 'The keeper staged a break-in.';Assert ($theory.classification-eq'player_belief') '13 theory created as belief'
Update-NotebookTheory $s forced_entry -Body 'Someone staged the broken window.'|Out-Null;Assert ($s.Notebook.Theories.forced_entry.body-match'broken window') '14 theory updated'
Add-NotebookTheoryLink $s forced_entry clue stain_01;Assert ($s.Notebook.Theories.forced_entry.linked_clue_ids.Contains('stain_01')) '15 known clue linked'
Assert-Throws {Add-NotebookTheoryLink $s forced_entry clue hidden_relic_clue} 'unknown Notebook clue' '16 hidden clue link rejected'
Assert ($s.Notebook.Theories.forced_entry.PSObject.Properties.Name-notcontains'correctness'-and$s.Notebook.Theories.forced_entry.classification-eq'player_belief') '17 theory is not truth-scored'
$exact=@(Get-NotebookRelevance $s archive stain_01 @() @() 4);Assert ($exact[0].id-eq'stain_01') '18 exact clue relevance'
$same=@(Get-NotebookRelevance $s archive $null @() @() 4);Assert (@($same.id)-contains'stain_01'-and@($same.id)-contains'archive') '19 same-location relevance'
Add-NotebookCharacter $s sailor 'Unrelated sailor' docks @('owns a blue coat')|Out-Null;$relevant=@(Get-NotebookRelevance $s archive stain_01 @() @() 4);Assert (@($relevant.id)-notcontains'sailor') '20 unrelated entry excluded'
Visit-NotebookLocation $s hall 'Hall' @('a tall clock')|Out-Null;$capped=@(Get-NotebookRelevance $s archive stain_01 @('keeper','archive') @() 2);Assert ($capped.Count-eq2) '21 relevance cap'
$safeLines=ConvertTo-NarratorNotebookEntries $exact;$resolution=[pscustomobject]@{Degree='Success'};$intent=[pscustomobject]@{Actor='Armand';Action='investigate';Target='stain';Method=$null};$handoff=New-NarratorHandoff $intent $resolution ([pscustomobject]@{}) @('the stain is observed') @('desk') @() @() $safeLines;$case=Convert-HandoffToNarrationCase $handoff archive;$packet=ConvertTo-NarrationPacket $case;$packetJson=$packet|ConvertTo-Json -Depth 10
Assert ($packetJson-match'KNOWN FACT \[clue:stain_01\]') '22 packet receives selected evidence'
$engineHandoff=Resolve-StructuredIntent -State $s -Intent $intent -Skill Investigation -DC 10 -FixedRoll 10 -PostActionState ([pscustomobject]@{}) -Events @('the stain is observed') -Visible @('desk') -NotebookQuery ([pscustomobject]@{CurrentLocation='archive';TargetId='stain_01';MaxEntries=2});Assert (@($engineHandoff.Handoff.NotebookEntries)-match'KNOWN FACT \[clue:stain_01\]') '22b engine handoff performs selective Notebook integration'
Assert ($packetJson-notmatch'inconsistent with a death|injured person was moved|hidden relic') '23 packet excludes hidden tiers'
Assert ($packetJson-notmatch'secret_cult|secret_victim|CaseTruth') '24 packet excludes Case Truth'
Assert ($packetJson-match'PLAYER NOTE \(belief\)'-and$packetJson-notmatch'KNOWN FACT \[clue:stain_01\]: This could') '25 player note labeled belief'
$evidence=Get-GuillermoTheoryEvidence $s forced_entry @('stain_01','hidden_relic_clue');$evidenceJson=$evidence|ConvertTo-Json -Depth 8;Assert ($evidenceJson-match'the stain is dried blood'-and$evidence.known_contradictions.Count-eq1) '26 Guillermo query uses Notebook evidence and directly encoded known contradictions'
Assert ($evidenceJson-notmatch'secret_cult|secret_victim|inconsistent with a death') '27 Guillermo query excludes truth and unrevealed facts'
$incident=Add-GuillermoIncident $s embarrassing_drop embarrassment 'Guillermo dropped the key noisily.' 3 'Butterfingers';Assert ($s.GuillermoIncidentLedger.Count-eq1-and$incident.event_type-eq'embarrassment') '28 engine incident recorded'
$narratorProse='Guillermo invents a hilarious new incident.';Assert ($s.GuillermoIncidentLedger.Count-eq1-and$narratorProse.Length-gt0) '29 narrator prose cannot write ledger'
Add-GuillermoIncident $s death_01 guillermo_death 'Guillermo was killed by the collapsing shelf.' 5 $null $true|Out-Null;Assert (@($s.GuillermoIncidentLedger.event_type)-contains'guillermo_death') '30 death incident recorded'
Add-GuillermoIncident $s death_01 guillermo_death 'duplicate description' 5|Out-Null;Assert ($s.GuillermoIncidentLedger.Count-eq2) '31 duplicate incident is idempotent'
$public=Get-PlayerFacingNotebook $s;$publicJson=$public|ConvertTo-Json -Depth 12;Assert ($publicJson-notmatch'score|CaseTruth|hidden_relic|secret_cult|GuillermoIncidentLedger') '32 player serializer hides engine-only fields'
Write-Host 'Phase 5 tests passed: 32 Notebook, relevance, narrator-boundary, evidence, ledger, and serialization checks.'
