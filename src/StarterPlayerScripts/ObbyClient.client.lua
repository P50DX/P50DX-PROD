-- ObbyClient (LocalScript -> StarterPlayerScripts)
-- Client side of the worlds:
--   * animates every obby hazard from the server clock (so all players see the same timing, and it is smooth)
--   * stage-gate crossing, hazard hits, falls -> straight back to your checkpoint (never back to Stage 1)
--   * HUD: stage progress bar, big STAGE banner, chase warnings, SAFE!, rewards, toasts, screen flashes
--   * custom hold-to-interact prompts (progress ring, keyboard / gamepad / touch)
--   * per-world lighting and gentle ambience
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ZooMapRemotes")
local GateRemote, PadRemote, Notify, ResetRemote = remotes:WaitForChild("StageGate"), remotes:WaitForChild("RewardPad"), remotes:WaitForChild("Notify"), remotes:WaitForChild("Reset")

----------------------------------------------------------------------------------------------------------------
-- sounds (built-in Roblox sounds; swap the ids for your own SFX any time). Volumes are kept low on purpose.
----------------------------------------------------------------------------------------------------------------
local SFX = {
	Gate = { "rbxasset://sounds/electronicpingshort.wav", 0.35, 1.25 },
	Reward = { "rbxasset://sounds/victory.wav", 0.4, 1 },
	Press = { "rbxasset://sounds/button.wav", 0.4, 0.9 },
	Skip = { "rbxasset://sounds/Launching rocket.wav", 0.25, 1.2 },
	Alarm = { "rbxasset://sounds/electronicpingshort.wav", 0.4, 0.7 },
	Caught = { "rbxasset://sounds/hit.wav", 0.45, 0.8 },
	Safe = { "rbxasset://sounds/victory.wav", 0.35, 1.2 },
	Fall = { "rbxasset://sounds/impact_water.mp3", 0.25, 1 },
	Prompt = { "rbxasset://sounds/clickfast.wav", 0.3, 1.1 },
	Slam = { "rbxasset://sounds/collide.wav", 0.5, 0.55 },
	Whoosh = { "rbxasset://sounds/swordlunge.wav", 0.45, 0.55 },
	Rumble = { "rbxasset://sounds/Rocket whoosh 01.wav", 0.5, 0.35 },
	Impact = { "rbxasset://sounds/impact_explosion_03.mp3", 0.35, 0.8 },
}
local function play2D(name)
	local d = SFX[name]; if not d then return end
	local s = Instance.new("Sound"); s.SoundId = d[1]; s.Volume = d[2]; s.PlaybackSpeed = d[3]
	s.Parent = SoundService; s:Play()
	s.Ended:Once(function() s:Destroy() end)
	task.delay(8, function() if s.Parent then s:Destroy() end end)
end
local function play3D(name, part, maxDist)
	local d = SFX[name]; if not d or not part then return end
	local s = Instance.new("Sound"); s.SoundId = d[1]; s.Volume = d[2] * 1.6; s.PlaybackSpeed = d[3]
	s.RollOffMode = Enum.RollOffMode.InverseTapered; s.RollOffMinDistance = 20; s.RollOffMaxDistance = maxDist or 220
	s.Parent = part; s:Play()
	task.delay(7, function() s:Destroy() end)
	return s
end

