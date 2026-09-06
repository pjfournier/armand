# Playable Vertical Slice — Callum's Study

## Architecture

The prototype runs as three local components: Godot 4.7.2 provides presentation/input; a persistent PowerShell `HttpListener` bridge owns one in-memory session and invokes the existing Phase 3–5 modules; the existing persistent llama.cpp service provides interpretation and narration. Godot never stores authoritative state or calls the model directly.

The tested engine is **Godot 4.7.2 stable**, installed project-locally under ignored `.runtime/godot`. The source project uses GDScript and the compatibility renderer.

## Files and services

- `godot/project.godot`, `godot/Main.tscn`, `godot/Main.gd`: desktop client.
- `godot/BridgeBenchmark.gd`: Godot-side HTTP latency harness.
- `content/callum_study/*.json`: room, objects, clues, lead, and minimal hidden truth.
- `src/VerticalSlice.psm1`: authoritative session/content orchestration and narrator safety.
- `Start-GameBridge.ps1`, `Stop-GameBridge.ps1`: persistent bridge lifecycle.
- `Start-Prototype.ps1`, `Stop-Prototype.ps1`: convenient full lifecycle.
- `bridge_config.json`: localhost port, telemetry path, and quality tags.
- `Test-VerticalSlice.ps1`: automated gameplay/safety suite.
- `MANUAL_PLAYTEST.md`: suggested path and observed playtest findings.

Start everything and launch the game:

```powershell
.\Start-Prototype.ps1
```

Use `.\Start-Prototype.ps1 -Editor` for the Godot editor or `-NoGodot` for backend development. Stop managed local services with `.\Stop-Prototype.ps1`.

## Bridge API

The bridge listens only on `127.0.0.1:8090`:

- `GET /health`
- `POST /session/new`
- `POST /session/reset`
- `GET /session/state`
- `POST /action` with `{ "text": "..." }`
- `GET /notebook`
- `POST /notebook/theory`
- `POST /notebook/theory/link`
- `POST /notebook/character/important`
- `POST /telemetry/tag`

Player responses expose location, case time, visible objects, safe Notebook serialization, Guillermo availability/communication tier, changed Notebook data, narration, and ending state. Hidden truth, hidden tiers, engine stats, DCs, raw scores, secret flags, and Guillermo numbers are excluded.

## Authored slice

Callum's disturbed study contains a writing desk, hearth, rug/floor, painting, bookshelves, window, door, and paneled wall. The safe and burned-note lead begin inaccessible. A minimal landing exists solely to test leaving, returning, and session persistence.

Clues use existing tier mechanics:

- Blood: dark discoloration (10), dried blood (15), too little for a death here (20), injured person moved (25).
- Scorch marks: unusual burns (10), inconsistent with ordinary fire (15 Occult), occult energy discharge (20 Occult).
- Rope fibers: coarse fibers (10), hemp cordage (15), tightly pulled/dragged condition (20).
- Callum symbol: a three-pointed crown beside 1847; this supports safe access and selective relevance.
- Detect Magic residue: magical presence only, without identifying caster or meaning.
- External lead: the recovered note names Blackthorn Station and tomorrow's midnight meeting.

The safe can be discovered by inspecting the painting, searching the paneled wall, or directing Guillermo to the painting. It can be opened through Finesse/combination knowledge or with a crowbar that can produce progress plus a noisy setback. Misty Step cannot enter the opaque safe; movement to visible exits remains supported. No mandatory Athletics route exists.

After blood and rope evidence are known while the safe remains hidden, the engine may emit one early-tier Guillermo tell: he looks at Armand, looks at the painting, looks back, and repeats once. It identifies an attention target without stating a solution. Guillermo's failed painting attempt can create an engine-authored incident.

## Notebook and returning location

The Godot side panel exposes Clues, Characters, Locations, and Theories. Theory text is visibly labeled belief, known clues can be linked, and Callum can be marked important. Existing deterministic relevance feeds only bounded known evidence into narration. The three-pointed symbol can therefore surface again when the safe is examined without asserting who used it.

The landing transition preserves discovered clues, safe state, inventory, theories, and Notebook state. Return context says the player returns to the changed study rather than replaying the opening description.

