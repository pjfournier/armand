$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/VerticalSlice.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $root 'src/Clues.psm1') -Force
function Assert($Condition,[string]$Message){if(-not$Condition){throw "FAILED: $Message"}}
function Intent([string]$Action,[string]$Target,[string]$Method=$null){[pscustomobject]@{Actor='Armand';Action=$Action;Target=$Target;SecondaryTarget=$null;Method=$Method;Area=$null;CommunicativeIntent=$null;Spell=$null;Purpose=$null;Modifiers=@();RawInput='direct sanity test'}}

$blood=New-CallumStudySession $root
Resolve-SliceIntent $blood (Intent examine rug) 6|Out-Null
Assert ($blood.State.Notebook.Clues.bloodstain.known_facts.Count-eq1-and$blood.State.Notebook.Clues.bloodstain.known_facts[0]-match'dried blood') 'blood passive DC10 tier synchronizes alone'
Resolve-SliceIntent $blood (Intent investigate bloodstain) 16|Out-Null
Assert ($blood.State.Notebook.Clues.bloodstain.known_facts-match'too little blood') 'blood active Investigation 20'
Resolve-ClueInterpretation $blood.State bloodstain Investigation 25|Out-Null
Assert ($blood.State.Notebook.Clues.bloodstain.known_facts-match'injured person was moved') 'blood higher-tier Investigation 25 after changed approach'

$desk=New-CallumStudySession $root
$deskResult=Resolve-SliceIntent $desk (Intent examine writing_desk) 1
Assert ($desk.State.Notebook.Clues.rope_fibers.known_facts-match'hemp cordage'-and$deskResult.Events-notmatch'nothing consequential') 'desk hook reaches fibers before mundane content'

$scorch=New-CallumStudySession $root
Resolve-SliceIntent $scorch (Intent examine fireplace) 6|Out-Null
Assert ($scorch.State.Notebook.Clues.scorch_marks.known_facts.Count-eq1-and$scorch.State.Notebook.Clues.scorch_marks.known_facts[0]-match'inconsistent with an ordinary fire') 'scorch passive base observation'
Resolve-SliceIntent $scorch (Intent investigate scorch_marks) 17|Out-Null
Assert ($scorch.State.Notebook.Clues.scorch_marks.known_facts-match'magical or occult energy') 'scorch active Occult tier'

$passive=New-CallumStudySession $root
$look=Invoke-SliceInterpretation $passive 'look at the rug';Resolve-SliceIntent $passive $look.Intent 6|Out-Null
Assert ($passive.State.Notebook.Clues.Contains('bloodstain')) 'vertical-slice attention path fires passive discovery'
Write-Host 'Clue discovery sanity tests passed: blood tiers, desk fibers, scorch tiers, Notebook synchronization, and passive paths.'
