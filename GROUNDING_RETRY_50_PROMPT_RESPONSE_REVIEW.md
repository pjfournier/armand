# Grounding Retry — 50 Held-Out Prompts and Responses

These are the preserved Phase 1 held-out prompts and the raw-completion-based responses produced by the selected Phase 2 grounding retry harness (11 exemplars, facts packet, temperature 0.15). The response shown is the complete player-facing continuation assembled with the prompt-seeded `You `. The exact untrimmed runtime output remains in `eval/grounding_retry_regression_selected_raw.jsonl`.

No prompt facts or seeds were changed for this review run.

## 1. regression-01 — regression

Seed: 2001

### Prompt

```text
FACTS
location: Victorian study
time: midnight
weather: rain
actor: Armand
action: investigate
target: desk
result: success
resolved:
- scratches surround the locked drawer
- the drawer remains closed
visible:
- desk
- extinguished fireplace
- open window

NARRATION
```

### Response

You trace the edge of the locked drawer. Fresh scratches score the wood around its keyhole; whatever marked it did so recently, but the drawer remains closed.

## 2. regression-02 — regression

Seed: 2002

### Prompt

```text
FACTS
location: fogbound railway platform
time: dawn
weather: heavy fog
actor: Armand
action: search
target: abandoned suitcase
result: setback
resolved:
- a railway receipt is found
- opening the case makes a loud snap
visible:
- empty bench
- brass clock
- abandoned suitcase

NARRATION
```

### Response

You search the abandoned suitcase. The case opens with a loud snap, but its contents are gone.

## 3. regression-03 — regression

Seed: 2003

### Prompt

```text
FACTS
location: gaslit alley
time: late evening
weather: drizzle
actor: Armand
action: examine
target: discarded glove
result: success
resolved:
- the glove is wet
- black grease marks the fingertips
visible:
- brick wall
- locked gate
- discarded glove

NARRATION
```

### Response

You examine the discarded glove. It is wet, and black grease marks its fingertips; it lies on a brick wall beside a locked gate.

## 4. regression-04 — regression

Seed: 2004

### Prompt

```text
FACTS
location: dusty library
time: afternoon
weather: overcast
actor: Armand
action: move
target: rolling ladder
result: failure
resolved:
- the ladder jams halfway
- dust falls from the upper shelf
visible:
- tall shelves
- rolling ladder
- sealed envelope

NARRATION
```

### Response

You try to move the ladder, but it jams halfway. Dust falls from the upper shelf as you push.

## 5. regression-05 — regression

Seed: 2005

### Prompt

```text
FACTS
location: abandoned conservatory
time: sunset
weather: wind
actor: Armand
action: take
target: sealed envelope
result: success
resolved:
- the envelope enters inventory
- the seal remains intact
visible:
- broken glass
- dead roses
- marble fountain

NARRATION
```

### Response

You take a sealed envelope from the conservatory. The seal is intact, but the glass has shattered and the roses lie dead on the marble floor.

## 6. regression-06 — regression

Seed: 2006

### Prompt

```text
FACTS
location: riverside warehouse
time: 2 a.m.
weather: cold rain
actor: Armand
action: use crowbar
target: locked chest
result: setback
resolved:
- the lid opens
- the crowbar bends
- a hinge breaks loudly
visible:
- wooden crates
- cargo hook
- muddy footprints

NARRATION
```

### Response

You use the crowbar on the locked chest. The lid opens, but the crowbar bends; a hinge snaps with a loud crack as you work it. Muddy footprints lead from the doorway to the crates.

## 7. regression-07 — regression

Seed: 2007

### Prompt

```text
FACTS
location: hotel lobby
time: noon
weather: snow
actor: Armand
action: cast Detect Magic
target: display case
result: success
resolved:
- magic is present
- its nature and meaning remain unknown
visible:
- reception desk
- grand staircase
- unclaimed key

NARRATION
```

### Response

You cast Detect Magic on the display case. The spell succeeds, but the nature of the magic remains unknown.

## 8. regression-08 — regression

Seed: 2008

### Prompt

```text
FACTS
location: church vestry
time: early morning
weather: clear
actor: Armand
action: speak
target: night clerk
result: success
resolved:
- Armand asks who left the key
- the clerk says a veiled woman left it at midnight
visible:
- oak cabinet
- wax candle
- mud-stained cassock

NARRATION
```

