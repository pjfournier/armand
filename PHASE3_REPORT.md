# Phase 3 Deterministic Rules and State Engine

## 1–2. What was built

Phase 3 adds a small authoritative engine beneath the existing narrator:

- `src/Characters.psm1`: prototype Armand and internal Guillermo profiles.
- `src/GameState.psm1`: authoritative locations, items, clues, NPCs, objectives, time, resources, inventory, and world changes.
- `src/Resolution.psm1`: deterministic d20 checks, DCs, margins, degrees, advantage/disadvantage, natural-roll adjustment, passive and automatic resolution.
- `src/Clues.psm1`: cumulative clue interpretation tiers.
- `src/NarratorHandoff.psm1`: deterministic attempt/outcome/state/event/visible/disclosure serialization.
- `src/CoreEngine.psm1`: structured-intent resolution and consequence application.
- `Test-Phase3.ps1`: rules, state, security-boundary, integration, and regression tests.
- `tests/handoff_regression_cases.json`: 15 permanent structured grounding cases.
- `Run-Phase3EndToEnd.ps1` and `eval/phase3_end_to_end_results.json`: two engine-to-Comma proofs.

`src/NarrationPacket.psm1` received one compatibility extension: an explicit attempt description can replace raw action/target serialization. Existing Phase 2 cases remain supported.

## 3. State model

`New-GameState` owns the authoritative player, Guillermo, NPC, location, item, clue, objective, time, and world-change collections. Inventory transfers, item changes, NPC movement, spell-slot spending, and time advancement mutate only this state through explicit functions. Narrator handoffs are deep-copied data and retain no mutable state reference.

NPC records contain current location, awareness, suspicion, search state, goal, knowledge references, and target. Time tracks turns, elapsed minutes, and current case time. No scheduler or NPC AI was added.

## 4. Resolution

Active checks implement `d20 + skill modifier + situational modifier` against the fixed DC ladder. Margins map to Exceptional Success, Success, Setback, Failure, and Severe Failure. Natural 20 and 1 move one degree within the allowed range; an impossible action remains impossible. Advantage and disadvantage select the higher or lower of two rolls. Tests can provide fixed rolls or deterministic seeds.

The caller explicitly selects active, passive, or automatic resolution. A separate policy predicate captures when meaningful uncertainty warrants rolling.

## 5–6. Characters

Armand is represented at level 3 with the supplied prototype HP, AC, gold, skill modifiers, passive scores, spells, two second-level pact slots, spell attack, and save DC. This is not a full D&D character engine.

Guillermo has the supplied internal abilities, skills, advantage hooks, passive Awareness, movement, darkvision, 12 HP, mortality/availability, distraction tags, and Early communication tier. The player-facing serializer exposes only identity, availability, location, life state, and communication tier—not abilities, skills, Nerve, darkvision, or other hidden numbers.

## 7. Clue tiers

Clues retain ordered skill/DC/fact tiers, discovered state, highest tier, and cumulative known facts. Passive or active scores reveal every satisfied tier; failure leaves the clue in authoritative state and does not delete it.

## 8–12. Safe narrator handoff

The handoff contains only:

- `Attempt`: actor plus a neutral attempt description.
- `Outcome`: resolved degree.
- `PostActionState`: what is true now.
- `Events`: what occurred this turn.
- `Visible`: atomized visible objects.
- `NpcDisclosure`: distinct `Discloses` and `Withholds` lists.

Raw engine verbs are not serialized as completed events. `steal` becomes “tries to take,” `open` becomes “attempts to open,” and `climb` becomes “tries to climb.” Outcome and authoritative mutation remain separate. Visible objects stay an array with no causal edges, and state is never converted into an event such as “the door closed.”

## 13–14. Tests

`Test-Phase3.ps1` passes all requested rule and state categories, including every degree, natural rolls, advantage/disadvantage, seeded randomness, auto/passive checks, clue discovery/advancement, mutation, inventory, spell slots, time, NPC movement, objectives, failed/success/setback consequence gating, bounded disclosure, deep-copy isolation, and Guillermo data hiding.

The permanent hard-grounding regression suite passes **15/15** structured cases: failed steal/open/take/climb, inaccessible clue, bounded disclosure, preserved event, bounded Detect Magic, Guillermo retreat, unchanged item, non-causal visible state, partial success, setback consequence, spell slot, and inventory transfer.

## 15. Armand end-to-end test

- Intent: investigate fireplace.
- Skill/DC: Investigation +4 versus 15.
- Fixed roll/total: 13 / 17.
- Degree: Success.
- Engine state: `scorch_marks_observed: true`.
- Event: `scorch marks are discovered`.
- Attempt: `Armand examines fireplace.`
- Comma: “You examine the fireplace. The grate is cold, but a few scorch marks show on its surface.”

The pipeline works, but Comma adds “the grate is cold,” which the handoff did not assert. This reinforces that the Phase 2 model remains below production grounding standards; it does not affect engine authority.

## 16. Guillermo failed-steal end-to-end test

- Intent: steal brass key.
- Skill/DC: Finesse +5 versus 15.
- Fixed roll/total: 4 / 9.
- Degree: Failure.
- Authoritative state: key remains on hook; Guillermo inventory unchanged.
- Events: key rattles; Guillermo retreats.
- Attempt: `Guillermo tries to take brass key from the hook.`
- Comma: “You see Guillermo try to take the brass key from its hook. The key rattles, and he retreats.”

No successful theft wording reaches the handoff or narration.

## 17. Failed-action serialization

Within the supported action mapping, failed steal, take, open, unlock, climb, persuade, investigate, and cast actions cannot serialize as completed actions because handoff generation uses neutral attempt language regardless of degree. Unknown actions use the deterministic fallback “attempts to …”. The 15-case regression checks representative dangerous verbs.

## 18. Compatibility

The Phase 2 test suite passes unchanged except for its new compatible attempt field support. The Phase 1 raw-completion smoke path also remains available and is verified separately before delivery. The 11 exemplars and Phase 2 sampling configuration were not changed.

## 19. Open issues

- Comma can still infer unsupported sensory state from clean handoff data.
- Content-specific consequences and post-action fields must be authored by future game content; this phase intentionally provides the deterministic mechanism, not a complete mystery.
- Full combat remains unimplemented. Phase 4.5 has since locked the Callum house prototype as a stealth/evasion/observation encounter; see `PROTOTYPE_COMBAT_DECISION.md`.
- Natural-language intent interpretation, save/load, scheduling, full NPC behavior, and UI remain later-phase work.

Commit and branch are recorded in the delivery message after final verification and push.
