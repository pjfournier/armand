# Phase 2 Narrative Gate — Final Report

## 1. What was built

Phase 2 now has a narrow narrator packet API, immutable Armand and Guillermo identity anchors, two completion-shaped packet formatters, eight few-shot exemplars, lexical and structural validators, a resumable evaluation runner, held-out case data, raw JSONL evidence, and human-scored diagnostic and Gate 1 reports. No game engine, Phase 3 system, chat wrapper, LoRA, or fine-tuning code was added.

## 2. Files created or modified

- `src/NarrationPacket.psm1`: restricted packet construction and both formats.
- `src/NarrationPrompt.psm1`: exactly-eight exemplar loading and prompt assembly.
- `src/NarrationValidation.psm1`: report-only lexical and structural checks.
- `exemplars/narration_exemplars.json`: the eight authored patterns.
- `Run-Phase2Eval.ps1`: diagnostic, Gate 1, and preserved regression runner modes.
- `Test-Phase2.ps1`: packet, prompt, raw-preservation, lexical, agency, and dataset-form tests.
- `phase2_config.json`: selected sampling and packet settings.
- `eval/*.json` and `eval/*.jsonl`: cases, scores, baseline preservation, and raw runs.
- `DIAGNOSTIC_REPORT.md` and `GATE1_REPORT.md`: detailed evaluation reports.
- `.gitignore`: ignores transient evaluation work files.

## 3–5. Packet formats, diagnostic, and winner

The diagnostic tested facts-style and literary/editorial-style packets, each with zero and eight exemplars, on the same six cases and seeds.

| Condition | Packet | Exemplars | Grounded | Form | Agency | Identity |
|---|---|---:|---:|---:|---:|---:|
| A | facts | 0 | 0/6 | 6/6 | 0/6 | 0/6 |
| B | facts | 8 | **4/6** | 6/6 | 6/6 | 6/6 |
| C | literary | 0 | 0/6 | 0/6 | 0/6 | 0/6 |
| D | literary | 8 | 2/6 | 6/6 | 6/6 | 6/6 |

Condition B won because grounding is decisive. Eight exemplars materially changed behavior; the facts-style framing then produced fewer unsupported additions than the literary framing.

## 6. Final generation settings

- Raw base-model completion; no chat or instruction wrapper
- Facts-style packet with all eight exemplars
- Temperature 0.35, top-p 0.95, top-k 40
- Repetition penalty 1.1
- Maximum 224 generated tokens
- Reverse prompt `\nFACTS`
- Fixed per-case seeds; full CUDA offload retained

## 7. Eight exemplars

The corpus covers: entering a location, successful investigation, setback, failure that changes the situation, gesture-only Guillermo reaction, mundane/irrelevant search, NPC disclosure, and return to a changed location. None comes from the held-out 50-case suite.

## 8–9. Gate 1 and verdict

| Axis | Pass |
|---|---:|
| Grounding | **11/20** |
| Form | 20/20 |
| Agency | 17/20 |
| Register | 20/20 |
| Identity (additional measurement) | 20/20 |
| All criteria | 10/20 |

**Verdict: ARCHITECTURE WARNING.** Grounding is below the fixed 14/20 threshold. Per the explicit stop rule, work stopped before the 50-case regression rather than silently changing narrator scope or model architecture.

## 10–11. Regression and Phase 1 comparison

The original 50 prompts, seeds, and raw baseline outputs are preserved in `eval/baseline_50.json`, and the runner supports `-Suite regression`. The regression was **not executed** because Gate 1 triggered an architectural decision. Consequently no Phase 2 `/50` figures or quantitative baseline comparison are claimed.

Qualitatively, few-shot conditioning clearly fixes the Phase 1 baseline's dominant form and identity drift: Gate 1 has 20/20 form and identity stability. It does not yet fix the decisive grounding problem.

## 12. Remaining failure modes

- Explicit outcome reversal, such as opening a cabinet that remains locked.
- Decorative physical details becoming new state or evidence.
- Relocation or reinterpretation of a supplied observation.
- NPC disclosure compression changing a bounded refusal into a blanket refusal.
- Occasional player sensation or memory assignment.

## 13. Validator performance

The report-only validator passed 14/20 Gate samples. Against the stricter human all-axis judgment, it produced 9 true passes, 5 true failures, 5 semantic false accepts, and 1 conservative false rejection. The false accepts are expected: regex cannot prove factual entailment. The false rejection was first-person speech inside authorized NPC dialogue, not first-person narration. Raw completion is always retained even when validation fails.

## 14. Performance

Across Gate 1, average end-to-end generation time was **3.02 seconds**, average generation speed was **77.35 tokens/second**, and average completion length was **38.2 tokens**. All runs reported active GPU offload.

## 15–18. Conclusions

- Character identity now holds in this sample: 20/20 overall, including all Guillermo cases with no speech.
- Player agency is much better but not fully reliable: 17/20.
- Second-person present prose and the intended restrained register are reliable in this sample: 20/20 each.
- Consequential invention is not controlled well enough: grounding is only 11/20.
- Fine-tuning is **not yet justified as the automatic next step**. The development plan needs an explicit decision about constrained factual rendering, narrator scope, or model choice before spending effort on tuning.
- Phase 3 should remain blocked until that decision is made.

## 19. Version control

Branch and commit are recorded in the delivery message after the reviewed files are committed and pushed.