### Response

You ask who left the key. The night clerk glances from it to the wax candle, then says a veiled woman left it at midnight.

## 9. regression-09 — regression

Seed: 2009

### Prompt

```text
FACTS
location: opera dressing room
time: intermission
weather: storm
actor: Guillermo
action: search
target: high shelf
result: success
resolved:
- Guillermo finds a folded scrap
- Guillermo can communicate only through gestures
visible:
- vanity mirror
- costume rack
- half-written note

NARRATION
```

### Response

You see Guillermo search the high shelf. He finds a folded scrap, then communicates his discovery through gesture, expression, vocalization, and physical behavior.

## 10. regression-10 — regression

Seed: 2010

### Prompt

```text
FACTS
location: museum gallery
time: closing time
weather: hail
actor: Armand
action: wait
target: current location
result: success
resolved:
- ten minutes pass
- footsteps approach from the corridor
visible:
- covered portrait
- display case
- wet umbrella

NARRATION
```

### Response

You wait. Ten minutes pass, then footsteps approach from the corridor. A wet umbrella is held out of sight.

## 11. regression-11 — regression

Seed: 2011

### Prompt

```text
FACTS
location: boarding-house kitchen
time: breakfast
weather: mist
actor: Armand
action: investigate
target: muddy footprints
result: exceptional success
resolved:
- two different shoe patterns are present
- one trail enters and does not leave
visible:
- iron stove
- chipped cup
- back door

NARRATION
```

### Response

You investigate the muddy footprints. Two different shoe patterns are present, one of which trails into the kitchen but does not trail out again. The iron stove is hot, a chipped cup stands on it, and the back door is closed.

## 12. regression-12 — regression

Seed: 2012

### Prompt

```text
FACTS
location: lawyer's office
time: late afternoon
weather: rain
actor: Armand
action: move quietly
target: back door
result: setback
resolved:
- Armand reaches the door
- a loose board creaks
- suspicion increases
visible:
- filing cabinet
- inkwell
- torn contract

NARRATION
```

### Response

You move quietly toward the back door. The loose board creaks, and your suspicion increases. You see the filing cabinet, the inkwell, and a torn contract.

## 13. regression-13 — regression

Seed: 2013

### Prompt

```text
FACTS
location: cemetery gatehouse
time: midnight
weather: fog
actor: Armand
action: cast Minor Illusion
target: far corner
result: success
resolved:
- a sound of breaking glass occurs in the far corner
- nearby attention shifts toward it
visible:
- ledger
- rusted key
- muddy lantern

NARRATION
```

### Response

You cast your Minor Illusion. A sound of breaking glass occurs in the far corner, and nearby attention shifts toward it.

## 14. regression-14 — regression

Seed: 2014

### Prompt

```text
FACTS
location: apothecary cellar
time: evening
weather: thunderstorm
actor: Armand
action: investigate
target: half-written note
result: failure
resolved:
- the handwriting cannot be identified
- wet ink smears under the examination
visible:
- glass bottles
- wooden table
- locked chest

NARRATION
```

### Response

You examine the note. The handwriting is illegible, and the ink smears beneath your fingers as you turn it over. The apothecary's shelves are empty, but a locked chest stands against the wall.

## 15. regression-15 — regression

Seed: 2015

### Prompt

```text
FACTS
location: theatre balcony
time: after midnight
weather: clear
actor: Armand
action: open
target: window
result: severe failure
resolved:
- the window stays shut
- the latch snaps
- glass cracks loudly
visible:
- velvet seats
- opera glasses
- single white rose

NARRATION
```

### Response

You press the latch; it gives before the window does. A sliver of loose glass drops and breaks on the floor, bright and sharp in the silence, while the window stays shut.

## 16. regression-16 — regression

Seed: 2016

### Prompt

```text
FACTS
location: country manor foyer
time: dusk
weather: snow
actor: Armand
action: give command
target: Guillermo
result: success
resolved:
- command is to scout the next room
- Guillermo slips through the doorway
- no scouting result is available yet
visible:
- coat stand
- grandfather clock
- wet footprints

NARRATION
```

### Response

You give command. ‘Scoot the next room,’ you say, ‘and report.’ Guillermo slips through the doorway, but no scouting result is available yet.

