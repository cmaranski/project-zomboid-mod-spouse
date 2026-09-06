# Spouse Companion

A small Project Zomboid companion mod featuring a fixed private character based on Simon "Ghost" Riley from the Call of Duty: Modern Warfare reboot continuity. The first release targets single-player and provides one persistent spouse per save, with a guarded human NPC runtime when the selected game build exposes the required survivor APIs.

## Scope: version 0.1

- Simon Riley, known as Ghost, is introduced near the player on the first game start.
- The authored identity and character definition live in `SpouseProfile.lua`; the spouse is not randomly generated.
- Identity, alive state, trust, home position, follow state, inventory ownership, and dialogue flags are stored in versioned `ModData`.
- Context-menu commands provide Follow, Stay, Talk, and Go home.
- A separated spouse can be recovered by rejoining them near the player when following is enabled.
- NPC construction is guarded so unsupported builds retain their save data instead of crashing the game.
- Multiplayer is intentionally not enabled yet; ownership and authority need to be designed before that milestone.

## Install for development

1. Copy this repository into `%UserProfile%\Zomboid\mods\SpouseCompanion` (the user data folder, not the Steam install directory).
2. Ensure `mod.info` sits directly inside that folder, with the Lua code under `common/media/lua/...` (Build 42 requires a `common` or version folder — mods with `media` at the root are not detected).
3. Enable **Spouse Companion** from the in-game Mods menu.
4. Start a new single-player save for the introduction flow.

## Smoke test

- Start a new single-player world and confirm the spouse appears once.
- Save, quit, and reload; confirm no duplicate spouse is created.
- Use Follow, Stay, Talk, and Go home from the context menu.
- Walk far enough away to exercise recovery, then save and reload.
- Confirm a spouse marked dead is not recreated.

## Known limitations

Project Zomboid human NPC APIs vary by game build and are not a stable multiplayer companion system. Combat, trading, inventory transfer, sleep, injury, and relationship progression are reserved for later milestones. The current runtime is deliberately conservative and single-player only.
