# An Armand Mystery

Phases 1–6 provide the local Comma harness, grounded narration pipeline, deterministic rules/state engine, intent interpreter, persistent local inference service, player Notebook, Guillermo incident ledger, and the complete playable prototype house. The engine determines reality; models only interpret and narrate.

Phase 6 details and acceptance evidence are documented in `PHASE6_REPORT.md`. The Notebook stores engine-known facts separately from player notes and theories, and only bounded engine-selected evidence may enter narration.

## Playable Callum Study slice

The Godot desktop vertical slice is documented in `PLAYABLE_SLICE_REPORT.md`; the suggested freeform route is in `MANUAL_PLAYTEST.md`. Launch the local inference service, persistent game bridge, and game together with:

```powershell
.\Start-Prototype.ps1
```

Stop both managed backend services with `.\Stop-Prototype.ps1`.

The combat prototype is available from the three **Combat A/B/C** buttons in the running Godot slice. Combat keeps the same freeform text box: type commands such as `Move behind the desk and cast Eldritch Blast at the initiate`, `Cast Darkness`, or `Flee through the doorway and hide`. A first-fight tutorial explains the Movement and Action budget; the compact combat panel then shows turn order, semantic positions, and remaining budgets.

## Persistent inference

Start the shared local model service once before normal interpreter or narrator use:

```powershell
.\Start-InferenceService.ps1
```

Check readiness with `Test-InferenceService` from `src/InferenceService.psm1`, or request `http://127.0.0.1:8080/health`. Stop the managed service cleanly with:

```powershell
.\Stop-InferenceService.ps1
```

Host, port, model path, context size, GPU layers, and timeouts live in `inference_service.json`. Interpreter and narrator sampling settings remain independent in `interpreter_config.json` and `config.json`. An unavailable service raises a clear error and never falls back to fabricated output. The legacy CLI mode remains available for explicit debugging by setting `inference_backend` away from `server`.

## Original Phase 1 capability spike

This repository contains only the Phase 1 raw-completion harness. It proves that the `common-pile/comma-v0.1-2t` base model can run locally, accept a plain `FACTS`/`NARRATION` prefix, and return a timed completion. It contains no game engine, narrator packet assembler, validators, exemplars, training, character systems, or other later-phase work.

## Prerequisites

- Windows 10/11 with PowerShell 7
- NVIDIA GPU with a current driver (tested on RTX 4070 SUPER, 12 GB)
- About 20 GB free during setup and about 5 GB afterward
- `curl.exe` (included with current Windows)

Optional: `aria2c` makes the 14 GB model transfer much faster; setup uses it automatically when installed and otherwise uses resumable `curl`.

## Setup

From the repository root:

```powershell
.\setup.ps1
```

The setup script downloads the official llama.cpp Windows CUDA 12.4 release `b10816`, downloads the Apache-2.0 F16 GGUF conversion of `common-pile/comma-v0.1-2t` from `jadael/comma-v0.1-2t-GGUF`, verifies the published SHA-256 hashes, quantizes it locally to Q4_K_M, and removes the large intermediate unless `-KeepF16` is supplied. Model and runtime files are Git-ignored.

This GGUF route was selected because Comma identifies as a Llama-family causal language model, llama.cpp loads the available GGUF conversion directly, exposes every required sampler, supports stop sequences, and provides CUDA layer offload without a serving framework. No independently published Q4_K_M artifact was available when this spike was made, so setup derives Q4_K_M from the published F16 GGUF rather than substituting a different model.

Sources: [original Comma model](https://huggingface.co/common-pile/comma-v0.1-2t), [GGUF conversion](https://huggingface.co/jadael/comma-v0.1-2t-GGUF), [llama.cpp](https://github.com/ggml-org/llama.cpp).

## Run

Canonical one-command smoke test:

```powershell
.\run.ps1 -SmokeTest
```

Run any plain-text completion prefix:

```powershell
.\run.ps1 .\prompts\smoke_test.txt
```

Small overrides are available without editing source:

```powershell
.\run.ps1 -Seed 42 -Temperature 0.7 -MaxTokens 96
```

The command prints the prompt, generated continuation, model-load time, generation time, end-to-end time, generated-token count, tokens/second, and detected acceleration separately. `-SmokeTest` also fails if output is empty or simply contains the entire input.

## Configuration

All starting test values live in `config.json`; they are not balanced or final game settings.

| Setting | Starting value | Purpose |
|---|---:|---|
| `runtime_path` | `.runtime/llama.cpp/llama-completion.exe` | Raw completion executable |
| `model_path` | `models/comma-v0.1-2t-q4_k_m.gguf` | Local model artifact |
| `context_size` | `4096` | Prompt and output context |
| `temperature` | `0.8` | Sampling randomness |
| `top_p` | `0.95` | Nucleus sampling |
| `top_k` | `40` | Candidate cutoff |
| `repeat_penalty` | `1.1` | Repetition control |
| `max_tokens` | `160` | Maximum generated tokens |
| `seed` | `12345` | Reproducible starting seed |
| `stop_sequence` | `\nFACTS` | Stop before another facts block |
| `gpu_layers` | `all` | Request full CUDA offload |

Paths may be absolute or relative to the repository root.

## Why this is raw completion

The harness invokes `llama-completion.exe` with the prompt file directly, explicitly disables conversation mode, and does not supply a system prompt, messages, role tokens, ChatML, or a chat template. `--no-display-prompt` affects terminal output only. The model begins generating immediately after the final `NARRATION` text. Inspect `prompts/smoke_test.txt` to verify the exact bytes supplied.

## Troubleshooting

- **Runtime missing:** run `.\setup.ps1`, or point `runtime_path` at a compatible `llama-completion.exe`.
- **Model missing:** run `.\setup.ps1`, or update `model_path` to the locally derived Comma Q4_K_M GGUF.
- **CUDA unavailable / CPU fallback:** the result reports this explicitly. Update the NVIDIA driver and use the bundled CUDA build. Setting `gpu_layers` to `0` is supported only for an intentional, slower CPU test.
- **Unsupported model:** rerun setup to derive the quant from the documented F16 conversion; do not substitute an instruction-tuned Comma derivative.
- **Out of VRAM:** reduce `context_size`; Q4_K_M itself should fit a 12 GB card comfortably.
- **Malformed configuration or missing prompt:** the CLI identifies the affected file/setting and exits nonzero.
- **Download interrupted:** rerun setup; `curl -C -` resumes partial downloads.
