"""Install local Luau files as scripts in Studio.
    python3 tools/push.py local.lua Service.Folder.Name[:ModuleScript|Script|LocalScript] ...
Folders on the way are created. Existing script is replaced in place (Source updated)."""
import json, subprocess, sys
for spec in sys.argv[1:]:
    local, target = spec.split("=", 1)
    cls = "ModuleScript"
    if ":" in target: target, cls = target.split(":")
    src = open(local).read()
    lvl = 1
    while ("]" + "=" * lvl + "]") in src: lvl += 1
    eq = "=" * lvl
    parts = target.split(".")
    code = f"""local src = [{eq}[{src}]{eq}]
local node = game:GetService("{parts[0]}")
local path = {{{", ".join(json.dumps(x) for x in parts[1:-1])}}}
for _, n in ipairs(path) do local c = node:FindFirstChild(n) if not c then c = Instance.new("Folder") c.Name = n c.Parent = node end node = c end
local s = node:FindFirstChild("{parts[-1]}")
if s and s.ClassName ~= "{cls}" then s:Destroy() s = nil end
if not s then s = Instance.new("{cls}") s.Name = "{parts[-1]}" s.Parent = node end
s.Source = src
return "ok {target} " .. #src"""
    open("/tmp/push_code.lua", "w").write(code)
    r = subprocess.run(["python3", "/tmp/sc.py", "execute_luau", json.dumps({"code": "@/tmp/push_code.lua"})], capture_output=True, text=True)
    print(r.stdout.strip()[-300:], r.stderr.strip()[-300:])
