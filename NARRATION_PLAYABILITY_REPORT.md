# Narration Packet and Playability Polish Report

## Outcome

Callum's Study now presents questions before answers, visibly distinguishes active mechanical resolution from interpretation failure, prevents unchanged rerolls, and gives understandable unsupported actions bounded in-world consequences. The bridge, engine, Godot display contract, Notebook relevance, narrator packet, and actionable-referent validation were verified together without expanding beyond the existing slice.

## Runtime integration audit

The eight required inputs were compared through the automated semantic interpreter and a freshly restarted HTTP bridge. The audit recorded actor, action, target, secondary target, spell, purpose, modifiers, interpreter path, semantic/model path, engine routing, acceptance, and the exact Godot-displayed response in `eval/runtime_integration_audit.jsonl`.

- Matches: **8/8**.
- Divergences after restart: **0**.
- All eight used the expected semantic path and routing family.

The earlier live Misty Step movement rejection was a runtime lifecycle issue: the long-lived PowerShell bridge had loaded older module code. Restarting the bridge loaded the tested semantic implementation, after which `misty step to the desk` consistently routed as `cast / misty_step / writing_desk`. No compensating interpreter redesign was made.

## Discovery ladder and overview schema

Clues now have an authored `overview_fact` separate from interpretation tiers. Overview facts expose low-resolution anomalies:

- a dark discoloration beside the rug;
- unusual dark patterns around the hearth;
- a scratched desk scattered with papers.

They do not identify dried blood, hemp cordage, ordinary-versus-occult cause, forensic implications, or theories. A room overview exposes the blood and scorch referents without populating interpreted Notebook facts.

The implemented ladder is:

1. **Overview** — free environmental affordances and anomalies.
2. **Focused examination/passive observation** — first meaningful authored identity or interpretation, silently if the passive threshold is met.
3. **Active skill resolution** — deeper Investigation or Occult tier with visible outcome feedback.
4. **Higher tier** — authored implication or connection only.
5. **Theory** — remains explicitly player-authored.

Direct tests verify the blood, fibers, and scorch ladders and confirm the Notebook contains only reached tiers.

## Narration packet and relevance

The existing packet separation is retained and enforced:

- `NEW_THIS_TURN` contains the authoritative current resolution and is the normal narration subject.
- `KNOWN_CONTEXT` contains narrowly selected prior facts for continuity, comparison, explicit re-examination, theory support, or engine-signaled connection.

The handoff's attempt metadata now also retains actor, action, target, purpose, and description. Same-location relevance remains `0` in the slice configuration. Generic multi-room relevance support remains available for Phase 6.

Known-fact repetition validation now consults both supplied context and the authoritative Notebook. Repeating a known fact is allowed when that evidence is the current target, but rejected on an unrelated action or return transition.

## Safe and desk route audits

Safe discovery is permitted only through authored routes:

- examine/manipulate the painting;
- inspect the paneled wall;
- Guillermo successfully examines the painting.

Fresh-session desk, receipt, rug, and fireplace interactions cannot reveal the safe. Permanent regression tests cover all valid and invalid triggers.

Desk processing remains clue-first. Focused desk examination identifies authored fibers before applying any mundane texture; receipts and correspondence remain separate addressable objects. The engine no longer needs the judgmental phrase “nothing consequential appears.”

## Bounded unsupported actions and mundane fiction

`polish.json` now contains engine-authored response categories for force against walls, force against furniture, and a default bounded disturbance. For example, Eldritch Blast against the paneled wall may make it shudder and shed plaster dust, but cannot create a clue, compartment, damage state, or permanent mutation.

Harmless mundane actions continue to receive bounded sensory or physical truth with optional `dry_humor_allowed`. Truth and agency remain above tone. The model styles engine facts; it does not decide mundane reality.

## Actionable referents and narrator validation

The narrator's allowed affordances now include current visible labels, authored aliases, exposed sub-referents, inventory, engine events, and authorized mundane results. The focused validator checks actionable nouns including drawers, letters, cabinets, boxes, keys, knives, chairs, notes, receipts, correspondence, gaps, dials, and frames.

Registered sub-referents include:

- desk receipts and correspondence;
- blood discoloration/stain aliases;
- scorch/burn-mark aliases;
- rope fibers;
- bookshelf gap after exposure;
- painting frame;
- safe dial and door after discovery.

Overview narration is separately rejected if it prematurely introduces dried blood, hemp cordage, magical discharge, occult cause, or an ordinary-fire conclusion.

