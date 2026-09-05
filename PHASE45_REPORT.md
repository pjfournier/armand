# Phase 4.5 — Persistent Inference and Prototype Combat Decision

## Architecture

One `llama-server.exe` process loads the existing Comma Q4_K_M model once and serves both model roles through llama.cpp's local `/completion` endpoint. This avoids two heavyweight model copies while retaining separate request configuration. `src/InferenceService.psm1` owns configuration, readiness checks, bounded HTTP requests, raw completion capture, timing, and clear failures.

The interpreter still builds its existing player-visible context and per-call dynamic JSON Schema. `src/InterpreterModel.psm1` sends the unchanged prompt, schema, stable enums, seed, and low-variance sampler settings to the persistent service. The service performs schema-constrained decoding; there is no unconstrained JSON or regex recovery path.

The narrator continues through `CommaHarness.psm1` with the same safe packet, prompts, exemplars, independent sampler settings, raw output, and downstream lexical/structural validators. Context and grounding policy were not broadened. The legacy process-per-call implementation remains only as an explicit debugging fallback.

## Lifecycle and configuration

- Start: `.\Start-InferenceService.ps1`
- Readiness: llama.cpp `GET /health`, exposed through `Test-InferenceService`
- Stop: `.\Stop-InferenceService.ps1`
- Shared service settings: `inference_service.json`
- Interpreter generation settings: `interpreter_config.json`
- Narrator generation settings: `config.json` and existing Phase 2 overlays

The managed start script launches a hidden process, waits up to the configured startup timeout, records its PID and measured load/readiness time, and returns only when ready. Stop uses that exact PID. Ordinary calls do not start a model process. Connection failure is immediate and explicit, for example `Inference service unavailable at 127.0.0.1:8080`; there is no fake output or silent fallback.

## Benchmark

Measured locally on 2026-09-05 with the repository's existing CUDA llama.cpp build and Comma Q4_K_M:

| Measurement | Samples | Average | Median | Min | Max |
|---|---:|---:|---:|---:|---:|
| Service startup/model readiness | 1 | 2.117s | — | — | — |
| First interpreter request | 1 | 0.867s | — | — | — |
| Warm interpreter | 10 | 0.685s | 0.685s | 0.677s | 0.692s |
| First narrator request | 1 | 1.909s | — | — | — |
| Warm narrator | 10 | 2.631s | 3.043s | 0.345s | 3.208s |
| Full warm turn | 5 | 3.552s | 3.522s | 2.882s | 4.222s |

Warm interpreter latency fell 78.6% from the Phase 4 model-backed baseline of 3.20s. The prior ordinary two-model-call turn felt roughly six seconds; measured warm full turns now average 3.552s. Narrator duration varies substantially with generated output length, so persistent loading improves it less dramatically than interpretation.

All five benchmark narrations were rejected by the unchanged validator because Comma continued beyond the desired narration into unrelated text. This is the known Phase 2 grounding/termination quality risk, now made more visible by the benchmark. It does not mutate state or bypass validation, but it remains a genuine risk for later playtesting.

Raw benchmark data, including every end-to-end completion and validator result, is in `eval/phase45_benchmark_results.json`.

## Verification

- Phase 4.5 infrastructure/failure tests: passed.
- Phase 2 tests: passed.
- Phase 3 tests and 15/15 grounding regressions: passed.
- Phase 4 deterministic semantic suite: 30/30 passed.
- Real-model Gate 2 rerun over persistent service: 26/30 PASS, unchanged.
- Dynamic schema constraints and hidden-state boundaries: passed through Phase 4 tests and real-model Gate 2.
- Armand and Guillermo end-to-end scenarios: engine resolution and state preservation passed; narrator quality caveats remain model-side.
- Phase 1 smoke test: passed through the persistent backend.

## Prototype combat decision

**DECIDED — Prototype Combat Direction:** the Callum house prototype is a stealth/evasion/observation encounter, not a conventional combat encounter. Full combat is deferred beyond the prototype unless playtesting shows it is necessary. Existing combat-related character data remains intact. Unsupported deliberate violence must be explicitly rejected or deferred rather than implying a combat engine. See `PROTOTYPE_COMBAT_DECISION.md`.

## Scope and risks

No Notebook, theories, clue UI, incident ledger, profile memory, Callum house content, cultist AI, full combat, combat UI, progression, FP/AP, procedural locations, fine-tuning, compound planner, or autonomous agents were added.

The model no longer reloads for an ordinary interpreter or narrator call. Operationally, the local service must be started before play; unexpected service termination produces a clear error. Narration output-length/grounding remains the principal model-quality risk. No Phase 5 or Phase 6 gameplay system was implemented.
