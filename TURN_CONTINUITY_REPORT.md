# Turn State, Routing, and Conversational Continuity Report

## Outcome

The Callum's Study loop now treats every ordinary turn as a clean intent, preserves only explicitly pending missing fields, and grounds narration in authoritative pre/post state. The safe requires a named authored route; questions read visible world state without rolls; true compounds clarify before execution; Godot omits null response fields.

## Root causes and fixes

False transitions came from narration receiving only the current location, without a pre/post location invariant. Resolutions now record `PreLocation` and `PostLocation`; unchanged locations reject room-transition language. Same-room Misty Step and state queries use deterministic event wording, while real door movement remains authorized.

The safe resolver previously treated a generic attempt as an implicit Finesse check, and the narration packet did not preserve `Method` explicitly. Generic locked-safe attempts now stop with route choices. Valid routes are an explicitly named crowbar/force attempt, lock manipulation/Finesse, or a known combination/dial route. No tool is selected silently.

Every intent is newly constructed with null optional fields and empty modifiers unless present in current input. A one-slot `PendingIntent` may carry only an incomplete command's authored fields while a fragment fills its missing target. It is consumed once and cleared by cancellation, compounds, queries, unrelated full commands, or reset.

The partially burned note remains in the safe when examined or read. Only `take` invokes authoritative inventory transfer. Resolution snapshots record note and crowbar location/owner, and narration validation rejects invented safe-to-desk movement, possession, and unsupplied crowbar use.

True multi-action/multi-actor compounds return clarification before either clause executes. Compact purpose phrases remain one action. `query_state` directly answers visible authoritative state, never rolls or mutates, and exposes no hidden conclusion.

Player-facing failures now say what is missing or unavailable. The ambiguous phrase “safe target” is gone. Godot checks JSON null values before string conversion, so absent narration or roll metadata cannot render as `<null>`.

## Telemetry

Bridge records include raw input, full structured intent, pending inheritance/event, compound detection, selected method/tool, whether the method was player supplied, pre/post player location, pre/post relevant item locations, routing family, query result, clarification reason, roll feedback, and narration validation.

## Regression results

- Phase 2–5 passed, including 30/30 Phase 4 fixtures and 32 Phase 5 checks.
- Vertical slice passed 31/31 scenarios.
- Intent polish passed 59/59 paraphrases.
- Narration/playability passed all 24 required behaviors plus grounding checks.
- The new continuity suite passed the exact A–H transcript cases and added turn-hygiene invariants.
- Godot headless import passed.

The new suite verifies clean method/purpose/modifier/spell/secondary-target fields, pending target-only inheritance, unrelated-command clearing, safe route enforcement, no narration-only player or item movement, compound atomicity, roll-free state queries, roll-feedback preservation, and null suppression.

## Fresh live replay

A clean bridge restart preceded an 18-turn HTTP replay using the response contract displayed by Godot. Detailed turns are in `eval/turn_continuity_live_replay.jsonl`; the machine summary is in `eval/turn_continuity_live_replay_summary.json`.

- Resolved: 15; clarification: 2; intentional engine rejection: 1.
- Stale method leaks: 0.
- False location transitions: 0.
- Partial compound executions: 0.
- State-query rejections: 0.
- `<null>` values rendered: 0.
- Unauthoritative item relocations: 0.
- Average live latency: 0.7727 seconds.
- Narrator retries: 2/18 (11.1%).
- Safe fallbacks: 2/18 (11.1%); both retained authoritative event wording.

The failed active investigation displayed one roll; two identical repetitions displayed none. A careful changed approach legitimately rolled again. Leaving changed `Player.Location` to the landing, returning changed it to the study, and only those turns narrated room transitions.

## Remaining risks and recommendation

Pending completion is deliberately narrow: it fills a single missing target and is not a general dialogue planner. State queries cover authored visible prototype objects, not arbitrary propositions. Free-model narration still varies, so validators and deterministic authority-sensitive responses remain important. Any future live/test mismatch should first trigger a bridge freshness audit.

Recommendation: **replay again** in the visible Godot client, especially safe-route phrasing and fragment completion. If those feel natural, proceed toward Phase 6; no additional architecture pass is presently indicated.