## 17. regression-17 — regression

Seed: 2017

### Prompt

```text
FACTS
location: police archive
time: 3 a.m.
weather: rain
actor: Armand
action: investigate
target: dark stain
result: success
resolved:
- the stain is dried blood
- the amount is inconsistent with a death here
visible:
- case files
- oil lamp
- open drawer

NARRATION
```

### Response

You investigate the dark stain. It is dried blood, not enough for a death here; you find case files, an oil lamp, and an open drawer.

## 18. regression-18 — regression

Seed: 2018

### Prompt

```text
FACTS
location: dockside tavern
time: last call
weather: dense fog
actor: Armand
action: speak deceptively
target: dockworker
result: setback
resolved:
- the dockworker accepts the false name
- the dockworker demands payment before answering
visible:
- empty bottles
- cold hearth
- silver coin

NARRATION
```

### Response

You speak deceptively. The dockworker accepts your false name, then demands payment before answering. You pay him with a silver coin, and he answers: ‘A woman in a grey veil.’

## 19. regression-19 — regression

Seed: 2019

### Prompt

```text
FACTS
location: photographer's studio
time: morning
weather: bright sun
actor: Armand
action: cast Misty Step
target: visible balcony
result: success
resolved:
- Armand teleports to the balcony
- the spell slot is spent
visible:
- camera tripod
- painted backdrop
- broken plate

NARRATION
```

### Response

You cast Misty Step. The spell slot is spent, and you teleport to the balcony. You see a camera tripod, a painted backdrop, and a broken plate.

## 20. regression-20 — regression

Seed: 2020

### Prompt

```text
FACTS
location: underground tunnel
time: unknown
weather: dry
actor: Guillermo
action: steal
target: brass key
result: failure
resolved:
- the key remains on the hook
- the key rattles
- Guillermo retreats
visible:
- brick arch
- standing water
- chalk mark

NARRATION
```

### Response

You see Guillermo steal a brass key from the hook. The key remains on the hook; it rattles as he retreats. You hear him retreat, then see his small body in the arch of the tunnel, where standing water has left a chalk mark.

## 21. regression-21 — regression

Seed: 2021

### Prompt

```text
FACTS
location: university laboratory
time: late night
weather: wind
actor: Armand
action: investigate
target: desk
result: success
resolved:
- scratches surround the locked drawer
- the drawer remains closed
visible:
- brass microscope
- chemical stains
- open notebook

NARRATION
```

### Response

You trace the edge of the locked drawer. Fresh scratches score the wood around its keyhole; whatever marked it did so recently, but the drawer remains closed.

## 22. regression-22 — regression

Seed: 2022

### Prompt

```text
FACTS
location: clockmaker's workshop
time: noon
weather: rain
actor: Armand
action: search
target: abandoned suitcase
result: setback
resolved:
- a railway receipt is found
- opening the case makes a loud snap
visible:
- wall clocks
- workbench
- missing gear

NARRATION
```

### Response

You search the abandoned suitcase. A railway receipt lies inside, and when you open it, the case snaps with a loud sound. The wall clocks are still ticking, the workbench is empty, and one of its gears has gone.

## 23. regression-23 — regression

Seed: 2023

### Prompt

```text
FACTS
location: embassy drawing room
time: evening
weather: snow
actor: Armand
action: examine
target: discarded glove
result: success
resolved:
- the glove is wet
- black grease marks the fingertips
visible:
- piano
- silk curtains
- sealed dispatch

NARRATION
```

### Response

You examine the discarded glove. It is wet, and its fingertips are black with grease. The piano stands behind the silk curtains, and a sealed dispatch waits on the table.

## 24. regression-24 — regression

Seed: 2024

### Prompt

```text
FACTS
location: hospital corridor
time: before dawn
weather: storm
actor: Armand
action: move
target: rolling ladder
result: failure
resolved:
- the ladder jams halfway
- dust falls from the upper shelf
visible:
- empty stretcher
- medicine cabinet
- flickering lamp

NARRATION
```

### Response

You try to move the ladder, but it jams halfway. Dust falls from the upper shelf as you push, and the lamp flickers in the storm.

## 25. regression-25 — regression

Seed: 2025

### Prompt

