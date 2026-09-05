# Player Intent and Action Resolution Polish Report

## Outcome

The Callum's Study runtime now resolves player meaning through a semantic layer before falling back to the constrained model interpreter. It preserves purpose, distinguishes object manipulation from locomotion, prioritizes named spells, exposes only engine-authorized referents, resolves safe recent pronouns, and asks for clarification when a target is materially ambiguous. Resolution remains entirely engine-authoritative.

This is not Phase 6. No rooms, combat, progression, save/load, model training, planner, embeddings, or procedural systems were added.

## Architecture

The unchanged authority flow is:

`player text -> semantic interpretation -> structured intent -> engine routing -> state/clues/Notebook -> narrator handoff -> narration`

The semantic interpreter applies the following priority:

1. exact authored alias or exposed sub-referent;
2. explicit available spell;
3. safe recent referent for pronouns;
4. canonical action and purpose extraction;
5. player-facing clarification for multiple plausible targets;
6. existing constrained model interpreter for unmatched but grounded input;
7. unrecognized response when no accessible referent can be mapped.

It never supplies DCs, rolls, outcomes, clue facts, consequences, or mutations.

## Clue and passive-check verification

`Test-ClueDiscoverySanity.ps1` directly proves the discovery system before interpretation:

- Blood passive DC 10 exposes only the dark discoloration.
- Investigation 15 exposes dried blood.
- Investigation 20 exposes insufficient blood for a death without leaking the unreached movement inference.
- The Notebook contains only reached facts.
- Qualified desk examination exposes fibers/hemp cordage before mundane desk content.
- Fireplace attention exposes the base scorch observation; Occult interpretation exposes the ordinary-fire inconsistency.
- A normal vertical-slice attention action fires the passive discovery path.

All checks pass. No interpreter workaround is masking broken clue wiring.

## Structured intent

The compatible schema retains `actor`, `action`, `target`, `method`, `area`, `communicative_intent`, and `spell`, and formalizes:

- `secondary_target`: optional second entity or destination;
- `purpose`: the investigative question or immediate purpose;
- `modifiers`: explicit manners such as carefully, quietly, or without touching.

Older deterministic backends remain compatible because omitted new fields are normalized before validation. The JSON schema used for real constrained inference requires all fields, preventing silent purpose loss in new model output.

## Routing and action resolution

- Object-directed move/lift/pull/push/shift/roll/drag maps to `manipulate`; actor-directed movement remains `move`.
- Small compounds such as “move the rug to examine beneath” remain one action with `area=underneath` and a preserved purpose. True sequences containing “and then” still clarify instead of invoking a planner.
- Available named spells route before generic verbs. Misty Step remains a cast with a desk-associated destination; Detect Magic and Darkness retain their spell IDs and targets. The engine still validates destination, visibility, legality, and resources.
- Read, search, sensory examination, Guillermo direction, and unusual but clear verbs such as poke, rifle, and peer map to small canonical action families.
- Accepted resolutions are `MEANINGFUL` or `MUNDANE`; understood physical refusal is `IMPOSSIBLE`; interpretation exposes `AMBIGUOUS` or `UNRECOGNIZED`; a valid intent refused by rules is logged as `ENGINE_REJECTED`.

## Referents, aliases, and lifecycle

`content/callum_study/referents.json` defines engine-authorized dynamic subfeatures with parent, aliases, interaction capabilities, trigger, and lifecycle. Examples include bloodstain, scorch marks, rope fibers, bookshelf gap, painting frame, safe dial, and safe door.

- `VISIBLE`: exposed and present.
- `KNOWN`: discovered evidence that remains referable.
- `CONTEXTUAL`: an accessible recent referent used for a pronoun.
- `EXHAUSTED`: remains referable even after meaningful information is exhausted.
- `HIDDEN`: absent from interpreter context.

The safe dial and door appear only after safe discovery. The bookshelf gap appears only after an authoritative shelf interaction. Clue aliases appear only once their Notebook clue exists. Hidden-subfeature tests confirm no target leakage.

Alias matching favors the longest exact/semantic alias and then recent context. Authored examples include desk/table, shelves/bookcase, painting/portrait, and multiple forms of dark stain and scorch marks. If the same alias refers to both known blood and scorch marks, the game asks: “Which marks do you mean, the scorch marks by the hearth or the dark stain by the rug?” It does not silently pick one.

A single accessible recent referent resolves `it`, `that`, `those`, or `them`, and telemetry records that this occurred. Multiple recent candidates clarify. Narrator-invented nouns never enter the referent registry.