----------------------------------------------------------------------------------------------------------------
-- HUD
----------------------------------------------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "ZooMapHUD"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
local FONT, FONT_BOLD = Enum.Font.FredokaOne, Enum.Font.LuckiestGuy
local function stroke(o, t) local s = Instance.new("UIStroke"); s.Thickness = t or 3; s.Color = Color3.fromRGB(25, 20, 40); s.Parent = o; return s end
local function corner(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = o; return c end

-- flash overlay
local flash = Instance.new("Frame"); flash.Size = UDim2.fromScale(1, 1); flash.BackgroundTransparency = 1; flash.BorderSizePixel = 0; flash.ZIndex = 1; flash.Parent = gui
local function screenFlash(color, alpha, t)
	flash.BackgroundColor3 = color; flash.BackgroundTransparency = 1 - (alpha or 0.35)
	TweenService:Create(flash, TweenInfo.new(t or 0.5), { BackgroundTransparency = 1 }):Play()
end

-- progress bar (top): 1..10
local bar = Instance.new("Frame"); bar.Name = "StageBar"; bar.AnchorPoint = Vector2.new(0.5, 0)
bar.Position = UDim2.new(0.5, 0, 0, 10); bar.Size = UDim2.new(0.62, 0, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(30, 34, 52)
bar.BackgroundTransparency = 0.15; bar.Visible = false; bar.Parent = gui
corner(bar, 15); stroke(bar, 3)
local fill = Instance.new("Frame"); fill.Size = UDim2.fromScale(0, 1); fill.BackgroundColor3 = Color3.fromRGB(70, 190, 255); fill.Parent = bar; corner(fill, 15)
local fg = Instance.new("UIGradient"); fg.Color = ColorSequence.new(Color3.fromRGB(120, 230, 255), Color3.fromRGB(40, 140, 255)); fg.Rotation = 90; fg.Parent = fill
local nodes = {}
for i = 1, 10 do
	local n = Instance.new("TextLabel"); n.AnchorPoint = Vector2.new(0.5, 0.5); n.Position = UDim2.fromScale((i - 0.5) / 10, 0.5)
	n.Size = UDim2.new(0, 34, 0, 34); n.BackgroundColor3 = Color3.fromRGB(60, 70, 100); n.Text = tostring(i); n.Font = FONT
	n.TextScaled = true; n.TextColor3 = Color3.new(1, 1, 1); n.ZIndex = 3; n.Parent = bar; corner(n, 8); stroke(n, 2)
	nodes[i] = n
end
local race = Instance.new("TextLabel"); race.AnchorPoint = Vector2.new(0.5, 0); race.Position = UDim2.new(0.5, 0, 0, 46)
race.Size = UDim2.new(0.5, 0, 0, 26); race.BackgroundTransparency = 1; race.Font = FONT; race.TextScaled = true; race.RichText = true
race.TextColor3 = Color3.new(1, 1, 1); race.Text = ""; race.Parent = gui; stroke(race, 2)

local function setProgress(stage)
	bar.Visible = stage > 0
	TweenService:Create(fill, TweenInfo.new(0.4), { Size = UDim2.fromScale(math.clamp(stage / 10, 0, 1), 1) }):Play()
	for i, n in ipairs(nodes) do
		local done = i <= stage
		n.BackgroundColor3 = (i == stage) and Color3.fromRGB(255, 200, 50) or (done and Color3.fromRGB(60, 160, 255) or Color3.fromRGB(60, 70, 100))
		n.Size = (i == stage) and UDim2.new(0, 42, 0, 42) or UDim2.new(0, 34, 0, 34)
	end
end

-- big centre banner
local banner = Instance.new("TextLabel"); banner.AnchorPoint = Vector2.new(0.5, 0.5); banner.Position = UDim2.fromScale(0.5, 0.3)
banner.Size = UDim2.fromScale(0.7, 0.13); banner.BackgroundTransparency = 1; banner.Font = FONT_BOLD; banner.TextScaled = true
banner.TextColor3 = Color3.new(1, 1, 1); banner.TextTransparency = 1; banner.Parent = gui
local bannerStroke = stroke(banner, 5); bannerStroke.Transparency = 1
local bannerGrad = Instance.new("UIGradient"); bannerGrad.Rotation = 90; bannerGrad.Parent = banner
local sub = Instance.new("TextLabel"); sub.AnchorPoint = Vector2.new(0.5, 0.5); sub.Position = UDim2.fromScale(0.5, 0.39)
sub.Size = UDim2.fromScale(0.6, 0.05); sub.BackgroundTransparency = 1; sub.Font = FONT; sub.TextScaled = true
sub.TextColor3 = Color3.new(1, 1, 1); sub.TextTransparency = 1; sub.Parent = gui
local subStroke = stroke(sub, 3); subStroke.Transparency = 1
local bannerToken = 0
local function showBanner(text, c1, c2, subtitle, hold)
	bannerToken += 1
	local tok = bannerToken
	banner.Text = text; sub.Text = subtitle or ""
	bannerGrad.Color = ColorSequence.new(c1, c2 or c1)
	banner.Size = UDim2.fromScale(0.45, 0.08)
	for _, o in ipairs({ banner, sub }) do o.TextTransparency = 0 end
	bannerStroke.Transparency = 0; subStroke.Transparency = 0
	TweenService:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Size = UDim2.fromScale(0.7, 0.13) }):Play()
	task.delay(hold or 1.6, function()
		if tok ~= bannerToken then return end
		local ti = TweenInfo.new(0.4)
		TweenService:Create(banner, ti, { TextTransparency = 1 }):Play(); TweenService:Create(sub, ti, { TextTransparency = 1 }):Play()
		TweenService:Create(bannerStroke, ti, { Transparency = 1 }):Play(); TweenService:Create(subStroke, ti, { Transparency = 1 }):Play()
	end)
end

