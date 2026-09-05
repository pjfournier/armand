# Phase 4 Intent Interpreter Report

## 1–3. Architecture and files

Phase 4 extends the Phase 3 structured-intent boundary with five composable pieces:

- `src/InterpreterContext.psm1`: projects authoritative state into a player-visible reference context.
- `src/IntentSchema.psm1`: creates the structured schema, validates outputs, formalizes statuses, and adapts resolved intents to Phase 3.
- `src/InterpreterModel.psm1`: builds a concise completion corpus and invokes Comma using llama.cpp JSON Schema constrained decoding.
- `src/IntentInterpreter.psm1`: ambiguity, compound, referent, output-validation, clarification, status, and development-log orchestration.
- `interpreter_config.json`: independent low-variance extraction settings.

Supporting artifacts are `Test-Phase4.ps1`, `tests/gate2_cases.json`, `Run-Gate2.ps1`, `Write-Gate2Scores.ps1`, `Run-Phase4EndToEnd.ps1`, `GATE2_REPORT.md`, and the evaluation logs under `eval/`.

The structured intent fields are:

```json
{
  "actor": "armand | guillermo",
  "action": "canonical action",
  "target": "player-accessible stable ID | null",
  "method": "stated tool or manner | null",
  "area": "underneath | behind | inside | on_top | around | through | above | below | null",
  "communicative_intent": "preserved meaning | null",
  "spell": "available spell ID | null",
  "raw_input": "original player text"
}
```

The model cannot emit `raw_input`; it is attached after validation. It also cannot emit engine fields.

## 4. Dynamic constrained decoding

The context builder includes only the current location, visible/known interactable IDs and aliases, present NPCs, exits, Armand inventory, available spells, Guillermo availability, supported actions, and valid recent referents. A JSON Schema is generated per call with enums for actors, actions, target IDs, areas, and spell IDs. llama.cpp converts that schema to its constrained grammar internally.

The exact raw completion is retained. This llama.cpp build appends `[end of text]` after schema-valid JSON; only that known runtime sentinel is removed for parsing. Unconstrained prose plus regex parsing is not used.

## 5. Interpretation outcomes

- `RESOLVED`: validated actor/action/accessible target and optional method/area/social/spell fields.
- `NEEDS_CLARIFICATION`: duplicate aliases, ambiguous pronouns, or unsupported action sequences.
- `UNRECOGNIZED`: no accessible referent, unsupported nonsense, invalid structured output, hidden-target attempts, or direct NPC control.
- `ENGINE_REJECTED`: a previously resolved intent that Phase 3 rejects; the interpreter never makes that decision itself.

Impossible-but-understandable actions remain resolved intents. Guillermo commands identify only what Guillermo is being asked to attempt; no obedience, refusal, safety, skill, or outcome is generated. Social inputs preserve their claim/request meaning without selecting Influence or Deception. Named spells normalize to `cast` plus a stable spell ID; range, destination validity, resources, and effects stay engine-side. Because Phase 3 does not support sequences, compound inputs clarify instead of executing the first clause.

## 6. Authority and security boundary

The full `GameState` is never serialized. Tests prove the interpreter context, generated schema, and debug logs exclude undiscovered clues, hidden objectives, off-screen NPCs, non-visible items, NPC knowledge references, and Guillermo mechanics. The generated schema rejects skill, DC, roll, result, degree, consequence, and mutation fields. Stable target IDs must be members of the current context.

Development JSONL logging records raw player input, a safe context summary, raw structured output, parsed intent, status, clarification reason, and optional engine acceptance. It never writes full state.

## 7–8. Tests and Gate 2

- Deterministic semantic fixtures: **30/30 passed**.
- Additional context-security, malicious-output, configuration, logging, engine-rejection, and natural-language-to-Phase-3 boundary checks: passed.
- Real-model Gate 2: **26/30 — PASS**.

The four real-model misses are semantic field overreach, not target hallucination or authority leakage. See `GATE2_REPORT.md`.

## 9. Latency

Model-backed interpretation averages 3.20 seconds on the current GPU environment. Structural clarification/rejection paths do not load the model. The completion CLI still reloads Comma for each ordinary action; a persistent local server/session should be evaluated before interactive production use. That optimization is not a Phase 4 correctness blocker.

## 10. End-to-end results

### Armand

`Look beneath the desk.` resolves to Armand/examine/`desk_01`/underneath. Phase 3 uses Investigation +4, fixed roll 13, total 17, Success, then hands off an observed-scratches state/event. Comma narrates the attempt and scratches, while adding “nothing else,” an unsupported narrator embellishment that cannot mutate state.

### Guillermo

`Have Guillermo steal the key.` resolves to Guillermo/steal/`brass_key` without deciding obedience or outcome. Phase 3 uses Finesse +5, fixed roll 4, total 9, Failure. The key remains on the hook, Guillermo has no key, and the handoff says “tries to take.” Comma does not claim theft, but adds an unrequested second attempt after the retreat. The authoritative state remains unchanged.

Evidence is preserved in `eval/phase4_end_to_end_results.json` and the player-safe interpreter log in `eval/phase4_interpreter_debug.jsonl`.

## 11–12. Blockers and design questions

No correctness blocker prevented Phase 4 completion. Two issues should be carried forward:

1. Comma's narrator can still invent follow-on actions even with a correct handoff; Phase 2 validation/grounding remains non-production-safe.
2. Compound commands currently clarify because Phase 3 has no sequence executor. Supporting ordered sequences later requires an explicit product decision about interruption, partial completion, and state changes between steps; Phase 4 does not invent that planner.

No Notebook, incident ledger, mystery content, combat, UI, autonomous planning, state mutation by an LLM, new spells, progression, or fine-tuning was added.

Commit and branch are recorded in the delivery message after final verification and push.
