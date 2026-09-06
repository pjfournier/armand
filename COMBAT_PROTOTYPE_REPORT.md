# Combat Prototype Pass Report

## Outcome and recommendation

The prototype answers the pass question positively: combat can use the same natural-language interface and deterministic authority as investigation. The recommendation is **keep combat, then rebalance it** before Phase 6 content integration. The turn model is understandable and fast, Darkness creates a meaningful survival swing, fleeing reconnects cleanly to stealth, and the Adept is threatening. The benchmark also exposes tuning work: Darkness is very strong, one Cultist is currently forgiving, and damage-free creative maneuvers need stronger follow-through to compete with Eldritch Blast.

This is deliberately not a complete 5e system. It contains no grid, pathfinding, bestiary, generic spell/condition engine, equipment combat, loot, or new mystery content.

## Architecture and authority

`src/CombatPrototype.psm1` owns combat parsing, validation, initiative, turn advancement, rolls, HP, temporary HP, semantic position, effects, reactions, enemy decisions, end conditions, and public-state projection. `content/combat_prototype.json` contains exactly three tiers and exactly three benchmark encounters. The bridge routes `/action` through combat only while combat is active; otherwise the established investigation interpreter/resolver remains authoritative. Narration is assembled only after state resolution and cannot mutate combat state.

The public state tracks active status, initiative order and active combatant, turn number, HP/temp HP, alive/incapacitated status, semantic position, engagement, three budgets, reaction availability, effects, Darkness, awareness, pursuit, layer, and end reason. RNG seed/index, attack internals, priorities, and other implementation details are excluded from Godot-facing state.

## Turn economy, initiative, and parsing

Each normal turn has one semantic Movement and one Action. Armand has a Bonus Action only for an eligible Guillermo command and a Reaction for Hellish Rebuke. Initiative is rolled once as d20 + Dexterity and sorted deterministically for ties. Enemies then resolve in order until Armand acts again.

The parser separates free text into Movement, Action, and optional Guillermo command. Compounds such as “Move behind the desk and cast Eldritch Blast” resolve both parts. Misty Step consumes Movement. Two movements or two actions return a targeted clarification and silently discard nothing. Positions are labels such as engaged, desk, doorway, and adjacent room; there is no distance grid.

Traditional attacks roll d20 + 5 against AC and deal 1d10 force/fire on a hit. Active roll feedback is concise. Creative shove, trip, environmental, deception, and intimidation actions use the existing five-degree margin ladder with bounded consequences. Identical creative actions in unchanged state do not reroll, while a normal attack remains repeatable on later turns.

## Guillermo, reactions, and class features

Early-tier minor Guillermo commands—reposition, nearby retrieval, scouting, signals, and simple uncontested distractions—use the Bonus Action. Consequential sabotage, theft, contested distraction, or tactical-state manipulation uses the Action. Guillermo retains 12 prototype HP and can be injured or killed. The authored progression hook reserves later Bond tiers for consequential commands as Bonus Actions and eventually a limited independent turn; those upgrades are not implemented.

An enemy hit may pause advancement for a Yes/No Hellish Rebuke prompt. Resolving it consumes the Reaction but not the next Movement or Action. A decisive hostile defeat, including surrender, rout, or incapacitation, grants Dark One’s Blessing as 6 temporary HP.

## Darkness, movement, fleeing, and enemy behavior

Darkness marks a semantic area. Devil’s Sight allows Armand to attack there with advantage; enemies unable to see there avoid blind trading and may leave, guard the edge, spread pressure, or pursue according to authored priorities. This keeps Darkness powerful without making it a state-erasing win button.

Leaving an engaged enemy for an adjacent room spends Movement and permits one normal opportunity attack per eligible enemy. Hide then spends the Action and resolves Stealth against the highest pursuing enemy passive Perception. Success ends combat with `escaped_and_hidden` and returns the authoritative layer to stealth. Pursuit is per-enemy: injured Initiates retreat, Cultists pursue, and an Adept orders pursuit.

Enemy AI is a small rule set, not a planner. Initiates may retreat when badly injured; Cultists leave Darkness and guard exits; the Adept opens with one authored `shadow_bind` behavior and can order pursuit. Otherwise enemies attack or pursue. Combat may end through incapacitation, surrender, enemy flight, successful escape/hide, or another authored hostility-ending event.

## Enemy tiers and encounters

