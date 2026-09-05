# Comma Phase 1 Smoke Test Report

Run date: September 5, 2026  
Result: **PASS**

## Prompt sent to the model

The following text was sent directly to Comma as a raw completion. No system message, user/assistant roles, ChatML, instruction wrapper, or chat template was applied.

```text
FACTS
location: Victorian study
time: midnight
weather: rain
visible:
- desk
- extinguished fireplace
- open window

NARRATION
```

## Model response

```text
There is a kitchen with one large desk and a fireplace that is completely covered by a wooden curtain. There are several windows on the walls. It’s now 5 a.m., and there is no sign of anyone else in the house. The curtains at the windows are drawn and everything seems safe.

There is one window that I cannot open because the curtains are tightly closed. I do not know why, but I suspect that someone has left something here. There is also a door that leads to another room, where there should be the master’s bed. I will enter the other room.
As I approach the door, I hear a loud thumping sound from inside. I cannot find a way to open it. I
```

## Generation settings

| Setting | Value |
|---|---:|
| Model | Comma v0.1-2T Q4_K_M GGUF |
| Context size | 4096 |
| Temperature | 0.8 |
| Top-p | 0.95 |
| Top-k | 40 |
| Repetition penalty | 1.1 |
| Maximum generated tokens | 160 |
| Random seed | 12345 |
| Stop sequence | `\nFACTS` |
| GPU layers | all |

## Measured results

| Metric | Result |
|---|---:|
| Model load | 1.66 seconds |
| Generation | 1.88 seconds |
| End-to-end | 4.30 seconds |
| Generated tokens | 160 |
| Generation speed | 87.33 tokens/second |
| Acceleration | NVIDIA CUDA |
| Automated smoke test | PASS |

The automated smoke test passed because the model initialized, accepted the prompt, returned non-empty generated text, did not echo the entire prompt, and exited successfully.

## Observations

The Phase 1 capability test succeeds: Comma runs locally through a raw-completion interface with CUDA acceleration and configurable generation settings.

The response does not reliably follow the supplied facts. It changes the study into a kitchen, changes midnight to 5 a.m., introduces unprovided rooms and events, and shifts into first person. Literary quality and grounding are not Phase 1 acceptance criteria, but these results should be carried into Phase 2's exemplar and model-viability evaluation.
