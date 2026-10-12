--!strict
-- PetFollow (ModuleScript -> ReplicatedStorage)
-- Client side: every client moves every equipped pet itself, so pets follow smoothly with no network cost.
-- Pets live in workspace.Pets.<PlayerName> (put there by PetService on the server) with a "Slot" attribute.
-- Walkers snap to the ground, flyers ("Flying" attribute) hover and bob. AnimalMotion animates them from their movement.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PetFollow = {}

local SPACING = 3.2         -- studs between pets in the formation
local BACK = 2.5            -- gap between the owner's back end and the first row
local FOLLOW = 8            -- how fast pets catch up (higher = tighter)
local TELEPORT = 60         -- snap to the owner when farther than this

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- slot 1..n -> offset behind the owner: rows of 3 (centre, left, right)
local function slotOffset(slot: number, ownerLength: number): Vector3
	local row = math.floor((slot - 1) / 3)
	local col = (slot - 1) % 3
	local x = (col == 0) and 0 or ((col == 1) and -SPACING or SPACING)
	return Vector3.new(x, 0, ownerLength / 2 + BACK + row * SPACING)
end

local function groundY(pos: Vector3, ignore: { Instance }): number?
	rayParams.FilterDescendantsInstances = ignore
	local hit = workspace:Raycast(pos + Vector3.new(0, 6, 0), Vector3.new(0, -40, 0), rayParams)
	return hit and hit.Position.Y
end

local running = false
function PetFollow.start()
	if running then return end
	running = true
	local petsFolder = workspace:WaitForChild("Pets")
	RunService.PreSimulation:Connect(function(dt)
		local t = os.clock()
		for _, folder in petsFolder:GetChildren() do
			local owner = Players:FindFirstChild(folder.Name) :: Player?
			local char = owner and owner.Character
			local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not root then continue end
			local ignore = { petsFolder, char :: Instance }
			for _, pet in folder:GetChildren() do
				if not pet:IsA("Model") or not pet.PrimaryPart then continue end
				local slot = pet:GetAttribute("Slot")
				local flying = pet:GetAttribute("Flying") == true
				local target = root.CFrame:PointToWorldSpace(slotOffset(if typeof(slot) == "number" then slot else 1, root.Size.Z))
				local pivot = pet:GetPivot()
				local cur = pivot.Position
				local half = pet.PrimaryPart.Size.Y / 2
				local flat = Vector3.new(target.X, cur.Y, target.Z)
				local nextPos = if (flat - cur).Magnitude > TELEPORT then flat else cur:Lerp(flat, math.min(1, dt * FOLLOW))
				local g = groundY(nextPos, ignore) or (root.Position.Y - root.Size.Y / 2)
				local y = g + half + (if flying then 2.5 + math.sin(t * 2.5 + (slot :: number? or 1)) * 0.35 else 0)
				nextPos = Vector3.new(nextPos.X, cur.Y + (y - cur.Y) * math.min(1, dt * 12), nextPos.Z)
				-- face the way it is moving, or the owner's way when standing still
				local move = Vector3.new(nextPos.X - cur.X, 0, nextPos.Z - cur.Z)
				local look = if move.Magnitude > 0.02 then move.Unit else root.CFrame.LookVector * Vector3.new(1, 0, 1)
				local want = CFrame.lookAt(nextPos, nextPos + look)
				pet:PivotTo(pivot.Rotation:Lerp(want.Rotation, math.min(1, dt * 10)) + nextPos)
			end
		end
	end)
end

return PetFollow
