-- TEST ONLY: spawns every model as a moving NPC and runs idle / walk / run / jump / fall phases.
local SS = game:GetService("ServerStorage")
local AR = require(game.ReplicatedStorage.AnimalRig)
task.wait(4)
local npcs = {}
local list = {}
for _, f in ipairs({"Animals", "Pets", "Zookeepers"}) do for _, m in ipairs(SS.ZooModels[f]:GetChildren()) do table.insert(list, m) end end
local folder = Instance.new("Folder"); folder.Name = "MotionTest"; folder.Parent = workspace
for i, src in ipairs(list) do
	local m = src:Clone()
	AR.prepare(m, "npc")
	if m.Name == "ForestSpirit" or m.Name == "MiniBee" or m.Name == "FireBat" then m:SetAttribute("Flying", true) end
	local x, z = 80 + ((i - 1) % 11) * 12, 40 + math.floor((i - 1) / 11) * 14
	m:PivotTo(CFrame.new(x, m:GetPivot().Y + 0.5, z)); m.Parent = folder
	table.insert(npcs, {m = m, h = m:FindFirstChildOfClass("Humanoid"), home = Vector3.new(x, 0, z)})
end
local function phase(name, secs, fn)
	workspace:SetAttribute("TestPhase", name)
	local t0 = os.clock()
	while os.clock() - t0 < secs do fn(os.clock() - t0); task.wait(0.25) end
end
task.wait(2)
phase("idle", 4, function() end)
phase("walk", 5, function(t) for _, n in ipairs(npcs) do n.h.WalkSpeed = 8; n.h:Move(Vector3.new(0, 0, (t % 4 < 2) and -1 or 1)) end end)
phase("run", 5, function(t) for _, n in ipairs(npcs) do n.h.WalkSpeed = 26; n.h:Move(Vector3.new(0, 0, (t % 3 < 1.5) and -1 or 1)) end end)
for _, n in ipairs(npcs) do n.h:Move(Vector3.zero) end
phase("jump", 3, function() for _, n in ipairs(npcs) do n.h.Jump = true end end)
phase("fall", 3, function(t) if t < 0.3 then for _, n in ipairs(npcs) do n.m:PivotTo(n.m:GetPivot() + Vector3.new(0, 25, 0)) end end end)
workspace:SetAttribute("TestPhase", "done")