```text
FACTS
location: seaside cottage
time: sunrise
weather: gale
actor: Armand
action: take
target: sealed envelope
result: success
resolved:
- the envelope enters inventory
- the seal remains intact
visible:
- cold stove
- nautical chart
- broken compass

NARRATION
```

### Response

You take a sealed envelope from the cottage. The envelope is yours to examine, but its contents remain beyond reach.

## 26. regression-26 — regression

Seed: 2026

### Prompt

```text
FACTS
location: taxidermist's shop
time: closing time
weather: fog
actor: Armand
action: use crowbar
target: locked chest
result: setback
resolved:
- the lid opens
- the crowbar bends
- a hinge breaks loudly
visible:
- glass eyes
- display cabinet
- black feather

NARRATION
```

### Response

You use a crowbar on the locked chest. The lid opens, the crowbar bends, and a hinge snaps with a loud crack. Inside you see a row of glass eyes, a display cabinet, and a black feather.

## 27. regression-27 — regression

Seed: 2027

### Prompt

```text
FACTS
location: courthouse records room
time: midday
weather: rain
actor: Armand
action: cast Detect Magic
target: display case
result: success
resolved:
- magic is present
- its nature and meaning remain unknown
visible:
- bound ledgers
- high window
- missing file

NARRATION
```

### Response

You cast Detect Magic on the display case. It reveals magic, but its nature and meaning remain unknown. The bound ledgers are there, but one is missing.

## 28. regression-28 — regression

Seed: 2028

### Prompt

```text
FACTS
location: botanical garden pavilion
time: afternoon
weather: humid
actor: Armand
action: speak
target: night clerk
result: success
resolved:
- Armand asks who left the key
- the clerk says a veiled woman left it at midnight
visible:
- iron bench
- exotic orchids
- dropped handkerchief

NARRATION
```

### Response

You ask who left the key. The night clerk glances from it to the exotic orchids, then says a veiled woman left it at midnight.

## 29. regression-29 — regression

Seed: 2029

### Prompt

```text
FACTS
location: private railway carriage
time: night
weather: snow
actor: Guillermo
action: search
target: high shelf
result: success
resolved:
- Guillermo finds a folded scrap
- Guillermo can communicate only through gestures
visible:
- leather seat
- travel trunk
- cracked watch

NARRATION
```

### Response

You see Guillermo search the high shelf. He finds a folded scrap of paper, then communicates his discovery through gesture, expression, vocalization, and physical behavior.

## 30. regression-30 — regression

Seed: 2030

### Prompt

```text
FACTS
location: newspaper press room
time: dawn
weather: clear
actor: Armand
action: wait
target: current location
result: success
resolved:
- ten minutes pass
- footsteps approach from the corridor
visible:
- printing press
- fresh proofs
- red pencil

NARRATION
```

### Response

You wait for ten minutes, then hear footsteps approach from the corridor. The printing press is in operation, fresh proofs are ready, and a red pencil lies on the desk.

## 31. regression-31 — regression

Seed: 2031

### Prompt

```text
FACTS
location: canal lock
time: midnight
weather: fog
actor: Armand
action: investigate
target: muddy footprints
result: exceptional success
resolved:
- two different shoe patterns are present
- one trail enters and does not leave
visible:
- iron winch
- mooring rope
- floating hat

NARRATION
```

### Response

You investigate the muddy footprints. Two different shoe patterns are present, one of which trails into the lock but does not trail out. The iron winch is in place, the mooring rope is attached, and a floating hat rests on the water.

## 32. regression-32 — regression

Seed: 2032

### Prompt

```text
FACTS
location: tailor's fitting room
time: morning
weather: rain
actor: Armand
action: move quietly
target: back door
result: setback
resolved:
- Armand reaches the door
- a loose board creaks
- suspicion increases
visible:
- three-way mirror
- measuring tape
- unfinished coat

NARRATION
```

### Response

You move quietly toward the back door. A loose board creaks, and your suspicion increases. You see a three-way mirror, a measuring tape, and an unfinished coat.

## 33. regression-33 — regression

Seed: 2033

### Prompt

```text
FACTS
location: bell tower
time: sunset
weather: wind
actor: Armand
action: cast Minor Illusion
target: far corner
result: success
resolved:
- a sound of breaking glass occurs in the far corner
- nearby attention shifts toward it
visible:
- great bell
- wooden stairs
- frayed rope

NARRATION
```