-- toast (bottom)
local toast = Instance.new("TextLabel"); toast.AnchorPoint = Vector2.new(0.5, 1); toast.Position = UDim2.new(0.5, 0, 1, -120)
toast.Size = UDim2.new(0.5, 0, 0, 34); toast.BackgroundColor3 = Color3.fromRGB(30, 34, 52); toast.BackgroundTransparency = 1
toast.Font = FONT; toast.TextScaled = true; toast.TextColor3 = Color3.new(1, 1, 1); toast.TextTransparency = 1; toast.Parent = gui
corner(toast, 12)
local toastToken = 0
local function showToast(text)
	toastToken += 1; local tok = toastToken
	toast.Text = "  " .. text .. "  "; toast.TextTransparency = 0; toast.BackgroundTransparency = 0.25
	task.delay(3, function() if tok == toastToken then
		TweenService:Create(toast, TweenInfo.new(0.4), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
	end end)
end

-- chase vignette (red edges while the Zookeeper is after you)
local vignette = Instance.new("Frame"); vignette.Size = UDim2.fromScale(1, 1); vignette.BackgroundTransparency = 1; vignette.Parent = gui
local vstroke = Instance.new("UIStroke"); vstroke.Thickness = 0; vstroke.Color = Color3.fromRGB(255, 40, 40); vstroke.Transparency = 0.4; vstroke.Parent = vignette
local chasing = false

----------------------------------------------------------------------------------------------------------------
-- character helpers
----------------------------------------------------------------------------------------------------------------
local char, hrp, hum, charSize
local function bindChar(c)
	char = c
	hrp = c:WaitForChild("HumanoidRootPart", 10)
	hum = c:FindFirstChildOfClass("Humanoid") or c:WaitForChild("Humanoid", 10)
	task.wait(0.2)
	if char == c then local _, s = c:GetBoundingBox(); charSize = s end
end
player.CharacterAdded:Connect(bindChar)
if player.Character then task.spawn(bindChar, player.Character) end

local resetting = false
local function backToCheckpoint(reason)
	if resetting then return end
	resetting = true
	if reason == "fall" then play2D("Fall") else play2D("Caught") end
	screenFlash(reason == "fall" and Color3.fromRGB(80, 170, 255) or Color3.fromRGB(255, 70, 50), 0.45, 0.6)
	if reason ~= "fall" then showBanner(reason == "net" and "NETTED!" or "OUCH!", Color3.fromRGB(255, 120, 90), Color3.fromRGB(255, 50, 50), "Back to your checkpoint", 1) end
	ResetRemote:FireServer()
	task.delay(0.6, function() resetting = false end)
end

----------------------------------------------------------------------------------------------------------------
-- server notifications
----------------------------------------------------------------------------------------------------------------
player:GetAttributeChangedSignal("CurrentStage"):Connect(function() setProgress(player:GetAttribute("CurrentStage") or 0) end)
setProgress(player:GetAttribute("CurrentStage") or 0)

local defaultFov = 70
Notify.OnClientEvent:Connect(function(kind, a, b, c)
	if kind == "StageStart" then
		play2D("Gate")
		screenFlash(Color3.fromRGB(150, 230, 255), 0.25, 0.5)
		showBanner("STAGE " .. a, Color3.fromRGB(255, 255, 150), Color3.fromRGB(110, 225, 70), nil, 1.4)
	elseif kind == "ChaseWarning" then
		for i = 0, 2 do task.delay(i * 0.45, function() play2D("Alarm") end) end
		screenFlash(Color3.fromRGB(255, 90, 40), 0.4, 0.8)
		showBanner("ZOOKEEPER INCOMING!", Color3.fromRGB(255, 220, 90), Color3.fromRGB(255, 60, 40), "RUN to the end of the stage!", 2.4)
	elseif kind == "ChaseStart" then
		chasing = true
		TweenService:Create(vstroke, TweenInfo.new(0.5), { Thickness = 18 }):Play()
		local cam = workspace.CurrentCamera
		TweenService:Create(cam, TweenInfo.new(0.6), { FieldOfView = defaultFov + 8 }):Play()
	elseif kind == "ChaseSafe" then
		chasing = false
		play2D("Safe")
		TweenService:Create(vstroke, TweenInfo.new(0.6), { Thickness = 0 }):Play()
		TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.6), { FieldOfView = defaultFov }):Play()
		screenFlash(Color3.fromRGB(120, 255, 140), 0.35, 0.6)
		showBanner("SAFE!", Color3.fromRGB(200, 255, 160), Color3.fromRGB(60, 210, 90), "The Zookeeper gave up", 1.6)
	elseif kind == "Caught" then
		chasing = false
		TweenService:Create(vstroke, TweenInfo.new(0.3), { Thickness = 0 }):Play()
		TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.3), { FieldOfView = defaultFov }):Play()
		play2D("Caught"); screenFlash(Color3.fromRGB(255, 50, 40), 0.5, 0.7)
		showBanner("CAUGHT!", Color3.fromRGB(255, 160, 120), Color3.fromRGB(255, 40, 40), "Back to the start of the stage", 1.5)
	elseif kind == "Reward" then
		play2D("Reward"); screenFlash(b and c == "Double" and Color3.fromRGB(190, 90, 255) or Color3.fromRGB(255, 210, 60), 0.35, 0.7)
		showBanner("+" .. tostring(b) .. (b == 1 and " WIN" or " WINS"), Color3.fromRGB(255, 250, 170), c == "Double" and Color3.fromRGB(190, 90, 255) or Color3.fromRGB(255, 170, 30), "Stage " .. a .. " complete!", 1.6)
	elseif kind == "Skipped" then
		play2D("Skip"); screenFlash(Color3.fromRGB(80, 255, 120), 0.35, 0.6)
		showBanner("STAGE SKIPPED", Color3.fromRGB(200, 255, 170), Color3.fromRGB(60, 220, 90), nil, 1.3)
	elseif kind == "TestPurchase" then
		showToast("TEST MODE: " .. (a == "Double" and "x2 Wins" or "Skip Stage") .. " is free until you add the Product ID")
	elseif kind == "Toast" then
		showToast(a)
	end
