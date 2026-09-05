# Phase 2 Gate 1 Grounding Retry Report

## 1–5. What changed

The existing Phase 2 facts packet was extended, not replaced. It now supports affirmative `POST_ACTION_STATE` and `EVENT_STATE` key/value fields plus bounded `NPC_DISCLOSURE` sections with separate `discloses` and `withholds` lists. These fields describe what is true after resolution without accepting a complete or hidden game-state object.

The original eight exemplars are unchanged. Three targeted exemplars were added separately:

1. A failed deed-box unlock where the box, lock, and access state remain unchanged.
2. A partial-success cabinet search where a tag is obtained but the cabinet remains sealed.
3. A clerk who provides an arrival time while withholding only a specific identity.

No chat template, engine feature, split narration, deterministic authored outcome, fine-tuning, or Phase 3 system was introduced.

## 6. Stage A results

The same 20 held-out Gate cases and seeds were run under the revised representation and 11 exemplars.

| Temperature | Grounding | Form | Agency | Register | Identity |
|---:|---:|---:|---:|---:|---:|
| 0.15 (R1) | **15/20** | 20/20 | 19/20 | 20/20 | 19/20 |
| 0.20 (R2) | **15/20** | 20/20 | 18/20 | 20/20 | 19/20 |

## 7. Selected temperature

Temperature **0.15** was selected after a 15/20 grounding tie because agency is the first specified tiebreaker: 19/20 at 0.15 versus 18/20 at 0.20. The other sampling parameters remain unchanged: top-p 0.95, top-k 40, repetition penalty 1.1, and maximum 224 tokens.

## 8. Stage B confirmation

The selected condition was run on a new, distinct 20-case confirmation set.

| Grounding | Form | Agency | Register | Identity |
|---:|---:|---:|---:|---:|
| **17/20** | 20/20 | 19/20 | 20/20 | 20/20 |

## 9. Combined 40-case result

| Grounding | Form | Agency | Register | Identity |
|---:|---:|---:|---:|---:|
| **32/40 (80%)** | 40/40 | 38/40 | 40/40 | 39/40 |

## 10. Comparison with previous Gate 1

| Measure | Previous Gate | Retry Stage A, same cases | Combined retry |
|---|---:|---:|---:|
| Grounding | 11/20 (55%) | 15/20 (75%) | 32/40 (80%) |
| Form | 20/20 | 20/20 | 40/40 |
| Agency | 17/20 | 19/20 | 38/40 |
| Register | 20/20 | 20/20 | 40/40 |
| Identity | 20/20 | 19/20 | 39/40 |

On the same Stage A cases, the intervention improves grounding by 4 cases and 20 percentage points. The independent confirmation set improves the combined estimate to 80%, although that remains far below a production-quality requirement.

## 11–12. Targeted failure rates

Among four Stage A cases explicitly tracking inaccessible or unchanged state, explicit outcome reversal falls from 2/4 in the previous Gate to 0/4 in the retry. One retry case still misdescribes an unchanged proof-sheet location as a change, so the broader unchanged-state semantic error rate is 1/4.

Bounded-disclosure failure remains 2/3 on Stage A because two responses omit the specifically withheld field. All three new Stage B disclosure cases pass, making the combined bounded-disclosure failure rate 2/6. This suggests targeted conditioning helps but has not made disclosure boundaries uniformly reliable.

## 13. Performance

| Run | Average end-to-end time | Average tokens/sec | Average generated tokens |
|---|---:|---:|---:|
| Stage A, 0.15 | 3.17 s | 70.44 | 31.1 |
| Stage A, 0.20 | 3.11 s | 71.44 | 31.0 |
| Stage B, 0.15 | 3.10 s | 70.68 | 28.9 |
| 50-case review run, 0.15 | 3.28 s | 70.14 | 38.9 |

Every run reported active GPU offload. The longer 11-exemplar prompt reduces throughput relative to the prior 77.35 tokens/sec average; lower temperature does not improve speed.

## 14–16. Conclusion

The three controlled changes materially improve grounding. The combined result is **PROMISING** under the fixed 70% threshold. Comma now preserves explicit inaccessible/closed states much more reliably, while the remaining failures cluster around referent ambiguity, converting state into a new event, omitted withholding boundaries, and one Guillermo/player identity collapse.

Recommended next step: stop here as required, review the raw evidence, and decide whether another Phase 2 experiment should target bounded disclosure and state-versus-event phrasing. Fine-tuning is now more defensible as a later option, but it should not begin automatically and Phase 3 remains out of scope.

## Additional requested 50-prompt review

The preserved Phase 1 50-case suite was run at the selected temperature with all 11 exemplars. Its facts and seeds were not modified. This run is supplied for human review rather than folded into the retry's fixed 40-case viability verdict.

- Human-readable prompt/response document: `GROUNDING_RETRY_50_PROMPT_RESPONSE_REVIEW.md`
- Exact raw machine log: `eval/grounding_retry_regression_selected_raw.jsonl`

## Evidence files

- `eval/grounding_retry_stageA_R1_raw.jsonl` and `eval/grounding_retry_stageA_R2_raw.jsonl`
- `eval/grounding_retry_stageA_R1_scores.json` and `eval/grounding_retry_stageA_R2_scores.json`
- `eval/grounding_retry_stageB_selected_raw.jsonl` and `eval/grounding_retry_stageB_scores.json`

Commit and branch are recorded in the delivery message after final verification and push.
