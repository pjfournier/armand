# Phase 2 Gate 1 Report

## Result: Fail — architecture warning

The selected facts-style packet with eight exemplars produced **10 fully passing samples out of 20**. Gate 1 requires at least 14/20, with every passing sample satisfying every criterion. The result therefore triggers the task's stop condition. The held-out 50-case regression was not run.

| Criterion | Passing samples |
|---|---:|
| Grounded in packet | 11/20 |
| Direct second-person present prose | 20/20 |
| Preserves player agency | 17/20 |
| Preserves Armand/Guillermo identity | 20/20 |
| Register fit | 20/20 |
| All five criteria | **10/20** |

## Findings

The exemplars solve the broad conditioning problem: no sample drifted into dataset form, third-person Armand, a speaking Guillermo, or generic chapter prose. The remaining failure is architectural rather than cosmetic. A prose completion model can still reverse a deterministic outcome or decorate a fact into a new observation:

- Gate 09 opens a cabinet that the packet explicitly says remains locked.
- Gate 06 invents the room shaking and assigns the player a sensation.
- Gates 16 and 17 turn bounded NPC disclosures into blanket refusals.
- Several other cases add or relocate physical evidence.

These defects cannot be made safe by post-processing without violating the raw-completion requirement. Phase 3 should not begin until the project owner chooses whether to revise prompting/model strategy or introduce an explicit constrained-verification architecture.

## Method and evidence

All samples used the selected condition, temperature 0.35, fixed seeds 5101–5120, and no hand edits. `eval/gate1_B_raw.jsonl` preserves the exact model continuation, the stop-marker-trimmed assembled narration, validator flags, settings, and runtime data. `eval/gate1_scores.json` contains the five manual judgments and a reason for every failure.

The machine validator is intentionally report-only. It catches forbidden lexical terms, player first-person drift, common agency phrases, dataset headings, third-person Armand patterns, and length. Human grounding review remains authoritative because semantic contradictions such as “force open” versus “remains locked” are not safely reducible to lexical rules.
