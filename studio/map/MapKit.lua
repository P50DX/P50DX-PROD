-- MapKit: building blocks for the Zoo Escape worlds. Everything is plain Roblox Parts (studded Plastic for the
-- Lego look, SmoothPlastic/Neon/Glass for trims), so it stays in Studio and stays cheap.
-- Coordinates: +Y up. K.parent is where new parts go (set it per section so the Explorer stays tidy).
local CollectionService = game:GetService("CollectionService")

local K = {}
K.parent = workspace
local rng = Random.new(1)

function K.seed(n) rng = Random.new(n) end
function K.rand(a, b) return a + (b - a) * rng:NextNumber() end
function K.chance(p) return rng:NextNumber() < p end
function K.pick(t) return t[rng:NextInteger(1, #t)] end
function K.rgb(r, g, b) return Color3.fromRGB(r, g, b) end
function K.shade(c, f) -- f < 1 darker, f > 1 lighter
	if f < 1 then return c:Lerp(Color3.new(0, 0, 0), 1 - f) end
	return c:Lerp(Color3.new(1, 1, 1), f - 1)
end
function K.jitter(c, a) -- small random tint so repeated props do not look copy-pasted
	local h, s, v = c:ToHSV()
	return Color3.fromHSV(h, math.clamp(s + K.rand(-a, a) * 0.5, 0, 1), math.clamp(v + K.rand(-a, a), 0, 1))
end

function K.folder(name, parent)
	local f = (parent or K.parent):FindFirstChild(name)
	if not f then f = Instance.new("Folder"); f.Name = name; f.Parent = parent or K.parent end
	return f
end
function K.model(name, parent)
	local m = Instance.new("Model"); m.Name = name; m.Parent = parent or K.parent
	return m
end

-- o: shape ("ball"|"cyl"|"wedge"|"corner"), studs, mat, neon, glass, transp, collide (default true), touch,
--    shadow, name, parent, refl, tag
function K.part(size, cf, color, o)
	o = o or {}
	local p
	if o.shape == "wedge" then p = Instance.new("WedgePart")
	elseif o.shape == "corner" then p = Instance.new("CornerWedgePart")
	else
		p = Instance.new("Part")
		if o.shape == "ball" then p.Shape = Enum.PartType.Ball
		elseif o.shape == "cyl" then p.Shape = Enum.PartType.Cylinder end
	end
	p.Anchored = true
	p.Size = size
	p.CFrame = typeof(cf) == "Vector3" and CFrame.new(cf) or cf
	p.Color = color
	p.Material = o.mat or (o.studs and Enum.Material.Plastic or Enum.Material.SmoothPlastic)
	if o.neon then p.Material = Enum.Material.Neon end
	if o.glass then p.Material = Enum.Material.Glass end
	p.TopSurface = o.studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
	if o.lego then -- studs on every face (chunky toy-brick look)
		p.Material = Enum.Material.Plastic
		for _, f in ipairs({ "TopSurface", "FrontSurface", "BackSurface", "LeftSurface", "RightSurface" }) do p[f] = Enum.SurfaceType.Studs end
	end
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Transparency = o.transp or 0
	p.Reflectance = o.refl or 0
	local collide = o.collide ~= false
	p.CanCollide = collide
	p.CanQuery = collide or o.query == true or o.tag == "HazardKill"
	p.CanTouch = o.touch == true
	p.CastShadow = o.shadow ~= false and (o.transp or 0) < 0.5
	p.Name = o.name or "Part"
	if o.tag then CollectionService:AddTag(p, o.tag) end
	p.Parent = o.parent or K.parent
	return p
end

-- axis-aligned block from a centre position; rotY in degrees
function K.block(size, pos, color, o)
	o = o or {}
	local cf = CFrame.new(pos)
	if o.ry or o.rx or o.rz then
		cf = cf * CFrame.Angles(math.rad(o.rx or 0), math.rad(o.ry or 0), math.rad(o.rz or 0))
	end
	return K.part(size, cf, color, o)
end

-- block whose bottom sits at pos.Y (handy for anything standing on the ground)
function K.stand(size, pos, color, o)
	return K.block(size, pos + Vector3.new(0, size.Y / 2, 0), color, o)
end

-- vertical cylinder (Roblox cylinders run along X, so rotate them upright)
function K.cyl(diam, height, pos, color, o)
	o = o or {}; o.shape = "cyl"
	return K.part(Vector3.new(height, diam, diam), CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)), color, o)
end

