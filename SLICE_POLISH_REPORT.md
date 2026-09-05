# Vertical Slice Polish Report

## Outcome

The Callum's Study slice now rewards understandable player intent with an engine-grounded world response. The six inputs from the first player transcript route correctly, harmless curiosity produces authored mundane outcomes, clue-bearing desk interactions take precedence over mundane texture, and the narrator receives an explicit separation between new facts and prior context.

This remains a one-room polish pass. No Phase 6 expansion, combat, progression, save/load, new spells, or model training was added.

## Implementation summary

### Narration packet and relevance

The narrator handoff and packet now include:

- `NEW_THIS_TURN`: engine events and facts produced by the current resolution. These are the normal subject of narration.
- `KNOWN_CONTEXT`: selected prior Notebook evidence, labeled not to be restated unless the current action directly compares or revisits it.
- `MUNDANE_RESULT`: a bounded engine-authored physical result.
- `TONE`: one of `neutral`, `tense`, `dry_humor_allowed`, `guillermo_comic`, or `serious`.
- `SUPPORTED_AFFORDANCES`: visible objects, inventory objects, and concrete engine-event details the narration may safely expose.

Legacy packet fields remain available for compatibility. Same-location Notebook relevance is set to `0` in `content/callum_study/polish.json` and the slice requests targeted relevance without a current-location boost. The generic relevance architecture was not removed; a multi-room Phase 6 can restore that weight.

### Intent routing and engine authority

The slice adds a narrow structural routing layer before the existing model interpreter:

- Explicit known spells route first. `misty step to the desk` becomes `cast / misty_step / writing_desk`; the engine validates visibility and destination and spends the spell slot.
- `move`, `lift`, `shift`, `push`, `pull`, `turn`, and `knock` route to one canonical `manipulate` action when their target is an object, rather than to locomotion.
- Direct sensory, read, examine, and Guillermo-question forms route predictably.
- Inputs outside these clear patterns still use the existing interpreter, preserving ambiguity and unrecognized handling.

Resolution now distinguishes `MEANINGFUL` and `MUNDANE` accepted actions. Existing engine rejection reasons supply concise fiction-compatible responses for understood impossible actions. The broader interpreter retains its ambiguous and unrecognized states.

### Desk and mundane content audit

The desk resolves clue discovery before any exhausted-object response. Its hemp cordage clue can no longer be shadowed by receipts or correspondence. Correspondence, receipts, the window latch, chair, and other named affordances are real interactable sub-objects. A small deterministic mundane table supplies safe details for reading, smelling, touching, looking beneath, staring, knocking, and repeated inspection. These actions do not create clues or mutate consequential state.

Dry humor is permission, not an outcome requirement. The engine marks safe mundane turns with `dry_humor_allowed` or `guillermo_comic`; the narrator may add restrained personality but cannot alter the supplied reality.

### Narrator safety and conditioning

The focused affordance validator checks risky concrete nouns such as drawers, letters, cabinets, boxes, keys, knives, chairs, and notes against supported affordances. It also rejects a small set of consequential exemplar-bleed details when unsupported. Existing state, continuity, hidden-truth, agency, lexical, length, person, and dataset-form validation remains active. All generation-attempt validations are now retained in telemetry.

Four targeted exemplars cover new-versus-known context, dry mundane inspection, irrelevant correspondence, and manipulation that reveals nothing. The unrelated NPC-disclosure exemplar is excluded from this slice's narrator prompt because the small model copied its woman/clerk details into Guillermo and correspondence turns. The raw-completion stop boundary is now a CRLF paragraph break; this prevents valid first paragraphs from continuing into copied `FACTS` blocks while preserving raw completion.

## Permanent transcript regression

All six exact inputs pass:

1. `look down at the floor` — examines the rug/floor and discovers the authored blood evidence.
2. `move the rug to examine beneath` — routes as object manipulation, not locomotion.
3. `misty step to the desk` — routes as a spell and resolves beside the visible desk.
4. `look at the desk` — discovers hemp fibers; mundane desk content does not shadow the clue.
5. `read correspondence` — returns bounded irrelevant correspondence as a mundane world response.
6. `look at the painting` — responds to the painting and reveals the authored safe without dumping blood/fiber context.

The additional permanent suite covers knocking on the wall, smelling the rug, looking under the desk twice, inspecting the window latch, touching the hearth, reading a receipt, asking Guillermo what he thinks, and staring at the bookshelf. All are accepted, do not create unauthorised clues, and several permit dry narration.

## Real-model 30-turn diagnostic

The final clean run used the installed real Comma model and persistent inference service. Raw inputs, generations, per-attempt validator records, engine events, classifications, displayed narration, and timings are in `eval/slice_polish_diagnostic_raw.jsonl`; the machine-readable aggregate is in `eval/slice_polish_diagnostic_summary.json`.

| Measure | Result |
|---|---:|
| Turns accepted | 30 / 30 (100%) |
| Meaningful turns | 12 / 30 (40%) |
| Mundane turns | 18 / 30 (60%) |
| First-pass narration | 29 / 30 (96.7%) |
| Retried turns | 1 / 30 (3.3%) |
| Safe fallbacks | 0 / 30 (0%) |
| Generation attempts | 31 |
| Average total turn latency | 0.5112 s |
| Median total turn latency | 0.4379 s |
| Maximum total turn latency | 1.0292 s |

Validator failures by generation:

| Category | Count |
|---|---:|
| unsupported_object | 1 |
| state_contradiction | 0 |
| known_context_restatement | 0 |
| agency_violation | 0 |
| dataset_form | 0 |
| excessive_length | 0 |

The sole rejected generation invented a `drawer` while knocking on the desk. The focused affordance validator caught it; retry two used the supported `compartment` language and passed. This is a narrow, successfully contained failure rather than a distributed conditioning ceiling.

Real-model replay observations: the transcript remained target-correct; known blood and fiber evidence did not appear in the unrelated painting discovery; mundane interactions received concise physical responses; occasional dry lines appeared without hiding clues; and no invalid generation reached the displayed response.

## Regression results

- Phase 2: passed.
- Phase 3: passed, including core rules, state, clues, handoff, and 15 grounding regressions.
- Phase 4: passed, 30/30 semantic fixtures plus authority and logging checks.
- Phase 4.5: passed.
- Phase 5: passed, 32 Notebook, relevance, boundary, evidence, ledger, and serialization checks.
- Existing vertical slice: passed, 31 gameplay and safety scenarios.
- Slice polish: passed, including the six transcript cases, eight mundane actions, packet separation, routing, humor, and affordance safety.

## Blockers and recommendation

There is no implementation blocker. Recommendation: **replay the prototype once more in Godot** to judge pacing and tone in the actual UI. If that hands-on replay feels good, proceed to Phase 6; the measured narrator behavior does not justify fine-tuning or a separate narrator-quality phase first.
