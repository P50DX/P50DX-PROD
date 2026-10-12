-- BlockAnimal: builds brick-style animals from a spec (lives in ReplicatedStorage.BlockAnimal).
-- spec.parts = { {group, size, pos, color, opts}, ... }   pos = centre (studs), front = -Z, up = +Y
-- opts: rot={x,y,z} deg, studs=true (all faces studded), mat=Enum.Material.*, shape="wedge"|"ball"|"cyl", neon=true
-- spec.joints = { group = {parent, pivot}, ... }  -> Motor6D from parent group root to group root at pivot.
-- The first part listed for a group is that group's root; the rest weld to it.
local BlockAnimal = {}

function BlockAnimal.build(spec, origin)
	origin = origin or Vector3.zero
	local model = Instance.new("Model"); model.Name = spec.name
	local roots, count = {}, 0
	for _, p in ipairs(spec.parts) do
		local g, size, pos, color, o = p[1], p[2], p[3], p[4], p[5] or {}
		local part = (o.shape == "wedge") and Instance.new("WedgePart") or Instance.new("Part")
		if o.shape == "ball" then part.Shape = Enum.PartType.Ball elseif o.shape == "cyl" then part.Shape = Enum.PartType.Cylinder end
		part.Size = size
		local r = o.rot or {0, 0, 0}
		if o.look then
			local up = o.up or Vector3.yAxis
			if math.abs((o.look - pos).Unit:Dot(up)) > 0.97 then up = Vector3.zAxis end   -- straight up/down rods
			part.CFrame = CFrame.lookAt(origin + pos, origin + o.look, up)        -- rods: long axis = Z
		else part.CFrame = CFrame.new(origin + pos) * CFrame.Angles(math.rad(r[1]), math.rad(r[2]), math.rad(r[3])) end
		part.Color = color
		part.Material = o.neon and Enum.Material.Neon or (o.mat or (o.studs and Enum.Material.Plastic or Enum.Material.SmoothPlastic))  -- studs only render on Plastic
		local surf = o.studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
		for _, f in ipairs({"Top", "Bottom", "Front", "Back", "Left", "Right"}) do part[f .. "Surface"] = surf end
		part.Transparency = o.transp or 0
		part.CanCollide = false; part.CanQuery = false; part.CanTouch = false; part.Massless = true
		part.Anchored = true
		if not roots[g] then roots[g] = part; part.Name = g; part.Parent = model
		else part.Name = o.name or (g .. "_Detail"); local w = Instance.new("WeldConstraint"); w.Part0 = roots[g]; w.Part1 = part; w.Parent = part; part.Parent = roots[g] end
		count += 1
	end
	local hrp = Instance.new("Part"); hrp.Name = "HumanoidRootPart"; hrp.Transparency = 1
	hrp.Size = spec.hrpSize or Vector3.new(2, 2, 2); hrp.CFrame = CFrame.new(origin + (spec.hrpPos or Vector3.new(0, 1, 0)))
	hrp.Anchored = true; hrp.CanCollide = true; hrp.Parent = model; model.PrimaryPart = hrp
	for g, j in pairs(spec.joints) do
		local p0 = (j[1] == "Root") and hrp or roots[j[1]]; local p1 = roots[g]
		if p0 and p1 then
			local pv = CFrame.new(origin + j[2])
			local m = Instance.new("Motor6D"); m.Name = g; m.Part0 = p0; m.Part1 = p1
			m.C0 = p0.CFrame:Inverse() * pv; m.C1 = p1.CFrame:Inverse() * pv; m.Parent = p0
		end
	end
	model:SetAttribute("PartCount", count)
	return model
end

return BlockAnimal
