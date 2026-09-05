# Phase 4 Gate 2 — Intent Interpretation

## Result: PASS — 26/30

Thirty canonical utterances were evaluated with the real Comma model under dynamically generated llama.cpp JSON Schema constraints. Scoring uses semantic correctness, not JSON text similarity. Legitimate clarification counts as correct.

| Outcome | Count |
|---|---:|
| Correct | **26** |
| Incorrect | 4 |
| Gate verdict | **PASS** |

The fixed Development Plan threshold is 25–30 for PASS.

## Incorrect cases

- `02-paraphrase`: correctly resolves examine/desk but invents `area: inside` for an unqualified closer look.
- `09-guillermo-search`: correctly resolves Guillermo/search/cabinet but narrows the search to `inside`.
- `14-misty-step`: recognizes Misty Step but selects the guard rather than the hallway/destination as target.
- `25-verbose`: recognizes examine/fireplace but invents `inside` and stores “without touching” as communicative intent instead of method.

## Safety behavior

- Ambiguous `Check it.` returns `NEEDS_CLARIFICATION`.
- Two visible desks return `NEEDS_CLARIFICATION` rather than a guessed target.
- Unknown objects, nonsense, a hidden-target prompt, and direct NPC control return `UNRECOGNIZED`.
- Compound and sequential commands return `NEEDS_CLARIFICATION`; no half-command executes.
- An impossible but understandable bare-handed vault attempt resolves as intent for the engine to accept or reject.
- No model output can contain DC, roll, skill, result, degree, or mutation fields under the generated schema.

## Performance

Twenty-two cases required model inference; eight were safely resolved before inference by ambiguity, target, compound, or NPC-control checks.

- Average model-backed interpretation: 3.20 seconds
- Maximum model-backed interpretation: 3.30 seconds
- Average across all 30 inputs: 2.35 seconds

The current llama.cpp completion process reloads the model for every model-backed input. A persistent local inference service is the primary future performance improvement, but was not required to answer Gate 2.

Raw outputs and parsed results are in `eval/gate2_real_model_raw.jsonl`; human semantic scores are in `eval/gate2_scores.json`.
