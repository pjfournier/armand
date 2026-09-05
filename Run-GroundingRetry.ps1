[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('stageA','stageB','regression')][string]$Suite,
    [ValidateSet('R1','R2')][string[]]$Condition = @('R1','R2'),
    [ValidateSet(0.15,0.20)][double]$Temperature = 0.15,
    [switch]$Force
)
$ErrorActionPreference='Stop';$root=$PSScriptRoot
Import-Module (Join-Path $root 'src/CommaHarness.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationPrompt.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationPacket.psm1') -Force
Import-Module (Join-Path $root 'src/NarrationValidation.psm1') -Force
$base=Get-Content -Raw (Join-Path $root 'config.json')|ConvertFrom-Json
$original=@(Read-NarrationExemplars (Join-Path $root 'exemplars/narration_exemplars.json') -ExpectedCount 8)
$targeted=@(Read-NarrationExemplars (Join-Path $root 'exemplars/grounding_retry_exemplars.json') -ExpectedCount 3)
$exemplars=@($original)+@($targeted)
$work=Join-Path $root 'eval/.work';New-Item -ItemType Directory -Force $work|Out-Null
if($Suite-eq'stageA'){$cases=@(Get-Content -Raw (Join-Path $root 'eval/grounding_retry_stageA_cases.json')|ConvertFrom-Json);$runs=@($Condition|%{[pscustomobject]@{name=$_;temp=$(if($_-eq'R1'){0.15}else{0.20})}})}
elseif($Suite-eq'stageB'){$cases=@(Get-Content -Raw (Join-Path $root 'eval/grounding_retry_stageB_cases.json')|ConvertFrom-Json);$runs=@([pscustomobject]@{name='selected';temp=$Temperature})}
else{$cases=@(Get-Content -Raw (Join-Path $root 'eval/baseline_50.json')|ConvertFrom-Json);$runs=@([pscustomobject]@{name='selected';temp=$Temperature})}
foreach($run in $runs){
 $log=Join-Path $root "eval/grounding_retry_${Suite}_$($run.name)_raw.jsonl";if($Force-and(Test-Path $log)){Remove-Item -LiteralPath $log}
 $done=@{};if(Test-Path $log){Get-Content $log|%{if($_){$x=$_|ConvertFrom-Json;$done[[string]$x.case_id]=$true}}}
 $cfg=$base.PSObject.Copy();$cfg.temperature=$run.temp;$cfg.max_tokens=224;$cfg.stop_sequence="`nFACTS"
 $cfgPath=Join-Path $work "retry_${Suite}_$($run.name).json";$cfg|ConvertTo-Json -Depth 8|Set-Content -Encoding utf8 $cfgPath
 foreach($case in $cases){
  if($done.ContainsKey([string]$case.id)){continue};Write-Host "RUN $Suite/$($run.name)/$($case.id)"
  $packet=ConvertTo-NarrationPacket $case;$prompt=Build-NarrationPrompt -Packet $packet -Format facts -Exemplars $exemplars
  $promptPath=Join-Path $work "retry_$($run.name)_$($case.id).txt";$prompt|Set-Content -NoNewline -Encoding utf8 $promptPath
  $result=Invoke-CommaGeneration -PromptPath $promptPath -ConfigPath $cfgPath -Seed ([int]$case.seed) -Temperature $run.temp -MaxTokens 224
  $trimmed=$result.Text-replace'(?s)\s*FACTS\s*$','';$narration='You '+$trimmed.TrimStart()
  $validation=Test-NarrationOutput -Text $narration -ForbiddenTerms @($case.forbidden_terms) -MaxWords 180 -Actor ([string]$case.actor)
  [ordered]@{suite=$Suite;condition=$run.name;temperature=$run.temp;case_id=$case.id;category=$case.category;seed=[int]$case.seed;input_packet=$packet;exemplar_count=11;packet_format='facts';raw_completion=$result.Text;trimmed_completion=$trimmed;assembled_narration=$narration;validated_output=$validation.ValidatedOutput;validator_passed=$validation.Passed;lexical=$validation.Lexical;structural=$validation.Structural;generated_tokens=$result.TokenCount;elapsed_seconds=[math]::Round($result.ElapsedSeconds,3);tokens_per_second=$result.TokensPerSecond;gpu_active=$result.GpuActive;settings=$result.Settings}|ConvertTo-Json -Depth 14 -Compress|Add-Content -Encoding utf8 $log
 }
}
Write-Host "Completed $Suite."
