local L = game.Lighting
pcall(function() L.Technology = Enum.Technology.Future end)
L.ClockTime = 14.3; L.GeographicLatitude = 35
L.Brightness = 2.3; L.ExposureCompensation = -0.28
L.Ambient = Color3.fromRGB(95, 95, 110); L.OutdoorAmbient = Color3.fromRGB(135, 140, 158)
L.EnvironmentDiffuseScale = 0.6; L.EnvironmentSpecularScale = 0.4; L.GlobalShadows = true
L.ShadowSoftness = 0.25
for _, c in L:GetChildren() do if c:IsA("PostEffect") or c:IsA("Atmosphere") or c:IsA("Sky") or c:IsA("Clouds") then c:Destroy() end end
local a = Instance.new("Atmosphere"); a.Density = 0.3; a.Offset = 0.12; a.Color = Color3.fromRGB(196, 222, 255); a.Decay = Color3.fromRGB(110, 150, 200); a.Glare = 0.15; a.Haze = 1.1; a.Parent = L
local sky = Instance.new("Sky"); sky.SunAngularSize = 14; sky.Parent = L
local b = Instance.new("BloomEffect"); b.Intensity = 0.55; b.Size = 28; b.Threshold = 1.4; b.Parent = L
local cc = Instance.new("ColorCorrectionEffect"); cc.Saturation = 0.2; cc.Contrast = 0.14; cc.Brightness = 0.0; cc.TintColor = Color3.fromRGB(255, 252, 245); cc.Parent = L
local sr = Instance.new("SunRaysEffect"); sr.Intensity = 0.04; sr.Spread = 0.6; sr.Parent = L
local cl = Instance.new("Clouds"); cl.Cover = 0.55; cl.Density = 0.6; cl.Color = Color3.new(1,1,1); cl.Parent = workspace.Terrain
return "ok"
