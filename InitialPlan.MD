Implementation plan:


Define the spouse feature scope

Decide whether the spouse is purely a follower NPC, a home-base companion, or a full relationship/survival system.
Define the minimum player-facing behavior: how the spouse appears, how the player meets them, whether they can follow, fight, loot, heal, talk, or die.
Decide whether the add-on targets single-player only at first, or must support multiplayer from the start.
Decide whether the spouse is unique per save, per player, or globally shared in multiplayer.

Establish the mod skeleton

Create the standard Project Zomboid mod structure for metadata, media assets, and Lua scripts.
Separate logic into shared, client, and server areas so future multiplayer support is not blocked by early design choices.
Add placeholder assets and configuration files needed for the game to recognize the add-on and for future Workshop packaging.

Design the spouse data model

Define persistent spouse state: identity, alive/dead state, trust/relationship level, inventory ownership, home/safe location, follow state, and dialogue flags.
Define how the spouse is linked to the player across save/load.
Plan for versioned save data so new spouse features can be added later without breaking old saves.

Plan the spouse spawn and introduction flow

Choose a reliable first-spawn trigger, such as world start, first day, first safehouse entry, or a special event.
Define constraints to avoid bad spawns, such as unsafe cells, zombie-heavy areas, or duplicate spouse creation after reloads.
Add a fallback recovery path if the spouse becomes invalid, lost, or unloaded.

Implement spouse behavior in phases

Phase 1: presence only — spawn spouse, persist identity, basic idle behavior.
Phase 2: simple companionship — basic follow/stay commands, teleport/rejoin recovery, safe distance handling.
Phase 3: survival interaction — inventory sharing, weapon use rules, panic/injury reactions, sleep/eat routines.
Phase 4: relationship layer — dialogue states, affection/trust changes, optional mood effects or buffs/debuffs.

Define command and interaction UX

Decide how the player controls the spouse: context menu, radial menu, hotkey, timed action, or dialogue menu.
Keep the first version small: follow, stay, talk, trade, and go home are enough.
Make commands resilient to edge cases like combat, driving, sleeping, or spouse being in another loaded area.

Plan AI and safety rules

Define pathing expectations and when to abandon pathing and snap/recover.
Define combat participation rules to prevent the spouse from becoming overpowered or suicidal.
Define safehouse/home behavior for idle time.
Define anti-frustration protections, such as refusing impossible orders, avoiding fire/windows/falling, and reuniting after chunk unloads.

Dialogue and presentation

Decide whether the spouse has fixed writing, lightweight barks, or branching dialogue.
Add lightweight feedback for important state changes: found, following, injured, separated, dead, waiting at home.
Keep dialogue data separate from control logic so it can expand later.

Persistence and save compatibility

Save spouse state independently from transient runtime objects.
Rebuild runtime state cleanly on load.
Validate that loading an existing save does not create duplicates or break when spouse data is missing or outdated.

Multiplayer and ownership rules

If multiplayer is required, define spouse ownership, authority, and conflict handling up front.
Prevent multiple players from controlling the same spouse unless intentionally designed.
Define what happens when the owning player disconnects, dies, or transfers leadership.

Testing plan

Manual test scenarios should cover: new game start, save/load, spouse death, player death, spouse separation, building entry/exit, combat, vehicle travel, sleeping, and migration from older save data.
Add a simple repeatable smoke-test checklist for every iteration since automated testing is likely limited for a PZ Lua mod.

Packaging and release readiness

Prepare metadata, preview assets, and install instructions.
Document supported game version, limitations, and known issues.
Keep configuration hooks in mind for future options like spouse difficulty, immortality, combat aggression, and spawn style.

Recommended delivery order:


Milestone 1: mod skeleton + metadata + spouse persistence scaffold
Milestone 2: spouse spawn/introduction + single spouse per save guarantee
Milestone 3: follow/stay/talk/trade interactions
Milestone 4: combat/survival behavior + recovery logic
Milestone 5: relationship progression + polish + packaging

Key risks to plan around:


Project Zomboid NPC limitations or lack of native human companion systems
Chunk unloading/pathfinding causing spouse loss or broken following
Save persistence bugs creating duplicates or invalid references
Multiplayer authority issues if support is added later instead of planned early

Clarifying questions:


Should this spouse be a true human NPC companion, or is a lighter simulated companion acceptable if full NPC behavior is too limited?
Is the first release single-player only, or must it support multiplayer?
Do you want the spouse to be central gameplay with commands/combat/trading, or mainly narrative flavor with light interaction?
Should the spouse be recruitable through gameplay, or automatically present from the start?
Are there any must-have features for v1, such as following, dialogue, romance progression, inventory sharing, or permadeath?