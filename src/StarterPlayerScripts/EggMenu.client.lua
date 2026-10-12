-- EggMenu (LocalScript -> StarterPlayerScripts)
-- Opened by the egg station prompt. Shows the egg's 5 pets (3D previews, rarity) and a Hatch button.
-- The pets are not displayed in the world any more - only here, when the player wants to look.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local cfg = require(ReplicatedStorage:WaitForChild("ZooMapConfig"))
local remotes = ReplicatedStorage:WaitForChild("ZooMapRemotes")
local Notify, Hatch = remotes:WaitForChild("Notify"), remotes:WaitForChild("HatchEgg")
local FONT, BOLD = Enum.Font.FredokaOne, Enum.Font.LuckiestGuy

local gui = Instance.new("ScreenGui"); gui.Name = "EggMenu"; gui.ResetOnSpawn = false; gui.Enabled = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = player:WaitForChild("PlayerGui")
local function corner(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 14); c.Parent = o end
local function stroke(o, t, c) local s = Instance.new("UIStroke"); s.Thickness = t or 3; s.Color = c or Color3.fromRGB(25, 20, 40); s.Parent = o; return s end

local win = Instance.new("Frame"); win.AnchorPoint = Vector2.new(0.5, 0.5); win.Position = UDim2.fromScale(0.5, 0.5)
win.Size = UDim2.fromScale(0.62, 0.6); win.BackgroundColor3 = Color3.fromRGB(34, 30, 60); win.Parent = gui
corner(win, 22); stroke(win, 4)
local lim = Instance.new("UISizeConstraint"); lim.MaxSize = Vector2.new(820, 480); lim.MinSize = Vector2.new(420, 300); lim.Parent = win
local grad = Instance.new("UIGradient"); grad.Rotation = 90; grad.Color = ColorSequence.new(Color3.fromRGB(70, 60, 120), Color3.fromRGB(30, 26, 52)); grad.Parent = win

local title = Instance.new("TextLabel"); title.BackgroundTransparency = 1; title.Position = UDim2.new(0, 20, 0, 10); title.Size = UDim2.new(1, -90, 0, 46)
title.Font = BOLD; title.TextScaled = true; title.TextXAlignment = Enum.TextXAlignment.Left; title.TextColor3 = Color3.fromRGB(255, 225, 120); title.Parent = win; stroke(title, 3)
local price = Instance.new("TextLabel"); price.BackgroundTransparency = 1; price.Position = UDim2.new(0, 22, 0, 56); price.Size = UDim2.new(0.6, 0, 0, 26)
price.Font = FONT; price.TextScaled = true; price.TextXAlignment = Enum.TextXAlignment.Left; price.TextColor3 = Color3.new(1, 1, 1); price.Parent = win; stroke(price, 2)
local close = Instance.new("TextButton"); close.AnchorPoint = Vector2.new(1, 0); close.Position = UDim2.new(1, -12, 0, 12); close.Size = UDim2.fromOffset(46, 46)
close.BackgroundColor3 = Color3.fromRGB(255, 80, 80); close.Text = "X"; close.Font = BOLD; close.TextScaled = true; close.TextColor3 = Color3.new(1, 1, 1); close.Parent = win
corner(close, 12); stroke(close, 3)

local row = Instance.new("Frame"); row.BackgroundTransparency = 1; row.Position = UDim2.new(0, 16, 0, 92); row.Size = UDim2.new(1, -32, 1, -180); row.Parent = win
local lay = Instance.new("UIGridLayout"); lay.CellSize = UDim2.new(0.19, 0, 1, 0); lay.CellPadding = UDim2.new(0.0125, 0, 0, 0)
lay.HorizontalAlignment = Enum.HorizontalAlignment.Center; lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Parent = row

local hatch = Instance.new("TextButton"); hatch.AnchorPoint = Vector2.new(0.5, 1); hatch.Position = UDim2.new(0.5, 0, 1, -16); hatch.Size = UDim2.new(0.36, 0, 0, 58)
hatch.BackgroundColor3 = Color3.fromRGB(90, 220, 100); hatch.Font = BOLD; hatch.TextScaled = true; hatch.TextColor3 = Color3.new(1, 1, 1); hatch.Text = "HATCH"; hatch.Parent = win
corner(hatch, 16); stroke(hatch, 3)
local hp = Instance.new("UIPadding"); hp.PaddingTop = UDim.new(0, 8); hp.PaddingBottom = UDim.new(0, 8); hp.Parent = hatch

