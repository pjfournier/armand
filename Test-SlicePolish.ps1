$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/VerticalSlice.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $root 'src/IntentSchema.psm1') -Force
function Assert($Condition,[string]$Message){if(-not$Condition){throw "FAILED: $Message"}}
$modelBackend={param($text,$context,$schema,$seed)$target=if($text-match'(?i)painting'){'large_painting'}elseif($text-match'(?i)desk'){'writing_desk'}else{$null};[pscustomobject]@{RawOutput=([ordered]@{actor='armand';action='examine';target=$target;method=$null;area=$null;communicative_intent=$null;spell=$null}|ConvertTo-Json -Compress);ElapsedSeconds=.001}}
function Interpret($Session,[string]$Text){Invoke-SliceInterpretation $Session $Text $modelBackend}
$s=New-CallumStudySession $root
$floor=Interpret $s 'look down at the floor';Assert ($floor.Status-eq'RESOLVED'-and$floor.Intent.target-eq'rug'-and$floor.Intent.action-eq'examine') 'real transcript: floor maps to rug examination'
$rug=Interpret $s 'move the rug to examine beneath';Assert ($rug.Status-eq'RESOLVED'-and$rug.Intent.action-eq'manipulate'-and$rug.Intent.target-eq'rug') 'real transcript: rug movement is manipulation'
$rugResult=Resolve-SliceIntent $s (ConvertTo-EngineIntent $rug.Intent);Assert ($rugResult.Accepted-and$rugResult.Classification-eq'MEANINGFUL'-and$s.State.Notebook.Clues.Contains('bloodstain')) 'rug manipulation resolves clue before mundane texture'
$mist=Interpret $s 'misty step to the desk';Assert ($mist.Status-eq'RESOLVED'-and$mist.Intent.action-eq'cast'-and$mist.Intent.spell-eq'misty_step'-and$mist.Intent.target-eq'writing_desk') 'real transcript: spell-first Misty Step routing'
$mistResult=Resolve-SliceIntent $s (ConvertTo-EngineIntent $mist.Intent);Assert ($mistResult.Accepted-and$mistResult.Events-match'reappears beside the writing desk') 'Misty Step reaches valid visible destination'
$desk=Interpret $s 'look at the desk';Assert ($desk.Status-eq'RESOLVED'-and$desk.Intent.target-eq'writing_desk') 'real transcript: desk target preserved'
$deskResult=Resolve-SliceIntent $s (ConvertTo-EngineIntent $desk.Intent);Assert ($deskResult.Events-notmatch'nothing consequential'-and$s.State.Notebook.Clues.Contains('rope_fibers')) 'desk clue outranks mundane result'
$correspondence=Interpret $s 'read correspondence';$correspondenceResult=Resolve-SliceIntent $s (ConvertTo-EngineIntent $correspondence.Intent);Assert ($correspondenceResult.Accepted-and$correspondenceResult.Classification-eq'MUNDANE'-and$correspondenceResult.Handoff.MundaneResult-match'academic dinner') 'real transcript: correspondence has authored mundane content'
$painting=Interpret $s 'look at the painting';$paintingResult=Resolve-SliceIntent $s (ConvertTo-EngineIntent $painting.Intent);Assert ($paintingResult.Accepted-and$paintingResult.Events-match'safe'-and$paintingResult.Events-notmatch'blood|fiber') 'real transcript: painting responds to painting only'
Assert (($paintingResult.Handoff.KnownContext-join' ')-notmatch'blood|fiber') 'same-location relevance disabled for slice'
$mundaneCases=@(
 @{text='knock on the wall';target='paneled_wall';marker='solid, ordinary knock'},
 @{text='smell the rug';target='rug';marker='dust, damp'},
 @{text='look under the desk';target='writing_desk';marker='Dust softens'},
 @{text='inspect the window latch';target='window_latch';marker='cold, intact'},
 @{text='touch the hearth';target='fireplace';marker='cold and lightly gritty'},
 @{text='read a receipt';target='receipt';marker='two bottles of ink'},
 @{text='ask Guillermo what he thinks';target='guillermo';marker='noncommittal shrug'},
 @{text='stare at the bookshelf';target='bookshelves';marker='endure the scrutiny'}
)
foreach($case in $mundaneCases){$i=Interpret $s $case.text;$r=Resolve-SliceIntent $s (ConvertTo-EngineIntent $i.Intent);Assert ($i.Status-eq'RESOLVED'-and$i.Intent.target-eq$case.target) "mundane target: $($case.text)";Assert ($r.Accepted-and$r.Classification-eq'MUNDANE'-and$r.Events-match[regex]::Escape($case.marker)-and$r.Handoff.Tone-in@('dry_humor_allowed','guillermo_comic')) "mundane world response: $($case.text)"}
$firstUnder=Resolve-SliceIntent $s (ConvertTo-EngineIntent (Interpret $s 'look under the desk').Intent);$secondUnder=Resolve-SliceIntent $s (ConvertTo-EngineIntent (Interpret $s 'look under the desk').Intent);Assert ($firstUnder.Accepted-and$secondUnder.Accepted-and$secondUnder.Classification-eq'MUNDANE') 'repeat empty inspection remains valid'
$beforeClues=$s.State.Notebook.Clues.Count;Resolve-SliceIntent $s (ConvertTo-EngineIntent (Interpret $s 'read a receipt').Intent)|Out-Null;Assert ($s.State.Notebook.Clues.Count-eq$beforeClues) 'mundane actions do not invent clues'
$packet=$paintingResult.Handoff;Assert ($packet.NewThisTurn-match'safe'-and$packet.PSObject.Properties.Name-contains'KnownContext') 'NEW_THIS_TURN and KNOWN_CONTEXT separated'
$base=[pscustomobject]@{Passed=$true;Lexical=$null;Structural=$null};$unsupported=Test-SliceNarrationGrounding $s $paintingResult 'You find a silver knife beneath the painting.' $base;Assert (-not$unsupported.Passed-and$unsupported.GroundingErrors-match'unsupported physical affordance') 'physical affordance validator rejects invented knife'
$inventedPerson=Test-SliceNarrationGrounding $s $correspondenceResult "You find proof that a woman was Callum's wife." $base;Assert (-not$inventedPerson.Passed-and$inventedPerson.GroundingErrors-match'unsupported consequential detail') 'grounding validator rejects exemplar bleed-through'
$repeatKnown=$paintingResult.Handoff.PSObject.Copy();$repeatKnown.KnownContext=@('KNOWN FACT [clue:bloodstain]: The discoloration is dried blood.');$repeatKnown.NewThisTurn=@('The safe is revealed.');$repeatResolution=[pscustomobject]@{Handoff=$repeatKnown;Events=@('The safe is revealed.')};$restate=Test-SliceNarrationGrounding $s $repeatResolution 'You reveal the safe. The stain is dried blood.' $base;Assert (-not$restate.Passed-and$restate.GroundingErrors-match'known context') 'known context is not automatically restated'
$exemplars=Get-Content -Raw (Join-Path $root 'exemplars/slice_polish_exemplars.json')|ConvertFrom-Json;Assert (@($exemplars|ForEach-Object{$_}).Count-eq4) 'four focused polish exemplars'
Write-Host 'Slice polish tests passed: six real transcript regressions, eight mundane actions, packet separation, routing, humor, and affordance safety.'
