# Phase 2 Prompt Diagnostic

## Decision

Condition B — facts-style packet with all eight exemplars — is the selected Phase 2 prompt architecture.

| Condition | Packet | Exemplars | Grounded | Form | Agency | Identity | Total |
|---|---|---:|---:|---:|---:|---:|---:|
| A | facts | 0 | 0/6 | 6/6 | 0/6 | 0/6 | 6/24 |
| B | facts | 8 | 4/6 | 6/6 | 6/6 | 6/6 | 22/24 |
| C | literary | 0 | 0/6 | 0/6 | 0/6 | 0/6 | 0/24 |
| D | literary | 8 | 2/6 | 6/6 | 6/6 | 6/6 | 20/24 |

The no-exemplar conditions were decisively unstable. Both eight-exemplar conditions controlled form, agency, and identity, but the facts-style packet made fewer unsupported additions. Its two misses were both explicit outcome reversals: suppressing the watchman's call and retrieving a ledger that remained out of reach.

## Method

The same six cases and seeds were used for all four conditions at temperature 0.35. Scoring was performed against raw, unedited completions assembled with the prompt-seeded `You `. The llama.cpp reverse-prompt marker is retained verbatim in each `raw_completion` log field and omitted only from `assembled_narration` for player-facing scoring.

Machine-readable raw runs are in `eval/diagnostic_[A-D]_raw.jsonl`; human scores and notes are in `eval/diagnostic_scores.json`.
