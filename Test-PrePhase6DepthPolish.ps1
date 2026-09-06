$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/VerticalSlice.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $root 'src/IntentSchema.psm1') -Force
function Assert($Condition,[string]$Message){if(-not$Condition){throw "FAILED: $Message"}}
function Run($Session,[string]$Text,[Nullable[int]]$Roll=$null){$i=Invoke-SliceInterpretation $Session $Text;if($i.Status-ne'RESOLVED'){return [pscustomobject]@{Interpretation=$i;Resolution=$null}};$args=@{Session=$Session;Intent=(ConvertTo-EngineIntent $i.Intent)};if($null-ne$Roll){$args.FixedRoll=$Roll};[pscustomobject]@{Interpretation=$i;Resolution=(Resolve-SliceIntent @args)}}

$s=New-CallumStudySession $root;$overview=Run $s 'look around the room'
Assert ($overview.Resolution.Events-match'dark discoloration'-and$overview.Resolution.Events-match'coarse fibers'-and$s.State.Notebook.Clues.Count-eq0-and$overview.Resolution.Check-eq$null) 'overview exposes observations without Notebook interpretation or roll'
$book=Get-SlicePlayerState $s;Assert (($book.notebook|ConvertTo-Json -Depth 12)-notmatch'dried blood|hemp cordage|ordinary fire') 'fresh overview Notebook contains no interpreted facts'
$blood=Run $s 'look at the dark discoloration';Assert ($s.State.Notebook.Clues.bloodstain.known_facts-match'dried blood') 'focused blood observation earns first tier'

$desk=New-CallumStudySession $root;Run $desk 'look around the room'|Out-Null;$deskFocus=Run $desk 'look at the top of the desk'
Assert ($deskFocus.Interpretation.Intent.target-eq'writing_desk'-and$deskFocus.Interpretation.Intent.area-eq'on_top'-and$desk.State.Notebook.Clues.rope_fibers.known_facts-match'rope fibers'-and$desk.State.Notebook.Clues.rope_fibers.known_facts-notmatch'hemp cordage') 'desk focus earns rope identity but not hemp'
$deskActive=Run $desk 'carefully investigate the coarse fibers' 20;Assert ($deskActive.Resolution.Check-and$desk.State.Notebook.Clues.rope_fibers.known_facts-match'hemp cordage') 'active investigation earns hemp tier with roll'
$scorch=New-CallumStudySession $root;Run $scorch 'look around the room'|Out-Null;Run $scorch 'look at the dark patterns'|Out-Null;Assert ($scorch.State.Notebook.Clues.scorch_marks.known_facts-match'ordinary fire'-and$scorch.State.Notebook.Clues.scorch_marks.known_facts-notmatch'magical or occult') 'focused scorch observation earns only ordinary-fire tier'

$gesture=Run $s 'wave at guillermo and whistle';Assert ($gesture.Interpretation.Intent.action-eq'gesture'-and$gesture.Resolution.Events-notmatch'(?i)ask|says|answers|replies') 'Guillermo gesture remains nonverbal'
$property=Run $s 'how high is the window?';Assert ($property.Interpretation.Intent.action-eq'query_property'-and$property.Interpretation.Intent.target-eq'window'-and$property.Interpretation.Intent.property-eq'height'-and$property.Resolution.Events-match'waist'-and$property.Resolution.Check-eq$null) 'window height query answers requested property without roll or latch substitution'
$window=Run $s 'got to window and try to open it';Assert ($window.Interpretation.Intent.target-eq'window'-and$s.WindowOpen-and$window.Resolution.Events-notmatch'harmless experiment') 'natural window opening mutates authored window state'
$beforeLocation=$s.State.Player.Location;$compound=Invoke-SliceInterpretation $s 'close the window and look at the top of the desk';Assert ($compound.Status-eq'NEEDS_CLARIFICATION'-and$compound.CompoundDetected-and$s.State.Player.Location-eq$beforeLocation-and$s.WindowOpen) 'true compound executes neither clause nor unrelated movement'
$drawers=Run $s 'look through the drawers and see if there are any papers';Assert ($drawers.Interpretation.Intent.target-eq'desk_drawers'-and$drawers.Resolution.Events-match'no accessible drawers') 'drawers never substitute correspondence'
$letters=Run $s 'read any letters i find';Assert ($letters.Interpretation.Intent.target-eq'correspondence'-and$letters.Resolution.Events-match'academic dinner'-and$letters.Resolution.Events-notmatch'harmless experiment|mundane result|result category') 'letters resolve to authored correspondence in world-facing prose'

foreach($clue in $s.State.Notebook.Clues.Values){$authoritative=$s.State.Clues[$clue.clue_id];foreach($fact in @($clue.known_facts)){Assert ($authoritative.KnownFacts.Contains([string]$fact)) "Notebook fact is authoritative for $($clue.clue_id)"}}
$base=[pscustomobject]@{Passed=$true;Lexical=$null;Structural=$null};Assert (-not(Test-SliceNarrationGrounding $s $gesture.Resolution 'You ask Guillermo what he knows.' $base).Passed) 'gesture validator rejects invented dialogue';Assert (-not(Test-SliceNarrationGrounding $s $letters.Resolution 'The mundane result permits a harmless experiment.' $base).Passed) 'validator rejects internal classification language'
$examples=@(Get-Content -Raw (Join-Path $root 'exemplars/playability_polish_exemplars.json')|ConvertFrom-Json);Assert ($examples.Count-eq7) 'seven targeted rich-prose exemplars';foreach($e in $examples){$sentences=@([regex]::Matches($e.narration,'[.!?](?:\s|$)')).Count;Assert ($sentences-ge2-and$sentences-le4) "exemplar $($e.id) uses two to four sentences"}
'Pre-Phase-6 depth polish tests passed: overview knowledge, gesture, property, compound, exact targeting, tiers, prose safety, and Notebook authority.'