## Narrator safety and telemetry

Each generation is validated. The slice adds narrow state-grounding checks for premature safe/lead revelation, false open/picked-safe claims, invented physical Notebook objects, contradiction of positive evidence, false safe continuity, locked-door invention, and player epistemic assignment. One retry is allowed. If both attempts fail, the UI receives a deterministic narration assembled only from engine events. Raw invalid output is never displayed.

`eval/playtest_turns.jsonl` records timestamp, input, intent/status, engine result/degree, Notebook change, every raw generation, validator details, displayed narration, retry/fallback flags, interpreter/narrator/full-turn latency, and a turn ID. Quality tags may be appended through `/telemetry/tag` using the configured small taxonomy.

## Verification and measured play

- Vertical slice backend: 31 required gameplay/safety scenarios passed (with additional subchecks for retry, fallback, state contradictions, continuity, and epistemic statements).
- Phase 2–5 regression suites: passed; Phase 3 retains 15/15 handoff cases and Phase 4 retains 30/30 deterministic intent cases.
- Godot project import/runtime: passed headlessly with no script errors.
- Real bridge natural-language playthrough: reached the lead, with Guillermo, Detect Magic, Notebook persistence, landing return, safe opening, and final lead confirmed.
- Godot HTTP benchmark, five warm full turns: average **4.426s**, median **4.505s**, min **3.926s**, max **5.168s**.
- Benchmark narration: 0/5 passed first try; 5/5 (100%) passed after retry; 0/5 required fallback.

The retry rate is a genuine risk and explains why the measured Godot turn is slower than the earlier Phase 4.5 backend benchmark. Manual play also exercised facts-only fallbacks; they preserved playability and authority at the cost of prose quality.

## Scope

This is one room plus a minimal landing, not full Phase 6. No full house, cultist encounter, conventional combat, save/load, progression, inventory UI, mature Guillermo, full hint escalation, procedural room, map, art pipeline, audio, cloud service, embeddings, fine-tuning, LoRA, dialogue tree, or autonomous planner was implemented.

## Standing playability rules

The room overview should tempt the player into investigating, not answer the investigation for them. Authored `overview_fact` text may expose objects, disturbances, and suspicious anomalies, while material identity, causal conclusions, forensic implications, and occult conclusions remain in earned clue tiers.

Discovery follows: overview affordance → focused passive observation → active skill resolution → higher authored implication → player theory. Passive and automatic facts remain unobtrusive. Active checks use prototype-standard feedback (`🎲 Skill • Outcome`) without exposing raw roll, modifier, DC, or margin.

Identical active checks under materially unchanged conditions do not reroll. A changed method, purpose, actor, clue tier, or relevant world state may justify a new check. This prevents paraphrasing from becoming unlimited rerolls.

Understandable unsupported actions receive a bounded engine-authored physical result. The narrator may style that result but cannot create clues, damage, objects, compartments, or persistent changes. Any actionable noun introduced by narration must correspond to a visible object, registered sub-referent, inventory item, engine event, persistent decoration, or authorized mundane result.

If behavior passes automated interpretation tests but fails in the live Godot build, runtime integration must be diagnosed before interpretation logic changes. A clean bridge restart is part of that audit because a long-lived PowerShell bridge retains the code loaded when its process started.

Narration is also checked against pre/post player and consequential-item locations: unchanged state cannot produce room transitions or move the burned note. Locked-safe access requires a player-named route, and optional intent fields never carry into an ordinary later turn. One bounded pending intent can accept a missing-target fragment; true compounds clarify before execution. Visible state questions resolve directly without mutation or rolls, and Godot omits null response metadata.

Pre-Phase-6 depth rules add nonverbal `gesture` interactions, roll-free `query_property` answers, authoritative window state, and exact desk-drawer targeting. Overview observations never enter Notebook as interpreted facts. The rope ladder is coarse fibers → recognizable rope fibers → active hemp identification → higher tension evidence. Narration targets two to four grounded sentences with a small sensory budget; target drift, invented follow-on actions or dialogue, internal engine language, repetition, and excess length are rejected.
