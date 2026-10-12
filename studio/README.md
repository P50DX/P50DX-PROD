# Zoo Escape – block models (built in Roblox Studio)

Every animal, pet and zookeeper is built from Roblox Parts in a brick style:
- studded Plastic bodies
- pixel eyes with a shine
- angry brows and glowing eyes on scary animals
- neon trims on premium animals

## Files

| Path | What it is |
|---|---|
| `BlockAnimal.lua` | Builder: turns a spec into a Model. Body groups are welded, Motor6D joints sit between groups, and an invisible HumanoidRootPart is the collider. |
| `Kit.lua` | Shared helpers for specs: `quad`, `pup` (chibi pet), `face`, `cute`, `eye`, `ears`, `tail`, `rod`, `sprinkle`. |
| `animals/*.lua` | One spec per model (73 animals, 30 pets, 2 zookeepers). A spec starting with `--@base Other` reuses another spec with a new palette plus extras. |
| `../tools/mk_build.py` | Packs specs into one Luau build script, e.g. `python3 tools/mk_build.py Lion:0,0 Tiger:10,0`. |
| `../src/ReplicatedStorage/AnimalVariants.lua` | The 6 variants: Golden, Rainbow, Diamond, Shadow, Celestial, Cosmic. Recolours the model and adds sparkles. One shared loop runs Rainbow. |
| `../src/ReplicatedStorage/AnimalRig.lua` | `prepare(model, "player" / "npc" / "pet")` makes a display model movable. |
| `../src/ReplicatedStorage/AnimalMotion.lua` | Procedural animation for everything tagged `AnimalRig`, run by one client loop. It covers idle, walk, run, gallop, jump, fall, land and turn, plus tails, ears, wings, fins and tentacles. Leg speed is capped. |
| `../src/ReplicatedStorage/PetFollow.lua` | Client side: pets follow the owner in rows of 3. Walkers snap to the ground; flyers hover. |
| `../src/ServerScriptService/PetService.lua` | Server side: `equip(player, "BabyPanda")`, `unequip`, `clear`. Clones from `ServerStorage.ZooModels.Pets`. |
| `../src/StarterPlayerScripts/*.client.lua` | Tiny starters that call `.start()` on the modules above. |

## In the test place (Studio)

- **ServerStorage.ZooModels:** clean copies of every model, in the folders `Animals`, `Pets` and `Zookeepers`.
- **StarterPlayer.StarterCharacter:** a playable Cheetah, for testing.
- **ServerScriptService.PetTest:** a test-only script that equips 3 pets. Delete it for the real game.

## Testing animals yourself (Change Animal button)
- `ServerScriptService.AnimalSwitchService` + `StarterPlayerScripts.AnimalPicker`: press **Change Animal** (bottom-left)
  in Play mode, pick a tab (Animals / Pets / Zookeepers), a version (Normal, Golden, ...) and click a thumbnail.
  You turn into it on the spot; the pick is kept when you respawn. Remove both scripts before publishing if players
  shouldn't have it.

## Moving it into the real Zoo Escape place

1. In the test place, select these and right-click → Save to File (`.rbxm`):
   - `ServerStorage.ZooModels`
   - the 4 ModuleScripts in ReplicatedStorage
   - `ServerScriptService.PetService`
   - the 3 LocalScripts in `StarterPlayerScripts`
2. Insert them into the same places in the real game.
3. To make a player an animal:
   1. Clone the model from `ZooModels.Animals`.
   2. Run `AnimalRig.prepare(clone, "player")`.
   3. Set `player.Character = clone` (or use it as `StarterCharacter`).
4. Variants: `AnimalVariants.apply(model, "Golden")`.
5. Pets: call `PetService.equip(player, petName)` from the egg-hatch code.

## Worlds, obbies and the map (World 1: Zoo)

Built entirely in Studio from Parts by the builder modules in `studio/map/` (installed in Studio under
`ServerStorage.MapBuilder`). Rebuild with `tools/build_zoo_world.lua` (run it with execute_luau / the command bar).

| File | What it builds |
|---|---|
| `map/MapKit.lua` | Part / text / effect helpers |
| `map/Props.lua` | Trees, rocks, cliffs, lamps, fences, crates, banners, signposts, arches, distant hills |
| `map/Stations.lua` | Stage gates, reward pads (yellow / purple x2 / green skip), speed upgrades, treadmills, eggs, Version Wheel, shops, leaderboards, portals, premium (Alpha) pads |
| `map/Obby.lua` | Generic 10-stage course builder (jumps, ramps, climbs, movers, sweepers, crushers, blink + collapse platforms, cage walls, nets, rolling ball with safe pockets, Zookeeper chase routes) |
| `map/ZooHub.lua`, `map/ZooObby.lua` | World 1 (hub layout from your overhead screenshot; 10 stages, chases on 3/5/9, ball on 6 + 10, nets on 8 + 10). No Version Wheel in the Zoo. |

Runtime:
- `src/ReplicatedStorage/ZooMapConfig.lua` - what the gates / pads / stations display, Product IDs (empty = free in TestMode).
- `src/ServerScriptService/ObbyService.server.lua` - gates, checkpoints, rewards, skip, Zookeeper chase AI, prompts.
  Your systems connect through `ServerStorage.ZooMapHooks`: `GrantReward`, `StageReached`, `Interact`,
  and you fire `ProductPurchased(player, productId)` from your own ProcessReceipt.
- `src/StarterPlayerScripts/ObbyClient.client.lua` - hazard animation (server-clock synced), falls/hits -> checkpoint,
  HUD (1-10 bar, banners, chase warnings, SAFE!), hold-to-interact prompts, world lighting, ambience.

### Round 2 changes (Zoo)
- `map/Eggs.lua`: one unique egg per world (Zoo, Desert, Snow, Forest, Volcano, Space), stored as
  `ServerStorage.ZooModels.Eggs`. Egg stations no longer show pets in the world; the prompt opens the egg menu
  (`src/StarterPlayerScripts/EggMenu.client.lua`) with 3D pet previews, rarity and a Hatch button (`HatchEgg` remote ->
  `ZooMapHooks.Interact(player, "Egg", {...})`).
- `src/ServerScriptService/FastestStatue.server.lua`: the plinth east of the fountain shows a frozen copy of the
  fastest player's own animal + their name and Speed (leaderstats.Speed, else attribute "Speed").
- New treadmills (face the TRAINING CENTER sign), smaller reward buttons, new shops with 3D rooftop icons,
  zoo garden / snack court / picnic lawn instead of the entrance arch and animal pens.
- `tools/declutter_trees.lua`: after building, removes cliff trees that poke into neighbouring cliff blocks.
