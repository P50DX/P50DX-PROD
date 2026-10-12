--!strict
-- PartBuilder: builds cute part-based animals from a spec table.
-- spec = { name=, origin=Vector3, groups = { GroupName = { parent="Body", pivot=Vector3, parts = { {shape, size, pos, color, rot?, mat?, transp?}, ... } } } }
-- shape: "ball" | "block" | "cyl" | "wedge"; pos/pivot are relative to origin (studs, front = -Z, up = +Y); rot in degrees (X,Y,Z).
-- Every group becomes parts welded to one "<Group>" root part; groups are joined to their parent with Motor6D at
-- the pivot, so the model can be animated later (Body is the root, attached to HumanoidRootPart).
local function build(spec)
	local model = Instance.new("Model")
	model.Name = spec.name
	local origin = spec.origin or Vector3.zero
	local roots = {}
	local function mkpart(p, gname)
		local shape, size, pos, color = p[1], p[2], p[3], p[4]
		local o = p[5] or {}
		local part: BasePart
		if shape == "wedge" then part = Instance.new("WedgePart") else part = Instance.new("Part") end
		if shape == "ball" then (part :: Part).Shape = Enum.PartType.Ball
		elseif shape == "cyl" then (part :: Part).Shape = Enum.PartType.Cylinder end
		part.Size = size
		local rot = o.rot or Vector3.zero
		part.CFrame = CFrame.new(origin + pos) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
		part.Color = color
		part.Material = o.mat or Enum.Material.SmoothPlastic
		part.Transparency = o.transp or 0
		part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth
		part.CanCollide = false
		part.CastShadow = o.shadow ~= false
		part.Name = o.name or gname
		return part
	end
	-- HumanoidRootPart (invisible box at the feet centre)
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"; hrp.Size = spec.rootSize or Vector3.new(2, 2, 2)
	hrp.CFrame = CFrame.new(origin + Vector3.new(0, hrp.Size.Y / 2, 0)); hrp.Transparency = 1
	hrp.CanCollide = false; hrp.Anchored = true; hrp.Parent = model
	model.PrimaryPart = hrp
	-- groups: first part of each group is its root; the rest are welded to it
	for gname, g in pairs(spec.groups) do
		local folder = model
		local root: BasePart? = nil
		for i, p in ipairs(g.parts) do
			local part = mkpart(p, gname)
			if not root then
				root = part; part.Name = gname
			else
				local w = Instance.new("WeldConstraint"); w.Part0 = root; w.Part1 = part; w.Parent = part
			end
			part.Parent = folder
		end
		roots[gname] = root
	end
	-- joints: Motor6D from parent group root to this group root at the pivot
	for gname, g in pairs(spec.groups) do
		local parentPart = if g.parent then roots[g.parent] else hrp
		local child = roots[gname]
		if parentPart and child then
			local m = Instance.new("Motor6D"); m.Name = gname
			local pivot = CFrame.new(origin + (g.pivot or (child.Position - origin)))
			m.Part0 = parentPart; m.Part1 = child
			m.C0 = parentPart.CFrame:Inverse() * pivot; m.C1 = child.CFrame:Inverse() * pivot
			m.Parent = parentPart
		end
	end
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") and d ~= hrp then d.Anchored = true end   -- display mode; unanchor for animation
	end
	return model
end
return build