| Tier | AC | HP | Attack | Damage | Authored role |
|---|---:|---:|---:|---:|---|
| Initiate | 11 | 6 | +2 | 1d6 | Weak pressure; retreats when badly injured |
| Cultist | 12 | 11 | +3 | 1d6+1 | Standard threat; dangerous in pairs |
| Adept | 13 | 18 | +4 | 1d8+2 | Major threat; one-use shadow bind |

The only authored encounters are A: one Initiate, B: two Cultists, and C: Adept plus Initiate. The Godot debug controls start these three benchmarks without adding mystery content.

## UI and narration

The first combat in a bridge session displays the requested one-time tutorial. Later fights show a compact panel with order, active combatant, semantic positions, and Movement/Action/Bonus Action availability. Players still type in the existing input; there are no spell or attack buttons. Hellish Rebuke uses a focused Yes/No dialog. Combat output states the action, outcome, position, pressure, and next actor in concise engine-grounded sentences.

## Automated and regression results

- Combat prototype: **36/36 passed**, covering all 32 required checks plus exact content count, tutorial lifecycle, Adept magic, and creative anti-reroll.
- Phase 2: passed.
- Phase 3: passed, including 15 grounding regressions.
- Phase 4: passed, 30/30 semantic fixtures.
- Phase 4.5: passed.
- Phase 5: passed, 32 checks.
- Vertical slice: passed, 31 scenarios.
- Intent/action polish: passed, 59 checks.
- Narration/playability: passed, 24 required behaviors.
- Turn continuity: passed.
- Pre-Phase-6 depth polish: passed.
- Godot 4.7.2 headless import: passed.

Run `.\Test-CombatPrototype.ps1` for the combat suite and `.\Run-CombatBalanceBenchmarks.ps1` to regenerate the seeded matrix.

## Seeded balance simulation

The matrix used 20 deterministic seeds for each of five matchups and five strategies: straight Eldritch Blast, Darkness then Eldritch Blast, immediate flee/hide, a minor Guillermo command alongside attacks, and one creative maneuver followed by attacks. These are prototype observations, not a claim of balance.

| Matchup / strategy | Survival | Win | Escape | Avg rounds |
|---|---:|---:|---:|---:|
| Initiate — straight | 100% | 100% | 0% | 1.35 |
| Initiate — Darkness | 100% | 100% | 0% | 2.30 |
| Cultist — straight | 95% | 95% | 0% | 3.75 |
| Cultist — Darkness | 100% | 100% | 0% | 4.40 |
| Two Cultists — straight | 30% | 30% | 0% | 4.85 |
| Two Cultists — Darkness | 60% | 60% | 0% | 5.95 |
| Two Cultists — flee | 75% | 0% | 80% | 1.05 |
| Adept — straight | 20% | 20% | 0% | 4.10 |
| Adept — Darkness | 30% | 30% | 0% | 5.05 |
| Adept — flee | 85% | 0% | 100% | 1.65 |
| Adept + Initiate — straight | 15% | 15% | 0% | 3.35 |
| Adept + Initiate — Darkness | 15% | 15% | 0% | 4.40 |
| Adept + Initiate — flee | 55% | 0% | 55% | 1.25 |

Full per-seed data and all 25 aggregates are in `eval/combat_balance_results.json`.

### Findings

- One Movement + one Action reads clearly in both successful compounds and targeted over-budget clarification.
- Straight combat against one Initiate is comfortably survivable; one Cultist may be too forgiving at 95% survival.
- Two Cultists are dangerous in a straight exchange (30% survival), and Darkness materially improves survival to 60%.
- The Adept and Adept+Initiate are appropriately frightening in direct exchanges. The latter remains dangerous even with Darkness because the enemies leave and pressure its edge.
- Fleeing is viable but not free: opportunity attacks reduce survival, especially against multiple enemies. Successful hiding cleanly returns to stealth.
- Minor Guillermo utility does not change attack odds in this initial benchmark, so it neither becomes mandatory nor imposes a penalty when paired with an Action. More authored environments are needed to measure its tactical value.
- The tested creative maneuver costs an Action without direct damage; its benchmark survival trails direct attacks. Phase 6 content should give authored maneuvers stronger positional payoffs rather than raising generic bonuses.
- No free-reroll or repeated Bonus Action exploit appeared. Darkness is the dominant fighting strategy against two Cultists, but immediate escape is the safer non-victory choice in bad fights.

## Live runtime

A clean local bridge replay ran 20 fresh combat starts and natural Movement+Darkness turns. Average HTTP turn latency was **0.0079 seconds**, p95 **0.0129 seconds**, with **0 narration retries** and **0 fallbacks**. Combat narration is deterministic and engine-authored in this prototype, so it avoids model latency while preserving the established grounded output boundary.
