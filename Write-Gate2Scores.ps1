$ErrorActionPreference='Stop';$root=$PSScriptRoot
$failures=@{
 '02-paraphrase'='Correct actor/action/target, but invents an inside area for an unqualified closer look.'
 '09-guillermo-search'='Correct actor/action/target, but narrows an unqualified cabinet search to inside.'
 '14-misty-step'='Recognizes Misty Step but selects the guard instead of the hallway/destination as target.'
 '25-verbose'='Recognizes examine/fireplace but invents inside and places without-touching in communicative intent rather than method.'
}
$scores=@(Get-Content (Join-Path $root 'eval/gate2_real_model_raw.jsonl')|ForEach-Object{$x=$_|ConvertFrom-Json;[pscustomobject][ordered]@{id=$x.id;correct=(-not$failures.ContainsKey([string]$x.id));expected_status=$x.expected_status;actual_status=$x.actual_status;notes=$(if($failures.ContainsKey([string]$x.id)){$failures[[string]$x.id]}else{'Semantically correct.'})}})
$scores|ConvertTo-Json -Depth 6|Set-Content -Encoding utf8 (Join-Path $root 'eval/gate2_scores.json')
Write-Host "Gate 2 scored: $(@($scores|Where-Object correct).Count)/30 correct."
