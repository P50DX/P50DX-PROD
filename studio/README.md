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