end)

----------------------------------------------------------------------------------------------------------------
-- hazards: deterministic motion from the server clock
----------------------------------------------------------------------------------------------------------------
local now = function() return workspace:GetServerTimeNow() end
local TAU = math.pi * 2
local function frac(x) return x - math.floor(x) end

local entries = {} -- [inst] = { kind=, inst=, base=, ... }
local active = {}
local function add(kind, inst)
	if entries[inst] then return end
	local e = { kind = kind, inst = inst }
	e.base = inst:GetAttribute("BaseCF") or (inst:IsA("Model") and inst:GetPivot() or inst.CFrame)
	if kind == "RollingBall" then
		e.base = inst:GetAttribute("Top")
		e.top = inst:GetAttribute("Top"); e.bottom = inst:GetAttribute("Bottom")
		e.r = inst:GetAttribute("Radius") or 18
		e.parts = {}
		for _, p in inst:GetDescendants() do if p:IsA("BasePart") then e.parts[p] = p.Transparency end end
		e.scale = inst:GetScale()
		local stage = inst:FindFirstAncestorWhichIsA("Folder")
		e.lights = {}
		e.glows = {}
		if stage then
			for _, l in stage:GetDescendants() do
				if CollectionService:HasTag(l, "BallWarnLight") then table.insert(e.lights, l) end
				if CollectionService:HasTag(l, "BallSpawnGlow") then table.insert(e.glows, l) end
			end
		end
	elseif kind == "Treadmill" then
		local g = inst:FindFirstChild("BeltStripes"); e.scroll = g and g:FindFirstChild("Scroll")
	elseif kind == "PortalSpin" then
		e.swirl = inst:FindFirstChild("Swirl"); e.core = inst:FindFirstChild("Core")
		e.sbase = e.swirl and e.swirl.CFrame; e.cbase = e.core and e.core.CFrame
	end
	entries[inst] = e
end
local KINDS = { "Mover", "Spinner", "Pendulum", "Crusher", "Blink", "Collapse", "RollingBall", "MovingWall", "Treadmill", "PortalSpin", "SpinEgg", "SpinWheelDecor", "SpinIcon" }
for _, k in ipairs(KINDS) do
	for _, i in CollectionService:GetTagged(k) do add(k, i) end
	CollectionService:GetInstanceAddedSignal(k):Connect(function(i) add(k, i) end)
	CollectionService:GetInstanceRemovedSignal(k):Connect(function(i) entries[i] = nil end)
end

local function posOf(e) return e.base.Position end
task.spawn(function() -- refresh the list of hazards near the camera twice a second
	while true do
		local cam = workspace.CurrentCamera
		local c = cam and cam.CFrame.Position or Vector3.zero
		local list = {}
		for inst, e in pairs(entries) do
			if inst.Parent and (posOf(e) - c).Magnitude < 1100 then table.insert(list, e) end
		end
		active = list
		task.wait(0.5)
	end
end)

local function setVisible(e, on, fade)
	for p, t0 in pairs(e.parts) do
		p.Transparency = on and t0 or 1
		p.CanQuery = on and CollectionService:HasTag(p, "HazardKill")
	end
end

