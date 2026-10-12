--!strict
-- AnimalVariants (ModuleScript -> ReplicatedStorage)
-- Turns any block animal into one of the 6 variants: Golden, Rainbow, Diamond, Shadow, Celestial, Cosmic.
--   AnimalVariants.apply(model, "Golden")   -- recolour + sparkle VFX (call on the server or client)
--   AnimalVariants.apply(model, nil)        -- back to the normal colours
--   AnimalVariants.startRainbow()           -- ONE shared loop animates every Rainbow animal (call once, on the client)
-- Eyes (parts named "Eye"), Neon glows, black and white details keep their colours so faces stay readable.
-- The original colour of each part is kept in its "BaseColor" attribute, so variants can be swapped freely.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local AnimalVariants = {}

AnimalVariants.List = { "Golden", "Rainbow", "Diamond", "Shadow", "Celestial", "Cosmic" }

local RAINBOW_TAG = "VariantRainbow"
local FX_NAME = "VariantFX"
local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"

type Def = {
	ramp: { Color3 }, reflect: number, fx: { Color3 }, texture: string, glow: number,
	accent: Color3?, accentNeon: boolean?, eyeGlow: Color3?, glass: boolean?,
}

-- Each variant maps the part's brightness onto a dark -> mid -> light ramp, so shading survives. Thin flat parts
-- (spots, stripes, inner ears, blush, trims) become the variant's accent colour so the markings still read.
local DEFS: { [string]: Def } = {
	Golden = { ramp = { Color3.fromRGB(140, 76, 0), Color3.fromRGB(228, 160, 20), Color3.fromRGB(255, 226, 110) }, reflect = 0.04,
		accent = Color3.fromRGB(255, 250, 210), fx = { Color3.fromRGB(255, 230, 120) }, texture = SPARKLE, glow = 1 },
	Diamond = { ramp = { Color3.fromRGB(40, 120, 200), Color3.fromRGB(110, 200, 245), Color3.fromRGB(220, 248, 255) }, reflect = 0.15,
		accent = Color3.fromRGB(170, 250, 255), accentNeon = true, glass = true, fx = { Color3.fromRGB(200, 245, 255) }, texture = SPARKLE, glow = 1 },
	Shadow = { ramp = { Color3.fromRGB(10, 8, 18), Color3.fromRGB(40, 28, 64), Color3.fromRGB(96, 70, 136) }, reflect = 0,
		accent = Color3.fromRGB(170, 70, 255), accentNeon = true, eyeGlow = Color3.fromRGB(190, 90, 255), fx = { Color3.fromRGB(40, 20, 60) }, texture = SMOKE, glow = 0 },
	Celestial = { ramp = { Color3.fromRGB(150, 160, 230), Color3.fromRGB(220, 222, 255), Color3.fromRGB(255, 252, 240) }, reflect = 0.05,
		accent = Color3.fromRGB(255, 205, 70), accentNeon = true, fx = { Color3.fromRGB(255, 240, 180), Color3.fromRGB(200, 220, 255) }, texture = SPARKLE, glow = 1 },
	Cosmic = { ramp = { Color3.fromRGB(20, 10, 60), Color3.fromRGB(70, 36, 160), Color3.fromRGB(160, 110, 245) }, reflect = 0.1,
		accent = Color3.fromRGB(255, 110, 230), accentNeon = true, eyeGlow = Color3.fromRGB(120, 230, 255), fx = { Color3.fromRGB(255, 140, 240), Color3.fromRGB(120, 220, 255) }, texture = SPARKLE, glow = 1 },
	Rainbow = { ramp = { Color3.new(), Color3.new(), Color3.new() }, reflect = 0.05, fx = { Color3.fromRGB(255, 120, 120), Color3.fromRGB(120, 255, 160), Color3.fromRGB(140, 160, 255) }, texture = SPARKLE, glow = 1 },
}

local function rampColour(r: { Color3 }, l: number): Color3
	if l < 0.5 then return r[1]:Lerp(r[2], l * 2) end
	return r[2]:Lerp(r[3], (l - 0.5) * 2)
end

local function isMarking(p: BasePart): boolean
	local s = p.Size
	return math.min(s.X, s.Y, s.Z) <= 0.13 and p.Name ~= "Eye"
end

local function brightness(c: Color3): number
	return 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
end

local function keepsColour(part: BasePart, base: Color3): boolean
	if part.Name == "HumanoidRootPart" or part.Name == "Eye" or part.Material == Enum.Material.Neon then
		return true
	end
	if part.Transparency >= 0.95 then return true end
	local b = brightness(base)
	return b < 0.13 or (base.R > 0.96 and base.G > 0.96 and base.B > 0.96)
end

