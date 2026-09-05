$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/CoreEngine.psm1') -Force
Import-Module (Join-Path $root 'src/GameState.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationPrompt.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationPacket.psm1') -Force
Import-Module (Join-Path $root 'src/NarratorHandoff.psm1') -Force
Import-Module (Join-Path $root 'src/CommaHarness.psm1') -Force
$examples=@(Read-NarrationExemplars (Join-Path $root 'exemplars/narration_exemplars.json') -ExpectedCount 8)+@(Read-NarrationExemplars (Join-Path $root 'exemplars/grounding_retry_exemplars.json') -ExpectedCount 3)
$state=New-GameState;Add-LocationState $state study @('fireplace','extinguished grate','open window') @('hall');Add-LocationState $state cellar @('brick arch','standing water','chalk mark','brass key on hook') @('stairs');Add-ItemState $state brass_key hook $null @{state='on hook'} @('key')
$armandIntent=[pscustomobject]@{Actor='Armand';Action='investigate';Target='fireplace';Method=$null;Area=$null}
$armand=Resolve-StructuredIntent -State $state -Intent $armandIntent -Mode active -Skill Investigation -DC 15 -FixedRoll 13 -PostActionState ([pscustomobject]@{scorch_marks_observed=$true}) -Events @('scorch marks are discovered') -Visible @('fireplace','extinguished grate','open window')
$guillermoIntent=[pscustomobject]@{Actor='Guillermo';Action='steal';Target='brass key from the hook';Method=$null;Area=$null}
$guillermo=Resolve-StructuredIntent -State $state -Intent $guillermoIntent -Mode active -Skill Finesse -DC 15 -FixedRoll 4 -PostActionState ([pscustomobject]@{brass_key_location=$state.Items.brass_key.Location;Guillermo_has_key=$state.Guillermo.Inventory.Contains('brass_key')}) -Events @('brass key rattles','Guillermo retreats') -Visible @('brick arch','standing water','chalk mark','brass key on hook')
if(($guillermo.Handoff|ConvertTo-Json -Depth 10)-match'Guillermo steals'){throw 'Unsafe completed-action wording reached handoff.'}
$cfg=Get-Content -Raw (Join-Path $root 'config.json')|ConvertFrom-Json;$cfg.temperature=.15;$cfg.max_tokens=224;$cfg.stop_sequence="`nFACTS";$work=Join-Path $root 'eval/.work';New-Item -ItemType Directory -Force $work|Out-Null;$cfgPath=Join-Path $work 'phase3_e2e_config.json';$cfg|ConvertTo-Json -Depth 8|Set-Content -Encoding utf8 $cfgPath
$runs=@([pscustomobject]@{id='armand-investigation';location='study';engine=$armand},[pscustomobject]@{id='guillermo-failed-steal';location='cellar';engine=$guillermo});$results=@()
foreach($run in $runs){$case=Convert-HandoffToNarrationCase $run.engine.Handoff $run.location midnight rain;$packet=ConvertTo-NarrationPacket $case;$prompt=Build-NarrationPrompt $packet facts $examples;$promptPath=Join-Path $work "$($run.id).txt";$prompt|Set-Content -NoNewline -Encoding utf8 $promptPath;$generation=Invoke-CommaGeneration $promptPath $cfgPath -Seed $(if($run.id-eq'armand-investigation'){7301}else{7302}) -Temperature .15 -MaxTokens 224;$raw=$generation.Text;$narration='You '+(($raw-replace'(?s)\s*FACTS\s*$','').TrimStart());$results+=[pscustomobject]@{id=$run.id;intent=$run.engine.Intent;resolution=$run.engine.Resolution;handoff=$run.engine.Handoff;raw_completion=$raw;narration=$narration;elapsed_seconds=[math]::Round($generation.ElapsedSeconds,3);tokens_per_second=$generation.TokensPerSecond;gpu_active=$generation.GpuActive}}
$results|ConvertTo-Json -Depth 14|Set-Content -Encoding utf8 (Join-Path $root 'eval/phase3_end_to_end_results.json')
$results|ForEach-Object{Write-Host "[$($_.id)] $($_.resolution.Degree): $($_.narration)"}