local collapseState = {} -- part -> { t0 = touch time, base = cf }
local function step()
	local t = now()
	for _, e in ipairs(active) do
		local inst, k = e.inst, e.kind
		if k == "Mover" or k == "MovingWall" then
			local amp, per, ph = inst:GetAttribute("Amp"), inst:GetAttribute("Period"), inst:GetAttribute("Phase") or 0
			local a = TAU * (t / per + ph)
			local cf = e.base + amp * math.sin(a)
			if inst:IsA("Model") then inst:PivotTo(cf) else
				inst.CFrame = cf
				inst.AssemblyLinearVelocity = amp * math.cos(a) * TAU / per -- carries players standing on it
			end
		elseif k == "Spinner" then
			inst:PivotTo(CFrame.Angles(0, math.rad(inst:GetAttribute("Speed")) * t, 0) * (e.base - e.base.Position) + e.base.Position)
		elseif k == "Pendulum" then
			local per = inst:GetAttribute("Period")
			local s = math.sin(TAU * (t / per + (inst:GetAttribute("Phase") or 0)))
			inst:PivotTo(e.base * CFrame.Angles(0, 0, math.rad(inst:GetAttribute("Amp")) * s))
			local sign = s > 0
			if e.lastSign ~= nil and sign ~= e.lastSign then play3D("Whoosh", inst.PrimaryPart, 180) end
			e.lastSign = sign
		elseif k == "Crusher" then
			local u = frac(t / inst:GetAttribute("Period") + (inst:GetAttribute("Phase") or 0))
			local H = inst:GetAttribute("Height")
			local y
			if u < 0.35 then y = 0
			elseif u < 0.43 then local v = (u - 0.35) / 0.08; y = -H * v * v
			elseif u < 0.6 then y = -H
			else y = -H * (1 - (u - 0.6) / 0.4) end
			inst:PivotTo(e.base + Vector3.new(0, y, 0))
			local down = u >= 0.43 and u < 0.6
			if down and not e.down then play3D("Slam", inst.PrimaryPart, 200) end
			e.down = down
		elseif k == "Blink" then
			local u = frac(t / inst:GetAttribute("Period") + (inst:GetAttribute("Phase") or 0))
			local on = u < (inst:GetAttribute("OnFrac") or 0.6)
			local warn = on and u > (inst:GetAttribute("OnFrac") or 0.6) - 0.18
			inst.CanCollide = on
			inst.Transparency = (not on) and 0.85 or (warn and (math.floor(t * 10) % 2 == 0 and 0.45 or 0) or 0)
		elseif k == "RollingBall" then
			local spawnT, warnT, cool = inst:GetAttribute("Spawn"), inst:GetAttribute("Warn"), inst:GetAttribute("Cooldown")
			local dist = (e.top.Position - e.bottom.Position).Magnitude
			local roll = dist / inst:GetAttribute("Speed")
			local total = spawnT + warnT + roll + cool
			local u = t % total
			local phase, cf
			if u < spawnT then
				phase = "spawn"
				local v = u / spawnT
				cf = e.top + Vector3.new(0, 30 * (1 - v) ^ 2, 0)
				inst:ScaleTo(e.scale * math.max(0.05, v))
				setVisible(e, true)
			elseif u < spawnT + warnT then
				phase = "warn"
				inst:ScaleTo(e.scale)
				local w = (u - spawnT) / warnT
				cf = e.top * CFrame.new(math.sin(t * 40) * 0.6 * w, 0, 0)
			elseif u < spawnT + warnT + roll then
				phase = "roll"
				local v = (u - spawnT - warnT) / roll
				local p = e.top.Position:Lerp(e.bottom.Position, v)
				cf = CFrame.new(p) * (e.top - e.top.Position) * CFrame.Angles(dist * v / e.r, 0, 0)
			else
				phase = "gone"
				cf = e.bottom
				setVisible(e, false)
			end
			inst:PivotTo(cf)
			if phase ~= e.phase then
				if phase == "warn" then e.rumble = play3D("Rumble", inst.PrimaryPart, 600)
				elseif phase == "gone" then
					local hit = Instance.new("Part"); hit.Anchored = true; hit.CanCollide = false; hit.CanQuery = false; hit.Transparency = 1
					hit.CFrame = e.bottom; hit.Parent = workspace
					local pe = Instance.new("ParticleEmitter"); pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
					pe.Speed = NumberRange.new(20, 40); pe.SpreadAngle = Vector2.new(180, 180); pe.Lifetime = NumberRange.new(0.6, 1)
					pe.Size = NumberSequence.new(6, 0); pe.Color = ColorSequence.new(Color3.fromRGB(255, 240, 220)); pe.Parent = hit
					pe:Emit(40)
					play3D("Impact", hit, 400)
					task.delay(2, function() hit:Destroy() end)
				end
				e.phase = phase
			end
			local flashOn = (phase == "warn" or phase == "roll") and (math.floor(t * 6) % 2 == 0)
			for _, l in ipairs(e.lights) do l.Transparency = flashOn and 0 or 0.7 end
			for _, g in ipairs(e.glows) do g.Transparency = (phase == "spawn") and (0.5 - 0.5 * math.sin(t * 20)) or 0.6 end
		elseif k == "Treadmill" then
			if e.scroll then e.scroll.Position = UDim2.fromScale(0, -frac(t * 0.8)) end
		elseif k == "PortalSpin" then
			if e.swirl then e.swirl.CFrame = e.sbase * CFrame.Angles(t * 1.2, 0, 0) end
			if e.core then e.core.CFrame = e.cbase * CFrame.Angles(-t * 0.7, 0, 0) end
		elseif k == "SpinEgg" then
			inst:PivotTo(e.base * CFrame.new(0, math.sin(t * 2) * 0.8, 0) * CFrame.Angles(0, t * 0.6, math.sin(t * 1.3) * 0.08))
		elseif k == "SpinIcon" then
			inst:PivotTo(e.base * CFrame.new(0, math.sin(t * 1.5) * 0.5, 0) * CFrame.Angles(0, t * 0.9, 0))
		elseif k == "SpinWheelDecor" then
			inst:PivotTo(e.base * CFrame.Angles(0, 0, t * 0.4))
		end
	end
	-- collapsing platforms (local only)
	for p, st in pairs(collapseState) do
		local dt = t - st.t0
		local delay = p:GetAttribute("Delay") or 0.7
		if dt < delay then
			p.CFrame = st.base * CFrame.new(math.sin(t * 50) * 0.25, 0, math.cos(t * 43) * 0.25)
		elseif dt < delay + 1 then
			local v = dt - delay
			p.CanCollide = false
			p.CFrame = st.base - Vector3.new(0, 60 * v * v, 0)
			p.Transparency = v
		elseif dt > delay + (p:GetAttribute("Respawn") or 3) then
			p.CFrame = st.base; p.Transparency = 0; p.CanCollide = true
			collapseState[p] = nil
		end
	end
