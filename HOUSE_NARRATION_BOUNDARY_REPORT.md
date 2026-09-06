# Phase 6 Narration Boundary Closeout

## Finding

Commit `8412527` made the Comma narrator unreachable for ordinary full-house turns by returning the direct `Invoke-HouseTurn` result and continuing the bridge loop. The deterministic engine remained functional, so engine-only tests passed while the live architecture violated the Phase 6 narration requirement. No project record identified this bypass as an intentional model-quality mitigation.

## Corrections

- Added a red replay for the narration boundary.
- Added a structured house narration packet and restored production Comma routing.
- Converted authored overviews into narrator guidance with loud failure behavior.
- Removed the unreachable duplicate Study bridge path.
- Bound objects and exits to a canonical noun table and added content linting.
- Gated prose on observed facts.
- Separated persistent events from cooldown-controlled ambient texture.
- Added perceptual salience without changing clue truth.
- Restored diegetic house voice and separated the mailbox container from its mail.

## Scope held

Combat presentation, stealth mechanics, and model tuning were not changed. Existing Study behavior outside the unreachable duplicate bridge block was not redesigned.

## Verification targets

The closeout requires the complete PowerShell test suite, the focused boundary replay, the Phase 6 deterministic suite, the full-house replay, and Godot headless project validation. Live narration quality is evaluated separately from boundary correctness: a weak completion is a model-quality concern; a bypass or fabricated state is a boundary defect.
