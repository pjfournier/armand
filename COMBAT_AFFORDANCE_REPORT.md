# Combat Affordance Surfacing Report

## Outcome

Authored environmental maneuvers are now visible and executable through the existing freeform combat input. The implementation adds no second input, no look-around tax, no dynamic affordance generation, and no combat-only nouns.

The balance result is mixed: the Study oil-lamp maneuver is materially better than a generic damage-free creative maneuver, but it does not consistently beat straight Eldritch Blast. In the two-Cultist benchmark it produced 20% survival versus 30% for direct attacks. The authored payoffs were not adjusted after measurement.

## Content and noun authority

`content/combat_affordances.json` contains exactly sixteen affordances across seven rooms:

| Room | Count |
|---|---:|
| Exterior | 2 |
| Living room | 2 |
| Kitchen | 2 |
| Bathroom | 1 |
| Bedroom | 2 |
| Study | 4 |
| Cellar | 3 |

Each entry contains its stable ID, existing `referent_id`, player label, contextual panel hint, skills, single-use flag, semantic position requirement, authored opening prose, and all five degree outcomes. The v1.1 supplement provides explicit Success, Setback, and Failure results plus a standard rule for Exceptional and Severe extensions; the content encodes those extensions without adding raw damage.

Content loading fails immediately if an affordance refers to an object absent from its room inventory. The currently playable Study receives real `oil_lamp` and `fire_irons` objects alongside the existing writing desk and painting. The other room inventories live with their future-facing affordance content and do not make those rooms playable early.

## Runtime and UI

`Read-CombatAffordanceContent` validates referents and all five outcome keys. `Get-CombatAffordances` filters by current semantic position, omits spent single-use entries, preserves authored proximity order, and caps the public list at four.

The Godot combat panel now displays:

- the current turn economy;
- Armand’s semantic position and engaged enemy;
- a `Nearby:` line built from `panel_hint` values;
- at most four valid affordances.

The opening combat beat is assembled exclusively from authored `opening_text` fields and appears once per encounter. Neither the model nor combat narrator may add affordances.

## Resolution and persistence

Matching is performed against authored labels, panel hints, and referent names. The selected maneuver uses the established DC/margin ladder and emits `🎲 Skill • Degree`. Every degree applies the matching bounded outcome. Effects include action or movement denial, prone, disadvantage, cover, repositioning, route control, and escape support; no affordance inflicts direct damage.

Persistent outcomes enter authoritative `room_changes`. Single-use objects become spent even when an attempt goes badly, disappear from the nearby list, and cannot be rerolled in unchanged state. The bridge synchronizes room changes into the investigation session’s persistent environment and referent state. Subsequent investigation resolution includes deterministic aftermath text in the narrator packet. A painting failure also reveals the existing safe authoritatively.

## Expanded balance benchmark

The benchmark now runs six strategies over 20 deterministic seeds for all five matchups. The sixth strategy uses the Study oil lamp once, then attacks normally.

| Matchup | Straight | Generic creative | Study affordance | Darkness | Flee |
|---|---:|---:|---:|---:|---:|
| One Initiate | 100% | 100% | 100% | 100% | 100% survival / 100% escape |
| One Cultist | 95% | 60% | 75% | 100% | 100% survival / 100% escape |
| Two Cultists | 30% | 15% | 20% | 60% | 75% survival / 80% escape |
| Adept | 20% | 15% | 30% | 30% | 85% survival / 100% escape |
| Adept + Initiate | 15% | 10% | 10% | 15% | 55% survival / 55% escape |

Against an Adept, action denial lets the lamp compete with Darkness and outperform direct trading. Against one or two Cultists it improves on the generic maneuver but remains below direct attacks. Against Adept + Initiate, spending the opening Action is generally too slow. This suggests authored affordances are situationally viable rather than universally dominant, but the marquee maneuver still needs evaluation in a real encounter sequence before any tuning decision.

Full win, escape, survival, average-round, and per-seed results are in `eval/combat_balance_results.json`.

## Verification

- Combat affordance suite: **20/20 passed**.
- Combat prototype suite: **36/36 passed**.
- Phase 2–5 suites: passed.
- Vertical slice: 31 scenarios passed.
- Intent resolution: 59 checks passed.
- Narration/playability: 24 required behaviors passed.
- Turn continuity and Pre-Phase-6 depth suites: passed.
- Godot 4.7.2 headless import: passed after the panel update.
- Live bridge: four authored Study hints and authored opening prose returned; lamp resolution persisted `floor_fire` into investigation state.

Run `.\Test-CombatAffordances.ps1` and `.\Run-CombatBalanceBenchmarks.ps1` to reproduce the focused validation and balance matrix.