end

----------------------------------------------------------------------------------------------------------------
-- player checks: gates, hazard hits, falls, collapse triggers, reward pads
----------------------------------------------------------------------------------------------------------------
local gates = {}
local function addGate(g) gates[g] = true end
for _, g in CollectionService:GetTagged("StageGate") do addGate(g) end
CollectionService:GetInstanceAddedSignal("StageGate"):Connect(addGate)
local stageFolders = {}
local function addStage(s) stageFolders[s:GetAttribute("World") .. ":" .. s:GetAttribute("Stage")] = s end
for _, s in CollectionService:GetTagged("ObbyStage") do addStage(s) end
CollectionService:GetInstanceAddedSignal("ObbyStage"):Connect(addStage)

local lastLocal = {}
local overlap = OverlapParams.new(); overlap.FilterType = Enum.RaycastFilterType.Include
local function refreshOverlap() overlap.FilterDescendantsInstances = CollectionService:GetTagged("HazardKill") end
refreshOverlap()
CollectionService:GetInstanceAddedSignal("HazardKill"):Connect(refreshOverlap)
local ray = RaycastParams.new(); ray.FilterType = Enum.RaycastFilterType.Exclude

local padCooldown = {}
local function checkPlayer()
	if not (hrp and hrp.Parent and hum and hum.Health > 0) then return end
	local pos = hrp.Position
	-- gate planes (works at any speed: we compare which side of the plane we are on each frame)
	for g in pairs(gates) do
		if g.Parent then
			local lp = g.CFrame:PointToObjectSpace(pos)
			local prev = lastLocal[g]
			local w = (g:GetAttribute("Width") or 64) / 2 + 8
			if prev and prev.Z > 0 and lp.Z <= 0 and math.abs(lp.X) < w and lp.Y > -g.Size.Y and lp.Y < g.Size.Y then
				GateRemote:FireServer(g:GetAttribute("World"), g:GetAttribute("Stage"))
			end
			if math.abs(lp.Z) < 400 then lastLocal[g] = lp else lastLocal[g] = nil end
		end
	end
	-- hazards touching the animal's body box
	local size = (charSize or hrp.Size) * Vector3.new(0.8, 0.85, 0.8)
	local hits = workspace:GetPartBoundsInBox(hrp.CFrame, size, overlap)
	for _, h in ipairs(hits) do
		if h.Transparency < 0.9 then
			backToCheckpoint((h.Name == "Hoop" or h.Name == "Mesh") and "net" or "hit")
			break
		end
	end
	-- falls
	local stg = player:GetAttribute("CurrentStage") or 0
	local wld = player:GetAttribute("CurrentWorld") or 1
	local sf = stageFolders[wld .. ":" .. math.max(1, stg)]
	if sf and stg > 0 and pos.Y < (sf:GetAttribute("KillY") or -1e9) then backToCheckpoint("fall") end
	-- what are we standing on?
	ray.FilterDescendantsInstances = { char }
	local res = workspace:Raycast(pos, Vector3.new(0, -(size.Y + 6), 0), ray)
	if res and res.Instance then
		local p = res.Instance
		if CollectionService:HasTag(p, "Collapse") and not collapseState[p] then
			collapseState[p] = { t0 = now(), base = p.CFrame }
		elseif CollectionService:HasTag(p, "RewardPad") and (not padCooldown[p] or os.clock() - padCooldown[p] > 3) then
			padCooldown[p] = os.clock()
			play2D("Press")
			local top = p.Parent and p.Parent:FindFirstChild("CapTop")
			for _, part in ipairs({ p, top }) do
				if part then
					local c0 = part.CFrame
					TweenService:Create(part, TweenInfo.new(0.12), { CFrame = c0 - Vector3.new(0, 0.9, 0) }):Play()
					task.delay(0.35, function() TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back), { CFrame = c0 }):Play() end)
				end
			end
			local pe = p:FindFirstChildOfClass("ParticleEmitter"); if pe then pe:Emit(30) end
			PadRemote:FireServer(p)
		end
	end
end

