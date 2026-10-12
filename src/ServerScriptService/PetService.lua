--!strict
-- PetService (ModuleScript -> ServerScriptService)
-- Server side of pets: equip / unequip. Models come from ServerStorage.ZooModels.Pets.<PetName>.
--   PetService.equip(player, "BabyPanda")   -> the pet model (or nil if the name is unknown / slots are full)
--   PetService.unequip(player, petModel)
--   PetService.clear(player)
-- Clients move the pets (PetFollow) and animate them (AnimalMotion). Hook equip into the egg-hatch / inventory code.

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimalRig = require(ReplicatedStorage:WaitForChild("AnimalRig"))

local PetService = {}
PetService.MAX_EQUIPPED = 6

-- pets that hover instead of walking
local FLYING = { MiniBee = true, FireBat = true, IceOwl = true, OwlChick = true, NebulaOwl = true, ForestSpirit = true, GalaxyDragon = true }

local petsFolder = workspace:FindFirstChild("Pets") or Instance.new("Folder")
petsFolder.Name = "Pets"
petsFolder.Parent = workspace

local function folderFor(player: Player): Folder
	local f = petsFolder:FindFirstChild(player.Name)
	if not f then
		f = Instance.new("Folder")
		f.Name = player.Name
		f.Parent = petsFolder
	end
	return f :: Folder
end

function PetService.equip(player: Player, petName: string): Model?
	local source = ServerStorage:WaitForChild("ZooModels"):WaitForChild("Pets"):FindFirstChild(petName)
	if not (source and source:IsA("Model")) then return nil end
	local folder = folderFor(player)
	local used = {}
	for _, p in folder:GetChildren() do used[p:GetAttribute("Slot") :: number] = true end
	local slot = 1
	while used[slot] do slot += 1 end
	if slot > PetService.MAX_EQUIPPED then return nil end
	local pet = source:Clone()
	AnimalRig.prepare(pet, "pet")
	pet:SetAttribute("Slot", slot)
	pet:SetAttribute("Flying", FLYING[petName] == true)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then pet:PivotTo(root.CFrame * CFrame.new(0, 0, 4)) end
	pet.Parent = folder
	return pet
end

function PetService.unequip(player: Player, pet: Model)
	if pet.Parent == petsFolder:FindFirstChild(player.Name) then pet:Destroy() end
end

function PetService.clear(player: Player)
	local f = petsFolder:FindFirstChild(player.Name)
	if f then f:Destroy() end
end

Players.PlayerRemoving:Connect(PetService.clear)

return PetService
