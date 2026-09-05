$ErrorActionPreference='Stop';$root=$PSScriptRoot
$cases=@{};Get-Content -Raw (Join-Path $root 'eval/baseline_50.json')|ConvertFrom-Json|ForEach-Object{$cases[[string]$_.id]=$_}
$runs=@(Get-Content (Join-Path $root 'eval/grounding_retry_regression_selected_raw.jsonl')|ForEach-Object{$_|ConvertFrom-Json})
$lines=[Collections.Generic.List[string]]::new()
$lines.Add('# Grounding Retry — 50 Held-Out Prompts and Responses')
$lines.Add('')
$lines.Add('These are the preserved Phase 1 held-out prompts and the raw-completion-based responses produced by the selected Phase 2 grounding retry harness (11 exemplars, facts packet, temperature 0.15). The response shown is the complete player-facing continuation assembled with the prompt-seeded `You `. The exact untrimmed runtime output remains in `eval/grounding_retry_regression_selected_raw.jsonl`.')
$lines.Add('')
$lines.Add('No prompt facts or seeds were changed for this review run.')
$lines.Add('')
$index=0
foreach($run in $runs){
 $index++;$case=$cases[[string]$run.case_id]
 $lines.Add("## $index. $($run.case_id) — $($run.category)")
 $lines.Add('')
 $lines.Add("Seed: $($run.seed)")
 $lines.Add('')
 $lines.Add('### Prompt')
 $lines.Add('')
 $lines.Add('```text')
 foreach($line in ([string]$case.original_prompt -split "`r?`n")){$lines.Add($line)}
 $lines.Add('```')
 $lines.Add('')
 $lines.Add('### Response')
 $lines.Add('')
 $lines.Add([string]$run.assembled_narration)
 $lines.Add('')
}
$lines.RemoveAt($lines.Count-1)
$path=Join-Path $root 'GROUNDING_RETRY_50_PROMPT_RESPONSE_REVIEW.md'
$lines|Set-Content -Encoding utf8 $path
Write-Host "Wrote $path with $index prompt/response pairs."
