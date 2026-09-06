# Game Systems and Rules v1.4 Delta

This delta amends `Game_Systems_and_Rules_v1.3.md` for the Phase 6 house slice. Unchanged provisions of v1.3 remain authoritative.

## Deterministic boundary rules

- The engine determines target resolution, reachability, clue tiers, observed facts, time, rolls, event latches, and state transitions before narration.
- Every visible object and exit is registered in one canonical noun table with a display name and authored aliases. Movement and investigation resolve through that table.
- Narrative vocabulary may describe registered referents but cannot make an unregistered noun actionable.
- Knowledge-conditioned mundane responses declare `observed_all` predicates. A response cannot imply an upstairs comparison, prior discovery, or other state the player has not observed.
- Events are latched state. Ambient lines are repeatable texture with a six-turn cooldown. The cellar footstep warning is an event, not ambient, and suppresses contradictory silence after it occurs.
- Perceptual salience is presentation metadata only. It does not change clue truth or automatically add Notebook knowledge.

## Mail object model

The exterior mailbox is a container and the accumulated mail is its content. The mail is not targetable until the mailbox is opened or Guillermo retrieves it. Investigation facts—including addressee, postmarks, and date span—belong to the mail clue, not to the container.

These rules preserve the foundational boundary: the engine establishes reality; the Narrative LLM interprets and narrates it.