local current
local function nice(n) return (n:gsub("(%l)(%u)", "%1 %2")) end
local function card(i, petName)
	local rarity = cfg.Rarity and cfg.Rarity[petName] or ""
	local rc = (cfg.RarityColor and cfg.RarityColor[rarity]) or Color3.fromRGB(200, 200, 200)
	local f = Instance.new("Frame"); f.LayoutOrder = i; f.BackgroundColor3 = Color3.fromRGB(50, 46, 84); f.Parent = row
	corner(f, 16); stroke(f, 3, rc)
	local g = Instance.new("UIGradient"); g.Rotation = 90; g.Color = ColorSequence.new(rc:Lerp(Color3.new(0, 0, 0), 0.45), Color3.fromRGB(40, 36, 70)); g.Parent = f
	local vp = Instance.new("ViewportFrame"); vp.BackgroundTransparency = 1; vp.Size = UDim2.new(1, 0, 0.72, 0); vp.Parent = f
	vp.LightDirection = Vector3.new(-1, -1, -1); vp.Ambient = Color3.fromRGB(170, 170, 180)
	local prev = ReplicatedStorage:FindFirstChild("AnimalPreviews")
	local src = prev and prev:FindFirstChild("Pets") and prev.Pets:FindFirstChild(petName)
	if src then
		local m = src:Clone(); m.Parent = vp
		local cf, size = m:GetBoundingBox()
		local cam = Instance.new("Camera"); cam.FieldOfView = 30; cam.Parent = vp; vp.CurrentCamera = cam
		local d = math.max(size.X, size.Y, size.Z) * 2.4
		cam.CFrame = CFrame.lookAt(cf.Position + Vector3.new(d * 0.55, d * 0.25, -d * 0.8), cf.Position)
		task.spawn(function() -- slow turntable
			local a = 0
			while vp.Parent and gui.Enabled do
				a += 0.02
				cam.CFrame = CFrame.lookAt(cf.Position + Vector3.new(math.sin(a) * d, d * 0.25, -math.cos(a) * d), cf.Position)
				task.wait()
			end
		end)
	end
	local n = Instance.new("TextLabel"); n.BackgroundTransparency = 1; n.Position = UDim2.fromScale(0, 0.72); n.Size = UDim2.fromScale(1, 0.15)
	n.Font = FONT; n.TextScaled = true; n.TextColor3 = Color3.new(1, 1, 1); n.Text = nice(petName); n.Parent = f; stroke(n, 2)
	local r = Instance.new("TextLabel"); r.BackgroundTransparency = 1; r.Position = UDim2.fromScale(0, 0.86); r.Size = UDim2.fromScale(1, 0.12)
	r.Font = BOLD; r.TextScaled = true; r.TextColor3 = rc; r.Text = rarity; r.Parent = f; stroke(r, 2)
end

local function open(worldId, eggName)
	local w = cfg.Worlds[worldId]
	local egg = w and w.egg
	if not egg then return end
	current = { w = worldId, egg = eggName }
	for _, c in row:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
	title.Text = "🥚 " .. (egg.display or eggName)
	price.Text = egg.price and ("Price: " .. tostring(egg.price)) or ""
	gui.Enabled = true
	for i, p in ipairs(egg.pets) do card(i, p) end
	win.Size = UDim2.fromScale(0.5, 0.48)
	TweenService:Create(win, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Size = UDim2.fromScale(0.62, 0.6) }):Play()
end
local function shut() gui.Enabled = false; current = nil end
close.Activated:Connect(shut)
hatch.Activated:Connect(function()
	if current then
		Hatch:FireServer(current.w, current.egg, 1)
		TweenService:Create(hatch, TweenInfo.new(0.08), { Size = UDim2.new(0.33, 0, 0, 52) }):Play()
		task.delay(0.1, function() TweenService:Create(hatch, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Size = UDim2.new(0.36, 0, 0, 58) }):Play() end)
	end
end)
Notify.OnClientEvent:Connect(function(kind, a, b)
	if kind == "OpenEgg" then open(a, b)
	elseif kind == "Hatched" then
		title.Text = "🎉 You hatched: " .. nice(a)
	end
end)
-- walking away closes it
task.spawn(function()
	while true do
		task.wait(0.5)
		if gui.Enabled and current then
			local c = player.Character
			local r = c and c:FindFirstChild("HumanoidRootPart")
			local near = false
			for _, pp in game:GetService("CollectionService"):GetTagged("EggStation") do
				if pp.Parent and r and (pp.Parent.Position - r.Position).Magnitude < 40 then near = true end
			end
			if not near then shut() end
		end
	end
end)
