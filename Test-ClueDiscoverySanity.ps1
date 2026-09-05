$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/VerticalSlice.psm1') -Force -DisableNameChecking
function Assert($Condition,[string]$Message){if(-not$Condition){throw "FAILED: $Message"}}
function Intent([string]$Action,[string]$Target){[pscustomobject]@{Actor='Armand';Action=$Action;Target=$Target;SecondaryTarget=$null;Method=$null;Area=$null;CommunicativeIntent=$null;Spell=$null;Purpose=$null;Modifiers=@();RawInput='direct sanity test'}}

$blood=New-CallumStudySession $root
Resolve-SliceIntent $blood (Intent examine rug) 6|Out-Null
Assert ($blood.State.Notebook.Clues.bloodstain.known_facts.Count-eq1-and$blood.State.Notebook.Clues.bloodstain.known_facts[0]-match'dark discoloration') 'blood passive DC10 tier synchronizes alone'
Resolve-SliceIntent $blood (Intent investigate bloodstain) 11|Out-Null
Assert ($blood.State.Notebook.Clues.bloodstain.known_facts-match'dried blood') 'blood active Investigation 15'
Resolve-SliceIntent $blood (Intent investigate bloodstain) 16|Out-Null
Assert ($blood.State.Notebook.Clues.bloodstain.known_facts-match'too little blood'-and$blood.State.Notebook.Clues.bloodstain.known_facts-notmatch'injured person was moved') 'blood active Investigation 20 without unreached tier'

$desk=New-CallumStudySession $root
$deskResult=Resolve-SliceIntent $desk (Intent examine writing_desk) 11
Assert ($desk.State.Notebook.Clues.rope_fibers.known_facts-match'hemp cordage'-and$deskResult.Events-notmatch'nothing consequential') 'desk hook reaches fibers before mundane content'

$scorch=New-CallumStudySession $root
Resolve-SliceIntent $scorch (Intent examine fireplace) 6|Out-Null
Assert ($scorch.State.Notebook.Clues.scorch_marks.known_facts.Count-eq1-and$scorch.State.Notebook.Clues.scorch_marks.known_facts[0]-match'burn patterns') 'scorch passive base observation'
Resolve-SliceIntent $scorch (Intent investigate scorch_marks) 11|Out-Null
Assert ($scorch.State.Notebook.Clues.scorch_marks.known_facts-match'inconsistent with an ordinary fire') 'scorch active Occult tier'

$passive=New-CallumStudySession $root
$look=Invoke-SliceInterpretation $passive 'look at the rug';Resolve-SliceIntent $passive $look.Intent 6|Out-Null
Assert ($passive.State.Notebook.Clues.Contains('bloodstain')) 'vertical-slice attention path fires passive discovery'
Write-Host 'Clue discovery sanity tests passed: blood tiers, desk fibers, scorch tiers, Notebook synchronization, and passive paths.'
