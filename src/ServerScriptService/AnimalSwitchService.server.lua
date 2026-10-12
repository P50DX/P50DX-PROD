-- AnimalSwitchService (Script -> ServerScriptService)
-- Lets a player become any animal / pet / zookeeper in any version (for testing). Works with the AnimalPicker
-- LocalScript. Models come from ServerStorage.ZooModels (+ .Variants for Golden, Rainbow, ...).
-- The pick survives respawning (saved in the player's "ChosenAnimal" attribute).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local AnimalRig = require(ReplicatedStorage:WaitForChild("AnimalRig"))
local zoo = ServerStorage:WaitForChild("ZooModels")
local CATEGORIES = { Animals = true, Pets = true, Zookeepers = true }

-- display copies for the picker's 3D thumbnails (the client can't see ServerStorage)
local previews = ReplicatedStorage:FindFirstChild("AnimalPreviews")
if previews then previews:Destroy() end
previews = Instance.new("Folder")
previews.Name = "AnimalPreviews"
for cat in CATEGORIES do
	local f = Instance.new("Folder")
	f.Name = cat
	for _, m in zoo[cat]:GetChildren() do m:Clone().Parent = f end
	f.Parent = previews
end
previews.Parent = ReplicatedStorage

local remote = ReplicatedStorage:FindFirstChild("ChangeAnimal") or Instance.new("RemoteEvent")
remote.Name = "ChangeAnimal"
remote.Parent = ReplicatedStorage

local lastSwap: { [Player]: number } = {}

local function sourceFor(cat: string, name: string, variant: string?): Model?
	if not CATEGORIES[cat] then return nil end
	local base = zoo[cat]:FindFirstChild(name)
	if not base then return nil end
	if variant and variant ~= "Normal" then
		local v = zoo:FindFirstChild("Variants") and zoo.Variants:FindFirstChild(name)
		return (v and v:FindFirstChild(variant)) or base
	end
	return base
end

local function become(player: Player, cat: string, name: string, variant: string?)
	local src = sourceFor(cat, name, variant)
	if not src then return end
	local old = player.Character
	local oldRoot = old and old:FindFirstChild("HumanoidRootPart") :: BasePart?
	local char = src:Clone()
	char.Name = player.Name
	AnimalRig.prepare(char, "player")
	char:SetAttribute("Animal", name)
	char:SetAttribute("Variant", variant or "Normal")
	local root = char.PrimaryPart :: BasePart
	if oldRoot then -- stand on the same spot, feet on the ground, facing the same way
		local bottom = oldRoot.Position.Y - oldRoot.Size.Y / 2
		char:PivotTo(CFrame.new(oldRoot.Position.X, bottom + root.Size.Y / 2 + 0.3, oldRoot.Position.Z) * oldRoot.CFrame.Rotation)
	else
		local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
		char:PivotTo(CFrame.new((spawn and spawn.Position or Vector3.zero) + Vector3.new(0, root.Size.Y / 2 + 1, 0)))
	end
	player.Character = char
	char.Parent = workspace
	if old then old:Destroy() end
end

remote.OnServerEvent:Connect(function(player, cat, name, variant)
	if typeof(cat) ~= "string" or typeof(name) ~= "string" then return end
	if variant ~= nil and typeof(variant) ~= "string" then return end
	if os.clock() - (lastSwap[player] or 0) < 0.75 then return end -- no spamming
	lastSwap[player] = os.clock()
	player:SetAttribute("ChosenAnimal", cat .. "/" .. name .. "/" .. (variant or "Normal"))
	become(player, cat, name, variant)
end)

-- keep the chosen animal after respawning
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local chosen = player:GetAttribute("ChosenAnimal")
		if typeof(chosen) ~= "string" then return end
		local cat, name, variant = string.match(chosen, "^(%w+)/(%w+)/(%w+)$")
		if not cat or char:GetAttribute("Animal") == name then return end
		task.defer(become, player, cat, name, variant)
	end)
end)
Players.PlayerRemoving:Connect(function(player) lastSwap[player] = nil end)