local frames = 0
RunService.Heartbeat:Connect(function()
	frames += 1
	if frames % 120 == 0 then
		local kinds = {}
		for _, e in ipairs(active) do kinds[e.kind] = (kinds[e.kind] or 0) + 1 end
		local s = ""
		for k, n in pairs(kinds) do s = s .. k .. n .. " " end
		workspace:SetAttribute("ObbyClientFrames", frames .. " active=" .. #active .. " " .. s)
	end
	local ok, err = pcall(step)
	if not ok then workspace:SetAttribute("ObbyClientError", tostring(err)) end
	local ok2, err2 = pcall(checkPlayer)
	if not ok2 then workspace:SetAttribute("ObbyClientError", tostring(err2)) end
end)

----------------------------------------------------------------------------------------------------------------
-- next race timer (RaceService sets workspace attribute "NextRace" = server time of the next race)
----------------------------------------------------------------------------------------------------------------
task.spawn(function()
	while true do
		local nxt = workspace:GetAttribute("NextRace")
		if nxt then
			local left = math.max(0, math.floor(nxt - now()))
			race.Text = string.format('Next <font color="#FFE34D">Speed Race</font> event in %dm %ds', left // 60, left % 60)
		else race.Text = "" end
		task.wait(0.5)
	end
end)

----------------------------------------------------------------------------------------------------------------
-- custom hold-to-interact prompt (progress ring; E / gamepad X / tap)
----------------------------------------------------------------------------------------------------------------
local function ringHalf(parent, right)
	local clip = Instance.new("Frame"); clip.BackgroundTransparency = 1; clip.ClipsDescendants = true
	clip.Size = UDim2.fromScale(0.5, 1); clip.Position = UDim2.fromScale(right and 0.5 or 0, 0); clip.Parent = parent
	local circ = Instance.new("Frame"); circ.BackgroundTransparency = 1; circ.Size = UDim2.fromScale(2, 1)
	circ.Position = UDim2.fromScale(right and -1 or 0, 0); circ.Parent = clip
	corner(circ, 999)
	local st = Instance.new("UIStroke"); st.Thickness = 6; st.Color = Color3.fromRGB(255, 210, 60); st.Parent = circ
	local gr = Instance.new("UIGradient"); gr.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.499, 0), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 1) })
	gr.Rotation = right and 0 or 180; gr.Parent = st
	return gr
end

local promptUI = {}
ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
	if prompt.Style ~= Enum.ProximityPromptStyle.Custom then return end
	local bb = Instance.new("BillboardGui"); bb.Name = "PromptUI"; bb.AlwaysOnTop = true; bb.Size = UDim2.fromOffset(240, 84)
	bb.StudsOffsetWorldSpace = Vector3.new(0, 4, 0); bb.Adornee = prompt.Parent; bb.ResetOnSpawn = false; bb.Parent = player.PlayerGui
	local card = Instance.new("Frame"); card.Size = UDim2.fromScale(1, 1); card.BackgroundColor3 = Color3.fromRGB(28, 30, 48)
	card.BackgroundTransparency = 0.15; card.Parent = bb; corner(card, 16); stroke(card, 2)
	local ring = Instance.new("Frame"); ring.Size = UDim2.fromOffset(64, 64); ring.Position = UDim2.fromOffset(10, 10); ring.BackgroundColor3 = Color3.fromRGB(50, 54, 80); ring.Parent = card
	corner(ring, 999)
	local key = Instance.new("TextButton"); key.Size = UDim2.fromScale(0.7, 0.7); key.Position = UDim2.fromScale(0.15, 0.15); key.AutoButtonColor = false
	key.BackgroundColor3 = Color3.fromRGB(255, 255, 255); key.Font = FONT_BOLD; key.TextScaled = true; key.TextColor3 = Color3.fromRGB(30, 30, 50)
	key.Text = (inputType == Enum.ProximityPromptInputType.Gamepad and "X") or (inputType == Enum.ProximityPromptInputType.Touch and "👆") or prompt.KeyboardKeyCode.Name
	key.Parent = ring; corner(key, 999)
	local gR, gL = ringHalf(ring, true), ringHalf(ring, false)
	local act = Instance.new("TextLabel"); act.BackgroundTransparency = 1; act.Position = UDim2.fromOffset(84, 12); act.Size = UDim2.new(1, -94, 0, 34)
	act.Font = FONT_BOLD; act.TextScaled = true; act.TextXAlignment = Enum.TextXAlignment.Left; act.TextColor3 = Color3.new(1, 1, 1); act.Text = prompt.ActionText; act.Parent = card
	local obj = Instance.new("TextLabel"); obj.BackgroundTransparency = 1; obj.Position = UDim2.fromOffset(84, 48); obj.Size = UDim2.new(1, -94, 0, 24)
	obj.Font = FONT; obj.TextScaled = true; obj.TextXAlignment = Enum.TextXAlignment.Left; obj.TextColor3 = Color3.fromRGB(200, 205, 230); obj.Text = prompt.ObjectText; obj.Parent = card
	local hint = (inputType == Enum.ProximityPromptInputType.Touch) and "Hold" or ("Hold " .. key.Text)
	obj.Text = (prompt.ObjectText ~= "" and (prompt.ObjectText .. "  •  ") or "") .. hint
	local holdTween
	local prog = Instance.new("NumberValue")
	prog.Changed:Connect(function(v)
		gR.Rotation = math.clamp(v * 2, 0, 1) * 180
		gL.Rotation = 180 + math.clamp(v * 2 - 1, 0, 1) * 180
	end)
	prog.Value = 0
	local c1 = prompt.PromptButtonHoldBegan:Connect(function()
		holdTween = TweenService:Create(prog, TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear), { Value = 1 }); holdTween:Play()
		TweenService:Create(card, TweenInfo.new(0.15), { Size = UDim2.fromScale(1.05, 1.05) }):Play()
	end)
	local c2 = prompt.PromptButtonHoldEnded:Connect(function()
		if holdTween then holdTween:Cancel() end
		TweenService:Create(prog, TweenInfo.new(0.2), { Value = 0 }):Play()
		TweenService:Create(card, TweenInfo.new(0.15), { Size = UDim2.fromScale(1, 1) }):Play()
	end)
	local c3 = prompt.Triggered:Connect(function()
		play2D("Prompt")
		key.BackgroundColor3 = Color3.fromRGB(255, 215, 60)
		task.delay(0.3, function() key.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end)
	end)
	-- touch: press and hold the round button
	key.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then prompt:InputHoldBegin() end end)
	key.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then prompt:InputHoldEnd() end end)
	bb.Active = true
	promptUI[prompt] = { bb = bb, conns = { c1, c2, c3 } }
	card.Size = UDim2.fromScale(0.6, 0.6); card.Position = UDim2.fromScale(0.2, 0.2)
	TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, 0) }):Play()
