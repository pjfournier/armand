# Callum's Study — Manual Playtest

## Suggested freeform path

This is a suggestion, not a required solution:

1. `Look around the room.`
2. `Examine the rug.`
3. `Check it more closely.`
4. `Examine the writing desk.`
5. `Have Guillermo examine the large painting.`
6. `Use Detect Magic on the fireplace.`
7. Open Notebook → Theories and create “Callum was taken from the room.”
8. Link the blood and rope clues using the clue picker.
9. `Go through the study door.`
10. `Enter the study.`
11. `Open the safe.` or `Use the crowbar on the safe.`
12. `Take the burned note.`

The safe can also be found by examining the painting or searching the paneled wall. Failed attempts can be retried and do not delete evidence.

## Engineering playtest observations

Two complete bridge playthroughs and focused return-state runs were performed with real Comma inference. Natural-language actions reached the study ending, Guillermo exposed the safe, Detect Magic established residue without explaining it, Notebook clues persisted across the landing transition, theory creation/linking worked over HTTP, and the burned note produced the Blackthorn Station lead.

The playtest did reveal narrator problems that the base validator missed: contradiction of positive evidence, an unopened safe described as open/picked, false returning-location continuity, and a statement assigning knowledge to the player. Narrow slice-level grounding checks were added for those cases. Invalid generations retry once and then use an authored facts-only fallback; raw failures remain in telemetry.

The most encouraging interaction was Guillermo's repeated look toward the painting followed by a successful player instruction to inspect it. The weakest area remains narrator reliability: the prototype stays playable because fallback behavior is safe, but frequent retries make responses slower and sometimes less atmospheric.

The ending deliberately establishes only a direction—Blackthorn Station and a midnight meeting—not the identity or full motive of whoever removed Callum.
