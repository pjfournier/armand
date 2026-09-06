# Pre-Phase-6 Interaction, Notebook, and Narrative Depth Report

## Outcome

Callum's Study now answers the named interaction more faithfully and usually renders it in two to four compact sentences. Overview observations cannot grant interpreted Notebook facts; gestures remain nonverbal; property questions preserve their property; true compounds stop before execution; drawers never become papers; and richer prose is rejected whenever it drifts from the engine's target or state.

## Knowledge and clue pacing

The reported blood leakage was not in `Resolve-ClueInterpretation`: overview exposed referents, while interpreted Notebook facts are written only when clue resolution reaches a tier and synchronizes it. The missing protection was a permanent cross-clue invariant test. Fresh overview now exposes a dark discoloration, coarse fibers, and unusual dark patterns while leaving Notebook clue facts empty. Automated assertions verify every displayed Notebook fact is contained in the matching authoritative clue's `KnownFacts`.

The hemp ladder was deliberately revised:

1. Overview: coarse fibers caught on the scratched desk.
2. Focused Awareness: recognizable as rope fibers.
3. Active Investigation DC 20: hemp cordage.
4. Active Investigation DC 25: condition consistent with rope pulled tightly across the surface.

Blood and scorch use the same overview-without-interpretation invariant. Dried blood and ordinary-fire inconsistency appear only after focused observation; higher implications require active resolution.

## Interaction routing

- `gesture` handles waving, whistling, pointing, beckoning, snapping, clapping, smiling, and petting without converting them to speech. Early-tier Guillermo responds only through movement, posture, gesture, or vocalization.
- `query_property` carries `target`, `property`, and raw input. Authored approximations answer height, size, width, distance, color, weight, and depth without rolls or false precision.
- Compound detection runs before action routing. True action/action or multi-actor requests clarify without mutation; purpose-bearing phrases remain single actions.
- Exact drawer aliases route to `desk_drawers`. The authoring decision is that the desk has decorative drawer fronts but no accessible drawers. The response states that directly and never substitutes correspondence.
- Window open/closed state is now authoritative. The natural typo-bearing input `got to window and try to open it` resolves to opening the window rather than unrelated movement.

## Narration policy and safety

Seven targeted exemplars cover an atmospheric ordinary examination, dry humor, Guillermo gesture, property query, bounded clue discovery, correspondence, and failed active check. Each exemplar is two to four sentences. Runtime selects only the relevant small subset, reducing prompt size while retaining `NEW_THIS_TURN` and `KNOWN_CONTEXT` separation.

Ordinary narration targets two to four worthwhile sentences; trivial queries and transitions may remain shorter, and major reveals may reach five. The sensory budget is one or two grounded details drawn from rain, gaslight, cold brass, paper, wood, dust, soot, wool, stone, and other authored/persistent atmosphere.

Validation now rejects foreign-target evidence, invented follow-on actions, false desk/drawer structure, moved blood evidence, unsupported higher-tier fiber implications, player decisions, Guillermo speech, internal engine vocabulary, verbatim repeated sentences, and outputs longer than five sentences. Existing location, item, clue-tier, affordance, agency, and known-context checks remain active. Engine phrases such as “harmless experiment,” “mundane result,” and “safe target” cannot reach the player.

Dry-humor examples include the drawer joinery declining cross-examination, dust offering no amendment to its account, bureaucracy surviving an attempt to make correspondence interesting, and Guillermo treating a returned wave as official business.

## Notebook UI

The layout had one dense rich-text stream without explicit title hierarchy, line separation, or robust scrolling configuration; no duplicate clue-node path was found. Clue titles now use larger gold styling, entries receive explicit vertical separation, long text wraps inside a non-fit-content scrolling view, selection remains enabled, and theory text receives the same line-height/scroll treatment.

The headless layout regression builds 1, 4, and 10 clues, long facts, repeated refreshes, and multiple theories. It verifies clean rebuild counts and active scrolling; all cases pass.

## Exact transcript regressions

All eight latest-play inputs pass:

- Guillermo wave/whistle → `gesture`, no question or speech.
- Window approach/open phrase → window opens, no engine classification wording.
- Window-height question → `query_property(height)`, waist-height approximation, no roll.
- Close-window plus desk-look → clarification, neither clause executes.
- Desk-top look → `writing_desk / on_top`; focused rope-fiber tier only.
- Drawer/paper search → `desk_drawers`, explicit no-accessible-drawers response.
- Letters → authored correspondence with bounded dry humor.
- Fresh overview → no dried blood, hemp cordage, or ordinary-fire interpretation in Notebook.

## Thirty-generation quality diagnostic

Artifacts: `eval/pre_phase6_narrative_quality_raw.jsonl` and `eval/pre_phase6_narrative_quality_summary.json`.

- Turns: 30.
- Average sentences: 2.27.
- Average words: 24.5.
- Atmospheric-detail outputs: 12/30.
- First pass: 25/30 (83.3%).
- Retried: 5/30 (16.7%).
- Safe fallback: 5/30 (16.7%).
- Average prompt size: 3,317.9 characters.
- Average narration latency: 0.9166 seconds.
- Most common validation failure: wrong-target content (7 validator firings).

No invalid generation was displayed. The remaining raw-generation weakness is exemplar/subject drift under richer prose; the stricter validator converts it to grounded engine wording rather than accepting atmosphere attached to the wrong object.

## Fresh live replay

A clean bridge restart preceded the 22-turn replay in `eval/pre_phase6_live_replay.jsonl`; summary data is in `eval/pre_phase6_live_replay_summary.json`.

- Resolved: 20; clarification: 1; intentional safe-route rejection: 1.
- Overview Notebook leaks: 0.
- Gesture dialogue violations: 0.
- Property-target errors: 0.
- Partial compound executions: 0.
- Drawer substitutions: 0.
- Internal-language leaks: 0.
- Average sentences: 2.00.
- Average words: 21.8.
- Average live latency: 0.9463 seconds.
- Narrator retries: 5/22; safe fallbacks: 5/22.

The failed blood investigation displayed a roll; two identical repetitions displayed no roll; a changed careful approach rolled again. The live prose felt more atmospheric on overview, correspondence, window, blood, and Guillermo turns. Authority-sensitive fallbacks remained shorter, which is preferable to accepting attractive but incorrect prose.

## Regression results and recommendation

- Phase 2–5: passed, including 30/30 Phase 4 fixtures and 32 Phase 5 checks.
- Vertical slice: 31/31 passed.
- Intent polish: 59/59 passed.
- Narration/playability: all 24 required behaviors passed.
- Turn continuity: all exact and hygiene regressions passed.
- Pre-Phase-6 depth suite: overview, Notebook authority, gestures, properties, compounds, exact targets, tiers, prose safety, and exemplars passed.
- Godot 4.7.2 import and Notebook layout tests passed.

Remaining risk is model-level subject drift when asked for richer prose. Validation contains it, but the measured fallback rate is still visible. Recommendation: **replay once more** in the visible client to judge the balance between richer prose and concise fallbacks. Do not fine-tune yet; if the replay feels good, proceed to Phase 6.