### Response

You cast your Minor Illusion. A sound of breaking glass echoes from the far corner, and nearby attention turns there. The great bell hangs high above you, its wooden stairs descend, and a frayed rope swings in the wind.

## 34. regression-34 — regression

Seed: 2034

### Prompt

```text
FACTS
location: collector's cabinet room
time: late evening
weather: storm
actor: Armand
action: investigate
target: half-written note
result: failure
resolved:
- the handwriting cannot be identified
- wet ink smears under the examination
visible:
- curio cases
- ivory figurine
- empty pedestal

NARRATION
```

### Response

You examine the half-written note. The handwriting cannot be identified, and wet ink smears under your fingers as you turn it over.

## 35. regression-35 — regression

Seed: 2035

### Prompt

```text
FACTS
location: schoolroom
time: after dark
weather: snow
actor: Armand
action: open
target: window
result: severe failure
resolved:
- the window stays shut
- the latch snaps
- glass cracks loudly
visible:
- slate board
- small desks
- forgotten primer

NARRATION
```

### Response

You press the latch; it gives before the window does. A sliver of loose glass drops and breaks on the floor, bright and sharp in the silence, while the window stays shut.

## 36. regression-36 — regression

Seed: 2036

### Prompt

```text
FACTS
location: bank vault corridor
time: noon
weather: clear
actor: Armand
action: give command
target: Guillermo
result: success
resolved:
- command is to scout the next room
- Guillermo slips through the doorway
- no scouting result is available yet
visible:
- steel door
- gas sconce
- bent hairpin

NARRATION
```

### Response

You give command. Guillermo slips through the doorway, but no scouting result is available yet.

## 37. regression-37 — regression

Seed: 2037

### Prompt

```text
FACTS
location: laundry basement
time: early morning
weather: rain
actor: Armand
action: investigate
target: dark stain
result: success
resolved:
- the stain is dried blood
- the amount is inconsistent with a death here
visible:
- copper boiler
- linen basket
- single cufflink

NARRATION
```

### Response

You investigate the dark stain. It is dried blood, but the amount is inconsistent with a death in this room; only a single cufflink is present.

## 38. regression-38 — regression

Seed: 2038

### Prompt

```text
FACTS
location: music hall backstage
time: midnight
weather: fog
actor: Armand
action: speak deceptively
target: dockworker
result: setback
resolved:
- the dockworker accepts the false name
- the dockworker demands payment before answering
visible:
- rope rigging
- painted scenery
- discarded mask

NARRATION
```

### Response

You speak deceptively. The dockworker accepts your false name, but demands payment before he answers you. You see the rigging above him, the painted scenery behind him, and a discarded mask on the floor.

## 39. regression-39 — regression

Seed: 2039

### Prompt

```text
FACTS
location: ornithologist's attic
time: afternoon
weather: wind
actor: Armand
action: cast Misty Step
target: visible balcony
result: success
resolved:
- Armand teleports to the balcony
- the spell slot is spent
visible:
- bird cages
- field journals
- open skylight

NARRATION
```

### Response

You cast Misty Step. The spell slot is spent, but you teleport to the balcony.

## 40. regression-40 — regression

Seed: 2040

### Prompt

```text
FACTS
location: telegraph office
time: 2 a.m.
weather: thunderstorm
actor: Guillermo
action: steal
target: brass key
result: failure
resolved:
- the key remains on the hook
- the key rattles
- Guillermo retreats
visible:
- telegraph key
- paper tape
- locked drawer

NARRATION
```

### Response

You see Guillermo steal a brass key from the hook. The key rattles as he takes it, and he retreats without speaking.

## 41. regression-41 — regression

Seed: 2041

### Prompt

```text
FACTS
location: funeral parlour
time: dusk
weather: drizzle
actor: Armand
action: investigate
target: desk
result: success
resolved:
- scratches surround the locked drawer
- the drawer remains closed
visible:
- closed coffin
- flower wreath
- muddy shoe

NARRATION
```

### Response

You trace the edge of the locked drawer. Fresh scratches score the wood around its keyhole; whatever marked it did so recently, but the drawer remains closed.

## 42. regression-42 — regression

Seed: 2042

### Prompt

