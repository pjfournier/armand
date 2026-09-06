$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/VerticalSlice.psm1') -Force -DisableNameChecking
function Assert($Condition,[string]$Message){if(-not$Condition){throw "FAILED: $Message"}}
function Intent([string]$Action,[string]$Target,[string]$Method=$null,[string]$Spell=$null,[string]$Purpose=$null,[string]$Actor='Armand'){[pscustomobject]@{Actor=$Actor;Action=$Action;Target=$Target;SecondaryTarget=$null;Method=$Method;Area=$null;CommunicativeIntent=$null;Spell=$Spell;Purpose=$Purpose;Modifiers=@();RawInput='playability test'}}

$overview=New-CallumStudySession $root;$overviewResult=Resolve-SliceIntent $overview (Intent examine study_room);$overviewText=$overviewResult.Events-join' '
Assert ($overviewText-match'dark discoloration|dark patterns'-and$overviewText-notmatch'dried blood|hemp cordage|magical|occult|ordinary fire') '1-4 overview tempts with authored anomalies but no interpretation'
Assert ($overviewResult.Check-eq$null-and$overview.State.Notebook.Clues.Count-eq0) 'overview is free and does not populate interpreted clues'
$focus=Resolve-SliceIntent $overview (Intent examine bloodstain) 1;Assert ($focus.Events-match'dried blood'-and$focus.Check-eq$null) '5-6 focused passive observation reveals first tier without roll indicator'

$mist=New-CallumStudySession $root;$mistIntent=Invoke-SliceInterpretation $mist 'misty step to the desk';$mistResult=Resolve-SliceIntent $mist $mistIntent.Intent;Assert ($mistIntent.Intent.action-eq'cast'-and$mistIntent.Intent.spell-eq'misty_step'-and$mistResult.Accepted) '7 live Misty Step route matches semantic intent'

foreach($invalid in @(@('examine','writing_desk'),@('read','receipt'),@('examine','rug'),@('examine','fireplace'))){$s=New-CallumStudySession $root;Resolve-SliceIntent $s (Intent $invalid[0] $invalid[1])|Out-Null;Assert (-not$s.SafeDiscovered) "8 invalid safe trigger: $($invalid-join'/')"}
$painting=New-CallumStudySession $root;Resolve-SliceIntent $painting (Intent examine large_painting)|Out-Null;Assert ($painting.SafeDiscovered) '9a painting reveals safe'
$wall=New-CallumStudySession $root;Resolve-SliceIntent $wall (Intent examine paneled_wall)|Out-Null;Assert ($wall.SafeDiscovered) '9b authored wall route reveals safe'
$guillermo=New-CallumStudySession $root;Resolve-SliceIntent $guillermo (Intent examine large_painting $null $null $null Guillermo) 12|Out-Null;Assert ($guillermo.SafeDiscovered) '9c Guillermo painting route reveals safe'

$blast=New-CallumStudySession $root;$before=[pscustomobject]@{safe=$blast.SafeDiscovered;open=$blast.SafeOpen;lead=$blast.LeadRecovered;clues=$blast.State.Notebook.Clues.Count};$blastResult=Resolve-SliceIntent $blast (Intent cast paneled_wall $null eldritch_blast);Assert ($blastResult.Accepted-and$blastResult.Classification-eq'MUNDANE'-and$blastResult.Events-match'paneling shudders'-and$blastResult.Events-notmatch'clue|safe|compartment') '10 bounded Eldritch Blast world response';Assert ($blast.SafeDiscovered-eq$before.safe-and$blast.SafeOpen-eq$before.open-and$blast.LeadRecovered-eq$before.lead-and$blast.State.Notebook.Clues.Count-eq$before.clues) '11 unsupported force cannot mutate consequential state'

$known=New-CallumStudySession $root;Resolve-SliceIntent $known (Intent examine rug)|Out-Null;$unrelated=Resolve-SliceIntent $known (Intent examine large_painting);Assert (($unrelated.Handoff.KnownContext-join' ')-notmatch'blood') '12 unrelated turn excludes same-room known fact'

