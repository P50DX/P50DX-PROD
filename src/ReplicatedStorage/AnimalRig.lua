--!strict
-- AnimalRig (ModuleScript -> ReplicatedStorage)
-- Turns a block animal / pet / zookeeper model (built anchored, for display) into something that moves.
--   AnimalRig.prepare(model, "player")  -- playable character: everything unanchored + Humanoid (use as StarterCharacter
--                                         or swap it in as the player's Character)
--   AnimalRig.prepare(model, "npc")     -- zookeeper / chaser: same as player, drive it with Humanoid:MoveTo
--   AnimalRig.prepare(model, "pet")     -- pet: only the root is anchored; move it with PivotTo (see AnimalMotion)
-- Every prepared model is tagged "AnimalRig", so AnimalMotion animates it.

local CollectionService = game:GetService("CollectionService")

local AnimalRig = {}
AnimalRig.TAG = "AnimalRig"

function AnimalRig.prepare(model: Model, mode: string): Model
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart
	assert(root, model.Name .. " has no HumanoidRootPart")
	model.PrimaryPart = root
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = (mode == "pet") and d == root
			if d ~= root then
				d.CanCollide = false; d.CanQuery = false; d.CanTouch = false; d.Massless = true
			end
		end
	end
	root.CanCollide = mode ~= "pet"
	root.CanQuery = true; root.CanTouch = true
	if mode ~= "pet" and not model:FindFirstChildOfClass("Humanoid") then
		local hum = Instance.new("Humanoid")
		hum.RigType = Enum.HumanoidRigType.R15   -- R15 rule: root floats HipHeight + Size.Y/2 above the floor
		hum.HipHeight = 0.05
		hum.AutomaticScalingEnabled = false
		hum.Parent = model
		hum:SetAttribute("BaseWalkSpeed", hum.WalkSpeed)
	end
	-- leg length for the gait (stride + playback rate); the root's height is a good stand-in for these rigs
	model:SetAttribute("LegLength", root.Size.Y * 0.4)
	CollectionService:AddTag(model, AnimalRig.TAG)
	return model
end

return AnimalRig
