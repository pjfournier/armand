Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot 'IntentSchema.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'InterpreterModel.psm1') -Force

function Get-ActionCueCount {
 param([string]$PlayerText)
 $cues=@('look','inspect','examine','check','search','move','go','cross','take','grab','pick up','use','cast','tell','say','speak','ask','wait','open','unlock','climb','steal','send','have')
 @($cues|Where-Object{$PlayerText-match("(?i)\b"+[regex]::Escape($_)+"\b")}).Count
}
function Test-CompoundInput {
 param([string]$PlayerText)
 if($PlayerText-match'(?i)\b(and then|then|after that)\b'){return $true}
 ($PlayerText-match'(?i)\band\b'-and(Get-ActionCueCount $PlayerText)-ge2-and$PlayerText-notmatch'(?i)\b(?:get down and (?:check|look|search)|try and)\b')
}
function Find-AliasAmbiguity {
 param([string]$PlayerText,$Context)
 $groups=@{}
 foreach($e in $Context.Entities){foreach($alias in @($e.Aliases)+@($e.DisplayName)){if([string]::IsNullOrWhiteSpace($alias)){continue};$key=$alias.ToLowerInvariant();if(-not$groups.ContainsKey($key)){$groups[$key]=[Collections.Generic.List[string]]::new()};if(-not$groups[$key].Contains($e.Id)){$groups[$key].Add($e.Id)}}}
 foreach($key in $groups.Keys){if($groups[$key].Count-gt1-and$PlayerText-match("(?i)(?<![\p{L}\p{N}])"+[regex]::Escape($key)+"(?![\p{L}\p{N}])")){return [pscustomobject]@{Alias=$key;Candidates=@($groups[$key])}}}
 $null
}
function Test-ExplicitEntityReference {param([string]$PlayerText,$Context)foreach($e in $Context.Entities){foreach($name in @($e.DisplayName)+@($e.Aliases)){if(-not[string]::IsNullOrWhiteSpace($name)-and$PlayerText-match("(?i)(?<![\p{L}\p{N}])"+[regex]::Escape($name)+"(?![\p{L}\p{N}])")){return $true}}};$false}
function Get-ClarificationText {param([string]$Reason,[string[]]$Candidates=@())if($Candidates.Count){"Which do you mean: $($Candidates-join', ')?"}elseif($Reason-eq'compound'){"I can do those in sequence. Which action should happen first?"}elseif($Reason-eq'pronoun'){"What does 'it' refer to?"}else{'Could you clarify what you want to do?'}}
function Test-DirectNpcControl {param([string]$PlayerText,$Context)foreach($npc in @($Context.Entities|Where-Object Kind -eq npc)){foreach($name in @($npc.DisplayName)+@($npc.Aliases)){if($PlayerText-match("(?i)^\s*"+[regex]::Escape($name)+"\b")-and$PlayerText-notmatch'(?i)\b(tell|ask|say|speak)\b'){return $true}}};$false}
function Write-InterpretationLog {
 param([string]$Path,[string]$RawInput,$ContextSummary,[string]$RawOutput,$Parsed,[string]$Status,[string]$Reason,[Nullable[bool]]$EngineAccepted)
 if([string]::IsNullOrWhiteSpace($Path)){return};$dir=Split-Path -Parent $Path;if($dir){New-Item -ItemType Directory -Force $dir|Out-Null}
 [ordered]@{timestamp=[datetime]::UtcNow.ToString('o');raw_player_input=$RawInput;interpreter_context_summary=$ContextSummary;raw_model_structured_output=$RawOutput;parsed_intent=$Parsed;interpretation_status=$Status;clarification_reason=$Reason;engine_accepted=$EngineAccepted}|ConvertTo-Json -Depth 12 -Compress|Add-Content -Encoding utf8 $Path
}
function Invoke-IntentInterpretation {
 [CmdletBinding()]param([Parameter(Mandatory)][string]$PlayerText,[Parameter(Mandatory)]$Context,[scriptblock]$Backend,[string]$DebugLogPath,[Nullable[int]]$Seed)
 $summary=[pscustomobject]@{location=$Context.CurrentLocation;entity_ids=@($Context.Entities.Id);spell_ids=@($Context.Spells.Id);recent_referents=@($Context.RecentReferents);supported_actions=@($Context.SupportedActions)}
 $pronounTarget=$null
 if([string]::IsNullOrWhiteSpace($PlayerText)){$r=New-InterpretationResult UNRECOGNIZED $null 'Empty input.' $null $null;Write-InterpretationLog $DebugLogPath $PlayerText $summary $null $null $r.Status $r.Reason $null;return $r}
 if(Test-CompoundInput $PlayerText){$r=New-InterpretationResult NEEDS_CLARIFICATION $null 'compound' (Get-ClarificationText compound) $null;Write-InterpretationLog $DebugLogPath $PlayerText $summary $null $null $r.Status $r.Reason $null;return $r}
 $ambiguity=Find-AliasAmbiguity $PlayerText $Context;if($null-ne$ambiguity){$r=New-InterpretationResult NEEDS_CLARIFICATION $null "ambiguous alias: $($ambiguity.Alias)" (Get-ClarificationText alias $ambiguity.Candidates) $null;Write-InterpretationLog $DebugLogPath $PlayerText $summary $null $null $r.Status $r.Reason $null;return $r}
 if($PlayerText-match'(?i)\b(it|that)\b'-and-not(Test-ExplicitEntityReference $PlayerText $Context)){
  if($Context.RecentReferents.Count-ne1){$r=New-InterpretationResult NEEDS_CLARIFICATION $null 'pronoun' (Get-ClarificationText pronoun) $null;Write-InterpretationLog $DebugLogPath $PlayerText $summary $null $null $r.Status $r.Reason $null;return $r}
  $pronounTarget=$Context.RecentReferents[0]
 }
 if(Test-DirectNpcControl $PlayerText $Context){$r=New-InterpretationResult UNRECOGNIZED $null 'NPCs cannot be directly controlled.' $null $null;Write-InterpretationLog $DebugLogPath $PlayerText $summary $null $null $r.Status $r.Reason $null;return $r}
 $hasEntity=Test-ExplicitEntityReference $PlayerText $Context;$hasSpell=@($Context.Spells|Where-Object{$PlayerText-match("(?i)(?<![\p{L}\p{N}])"+[regex]::Escape($_.Name)+"(?![\p{L}\p{N}])")}).Count-gt0;$targetless=$PlayerText-match'(?i)^\s*wait\b'
 if(-not$hasEntity-and$null-eq$pronounTarget-and-not$hasSpell-and-not$targetless){$r=New-InterpretationResult UNRECOGNIZED $null 'No player-accessible referent is present.' $null $null;Write-InterpretationLog $DebugLogPath $PlayerText $summary $null $null $r.Status $r.Reason $null;return $r}
 $schema=New-IntentJsonSchema $Context
 $backendResult=$null
 try{$backendResult=if($null-ne$Backend){&$Backend $PlayerText $Context $schema $Seed}else{Invoke-CommaIntentBackend $PlayerText $Context $schema -Seed $Seed};$raw=[string]$backendResult.RawOutput;$parseText=$raw-replace'\s*\[end of text\]\s*$','';$intent=$parseText|ConvertFrom-Json;if($null-ne$pronounTarget){$intent.target=$pronounTarget}}
 catch{$r=New-InterpretationResult UNRECOGNIZED $null "Structured interpretation failed: $($_.Exception.Message)" $null $(if($null-ne$backendResult){$backendResult.RawOutput}else{$null});Write-InterpretationLog $DebugLogPath $PlayerText $summary $r.RawModelStructuredOutput $null $r.Status $r.Reason $null;return $r}
 $valid=Test-StructuredIntent $intent $Context;if(-not$valid.Valid){$r=New-InterpretationResult UNRECOGNIZED $null $valid.Reason $null $raw $backendResult.ElapsedSeconds;Write-InterpretationLog $DebugLogPath $PlayerText $summary $raw $intent $r.Status $r.Reason $null;return $r}
 if($null-eq$intent.target-and$intent.action-notin@('wait','cast')){$r=New-InterpretationResult UNRECOGNIZED $null 'No accessible target resolved.' $null $raw $backendResult.ElapsedSeconds;Write-InterpretationLog $DebugLogPath $PlayerText $summary $raw $intent $r.Status $r.Reason $null;return $r}
 $intent|Add-Member -NotePropertyName raw_input -NotePropertyValue $PlayerText
 $r=New-InterpretationResult RESOLVED $intent $null $null $raw $backendResult.ElapsedSeconds;Write-InterpretationLog $DebugLogPath $PlayerText $summary $raw $intent $r.Status $null $null;$r
}
function Set-EngineInterpretationDecision {param($Interpretation,[bool]$Accepted,[string]$Reason,[string]$DebugLogPath)if($Interpretation.Status-ne'RESOLVED'){return $Interpretation};$result=if($Accepted){$Interpretation}else{New-InterpretationResult ENGINE_REJECTED $Interpretation.Intent $Reason $null $Interpretation.RawModelStructuredOutput $Interpretation.ElapsedSeconds};Write-InterpretationLog $DebugLogPath $Interpretation.Intent.raw_input $null $Interpretation.RawModelStructuredOutput $Interpretation.Intent $result.Status $Reason $Accepted;$result}

Export-ModuleMember -Function Get-ActionCueCount,Test-CompoundInput,Find-AliasAmbiguity,Test-ExplicitEntityReference,Get-ClarificationText,Test-DirectNpcControl,Invoke-IntentInterpretation,Set-EngineInterpretationDecision,Write-InterpretationLog
