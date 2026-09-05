# Phase 5 — Notebook and Incident Ledger

## Architecture and schema

`GameState` now owns a dedicated `Notebook` with four stable-ID dictionaries—`Clues`, `Characters`, `Locations`, and `Theories`—plus a separate `GuillermoIncidentLedger`. Models own neither store and receive no mutation API.

- Clues: ID, label, discovery state, source location, reached tier, known facts, first/last turn, related entity IDs, and a separate player note.
- Characters: ID, label, known facts, known relationship/history, first encounter, last update, player-controlled important flag, and player note.
- Locations: ID, label, visited state, known features, known discovery IDs, first/last visit, and player note.
- Theories: ID, title, freeform body, explicit clue/character/location links, created/updated turns, player-managed status, and the fixed classification `player_belief`.
- Guillermo incidents: ID, small event tag, factual description, turn/case time, memorability, optional nickname seed, and across-death flag.

`notebook_config.json` holds the relevance cap and scoring constants. No graph, embedding, vector database, search model, truth score, probability, or suspect rank exists.

## Authoritative clue flow

`Resolve-ClueInterpretation` remains the authority for discovery and tier advancement. After it adds only reached tier facts to authoritative clue state, it calls `Sync-NotebookClue`. Synchronization copies only `KnownFacts`, updates the reached tier, timestamps the entry, and deduplicates repeated facts. A failed interpretation never calls synchronization with new knowledge. The narrator and interpreter cannot create clue facts.

Player clue notes live in `player_note`; they never enter `known_facts`. Theory bodies are likewise fixed as `player_belief`. This preserves the required distinction:

- Known fact: the engine revealed that the stain is dried blood.
- Player belief: the player wrote that the blood belongs to someone.

## Characters, locations, and theories

Character creation/fact APIs accept only facts already designated player-known. The important flag is changed only through `Set-NotebookCharacterImportant` and may be freely turned on or off regardless of actual relevance.

Location visits store only explicitly supplied known features and discovered Notebook clue IDs; they never clone authoritative location state. Hidden objects, rooms, NPCs, exits, and undiscovered clues therefore have no automatic path into the Notebook.

Players can create, edit, discard/reactivate, and link theories to known Notebook entities. Linking an undiscovered clue or otherwise unknown entity is rejected. A link is organization metadata and has no correctness meaning.

## Deterministic relevance and narration

`Get-NotebookRelevance` scores only eligible player-known entries:

- exact target: 100
- explicitly related entity: 50
- theory link to target/related evidence: 40
- same location: 25
- explicit search-term match: 20

Zero-score entries are omitted. Results are deterministically sorted by score, last update, and stable ID, then capped at four by default. Scores are available only with the explicit debug switch and are removed from normal projections.

`Resolve-StructuredIntent` accepts an optional engine-side `NotebookQuery`, selects relevant entries, and places only safe formatted lines into the handoff. `Convert-HandoffToNarrationCase` carries those lines through the existing `NotebookEntries` packet field. Known facts are labeled `KNOWN FACT`; notes and theory bodies are labeled `PLAYER NOTE (belief)` or `PLAYER THEORY (belief)`. Hidden tiers, Case Truth, and unrelated theories never enter through this path. Existing lexical and structural validation remains unchanged.

## Guillermo evidence boundary and incidents

`Get-GuillermoTheoryEvidence` returns the player's theory, its explicitly linked known Notebook evidence, and only directly supplied contradiction clue IDs that are themselves present in the Notebook. Unknown/hidden clue IDs are discarded. It never reads Case Truth and does not treat absence of support as contradiction. Full hint escalation and reaction behavior remain deferred.

The separate incident ledger accepts only its small fixed tag set and idempotently returns an existing incident when a stable ID repeats. It is intended for engine calls after authoritative events; narrator prose has no route to write it. It persists for the current GameState/session. Profile-level and cross-save persistence remain deferred because the project has no save architecture.

## Serialization and verification

`Get-PlayerFacingNotebook` returns only the Notebook projection: known clues/facts, visited locations, known characters, importance flags, theories, and player notes. It excludes relevance scores, Case Truth, authoritative world state, hidden objectives/NPC knowledge, and the private Guillermo incident ledger.

Verification results:

- Phase 5: 32/32 required Notebook, relevance, narration-boundary, Guillermo evidence, incident, and serializer checks passed.
- Phase 2 narrator tests: passed.
- Phase 3 rules/state and 15/15 handoff regressions: passed.
- Phase 4 deterministic intent suite: 30/30 passed.
- Phase 4.5 infrastructure/failure suite: passed.
- Phase 1 smoke test: passed with persistent local inference.

The Phase 4 interpreter schema was not expanded, so the real-model Gate 2 behavior is unaffected. Notebook-facing natural-language commands are deferred until they can be added without destabilizing interpretation.

## Scope and deferred work

No Callum study/house content, cultist encounter, Guillermo hint escalation, combat, save/load, profile persistence, quest log, auto-solver, graph UI, vector search, embeddings, additional model, fine-tuning, LoRA, polished UI, progression, AP/FP, procedural generation, or autonomous planner was implemented. In particular, no Phase 6 playable mystery content was added.

The main deferred questions are save/profile persistence, eventual Notebook command UX, and how authored content will declare directly known contradictions for Guillermo without conflating missing evidence with contradiction. There are no Phase 5 implementation blockers.
