-- remove trees / bushes that poke into other cliff blocks (run after building)
local removed = 0
local function pass(folder)
	local blocks = {}
	for _, d in folder:GetDescendants() do
		if d:IsA("BasePart") and not d:FindFirstAncestorWhichIsA("Model").Name:match("^Tree") and not d:FindFirstAncestorWhichIsA("Model").Name:match("^Bush") then table.insert(blocks, d) end
	end
	local saved = {}
	for _, b in ipairs(blocks) do saved[b] = b.CanQuery; b.CanQuery = true end
	local op = OverlapParams.new(); op.FilterType = Enum.RaycastFilterType.Include; op.FilterDescendantsInstances = blocks
	for _, m in folder:GetDescendants() do
		if m:IsA("Model") and (m.Name:match("^Tree") or m.Name:match("^Bush")) then
			local bad = false
			for _, p in m:GetDescendants() do
				if p:IsA("BasePart") then
					local cf = p.CFrame
					local size = p.Size * 0.8
					-- ignore the bottom 1.5 studs of trunks (they sit on the cap)
					if #workspace:GetPartBoundsInBox(cf + Vector3.new(0, 1.5, 0), size, op) > 0 then bad = true break end
				end
			end
			if bad then m:Destroy(); removed += 1 end
		end
	end
	for b, v in pairs(saved) do if b.Parent then b.CanQuery = v end end
end
local z = workspace.World1_Zoo
pass(z.Hub.Cliffs)
pass(z.Obby.Walls)
return "removed " .. removed
