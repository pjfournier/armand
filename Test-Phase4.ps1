$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/GameState.psm1') -Force
Import-Module (Join-Path $root 'src/InterpreterContext.psm1') -Force
Import-Module (Join-Path $root 'src/IntentSchema.psm1') -Force
Import-Module (Join-Path $root 'src/IntentInterpreter.psm1') -Force
Import-Module (Join-Path $root 'src/IntentSchema.psm1') -Force
function Assert($Condition,[string]$Message){if(-not$Condition){throw "FAILED: $Message"}}
function New-FixtureState([switch]$DuplicateDesk){
 $s=New-GameState;Add-LocationState -State $s -Id study -VisibleObjects @('desk_01','cabinet_01','window_01','brass_key','locked_door','fireplace_01','vault_01') -Exits @('hallway') -DisplayName 'Victorian study';Add-LocationState -State $s -Id hallway -VisibleObjects @() -Exits @('study') -DisplayName 'hallway'
 Add-ItemState -State $s -Id desk_01 -Location study -Owner $null -DisplayName 'writing desk' -Aliases @('desk','writing desk') -InteractableParts @('underneath','inside','on_top')
 Add-ItemState -State $s -Id cabinet_01 -Location study -Owner $null -DisplayName 'cabinet' -Aliases @('cabinet') -InteractableParts @('inside','behind','on_top')
 Add-ItemState -State $s -Id window_01 -Location study -Owner $null -DisplayName 'window' -Aliases @('window')
 Add-ItemState -State $s -Id brass_key -Location study -Owner $null -DisplayName 'brass key' -Aliases @('key','brass key')
 Add-ItemState -State $s -Id locked_door -Location study -Owner $null -DisplayName 'locked door' -Aliases @('door','locked door')
 Add-ItemState -State $s -Id fireplace_01 -Location study -Owner $null -DisplayName 'fireplace' -Aliases @('fireplace','grate')
 Add-ItemState -State $s -Id vault_01 -Location study -Owner $null -DisplayName 'locked vault' -Aliases @('vault','locked vault')
 Add-ItemState -State $s -Id crowbar -Location inventory -Owner Armand -DisplayName 'crowbar' -Aliases @('crowbar')
 Add-ItemState -State $s -Id secret_weapon -Location study -Owner $null -DisplayName 'murder weapon' -Aliases @('weapon')
 Add-NpcState -State $s -Id guard -Location study -DisplayName 'guard' -Aliases @('guard','constable') -KnowledgeReferences @('case_truth_secret')
 Add-NpcState -State $s -Id hidden_lord -Location cellar -DisplayName 'Lord Blackwood' -Aliases @('lord')
 $s.Clues['hidden_clue']=[pscustomobject]@{Id='hidden_clue';Discovered=$false;Fact='secret drawer'};$s.Objectives['hidden_objective']=[pscustomobject]@{Id='hidden_objective';Status='secret'}
 if($DuplicateDesk){$s.Locations.study.VisibleObjects+=@('desk_02');Add-ItemState -State $s -Id desk_02 -Location study -Owner $null -DisplayName 'oak desk' -Aliases @('desk','oak desk')}
 $s.Player.Location='study';$s.Guillermo.Location='study';$s
}
$cases=@(Get-Content -Raw (Join-Path $root 'tests/gate2_cases.json')|ConvertFrom-Json)
$backend={param($text,$context,$schema,$seed)$intent=if($null-ne$script:currentExpected){$script:currentExpected}else{[pscustomobject]@{actor='armand';action='examine';target=$null;method=$null;area=$null;communicative_intent=$null;spell=$null}};[pscustomobject]@{RawOutput=($intent|ConvertTo-Json -Compress);ElapsedSeconds=.001;TokensPerSecond=$null;GpuActive=$false}}
$results=@()
foreach($c in $cases){$script:currentExpected=$c.intent;$state=New-FixtureState -DuplicateDesk:($c.context-eq'duplicate_desks');$recent=switch($c.context){'single_recent'{@('desk_01')};'ambiguous_recent'{@('desk_01','cabinet_01')};default{@()}};$ctx=New-InterpretationContext $state $recent;$r=Invoke-IntentInterpretation $c.input $ctx $backend;$correct=$r.Status-eq$c.status;if($correct-and$c.status-eq'RESOLVED'){foreach($name in @('actor','action','target','method','area','communicative_intent','spell')){if($r.Intent.$name-ne$c.intent.$name){$correct=$false}}};Assert $correct "Gate fixture $($c.id): expected $($c.status)/$($c.intent|ConvertTo-Json -Compress), got $($r.Status)/$($r.Intent|ConvertTo-Json -Compress); reason=$($r.Reason)";$results+=$r}
Assert ($cases.Count-eq30) 'Gate 2 fixture count'
$a=$results[2].Intent;$b=$results[3].Intent;foreach($name in @('actor','action','target','method','area','communicative_intent','spell')){Assert ($a.$name-eq$b.$name) 'canonical desk paraphrases normalize identically'}
$securityState=New-FixtureState;$security=New-InterpretationContext $securityState;$securityJson=$security|ConvertTo-Json -Depth 12
foreach($term in @('secret_weapon','hidden_lord','hidden_clue','hidden_objective','case_truth_secret','Investigation','Nerve','Darkvision')){Assert ($securityJson-notmatch[regex]::Escape($term)) "hidden state excluded: $term"}
$schema=New-IntentJsonSchema $security;$schemaJson=$schema|ConvertTo-Json -Depth 12;Assert ($schemaJson-notmatch'secret_weapon|hidden_lord|dc|roll|degree') 'dynamic schema excludes hidden targets and outcomes'
$resolved=$results[20];$rejected=Set-EngineInterpretationDecision $resolved $false 'The vault cannot be opened by that method.';Assert ($rejected.Status-eq'ENGINE_REJECTED'-and$rejected.Intent.action-eq'open') 'engine rejection remains distinct'
$guillermo=$results[10].Intent;$gj=$guillermo|ConvertTo-Json;Assert ($gj-notmatch'refuse|success|failure|skill|dc|roll') 'Guillermo outcome remains engine-side'
$social=$results[14].Intent;Assert ($social.communicative_intent-eq'claim affiliation with the constabulary'-and($social.PSObject.Properties.Name-notcontains'skill')) 'social intent preserved without skill choice'
$log=Join-Path $root 'eval/.work/phase4_test_log.jsonl';if(Test-Path $log){Remove-Item $log};Invoke-IntentInterpretation 'Examine the desk.' $security $backend $log|Out-Null;$logged=Get-Content $log|ConvertFrom-Json;Assert (($logged|ConvertTo-Json -Depth 12)-notmatch'secret_weapon|hidden_lord|case_truth_secret') 'debug log excludes hidden state'
$badBackend={param($text,$context,$schema,$seed)[pscustomobject]@{RawOutput='{"actor":"armand","action":"examine","target":"desk_01","method":null,"area":null,"communicative_intent":null,"spell":null,"dc":5,"result":"success"}';ElapsedSeconds=.001}}
$bad=Invoke-IntentInterpretation 'Examine the desk.' $security $badBackend;Assert ($bad.Status-eq'UNRECOGNIZED') 'resolution fields from backend are rejected'
$config=Get-Content -Raw (Join-Path $root 'interpreter_config.json')|ConvertFrom-Json;foreach($field in @('runtime_path','model_path','context_size','temperature','top_p','top_k','seed','max_tokens','structured_output','debug_logging')){Assert ($null-ne$config.PSObject.Properties[$field]) "interpreter config field $field"}
Import-Module (Join-Path $root 'src/CoreEngine.psm1') -Force
$engineIntent=ConvertTo-EngineIntent $results[10].Intent
$integration=Resolve-StructuredIntent -State $securityState -Intent $engineIntent -Skill Finesse -DC 15 -FixedRoll 4 -Mutations @([pscustomobject]@{type='transfer_item';item_id='brass_key';to='Guillermo';apply_on=@('Success','Exceptional Success')}) -PostActionState ([pscustomobject]@{brass_key_location='study';Guillermo_has_key=$false}) -Events @('brass key rattles','Guillermo retreats') -Visible @('brass key')
Assert ($integration.Resolution.Degree-eq'Failure'-and$securityState.Items.brass_key.Owner-ne'Guillermo') 'natural language integration leaves key after failed theft'
Assert (($integration.Handoff|ConvertTo-Json -Depth 10)-notmatch'Guillermo steals') 'integrated failed theft keeps attempt separate from completion'
Write-Host 'Phase 4 tests passed: 30/30 deterministic semantic fixtures plus authority and logging checks.'