```text
FACTS
location: shipping office
time: morning
weather: fog
actor: Armand
action: search
target: abandoned suitcase
result: setback
resolved:
- a railway receipt is found
- opening the case makes a loud snap
visible:
- cargo manifests
- wall map
- broken seal

NARRATION
```

### Response

You search the suitcase. A railway receipt lies on top, and when you open it, the case snaps with a loud crack. The manifests are there, but so is a wall map and a broken seal.

## 43. regression-43 — regression

Seed: 2043

### Prompt

```text
FACTS
location: icehouse
time: midday
weather: snow
actor: Armand
action: examine
target: discarded glove
result: success
resolved:
- the glove is wet
- black grease marks the fingertips
visible:
- stacked ice blocks
- meat hook
- dark stain

NARRATION
```

### Response

You examine a discarded glove. It is wet, and black grease marks its fingertips; the ice blocks are stacked around it, and a meat hook hangs above it. A dark stain lies beyond.

## 44. regression-44 — regression

Seed: 2044

### Prompt

```text
FACTS
location: portrait gallery
time: evening
weather: rain
actor: Armand
action: move
target: rolling ladder
result: failure
resolved:
- the ladder jams halfway
- dust falls from the upper shelf
visible:
- family paintings
- marble bust
- crooked frame

NARRATION
```

### Response

You try to move the ladder, but it jams halfway. Dust falls from the upper shelf as you struggle.

## 45. regression-45 — regression

Seed: 2045

### Prompt

```text
FACTS
location: servants' passage
time: before dawn
weather: clear
actor: Armand
action: take
target: sealed envelope
result: success
resolved:
- the envelope enters inventory
- the seal remains intact
visible:
- narrow stairs
- service bell
- dropped tray

NARRATION
```

### Response

You take a sealed envelope from the servants' passage. The envelope is yours to examine, but its contents remain hidden.

## 46. regression-46 — regression

Seed: 2046

### Prompt

```text
FACTS
location: auction house storeroom
time: closing time
weather: hail
actor: Armand
action: use crowbar
target: locked chest
result: setback
resolved:
- the lid opens
- the crowbar bends
- a hinge breaks loudly
visible:
- numbered lots
- packing straw
- empty crate

NARRATION
```

### Response

You use your crowbar on the locked chest. The lid opens, but the crowbar bends before you can reach its contents. A hinge snaps loudly, and a number of numbered lots, packing straw, and an empty crate fall out.

## 47. regression-47 — regression

Seed: 2047

### Prompt

```text
FACTS
location: observatory dome
time: midnight
weather: clear
actor: Armand
action: cast Detect Magic
target: display case
result: success
resolved:
- magic is present
- its nature and meaning remain unknown
visible:
- brass telescope
- star charts
- open hatch

NARRATION
```

### Response

You cast Detect Magic on the display case. The spell succeeds, but its nature and meaning remain unknown.

## 48. regression-48 — regression

Seed: 2048

### Prompt

```text
FACTS
location: tram depot
time: first light
weather: mist
actor: Armand
action: speak
target: night clerk
result: success
resolved:
- Armand asks who left the key
- the clerk says a veiled woman left it at midnight
visible:
- parked tram
- ticket booth
- forgotten parcel

NARRATION
```

### Response

You ask who left the key. The night clerk glances from it to the parked tram, then says a veiled woman left it at midnight.

## 49. regression-49 — regression

Seed: 2049

### Prompt

```text
FACTS
location: bookbinder's workshop
time: afternoon
weather: rain
actor: Guillermo
action: search
target: high shelf
result: success
resolved:
- Guillermo finds a folded scrap
- Guillermo can communicate only through gestures
visible:
- binding press
- leather scraps
- loose photograph

NARRATION
```

### Response

You see Guillermo search the high shelf. He finds a folded scrap, then communicates his discovery through gesture, expression, vocalization, and physical behavior.

## 50. regression-50 — regression

Seed: 2050

### Prompt

```text
FACTS
location: winter garden
time: late evening
weather: snow
actor: Armand
action: wait
target: current location
result: success
resolved:
- ten minutes pass
- footsteps approach from the corridor
visible:
- frosted panes
- stone bench
- freshly dug soil

NARRATION
```

### Response

You wait. Ten minutes pass, then footsteps approach from the corridor. The frost on the panes is still fresh, and the freshly dug soil has not been disturbed.