-- polished "tile" block: studded slab with a darker skirt and a thin lighter rim, reads as bevelled from a distance
function K.slab(size, cf, color, o)
	o = o or {}
	local m = o.parent or K.parent
	local top = K.part(Vector3.new(size.X, size.Y, size.Z), cf, color, { studs = o.studs ~= false, parent = m, name = o.name or "Slab", touch = o.touch, tag = o.tag, mat = o.mat })
	if size.Y >= 1.5 and o.rim ~= false then
		local rimc = o.rim or K.shade(color, 0.72)
		local h = math.min(1.2, size.Y * 0.35)
		K.part(Vector3.new(size.X + 0.4, h, size.Z + 0.4), cf * CFrame.new(0, -size.Y / 2 + h / 2, 0), rimc, { parent = m, name = "Rim", collide = false })
	end
	return top
end

-- wedge ramp from point a (low) up to point b (high), width w
function K.ramp(a, b, w, color, o)
	local flat = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
	local h = b.Y - a.Y
	local len = flat.Magnitude
	local cf = CFrame.lookAt(Vector3.new((a.X + b.X) / 2, a.Y + h / 2, (a.Z + b.Z) / 2), Vector3.new(a.X, a.Y + h / 2, a.Z))
	-- a WedgePart is low at its -Z end, so point -Z at the low end
	return K.part(Vector3.new(w, h, len), cf, color, o)
end

----------------------------------------------------------------------------------------------------------------
-- Text
----------------------------------------------------------------------------------------------------------------
K.FONT = Enum.Font.FredokaOne
K.FONT_BOLD = Enum.Font.LuckiestGuy

local function stroke(obj, th, col)
	local s = Instance.new("UIStroke"); s.Thickness = th; s.Color = col or Color3.fromRGB(25, 20, 40)
	s.LineJoinMode = Enum.LineJoinMode.Round; s.Parent = obj
	return s
end
K.stroke = stroke

