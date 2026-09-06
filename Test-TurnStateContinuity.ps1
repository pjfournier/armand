$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/VerticalSlice.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $root 'src/IntentSchema.psm1') -Force
function Assert($Condition,[string]$Message){if(-not$Condition){throw "FAILED: $Message"}}
function Intent($Session,[string]$Text){Invoke-SliceInterpretation $Session $Text}

$s=New-CallumStudySession $root
$look=Intent $s 'look around the room';$before=$s.State.Player.Location;$lookResult=Resolve-SliceIntent $s (ConvertTo-EngineIntent $look.Intent)
Assert ($s.State.Player.Location-eq$before) 'look around cannot move Armand'
$base=[pscustomobject]@{Passed=$true;Lexical=$null;Structural=$null}
$badMove=Test-SliceNarrationGrounding $s $lookResult 'You step through the study door onto the upstairs landing.' $base
Assert (-not$badMove.Passed) 'unchanged location rejects false transition narration'

$misty=Intent $s 'misty step to the desk';$mistyResult=Resolve-SliceIntent $s (ConvertTo-EngineIntent $misty.Intent)
Assert ($misty.Intent.action-eq'cast'-and$misty.Intent.spell-eq'misty_step'-and$s.State.Player.Location-eq'callum_study') 'Misty Step stays within study'
Assert (-not(Test-SliceNarrationGrounding $s $mistyResult 'You step into the study beside the writing desk.' $base).Passed) 'Misty Step rejects room-entry narration'

$s.SafeDiscovered=$true
$generic=Intent $s 'try to open the safe';$genericResult=Resolve-SliceIntent $s (ConvertTo-EngineIntent $generic.Intent) -FixedRoll 20
Assert (-not$genericResult.Accepted-and-not$s.SafeOpen-and$generic.Intent.method-eq$null) 'generic safe attempt chooses no route and cannot open safe'
$crowbar=Intent $s 'use the crowbar to open the safe';$crowbarResult=Resolve-SliceIntent $s (ConvertTo-EngineIntent $crowbar.Intent) -FixedRoll 20
Assert ($crowbarResult.Accepted-and$s.SafeOpen-and$crowbar.Intent.method-match'crowbar') 'explicit crowbar route can open safe'
$noteBefore=$s.State.Items.burned_note.Location;$read=Intent $s 'read the note';$readResult=Resolve-SliceIntent $s (ConvertTo-EngineIntent $read.Intent)
Assert ($read.Intent.method-eq'read'-and$read.Intent.purpose-eq$null-and@($read.Intent.modifiers).Count-eq0-and$read.Intent.spell-eq$null-and$read.Intent.secondary_target-eq$null) 'new turn has clean optional intent fields'
Assert ($s.State.Items.burned_note.Location-eq$noteBefore-and$s.State.Items.burned_note.Owner-ne'Armand') 'reading does not move note'
Assert (-not(Test-SliceNarrationGrounding $s $readResult 'You read the note where it lies on the writing desk.' $base).Passed) 'narrator cannot relocate note to desk'
Assert (-not(Test-SliceNarrationGrounding $s $readResult 'You read the note using the crowbar.' $base).Passed) 'narrator cannot inherit crowbar'

$s2=New-CallumStudySession $root;$compound=Intent $s2 'look at the dark patterns on the ground and have guillermo look at the painting'
Assert ($compound.Status-eq'NEEDS_CLARIFICATION'-and$compound.CompoundDetected-and-not$s2.SafeDiscovered) 'true compound clarifies before either clause executes'
$pending=Intent $s2 'light a fire using your spells';Assert ($pending.Status-eq'NEEDS_CLARIFICATION'-and$pending.PendingEvent-eq'created') 'incomplete spell creates pending intent'
$complete=Intent $s2 'the fireplace';Assert ($complete.Status-eq'RESOLVED'-and$complete.Intent.action-eq'cast'-and$complete.Intent.target-eq'fireplace'-and$complete.Intent.spell-eq'fire_bolt'-and(@($complete.InheritedFromPending)-join',')-eq'target') 'fragment fills only pending target'
$query=Intent $s2 'is there a fire?';$qResult=Resolve-SliceIntent $s2 (ConvertTo-EngineIntent $query.Intent)
Assert ($query.Intent.action-eq'query_state'-and$qResult.Check-eq$null-and(@($qResult.Events)-join' ')-match'cold and unlit') 'world-state query is truthful, automatic, and roll-free'
$pending2=Intent $s2 'light a fire using your spells';$unrelated=Intent $s2 'look around the room';Assert ($unrelated.PendingEvent-eq'cleared_unrelated'-and$s2.PendingIntent-eq$null) 'unrelated full command clears pending intent'

$clean=Intent $s2 'look carefully at the desk';$next=Intent $s2 'read the correspondence'
Assert (@($clean.Intent.modifiers).Count-eq1-and@($next.Intent.modifiers).Count-eq0-and$next.Intent.purpose-eq$null-and$next.Intent.secondary_target-eq$null-and$next.Intent.spell-eq$null) 'modifiers, purpose, secondary target, and spell do not persist'
$godot=Get-Content -Raw (Join-Path $root 'godot/Main.gd');Assert ($godot-match'roll_value == null'-and$godot-match'narration_value == null') 'Godot omits null optional response values'

'Turn-state, routing, and continuity tests passed: exact transcript regressions plus turn-hygiene invariants.'