-- Rainbow hue drifts over time and shifts with height, so the colours flow up the body.
local function rainbowColour(part: BasePart, t: number): Color3
	local hue = (t * 0.25 + part.Position.Y * 0.07 + part.Position.Z * 0.03) % 1
	local l = part:GetAttribute("RainbowL")
	return Color3.fromHSV(hue, 0.72, 0.6 + 0.4 * (if typeof(l) == "number" then l else 0.7))
end

local function parts(model: Model): { BasePart }
	local list = {}
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then table.insert(list, d) end
	end
	return list
end

function AnimalVariants.reset(model: Model)
	for _, p in parts(model) do
		local base = p:GetAttribute("BaseColor")
		if typeof(base) == "Color3" then p.Color = base end
		local refl = p:GetAttribute("BaseReflectance")
		if typeof(refl) == "number" then p.Reflectance = refl end
		local mat = p:GetAttribute("BaseMaterial")
		if typeof(mat) == "string" then p.Material = (Enum.Material :: any)[mat] end
		local tr = p:GetAttribute("BaseTransparency")
		if typeof(tr) == "number" then p.Transparency = tr end
		CollectionService:RemoveTag(p, RAINBOW_TAG)
	end
	for _, d in model:GetDescendants() do
		if d.Name == FX_NAME then d:Destroy() end
	end
	model:SetAttribute("Variant", nil)
end

function AnimalVariants.apply(model: Model, variant: string?)
	AnimalVariants.reset(model)
	local def = variant and DEFS[variant]
	if not def then return end
	for _, p in parts(model) do
		local base = p:GetAttribute("BaseColor")
		if typeof(base) ~= "Color3" then
			base = p.Color
			p:SetAttribute("BaseColor", base)
			p:SetAttribute("BaseReflectance", p.Reflectance)
			p:SetAttribute("BaseMaterial", p.Material.Name)
			p:SetAttribute("BaseTransparency", p.Transparency)
		end
		local c = base :: Color3
		if p.Name == "Eye" then
			-- glowing eyes: the white shine and any coloured iris take the glow colour, the black stays
			if def.eyeGlow and brightness(c) > 0.13 then p.Color = def.eyeGlow; p.Material = Enum.Material.Neon end
		elseif not keepsColour(p, c) then
			local l = 0.08 + 0.84 * math.clamp((brightness(c) - 0.12) / 0.8, 0, 1)
			p.Reflectance = def.reflect
			if variant == "Rainbow" then
				p:SetAttribute("RainbowL", l)
				p.Color = rainbowColour(p, 0)
				CollectionService:AddTag(p, RAINBOW_TAG)
			elseif def.accent and isMarking(p) then
				p.Color = def.accent
				if def.accentNeon then p.Material = Enum.Material.Neon end
			else
				p.Color = rampColour(def.ramp, l)
				if def.glass and p.Material == Enum.Material.SmoothPlastic and p.Transparency < 0.5 then
					p.Material = Enum.Material.Glass; p.Transparency = 0.15
				end
			end
		end
	end
	-- One emitter per animal, on its root, sized to the model.
	local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if root then
		local size = model:GetExtentsSize()
		local fx = Instance.new("ParticleEmitter")
		fx.Name = FX_NAME
		fx.Texture = def.texture
		fx.LightEmission = def.glow
		fx.Rate = if def.texture == SMOKE then 8 else 5
		fx.Lifetime = NumberRange.new(0.8, 1.6)
		fx.Speed = NumberRange.new(0.5, 1.5)
		fx.SpreadAngle = Vector2.new(180, 180)
		fx.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, math.max(size.Y * 0.08, 0.3)), NumberSequenceKeypoint.new(1, 0) })
		fx.Transparency = NumberSequence.new(if def.texture == SMOKE then 0.4 else 0.1)
		local keys = {}
		for i, c in def.fx do
			table.insert(keys, ColorSequenceKeypoint.new(if #def.fx == 1 then (i - 1) else (i - 1) / (#def.fx - 1), c))
		end
		if #keys == 1 then table.insert(keys, ColorSequenceKeypoint.new(1, def.fx[1])) end
		fx.Color = ColorSequence.new(keys)
		fx.Shape = Enum.ParticleEmitterShape.Box
		fx.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
		fx.Parent = root
	end
	model:SetAttribute("Variant", variant)
end

-- One Heartbeat loop for every Rainbow animal in the game, throttled to 20 updates a second.
local rainbowRunning = false
function AnimalVariants.startRainbow()
	if rainbowRunning then return end
	rainbowRunning = true
	local acc = 0
	RunService.Heartbeat:Connect(function(dt)
		acc += dt
		if acc < 0.05 then return end
		acc = 0
		local t = os.clock()
		for _, p in CollectionService:GetTagged(RAINBOW_TAG) do
			if p:IsA("BasePart") then p.Color = rainbowColour(p, t) end
		end
	end)
end

return AnimalVariants