-- lines = { {text=, h=0..1 (share of height), color=, grad={c1,c2}, font=}, ... }
-- returns the SurfaceGui; pps = pixels per stud
function K.textPanel(part, face, lines, o)
	o = o or {}
	local g = Instance.new("SurfaceGui")
	g.Name = o.name or "Text"
	g.Face = face
	g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.PixelsPerStud = o.pps or 12
	g.LightInfluence = o.light or 0
	g.Brightness = o.brightness or 1.5
	g.MaxDistance = o.dist or 1200
	g.ClipsDescendants = false
	g.Parent = part
	local list = Instance.new("Frame"); list.BackgroundTransparency = 1; list.Size = UDim2.fromScale(1, 1); list.Parent = g
	local lay = Instance.new("UIListLayout"); lay.FillDirection = Enum.FillDirection.Vertical
	lay.HorizontalAlignment = Enum.HorizontalAlignment.Center; lay.VerticalAlignment = o.valign or Enum.VerticalAlignment.Center
	lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Parent = list
	for i, l in ipairs(lines) do
		local t = Instance.new("TextLabel")
		t.Name = l.name or ("Line" .. i)
		t.LayoutOrder = i
		t.BackgroundTransparency = 1
		t.Size = UDim2.fromScale(l.w or 1, l.h or (1 / #lines))
		t.Font = l.font or K.FONT
		t.Text = l.text
		t.RichText = true
		t.TextScaled = true
		t.TextColor3 = l.grad and Color3.new(1, 1, 1) or (l.color or Color3.new(1, 1, 1))
		t.Parent = list
		stroke(t, l.stroke or o.stroke or 6, l.strokeColor)
		if l.grad then
			local gr = Instance.new("UIGradient"); gr.Rotation = 90
			gr.Color = ColorSequence.new(l.grad[1], l.grad[2]); gr.Parent = t
		end
	end
	return g
end

-- an invisible board that only carries text (both faces so it reads from either side when o.both)
function K.textBoard(size, cf, lines, o)
	o = o or {}
	local p = K.part(size, cf, Color3.new(1, 1, 1), { transp = 1, collide = false, name = o.name or "TextBoard", parent = o.parent })
	K.textPanel(p, o.face or Enum.NormalId.Back, lines, o)
	if o.both then K.textPanel(p, o.face == Enum.NormalId.Front and Enum.NormalId.Back or Enum.NormalId.Front, lines, o) end
	return p
end

-- floating billboard (always faces the camera)
function K.billboard(adornee, lines, o)
	o = o or {}
	local b = Instance.new("BillboardGui")
	b.Name = o.name or "Billboard"
	b.Size = o.size or UDim2.fromScale(12, 4)
	b.StudsOffset = o.offset or Vector3.new(0, 6, 0)
	b.LightInfluence = 0
	b.MaxDistance = o.dist or 250
	b.AlwaysOnTop = o.top or false
	b.Adornee = adornee
	b.Parent = adornee
	local lay = Instance.new("UIListLayout"); lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
	lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Parent = b
	for i, l in ipairs(lines) do
		local t = Instance.new("TextLabel"); t.Name = l.name or ("Line" .. i); t.LayoutOrder = i
		t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, l.h or (1 / #lines))
		t.Font = l.font or K.FONT; t.Text = l.text; t.RichText = true; t.TextScaled = true
		t.TextColor3 = l.color or Color3.new(1, 1, 1); t.Parent = b
		stroke(t, l.stroke or 3, l.strokeColor)
		if l.grad then
			t.TextColor3 = Color3.new(1, 1, 1)
			local gr = Instance.new("UIGradient"); gr.Rotation = 90; gr.Color = ColorSequence.new(l.grad[1], l.grad[2]); gr.Parent = t
		end
	end
	return b
end

----------------------------------------------------------------------------------------------------------------
-- Effects
----------------------------------------------------------------------------------------------------------------
function K.light(part, color, range, bright, kind)
	local l = Instance.new(kind or "PointLight"); l.Color = color; l.Range = range or 16; l.Brightness = bright or 1.5
	l.Shadows = false; l.Parent = part
	return l
end

function K.sparkle(part, color, o)
	o = o or {}
	local e = Instance.new("ParticleEmitter")
	e.Name = o.name or "Sparkle"
	e.Texture = o.texture or "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(color, o.color2 or color)
	e.LightEmission = o.emission or 0.8
	e.Size = o.sizeSeq or NumberSequence.new({ NumberSequenceKeypoint.new(0, o.size or 1), NumberSequenceKeypoint.new(1, 0) })
	e.Transparency = o.transpSeq or NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	e.Lifetime = o.life or NumberRange.new(1, 2)
	e.Rate = o.rate or 6
	e.Speed = o.speed or NumberRange.new(1, 3)
	e.SpreadAngle = o.spread or Vector2.new(180, 180)
	e.Acceleration = o.accel or Vector3.zero
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-60, 60)
	e.LockedToPart = o.locked or false
	if o.shape then e.Shape = o.shape; e.ShapeStyle = o.shapeStyle or Enum.ParticleEmitterShapeStyle.Volume end
	if o.emitDir then e.EmissionDirection = o.emitDir end
	e.Parent = part
	return e
end

function K.tag(inst, tag, attrs)
	CollectionService:AddTag(inst, tag)
	-- animated / gameplay models must stream in as a whole (StreamingEnabled), never half-built
	if inst:IsA("Model") then inst.ModelStreamingMode = Enum.ModelStreamingMode.Atomic end
	if attrs then for k, v in pairs(attrs) do inst:SetAttribute(k, v) end end
	return inst
end

-- clone a ZooModels model as a decorative statue / display (anchored, no collisions on details)
function K.display(category, name, cf, scale, o)
	o = o or {}
	local ss = game:GetService("ServerStorage"):FindFirstChild("ZooModels")
	local src = ss and ss:FindFirstChild(category) and ss[category]:FindFirstChild(name)
	if o.variant and ss and ss:FindFirstChild("Variants") then
		local v = ss.Variants:FindFirstChild(name)
		src = (v and v:FindFirstChild(o.variant)) or src
	end
	if not src then warn("MapKit.display: missing " .. category .. "/" .. name) return nil end
	local m = src:Clone()
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false; d.CanTouch = false; d.CanQuery = false end
	end
	if scale and scale ~= 1 then m:ScaleTo(scale) end
	local _, size = m:GetBoundingBox()
	m:PivotTo(cf * CFrame.new(0, 0, 0))
	-- stand the model on cf's position
	local bb = m:GetBoundingBox()
	local low = bb.Position.Y - size.Y / 2
	m:PivotTo(m:GetPivot() + Vector3.new(0, cf.Position.Y - low, 0))
	if o.material then
		for _, d in m:GetDescendants() do
			if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
				d.Material = o.material; if o.color then d.Color = o.color end
				if o.refl then d.Reflectance = o.refl end
			end
		end
	end
	m.Name = o.name or (name .. "Display")
	m.Parent = o.parent or K.parent
	return m
end

return K
