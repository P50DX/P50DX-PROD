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

type Def = { dark: Color3, light: Color3, reflect: number, fx: { Color3 }, texture: string, glow: number }

-- Each variant maps the part's brightness onto a dark -> light ramp, so the animal's markings survive.
local DEFS: { [string]: Def } = {
	Golden = { dark = Color3.fromRGB(150, 86, 0), light = Color3.fromRGB(250, 186, 24), reflect = 0.04, fx = { Color3.fromRGB(255, 230, 120) }, texture = SPARKLE, glow = 1 },
	Diamond = { dark = Color3.fromRGB(90, 170, 230), light = Color3.fromRGB(210, 244, 255), reflect = 0.12, fx = { Color3.fromRGB(200, 245, 255) }, texture = SPARKLE, glow = 1 },
	Shadow = { dark = Color3.fromRGB(16, 12, 26), light = Color3.fromRGB(86, 62, 120), reflect = 0, fx = { Color3.fromRGB(40, 20, 60) }, texture = SMOKE, glow = 0 },
	Celestial = { dark = Color3.fromRGB(200, 196, 255), light = Color3.fromRGB(255, 250, 232), reflect = 0.05, fx = { Color3.fromRGB(255, 240, 180), Color3.fromRGB(200, 220, 255) }, texture = SPARKLE, glow = 1 },
	Cosmic = { dark = Color3.fromRGB(34, 18, 86), light = Color3.fromRGB(150, 96, 236), reflect = 0.1, fx = { Color3.fromRGB(255, 140, 240), Color3.fromRGB(120, 220, 255) }, texture = SPARKLE, glow = 1 },
	Rainbow = { dark = Color3.new(), light = Color3.new(), reflect = 0.05, fx = { Color3.fromRGB(255, 120, 120), Color3.fromRGB(120, 255, 160), Color3.fromRGB(140, 160, 255) }, texture = SPARKLE, glow = 1 },
}

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
		end
		if not keepsColour(p, base :: Color3) then
			local l = 0.15 + 0.7 * math.clamp((brightness(base :: Color3) - 0.15) / 0.75, 0, 1)   -- keep both ends of the ramp
			p.Reflectance = def.reflect
			if variant == "Rainbow" then
				p:SetAttribute("RainbowL", l)
				p.Color = rainbowColour(p, 0)
				CollectionService:AddTag(p, RAINBOW_TAG)
			else
				p.Color = def.dark:Lerp(def.light, l)
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
