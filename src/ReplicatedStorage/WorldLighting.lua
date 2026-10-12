-- WorldLighting (ModuleScript -> ReplicatedStorage): lighting + atmosphere + ambient particles per world.
-- Colourful but not washed out; each world gets its own mood. apply(worldId, tweenTime?)
-- Tuned by eye from aerial + ground screenshots (Atmosphere Color/Decay interact with the sun angle).
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local c = Color3.fromRGB
local M = {}
M.PRESETS = {
	[1] = { -- Zoo: bright blue / green
		lighting = { Brightness = 2.3, ExposureCompensation = -0.28, ClockTime = 14.3, Ambient = c(90, 92, 108), OutdoorAmbient = c(135, 140, 158) },
		atmosphere = { Density = 0.3, Offset = 0.12, Color = c(196, 222, 255), Decay = c(110, 150, 200), Glare = 0.15, Haze = 1.1 },
		cc = { Saturation = 0.2, Contrast = 0.14, TintColor = c(255, 251, 242) },
		particles = { color = c(150, 220, 110), rate = 3, accel = Vector3.new(1, -0.6, 0.5) },
	},
	[2] = { -- Desert: warm dusty orange
		lighting = { Brightness = 2.6, ExposureCompensation = -0.3, ClockTime = 15.6, Ambient = c(110, 90, 70), OutdoorAmbient = c(170, 140, 110) },
		atmosphere = { Density = 0.32, Offset = 0.1, Color = c(255, 214, 160), Decay = c(255, 200, 150), Glare = 0.4, Haze = 1.8 },
		cc = { Saturation = 0.15, Contrast = 0.12, TintColor = c(255, 240, 222) },
		particles = { color = c(240, 200, 140), rate = 8, accel = Vector3.new(6, 0, 1), smoke = true },
	},
	[3] = { -- Snow: cold blue / white
		lighting = { Brightness = 2.1, ExposureCompensation = -0.4, ClockTime = 13, Ambient = c(100, 110, 130), OutdoorAmbient = c(160, 175, 200) },
		atmosphere = { Density = 0.35, Offset = 0.15, Color = c(220, 235, 255), Decay = c(150, 180, 220), Glare = 0.1, Haze = 1.5 },
		cc = { Saturation = 0.05, Contrast = 0.12, TintColor = c(240, 248, 255) },
		particles = { color = c(255, 255, 255), rate = 25, accel = Vector3.new(1, -4, 0.5) },
	},
	[4] = { -- Forest: green / blue natural haze
		lighting = { Brightness = 2, ExposureCompensation = -0.2, ClockTime = 16.2, Ambient = c(80, 100, 80), OutdoorAmbient = c(120, 150, 120) },
		atmosphere = { Density = 0.32, Offset = 0.1, Color = c(196, 230, 206), Decay = c(100, 150, 120), Glare = 0.2, Haze = 1.2 },
		cc = { Saturation = 0.2, Contrast = 0.12, TintColor = c(245, 255, 240) },
		particles = { color = c(255, 240, 140), rate = 6, accel = Vector3.new(0.5, 0.3, 0.5), glow = true },
	},
	[5] = { -- Volcano: dark smoky red / orange
		lighting = { Brightness = 2, ExposureCompensation = 0, ClockTime = 17.3, Ambient = c(120, 70, 56), OutdoorAmbient = c(170, 110, 90) },
		atmosphere = { Density = 0.42, Offset = 0.08, Color = c(210, 120, 90), Decay = c(90, 130, 170), Glare = 0.6, Haze = 2 },
		cc = { Saturation = 0.25, Contrast = 0.18, TintColor = c(255, 228, 212) },
		particles = { color = c(255, 130, 40), rate = 14, accel = Vector3.new(0.5, 3, 0.5), glow = true },
	},
	[6] = { -- Space: purple / navy / cosmic
		lighting = { Brightness = 2, ExposureCompensation = 0.35, ClockTime = 0.2, Ambient = c(130, 120, 170), OutdoorAmbient = c(150, 140, 200) },
		atmosphere = { Density = 0.2, Offset = 0, Color = c(70, 50, 120), Decay = c(120, 80, 220), Glare = 0.3, Haze = 0.8 },
		cc = { Saturation = 0.08, Contrast = 0.12, TintColor = c(246, 242, 255) },
		particles = { color = c(200, 180, 255), rate = 10, accel = Vector3.new(0, 0.3, 0), glow = true },
	},
}
function M.apply(world, t)
	local p = M.PRESETS[world]; if not p then return end
	local atm = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)
	if t and t > 0 then
		local ti = TweenInfo.new(t)
		TweenService:Create(Lighting, ti, p.lighting):Play()
		TweenService:Create(atm, ti, p.atmosphere):Play()
		TweenService:Create(cc, ti, p.cc):Play()
	else
		for k, v in pairs(p.lighting) do Lighting[k] = v end
		for k, v in pairs(p.atmosphere) do atm[k] = v end
		for k, v in pairs(p.cc) do cc[k] = v end
	end
end
return M
