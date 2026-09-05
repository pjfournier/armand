Set-StrictMode -Version Latest

function Resolve-InterpreterPath {param([string]$Value,[string]$Root)if([IO.Path]::IsPathRooted($Value)){[IO.Path]::GetFullPath($Value)}else{[IO.Path]::GetFullPath((Join-Path $Root $Value))}}
function New-InterpreterPrompt {
 param([string]$PlayerText,$Context)
 $summary=$Context|ConvertTo-Json -Depth 8 -Compress
 @"
PLAYER-VISIBLE CONTEXT
$summary

FIELD CONVENTIONS
action names the intended act. A closer look is examine, never take or move.
method contains only an explicitly stated tool or manner.
area contains only an explicitly stated spatial qualifier.
A named available spell uses action cast and the spell ID.

INPUT
Look beneath the writing desk.
OUTPUT
{"actor":"armand","action":"examine","target":"desk_01","method":null,"area":"underneath","communicative_intent":null,"spell":null}

INPUT
Have Guillermo steal the brass key.
OUTPUT
{"actor":"guillermo","action":"steal","target":"brass_key","method":null,"area":null,"communicative_intent":null,"spell":null}

INPUT
Tell the guard I'm with the constabulary.
OUTPUT
{"actor":"armand","action":"speak","target":"guard","method":null,"area":null,"communicative_intent":"claim affiliation with the constabulary","spell":null}

INPUT
Use Darkness to move through the hallway unseen.
OUTPUT
{"actor":"armand","action":"cast","target":"hallway","method":"move through unseen","area":"through","communicative_intent":null,"spell":"darkness"}

INPUT
Study the mantelpiece closely.
OUTPUT
{"actor":"armand","action":"examine","target":"mantel_02","method":null,"area":null,"communicative_intent":null,"spell":null}

INPUT
Have a careful look on top of the writing table.
OUTPUT
{"actor":"armand","action":"examine","target":"table_02","method":null,"area":"on_top","communicative_intent":null,"spell":null}

INPUT
Rummage inside the travel chest.
OUTPUT
{"actor":"armand","action":"search","target":"chest_02","method":null,"area":"inside","communicative_intent":null,"spell":null}

INPUT
Walk through the stone archway.
OUTPUT
{"actor":"armand","action":"move","target":"archway_02","method":null,"area":"through","communicative_intent":null,"spell":null}

INPUT
Apply my pry bar to the cellar door.
OUTPUT
{"actor":"armand","action":"use","target":"cellar_door_02","method":"pry bar","area":null,"communicative_intent":null,"spell":null}

INPUT
Send Guillermo behind the screen to inspect it.
OUTPUT
{"actor":"guillermo","action":"examine","target":"screen_02","method":null,"area":"behind","communicative_intent":null,"spell":null}

INPUT
Check the reliquary with Detect Magic.
OUTPUT
{"actor":"armand","action":"cast","target":"reliquary_02","method":null,"area":null,"communicative_intent":null,"spell":"detect_magic"}

INPUT
Step beyond the constable using Misty Step.
OUTPUT
{"actor":"armand","action":"cast","target":"corridor_02","method":"past the constable","area":"through","communicative_intent":null,"spell":"misty_step"}

INPUT
Tell the porter that Doctor Vale sent me.
OUTPUT
{"actor":"armand","action":"speak","target":"porter_02","method":null,"area":null,"communicative_intent":"claim Doctor Vale sent Armand","spell":null}

INPUT
$PlayerText
OUTPUT
"@
}
function Invoke-CommaIntentBackend {
 [CmdletBinding()]param([string]$PlayerText,$Context,$Schema,[string]$ConfigPath=(Join-Path (Split-Path -Parent $PSScriptRoot) 'interpreter_config.json'),[Nullable[int]]$Seed)
 $root=Split-Path -Parent $PSScriptRoot;$cfg=Get-Content -Raw $ConfigPath|ConvertFrom-Json;$runtime=Resolve-InterpreterPath $cfg.runtime_path $root;$model=Resolve-InterpreterPath $cfg.model_path $root
 if(-not(Test-Path $runtime)){throw "Interpreter runtime missing: $runtime"};if(-not(Test-Path $model)){throw "Interpreter model missing: $model"}
 $work=Join-Path $root 'eval/.work';New-Item -ItemType Directory -Force $work|Out-Null;$id=[guid]::NewGuid().ToString('N');$promptPath=Join-Path $work "intent_$id.txt";$schemaPath=Join-Path $work "intent_$id.schema.json"
 New-InterpreterPrompt $PlayerText $Context|Set-Content -NoNewline -Encoding utf8 $promptPath;$Schema|ConvertTo-Json -Depth 12 -Compress|Set-Content -NoNewline -Encoding utf8 $schemaPath
 $args=@('--model',$model,'--file',$promptPath,'--ctx-size',[string]$cfg.context_size,'--temp',([double]$cfg.temperature).ToString([Globalization.CultureInfo]::InvariantCulture),'--top-p',([double]$cfg.top_p).ToString([Globalization.CultureInfo]::InvariantCulture),'--top-k',[string]$cfg.top_k,'--repeat-penalty',([double]$cfg.repeat_penalty).ToString([Globalization.CultureInfo]::InvariantCulture),'--predict',[string]$cfg.max_tokens,'--seed',[string]$(if($null-ne$Seed){[int]$Seed}else{[int]$cfg.seed}),'--json-schema-file',$schemaPath,'--gpu-layers',[string]$cfg.gpu_layers,'--no-conversation','--no-display-prompt','--color','off','--simple-io','--perf','--fit','off')
 $psi=[Diagnostics.ProcessStartInfo]::new();$psi.FileName=$runtime;$psi.UseShellExecute=$false;$psi.CreateNoWindow=$true;$psi.RedirectStandardOutput=$true;$psi.RedirectStandardError=$true;foreach($a in $args){[void]$psi.ArgumentList.Add([string]$a)}
 $p=[Diagnostics.Process]::new();$p.StartInfo=$psi;$watch=[Diagnostics.Stopwatch]::StartNew();[void]$p.Start();$outTask=$p.StandardOutput.ReadToEndAsync();$errTask=$p.StandardError.ReadToEndAsync();$p.WaitForExit();$watch.Stop();$out=$outTask.Result.Trim();$err=$errTask.Result;$code=$p.ExitCode;$p.Dispose();if($code-ne0){throw "Intent generation failed ($code): $err"}
 $tps=$null;if($err-match'(?m)eval time\s*=.*?([0-9]+(?:\.[0-9]+)?) tokens per second'){$tps=[double]$Matches[1]}
 [pscustomobject]@{RawOutput=$out;ElapsedSeconds=$watch.Elapsed.TotalSeconds;TokensPerSecond=$tps;GpuActive=($err-match'(?im)offloaded\s+[1-9][0-9]*/\s*[0-9]+\s+layers?\s+to GPU');RuntimeLog=$err}
}

Export-ModuleMember -Function New-InterpreterPrompt,Invoke-CommaIntentBackend