end)
ProximityPromptService.PromptHidden:Connect(function(prompt)
	local u = promptUI[prompt]
	if u then
		for _, c in ipairs(u.conns) do c:Disconnect() end
		u.bb:Destroy()
		promptUI[prompt] = nil
	end
end)

----------------------------------------------------------------------------------------------------------------
-- world lighting + ambience (per world; the Zoo is bright blue/green but not washed out)
----------------------------------------------------------------------------------------------------------------
local PRESETS = {
	[1] = { -- Zoo
		lighting = { Brightness = 2.3, ExposureCompensation = -0.28, ClockTime = 14.3, Ambient = Color3.fromRGB(90, 92, 108), OutdoorAmbient = Color3.fromRGB(135, 140, 158) },
		atmosphere = { Density = 0.3, Offset = 0.12, Color = Color3.fromRGB(196, 222, 255), Decay = Color3.fromRGB(110, 150, 200), Glare = 0.15, Haze = 1.1 },
		cc = { Saturation = 0.2, Contrast = 0.14, TintColor = Color3.fromRGB(255, 251, 242) },
		particles = { color = Color3.fromRGB(150, 220, 110), texture = "rbxasset://textures/particles/sparkles_main.dds", rate = 3 },
	},
}
local function applyWorld(w)
	local p = PRESETS[w]; if not p then return end
	local ti = TweenInfo.new(1.5)
	TweenService:Create(Lighting, ti, p.lighting):Play()
	local atm = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
	TweenService:Create(atm, ti, p.atmosphere):Play()
	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)
	TweenService:Create(cc, ti, p.cc):Play()
end
local currentWorld
player:GetAttributeChangedSignal("CurrentWorld"):Connect(function()
	local w = player:GetAttribute("CurrentWorld")
	if w ~= currentWorld then currentWorld = w; applyWorld(w) end
end)
currentWorld = player:GetAttribute("CurrentWorld") or 1
applyWorld(currentWorld)

-- ambient leaves / pollen around the camera (cheap: one emitter that follows the camera)
local amb = Instance.new("Part"); amb.Name = "AmbientFX"; amb.Anchored = true; amb.CanCollide = false; amb.CanQuery = false; amb.CanTouch = false
amb.Transparency = 1; amb.Size = Vector3.new(120, 1, 120); amb.Parent = workspace.CurrentCamera
local ambE = Instance.new("ParticleEmitter"); ambE.Texture = PRESETS[1].particles.texture; ambE.Rate = PRESETS[1].particles.rate
ambE.Lifetime = NumberRange.new(6, 9); ambE.Speed = NumberRange.new(1, 3); ambE.SpreadAngle = Vector2.new(180, 180)
ambE.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 0.5), NumberSequenceKeypoint.new(1, 0) })
ambE.Color = ColorSequence.new(PRESETS[1].particles.color); ambE.LightEmission = 0.3; ambE.Acceleration = Vector3.new(1, -0.6, 0.5)
ambE.Shape = Enum.ParticleEmitterShape.Box; ambE.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume; ambE.Parent = amb
RunService.RenderStepped:Connect(function()
	local cam = workspace.CurrentCamera
	if cam then amb.CFrame = CFrame.new(cam.CFrame.Position + Vector3.new(0, 25, 0)) end
end)
