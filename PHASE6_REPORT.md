# Phase 6 — The Full House

Phase 6 extends the existing vertical slice into a complete, traversable prototype house. Play begins outside in the rain. The locked front door directs exploration toward two discoverable entries, through the kitchen or the cellar, and both join the same fixed seven-location topology.

## Delivered

- Seven authored locations: exterior, cellar, kitchen, living room, bedroom, bathroom, and Callum's study.
- Twenty-three clues total and more than thirty-three mundane object responses.
- Addressable authored props with `static-renderable` or `animate-excluded` classification.
- Sparse room-specific ambient cues and Early-tier Guillermo investigation opportunities.
- A clue-gated, one-time encounter with a full warning turn. Stealth, evasion, social, and combat remain valid responses. The encounter is deliberately suppressed while Armand remains in the cellar.
- Persistent combat aftermath, ordered invariant save serialization, and save/load bridge routes.
- A three-pane Godot shell: fixed-aspect location placeholder, load-bearing transcript, and collapsible Notebook. Split positions persist in `user://layout.cfg`.
- The endpoint remains a lead only: Blackthorn Station at midnight tomorrow, without naming a culprit, group, motive, or solution.

## Verification

- `Test-Phase6.ps1`: 35/35 checks passed.
- Phase 2–5, vertical-slice, polish, continuity, clue, combat, and combat-affordance regression suites all passed.
- Godot 4.7.2 editor import and headless scene launch completed without parser errors.
- The live persistent bridge replay reached the lead in 16 turns after three clues and a stealth encounter resolution. The captured prompt/response transcript is in `eval/phase6_full_house_replay.json`.
- Save/load produces byte-identical ordered JSON, including fixed-precision floating-point values.

## Run it

From PowerShell in `C:\armand`:

```powershell
.\Start-Prototype.ps1
```

Enter natural-language actions in the bottom command box. A useful opening is `look around`, then `circle the house`; either newly exposed entry route is valid.