## Active-roll feedback and anti-reroll behavior

The bridge returns `roll_feedback` only for active checks. Godot displays it as a secondary blue line beneath the fiction:

`🎲 Investigation • Success`

Prototype configuration supports:

- `minimal`: no indicator;
- `standard`: skill and five-degree outcome;
- `detailed`: roll, modifier, DC, and outcome for diagnostics.

The configured prototype mode is `standard`; raw numbers remain hidden. Passive checks, movement, mundane actions, parser clarification, and engine rejection show no die indicator.

Active checks are keyed by actor, action, target, skill, method, purpose, modifiers, pending clue tier, and relevant world state. An identical failed approach under unchanged conditions returns bounded no-new-information narration and no reroll. A changed method/modifier, actor, purpose, tier, or relevant state can permit a new check.

## Exemplars

Seven compact playability exemplars cover the six required categories plus successful movement grounding:

1. overview affordances without interpretation;
2. new fact with unrelated known context omitted;
3. dry mundane action;
4. bounded unsupported force;
5. active check without invented facts;
6. clue-bearing desk with mundane contents;
7. successful door movement without invented lock failure.

Only this focused set is loaded by the slice narrator, reducing average prompt size and avoiding unrelated exemplar bleed.

## 30-generation real-model diagnostic

The final diagnostic artifacts are `eval/narration_playability_diagnostic_raw.jsonl` and `eval/narration_playability_diagnostic_summary.json`.

| Measure | Result |
|---|---:|
| Turns | 30 |
| Meaningful | 17 |
| Mundane | 13 |
| First pass | 29 / 30 (96.7%) |
| Retried | 1 / 30 (3.3%) |
| Fallback | 0 / 30 (0%) |
| Average latency | 1.2552 s |
| Median latency | 1.0291 s |
| Maximum latency | 3.2748 s |
| Average prompt characters | 6,381.2 |
| Average output words | 21.0 |

Validator failures by category:

| Category | Count |
|---|---:|
| known_fact_repetition | 1 |
| unsupported physical object | 0 |
| state contradiction | 0 |
| premature interpretation | 0 |
| agency violation | 0 |
| continuity error | 0 |
| termination | 0 |
| tense/person | 0 |
| other | 0 |

The single first attempt repeated known evidence; the retry passed. No invalid output reached the player.

Diagnostic roll indicators:

- Success: 1
- Setback: 1
- Failure: 2
- Exceptional Success: 0
- Severe Failure: 0

## Fresh live replay

The final 13-turn bridge replay used the exact response contract Godot displays. It covered overview-only investigation, focused blood identification, Misty Step, Eldritch Blast against the wall, desk evidence, receipts, correspondence, active investigation, identical repetition, changed approach, painting, leaving, and returning.

| Measure | Result |
|---|---:|
| Resolved turns | 13 / 13 |
| Meaningful | 9 |
| Mundane | 4 |
| Mechanical successes | 1 |
| Mechanical failures | 1 |
| Setbacks | 0 |
| Parser clarifications | 0 |
| Engine rejections | 0 |
| Roll indicators displayed | 2 |
| Narrator retries | 0 |
| Fallbacks | 0 |
| Average live latency | 1.1400 s |

The first changed-state investigation failed and displayed `🎲 Investigation • Severe Failure`. Its identical repeat produced no roll. Adding a careful modifier permitted a fresh check, succeeded, and displayed `🎲 Investigation • Success`.

## Regression results

- Phase 2: passed.
- Phase 3: passed, including 15 grounding regressions.
- Phase 4: passed, 30/30 semantic fixtures and authority/logging checks.
- Phase 4.5: passed.
- Phase 5: passed, including 32 Notebook/evidence/ledger/serialization checks.
- Vertical slice: passed, 31 gameplay and safety scenarios.
- Slice narration polish: passed.
- Clue discovery sanity: passed.
- Intent resolution: passed, 59/59 deterministic paraphrases.
- Narration/playability: passed, all 24 required behaviors plus overview/exemplar checks.
- Godot 4.7.2 headless import: passed.

## Remaining risks and recommendation

The main remaining risk is process freshness: bridge changes require a prototype restart, and an old background bridge can make live behavior disagree with tests. Narrator variation remains model-dependent, but the final measured retry rate was low and fallback use was zero.

Recommendation: **replay again** in the visible Godot client, concentrating on whether standard roll feedback feels helpful rather than intrusive. If the presentation feels right, proceed toward Phase 6. The current measurements do not justify fine-tuning or another engineering polish pass first.
