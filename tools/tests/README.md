# Studio test scripts

| File | What it checks | How to run |
|---|---|---|
| `connectivity_audit.lua` | Every visible part of every model touches the rest of its body, so nothing is floating or severed. | `execute_luau` in Edit mode. |
| `motion_test_server.lua` | Spawns all 105 models as moving NPCs and runs them through idle, walk, run, jump and fall. | Put it in ServerScriptService as a Script named `MotionTest`, then press Play. |
| `motion_test_client.lua` | Samples how far each model's joints move in each phase and lists any that don't animate. | `execute_luau` on the Client during that play session. |
