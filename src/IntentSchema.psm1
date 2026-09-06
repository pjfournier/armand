Set-StrictMode -Version Latest

function New-IntentJsonSchema {
 param([Parameter(Mandatory)]$Context)
 $actors=@('armand');if(@($Context.Entities.Id)-contains'guillermo'){$actors+='guillermo'}
 $targets=@($Context.Entities.Id|Select-Object -Unique);$spells=@($Context.Spells.Id|Select-Object -Unique)
 [ordered]@{
  type='object';additionalProperties=$false
  required=@('actor','action','target','method','area','communicative_intent','spell','secondary_target','purpose','modifiers')
  properties=[ordered]@{
   actor=[ordered]@{type='string';enum=$actors}
   action=[ordered]@{type='string';enum=@($Context.SupportedActions)}
   target=[ordered]@{type=@('string','null');enum=@($targets)+@($null)}
   method=[ordered]@{type=@('string','null')}
   area=[ordered]@{type=@('string','null');enum=@('underneath','behind','inside','on_top','around','through','above','below')+@($null)}
   communicative_intent=[ordered]@{type=@('string','null')}
   spell=[ordered]@{type=@('string','null');enum=@($spells)+@($null)}
   secondary_target=[ordered]@{type=@('string','null');enum=@($targets)+@($null)}
   purpose=[ordered]@{type=@('string','null')}
   modifiers=[ordered]@{type='array';items=[ordered]@{type='string'}}
  }
 }
}
function Test-StructuredIntent {
 param([Parameter(Mandatory)]$Intent,[Parameter(Mandatory)]$Context)
 $allowed=@('actor','action','target','method','area','communicative_intent','spell','secondary_target','purpose','modifiers');$required=@('actor','action','target','method','area','communicative_intent','spell');$names=@($Intent.PSObject.Properties.Name)
 if(@($names|Where-Object{$_-notin$allowed}).Count){return [pscustomobject]@{Valid=$false;Reason='Interpreter emitted prohibited fields.'}}
 foreach($field in $required){if($field-notin$names){return [pscustomobject]@{Valid=$false;Reason="Missing field: $field"}}}
 if($Intent.actor-notin@('armand','guillermo')){return [pscustomobject]@{Valid=$false;Reason='Invalid actor.'}}
 if($Intent.actor-eq'guillermo'-and'guillermo'-notin@($Context.Entities.Id)){return [pscustomobject]@{Valid=$false;Reason='Guillermo is unavailable.'}}
 if($Intent.action-notin$Context.SupportedActions){return [pscustomobject]@{Valid=$false;Reason='Unsupported action.'}}
 if($null-ne$Intent.target-and$Intent.target-notin@($Context.Entities.Id)){return [pscustomobject]@{Valid=$false;Reason='Target is not player-accessible.'}}
 if($Intent.PSObject.Properties['secondary_target']-and$null-ne$Intent.secondary_target-and$Intent.secondary_target-notin@($Context.Entities.Id)){return [pscustomobject]@{Valid=$false;Reason='Secondary target is not player-accessible.'}}
 if($null-ne$Intent.spell-and$Intent.spell-notin@($Context.Spells.Id)){return [pscustomobject]@{Valid=$false;Reason='Spell is not available.'}}
 $forbidden=@('dc','skill','roll','result','degree','success','failure','consequence','mutation');if(@($names|Where-Object{$_-in$forbidden}).Count){return [pscustomobject]@{Valid=$false;Reason='Interpreter crossed the resolution boundary.'}}
 [pscustomobject]@{Valid=$true;Reason=$null}
}
function New-InterpretationResult { param([ValidateSet('RESOLVED','NEEDS_CLARIFICATION','UNRECOGNIZED','ENGINE_REJECTED')][string]$Status,$Intent,[string]$Reason,[string]$Clarification,[string]$RawOutput,[double]$ElapsedSeconds=0) [pscustomobject]@{Status=$Status;Intent=$Intent;Reason=$Reason;Clarification=$Clarification;RawModelStructuredOutput=$RawOutput;ElapsedSeconds=$ElapsedSeconds} }
function ConvertTo-EngineIntent {param([Parameter(Mandatory)]$Intent)[pscustomobject]@{Actor=$(if($Intent.actor-eq'guillermo'){'Guillermo'}else{'Armand'});Action=$Intent.action;Target=$Intent.target;SecondaryTarget=$(if($Intent.PSObject.Properties['secondary_target']){$Intent.secondary_target}else{$null});Method=$Intent.method;Area=$Intent.area;CommunicativeIntent=$Intent.communicative_intent;Spell=$Intent.spell;Purpose=$(if($Intent.PSObject.Properties['purpose']){$Intent.purpose}else{$null});Property=$(if($Intent.PSObject.Properties['property']){$Intent.property}else{$null});Modifiers=$(if($Intent.PSObject.Properties['modifiers']){@($Intent.modifiers)}else{@()});RawInput=$Intent.raw_input}}

Export-ModuleMember -Function New-IntentJsonSchema,Test-StructuredIntent,New-InterpretationResult,ConvertTo-EngineIntent
