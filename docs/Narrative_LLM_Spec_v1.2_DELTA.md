# Narrative LLM Specification v1.2 Delta

This delta amends `Narrative_LLM_Spec_v1.1.md` for the full-house narration boundary. Unchanged provisions of v1.1 remain authoritative.

## Full-house production handoff

The deterministic engine remains the authority on reality. It supplies the Narrative LLM with a structured packet containing player input, current room, visible referents, resolved facts, observed facts, world events, ambient detail, roll feedback, and authorial intent. The model may render those facts but may not create state, clues, exits, targets, or outcomes.

`VISIBLE_REFERENTS` is the prompt whitelist. Entries provide player-facing names, aliases, and perceptual salience; canonical engine IDs are not player-facing vocabulary. Generated prose is checked against the current noun boundary before display.

Authored room `overview` text is `AUTHORIAL_INTENT`: grounded scene guidance for the narrator. It is not an automatic fallback response. A missing, invalid, or rejected completion produces a conspicuous development narration error and a diagnostic record in `eval/house_narration_errors.jsonl`.

## Channel semantics

- `RESOLVED_FACTS` contains facts established by the current resolution.
- `OBSERVED_FACTS` contains knowledge already earned by the player and safe to reference.
- `WORLD_EVENTS` contains stateful or one-shot occurrences.
- `AMBIENT` contains non-state-changing texture selected independently with cooldown.
- Salience (`dominant`, `notable`, or `texture`) guides attention but never implies cluehood.

Tests may inject an explicit mock narrator to verify packet integrity deterministically. Production house turns must use the configured Comma backend; a direct engine-prose path is not an acceptable successful production response.