$success=New-CallumStudySession $root;Resolve-SliceIntent $success (Intent examine rug)|Out-Null;$successResult=Resolve-SliceIntent $success (Intent investigate bloodstain) 16;Assert ((Format-SliceRollFeedback $successResult.Check standard)-eq'🎲 Investigation • Success') '13 active success indicator'
$failure=New-CallumStudySession $root;Resolve-SliceIntent $failure (Intent examine rug)|Out-Null;$failureResult=Resolve-SliceIntent $failure (Intent investigate bloodstain) 11;Assert ((Format-SliceRollFeedback $failureResult.Check standard)-eq'🎲 Investigation • Failure') '14 active failure indicator'
$setback=New-CallumStudySession $root;Resolve-SliceIntent $setback (Intent examine rug)|Out-Null;$setbackResult=Resolve-SliceIntent $setback (Intent investigate bloodstain) 12;Assert ((Format-SliceRollFeedback $setbackResult.Check standard)-eq'🎲 Investigation • Setback') '15 setback indicator preserved'
Assert ((Format-SliceRollFeedback $focus.Check standard)-eq$null) '16 passive success has no indicator'
$mundane=Resolve-SliceIntent (New-CallumStudySession $root) (Intent read receipt);Assert ((Format-SliceRollFeedback $mundane.Check standard)-eq$null) '17 mundane action has no indicator'
$clarifySession=New-CallumStudySession $root;Resolve-SliceIntent $clarifySession (Intent examine study_room)|Out-Null;$clarification=Invoke-SliceInterpretation $clarifySession 'look at the dark marks';Assert ($clarification.Status-eq'NEEDS_CLARIFICATION') '18 parser clarification is distinct and has no roll'

$repeat=New-CallumStudySession $root;Resolve-SliceIntent $repeat (Intent examine fireplace)|Out-Null;$first=Resolve-SliceIntent $repeat (Intent investigate scorch_marks) 1;$second=Resolve-SliceIntent $repeat (Intent investigate scorch_marks) 20;Assert ($first.Check-and$null-eq$second.Check-and$second.Events-match'nothing further') '19 identical failed approach does not reroll'
$changed=Resolve-SliceIntent $repeat (Intent investigate scorch_marks 'compare with Notebook') 16;Assert ($changed.Check-and(Format-SliceRollFeedback $changed.Check standard)) '20 changed method permits a new roll'

$base=[pscustomobject]@{Passed=$true;Lexical=[pscustomobject]@{Passed=$true;Hits=@()};Structural=[pscustomobject]@{Passed=$true;AgencyRiskHits=@();FirstPersonHits=@();DatasetFormHits=@();ExcessiveLength=$false;HasSecondPerson=$true;ThirdPersonActorDrift=$false}};$unsupported=Test-SliceNarrationGrounding $overview $overviewResult 'You find a locked cabinet beside the rug.' $base;Assert (-not$unsupported.Passed-and$unsupported.GroundingErrors-match'unsupported physical affordance') '21 unsupported actionable noun caught'
$allowed=Test-SliceNarrationGrounding $overview $overviewResult 'You inspect the dark discoloration beside the rug.' $base;Assert ($allowed.Passed) '22 engine-authorized sub-referent allowed'
$receiptIntent=Invoke-SliceInterpretation $overview 'read the receipts';Assert ($receiptIntent.Intent.target-eq'receipt') '23 receipts remain targetable'
Resolve-SliceIntent $overview (Intent examine bookshelves)|Out-Null;$gapIntent=Invoke-SliceInterpretation $overview 'inspect the gap';Assert ($gapIntent.Intent.target-eq'bookshelf_gap') '24 bookshelf gap remains targetable after exposure'
$premature=Test-SliceNarrationGrounding $overview $overviewResult 'You see dried blood and evidence of magical discharge.' $base;Assert (-not$premature.Passed-and$premature.GroundingErrors-match'prematurely interprets') 'overview validator catches premature interpretation'
$examples=Get-Content -Raw (Join-Path $root 'exemplars/playability_polish_exemplars.json')|ConvertFrom-Json;Assert (@($examples).Count-eq7) 'seven focused exemplars cover the six required categories plus movement grounding'
Write-Host 'Narration/playability polish tests passed: 24 required behaviors plus overview and exemplar grounding checks.'