## Purpose-bearing investigation

The interpreter retains questions such as addresses, recent travel, ordinary-fire origin, rope direction, and missing-book inference. The engine answers only from authored evidence:

- Receipts can establish their mundane purchases but provide no invented address, itinerary, or whereabouts.
- Shelf wear can establish recent removal but not a reliable size, title, or location when those facts are unauthored.
- Scorch and rope questions reveal only reached authored tiers.

This rewards a useful question with a bounded answer or explicit lack of evidence instead of replaying generic object description.

## Target capabilities and mundane actions

Authored objects and subfeatures declare interaction families such as examine, search, manipulate, read, open, unlock, and use. The engine dispatches from structured action/target semantics. Existing bounded mundane truth and dry-humor handling remains intact; no consequential detail is delegated to narration.

## Telemetry

Bridge diagnostics now record, without exposing them in Godot:

- raw input, resolved actor/action/target/purpose;
- matched aliases and recent-referent use;
- clarification reason;
- engine routing family and result category;
- interpretation, narration, and total latency;
- existing engine, Notebook, generation, validation, retry, and fallback details.

Ambiguous, unrecognized, and engine-rejected turns are logged as well as successful turns.

## Regression results

All ten exact real-play cases pass permanently:

1. `misty step to the desk` -> cast / `misty_step` / writing desk.
2. `look under the rug` -> rug with underneath area, never floor substitution.
3. `investigate the dark marks` -> unique known mark or clarification.
4. `look at the dark marks` -> unique known mark or clarification.
5. `look at desk` -> writing-desk examination.
6. `look at the receipts and see where Callum has been` -> receipts plus whereabouts purpose.
7. `send guillermo to investigate the bookcase` -> Guillermo plus bookshelves.
8. `look for the book that would fit that gap` -> exposed bookshelf gap plus missing-book purpose.
9. `move the rug to examine beneath` -> manipulation plus underneath purpose.
10. `read correspondence` -> correspondence read.

The larger deterministic matrix passes **59/59** utterances. It covers semantic equivalence, compound purpose, object versus actor movement, three spells, dynamic referents, synonyms, recent pronouns, ambiguity, hidden leakage, unusual verbs, mundane questions, and wrong-target prevention.

Measured common semantic-path interpretation latency over the 59 cases:

- average: **0.0126 seconds**;
- maximum: **0.0245 seconds**.

## Real-model interpretation gate

The final clean gate ran 40 representative utterances through the actual constrained Comma interpreter, rather than the semantic fast path. Results and raw structured output are preserved in `eval/intent_model_gate_raw.jsonl` and `eval/intent_model_gate_summary.json`.

| Measure | Result |
|---|---:|
| Passed cases | 38 / 40 (95%) |
| Average model latency | 1.0694 s |
| Maximum model latency | 1.7606 s |
| Actor failures | 0 |
| Action failures | 1 |
| Target failures | 1 |
| Purpose failures | 1 |
| Clarification failures | 0 |
| Hidden-target leaks | 0 |
| Silent wrong targets | 1 |
| Status failures | 0 |

Failures are counted by dimension, so one utterance can contribute to more than one category. The remaining clusters are:

- `check the receipts for addresses`: model chose `read` rather than `examine` and generalized the purpose to recent whereabouts instead of retaining addresses;
- `peer behind the painting`: model selected the authored painting frame rather than the painting as primary target.

Both utterances resolve correctly in the shipped semantic path, so neither miss can silently execute during slice play. The raw gate reports them instead of hiding them behind the aggregate score.

## Full verification

- Phase 2: passed.
- Phase 3: passed, including 15 grounding regressions.
- Phase 4: passed, 30/30 semantic fixtures and authority/logging checks.
- Phase 4.5: passed.
- Phase 5: passed, 32 Notebook/evidence/ledger/serialization checks.
- Existing vertical slice: passed, 31 gameplay and safety scenarios.
- Slice narration polish: passed.
- Clue discovery sanity: passed.
- Intent resolution polish: passed, 59 deterministic utterances plus lifecycle and outcome checks.
- Godot headless project load: passed.

## Blockers and recommendation

There is no implementation blocker. Recommendation: **replay the slice** in Godot with deduction-heavy phrasing and pronoun follow-ups. If that replay is satisfactory, proceed toward Phase 6. The two raw-model misses do not justify additional interpreter work before replay because the deterministic semantic layer safely resolves both and the gate showed no hidden leakage or status/clarification failure.
