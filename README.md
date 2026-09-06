# project-zomboid-mod-spouse

`project-zomboid-mod-spouse` is a greenfield Project Zomboid Build 42 mod scaffold for a spouse companion system.

## Current scope

This first implementation is intentionally **single-player first** and ships the foundation for a spouse companion instead of a full autonomous vanilla NPC. Project Zomboid does not expose a stable built-in human companion system, so this repository now provides:

- standard Project Zomboid mod metadata and folder structure
- versioned persistent spouse save data through `ModData`
- a spouse profile with bond, trust, home, command, dialogue, and presence state
- a context-menu command surface for follow, wait, rally, set home, go home, and talk
- lightweight spouse dialogue feedback for each command
- an NPC backend adapter layer that can later be wired to Bandits or another companion framework

## Repository structure

- `/home/runner/work/project-zomboid-mod-spouse/project-zomboid-mod-spouse/mod.info` — mod metadata
- `/home/runner/work/project-zomboid-mod-spouse/project-zomboid-mod-spouse/media/lua/shared/Spouse` — shared config, persistence, dialogue, commands, and backend adapter
- `/home/runner/work/project-zomboid-mod-spouse/project-zomboid-mod-spouse/media/lua/client/Spouse` — client bootstrap, world context menu, and spouse feedback
- `/home/runner/work/project-zomboid-mod-spouse/project-zomboid-mod-spouse/media/lua/server/Spouse` — server/bootstrap persistence hooks

## How the current add-on behaves

1. On first load, the mod creates a persistent spouse profile for the local player.
2. The spouse gets a generated display name, a default follow state, and a saved home position.
3. On game start, the player receives an introductory spouse line.
4. Right-clicking the world shows a **Spouse** submenu with commands and status lines.
5. Commands update persistent spouse state and return a spouse dialogue response.

## Assumptions and limitations

- This implementation targets **Build 42 style mod structure** and a **single-player-first** workflow.
- The current backend is `vanilla-simulated`, which means the spouse exists as persistent game state and interaction scaffolding, not yet as a fully simulated human actor in the world.
- `SpouseNpcAdapter.lua` is the extension point for future true-NPC integration.
- Multiplayer ownership and network authority are not implemented in this first pass.

## Installation

Copy this repository into your Project Zomboid mods directory so the `mod.info` file is at the root of the installed mod folder, then enable **Spouse** from the in-game mods menu.

## Manual smoke test checklist

Use this checklist during in-game verification:

- Start a new save with the mod enabled.
- Confirm an introduction line appears once on first load.
- Right-click the world and confirm the **Spouse** submenu is present.
- Confirm each command updates state and prints a spouse response.
- Save and reload, then verify the spouse name, home, command state, and bond persist.
- Use **Set Home Here**, move away, reload, and confirm the saved home coordinates remain stable.
- Use **Talk** multiple times and confirm bond increases without errors.
- Verify no duplicate spouse profile is created after multiple reloads.

## Next implementation steps

- connect `SpouseNpcAdapter.lua` to a real NPC backend if the project adopts one
- add inventory exchange and equipment rules
- add safehouse routines, separation recovery rules, and death handling
- add multiplayer-safe ownership and command syncing
- add richer dialogue pools and relationship progression
