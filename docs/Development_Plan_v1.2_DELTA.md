# Development Plan v1.2 Delta

This delta amends `Development_Plan_v1.1.md` for the Phase 6 full-house vertical slice. Unchanged provisions of v1.1 remain authoritative.

## Phase 6 completion correction

Phase 6 was previously reported complete while ordinary full-house turns bypassed the Narrative LLM. Commit `8412527` introduced a direct `Invoke-HouseTurn` response followed by `continue`, making the existing Comma narration path unreachable for those turns. That implementation did not satisfy the phase's narrator-routing acceptance criterion.

The correction is delivered by commits `2276dc0` through `286f488`. A Phase 6 house turn is complete only when:

1. The deterministic engine resolves intent, targets, state changes, observations, rolls, and events.
2. A structured narration packet exposes only currently grounded information.
3. The configured Narrative LLM renders player-facing prose for production turns.
4. Narration failure is loud and diagnosable; authored room prose is narrator input, not a silent substitute response.
5. Deterministic tests may explicitly request engine-only or mock narration, but production routing may not bypass narration.

## Added acceptance coverage

- Replay coverage proves noncombat house turns reach the narrator boundary.
- Every visible or actionable authored noun must bind to the canonical noun table.
- Knowledge-dependent prose requires explicit observed-fact predicates.
- Latched events and ambient texture have separate channels and persistence rules.
- Salience guides narration without granting clue status.
- Mail and mailbox are distinct world objects; mail becomes visible only after the mailbox is opened or Guillermo retrieves it.

This delta does not expand Phase 6 into stealth, combat redesign, or model-tuning work.
