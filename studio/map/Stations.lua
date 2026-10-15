-- Stations: the gameplay buildings every world shares (stage gates, reward pads, speed upgrades, treadmills,
-- eggs, wheel, shops, leaderboard, portals, premium animal pads). T = world theme table (colours + style).
-- Gameplay hooks are tags + attributes only; the runtime scripts (ObbyService, ZooMapClient) read them.
return function(K, P)
	local S = {}
	local V = Vector3.new
	local rad = math.rad
	local NF, NB = Enum.NormalId.Front, Enum.NormalId.Back

	local function ring(cf, radius, thick, width, color, n, o, parent)
		-- ring of n blocks lying in cf's XY plane (a portal / wheel rim)
		n = n or 20
		for i = 1, n do
			local a = (i - 0.5) / n * math.pi * 2
			local seg = 2 * radius * math.tan(math.pi / n) + 0.15
			K.part(V(seg, thick, width), cf * CFrame.Angles(0, 0, a) * CFrame.new(0, radius, 0), color, { parent = parent, neon = o and o.neon, collide = o and o.collide or false, studs = o and o.studs })
		end
	end
	S.ring = ring

	local function prompt(part, action, object, hold, tag, attrs)
		local pp = Instance.new("ProximityPrompt")
		pp.ActionText = action; pp.ObjectText = object or ""
		pp.HoldDuration = hold or 0.6
		pp.MaxActivationDistance = 22
		pp.RequiresLineOfSight = false
		pp.Style = Enum.ProximityPromptStyle.Custom -- drawn by ZooMapClient (progress ring, gamepad + touch aware)
		pp.KeyboardKeyCode = Enum.KeyCode.E
		pp.GamepadKeyCode = Enum.KeyCode.ButtonX
		pp.Parent = part
		if tag then K.tag(pp, tag, attrs) end
		return pp
	end
	S.prompt = prompt

	------------------------------------------------------------------------------------------------------------
	-- STAGE GATE: pillar - energy field - pillar, joined into the course walls. cf: centre of the opening on the
	-- floor, -Z = direction of travel. Players approach from +Z and read the Back face.
	------------------------------------------------------------------------------------------------------------
	function S.stageGate(cf, w, h, stage, cfg, T, parent)
		local m = K.model("StageGate" .. stage, parent)
		local pc, tc, fc = T.gatePillar, T.gateTrim, T.gateField
		local pw = 12
		for _, sx in ipairs({ -1, 1 }) do
			local x = sx * (w / 2 + pw / 2)
			K.part(V(pw + 4, 4, pw + 4), cf * CFrame.new(x, 2, 0), K.shade(pc, 0.75), { parent = m, studs = true })
			K.part(V(pw, h, pw), cf * CFrame.new(x, 4 + h / 2, 0), pc, { parent = m, studs = true })
			for k = 1, 4 do
				K.part(V(pw + 0.8, 1, pw + 0.8), cf * CFrame.new(x, 4 + h * k / 5, 0), tc, { parent = m, collide = false })
			end
			K.part(V(1, h, 1.2), cf * CFrame.new(x - sx * (pw / 2 + 0.3), 4 + h / 2, 0), fc, { parent = m, neon = true, collide = false })
			-- crown on the pillar top (themed)
			K.part(V(pw + 3, 3, pw + 3), cf * CFrame.new(x, 4 + h + 1.5, 0), K.shade(pc, 0.85), { parent = m, studs = true })
			if T.gateCrown then T.gateCrown(cf * CFrame.new(x, 4 + h + 3, 0), m) end
		end
		-- lintel
		local lint = K.part(V(w + pw * 2 + 6, 8, pw), cf * CFrame.new(0, 4 + h + 4, 0), pc, { parent = m, studs = true })
		K.part(V(w + pw * 2 + 6.4, 1.2, pw + 0.4), cf * CFrame.new(0, 4 + h + 0.4, 0), tc, { parent = m, collide = false })
		K.part(V(w, 1, 1.2), cf * CFrame.new(0, 4 + h - 0.2, 0), fc, { parent = m, neon = true, collide = false })
		-- the energy field (walk-through)
		local field = K.part(V(w, h + 4, 0.6), cf * CFrame.new(0, (h + 4) / 2, 0), fc, { parent = m, collide = false, transp = 0.55, mat = Enum.Material.ForceField, name = "Field", shadow = false })
		field.CastShadow = false
		local tint = K.part(V(w, h + 4, 0.3), cf * CFrame.new(0, (h + 4) / 2, 0.5), fc, { parent = m, collide = false, transp = 0.88, mat = Enum.Material.Glass, name = "Tint" })
		tint.CastShadow = false
		K.sparkle(field, fc, { rate = 10, size = 1.6, life = NumberRange.new(2, 3.5), speed = NumberRange.new(2, 5), accel = V(0, 2, 0), spread = Vector2.new(10, 10), emitDir = Enum.NormalId.Top, shape = Enum.ParticleEmitterShape.Box })
		-- the stage text (big STAGE X, then the two requirement lines)
		local info = cfg or {}
		local board = K.part(V(w, h * 0.9, 0.2), cf * CFrame.new(0, 4 + h * 0.52, 0.9), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "StageText" })
		K.textPanel(board, NB, {
			{ name = "Title", text = "STAGE " .. stage, h = 0.46, grad = T.titleGrad or { Color3.fromRGB(255, 255, 140), Color3.fromRGB(120, 230, 60) }, stroke = 10, font = K.FONT_BOLD },
			{ name = "Level", text = "Recommended Level: " .. tostring(info.recommendedLevel or "?"), h = 0.17, color = Color3.fromRGB(255, 205, 60), stroke = 6 },
			{ name = "Speed", text = "Speed Required: " .. tostring(info.speedRequired or "?"), h = 0.17, color = Color3.new(1, 1, 1), stroke = 6 },
		}, { pps = 8, dist = 900 })
		-- gameplay hook: crossing this plane = stage start (ZooMapClient checks the plane, so any speed works)
		K.tag(field, "StageGate", { World = T.id, Stage = stage, Width = w })
		return m, field
	end

	------------------------------------------------------------------------------------------------------------
	-- REWARD STATIONS: yellow (normal), purple (x2), green (skip next stage). cf at floor centre, facing -Z.
	------------------------------------------------------------------------------------------------------------
	local KIND = {
		Normal = { col = Color3.fromRGB(255, 205, 40), dark = Color3.fromRGB(190, 120, 10), icon = "🏆", title = "CLAIM" },
		Double = { col = Color3.fromRGB(175, 70, 255), dark = Color3.fromRGB(95, 25, 170), icon = "💎", title = "x2 WINS" },
		Skip = { col = Color3.fromRGB(60, 225, 90), dark = Color3.fromRGB(20, 140, 50), icon = "⏩", title = "SKIP STAGE" },
	}
	S.REWARD_KINDS = KIND
	function S.rewardPad(cf, kind, stage, label, T, parent)
		local k = KIND[kind]
		local m = K.model("Reward_" .. kind .. "_" .. stage, parent)
		local r = 17
		-- stepped hexagon base
		for i = 0, 5 do
			K.part(V(r * 0.58 + 0.2, 1.6, r), cf * CFrame.Angles(0, rad(i * 60), 0) * CFrame.new(0, 0.8, 0), T.padBase or Color3.fromRGB(70, 70, 95), { parent = m, studs = true })
		end
		for i = 0, 5 do
			K.part(V(r * 0.58 * 0.82, 1, r * 0.82), cf * CFrame.Angles(0, rad(i * 60 + 30), 0) * CFrame.new(0, 2.1, 0), k.dark, { parent = m, studs = true })
		end
		K.cyl(r * 0.78, 0.3, (cf * CFrame.new(0, 2.7, 0)).Position, k.col, { parent = m, neon = true, collide = false })
		-- the button cap (pressed down by ZooMapClient)
		local cap = K.cyl(r * 0.64, 1.3, (cf * CFrame.new(0, 3.2, 0)).Position, k.col, { parent = m, name = "Cap", touch = true })
		K.cyl(r * 0.46, 1.4, (cf * CFrame.new(0, 3.25, 0)).Position, K.shade(k.col, 1.15), { parent = m, collide = false, name = "CapTop" })
		K.light(cap, k.col, 18, 1.2)
		K.sparkle(cap, k.col, { rate = 6, size = 0.9, speed = NumberRange.new(2, 5), accel = V(0, 3, 0), emitDir = Enum.NormalId.Right, spread = Vector2.new(40, 40) })
		for i = 0, 2 do
			local p = cf * CFrame.Angles(0, rad(i * 120 + 60), 0) * CFrame.new(0, 0, -r * 0.62)
			K.part(V(1.6, 6, 1.6), p * CFrame.new(0, 3, 0), T.padTrim or Color3.fromRGB(240, 240, 255), { parent = m, studs = true })
			K.part(V(2, 2, 2), p * CFrame.new(0, 6.8, 0), k.col, { parent = m, shape = "ball", neon = true, collide = false })
		end
		local sign = K.part(V(1, 1, 1), cf * CFrame.new(0, 12, 0), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Sign" })
		K.billboard(sign, {
			{ name = "Icon", text = k.icon, h = 0.4, stroke = 0 },
			{ name = "Title", text = k.title, h = 0.32, color = k.col, font = K.FONT_BOLD, stroke = 4 },
			{ name = "Label", text = label or "", h = 0.28, color = Color3.new(1, 1, 1), stroke = 3 },
		}, { size = UDim2.fromScale(14, 8), offset = V(0, 0, 0), dist = 300 })
		K.tag(cap, "RewardPad", { World = T.id, Stage = stage, Kind = kind })
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- SPEED UPGRADE: one station; tier 1..n grows in size and glow. text = { plus=, wins= } from config
	------------------------------------------------------------------------------------------------------------
	local TIER_COL = {
		Color3.fromRGB(120, 230, 90), Color3.fromRGB(70, 220, 160), Color3.fromRGB(60, 190, 255), Color3.fromRGB(80, 130, 255),
		Color3.fromRGB(140, 90, 255), Color3.fromRGB(200, 80, 255), Color3.fromRGB(255, 80, 200), Color3.fromRGB(255, 90, 90),
		Color3.fromRGB(255, 150, 40), Color3.fromRGB(255, 215, 40),
	}
	S.TIER_COL = TIER_COL
	function S.speedUpgrade(cf, tier, info, T, parent)
		local m = K.model("SpeedUpgrade" .. tier, parent)
		local c = TIER_COL[math.clamp(tier, 1, #TIER_COL)]
		local s = 1 + (tier - 1) * 0.06
		K.part(V(16, 1.6, 16) * V(s, 1, s), cf * CFrame.new(0, 0.8, 0), T.padBase or Color3.fromRGB(60, 60, 80), { parent = m, studs = true })
		K.part(V(13, 0.5, 13) * V(s, 1, s), cf * CFrame.new(0, 1.85, 0), c, { parent = m, neon = true, collide = false })
		local top = K.part(V(12, 1, 12) * V(s, 1, s), cf * CFrame.new(0, 2.3, 0), K.shade(c, 0.85), { parent = m, studs = true, name = "Pad" })
		-- pedestal with a lightning bolt made of neon wedges
		local ped = K.part(V(4.5, 5 + tier * 0.4, 4.5), cf * CFrame.new(0, 2.8 + (5 + tier * 0.4) / 2, 4.5 * s), T.padTrim or Color3.fromRGB(235, 235, 245), { parent = m, studs = true })
		local tp = cf * CFrame.new(0, 2.8 + 5 + tier * 0.4, 4.5 * s)
		K.part(V(1.2, 4, 2.4), tp * CFrame.new(0.4, 2.6, 0) * CFrame.Angles(0, 0, rad(-20)), c, { parent = m, neon = true, collide = false })
		K.part(V(1.2, 4, 2.4), tp * CFrame.new(-0.4, 5.2, 0) * CFrame.Angles(0, 0, rad(-20)), c, { parent = m, neon = true, collide = false })
		K.part(V(2.6, 1, 2.4), tp * CFrame.new(0, 3.9, 0), c, { parent = m, neon = true, collide = false })
		if tier >= 6 then K.sparkle(top, c, { rate = 2 + tier, size = 0.8, accel = V(0, 4, 0) }) end
		local sign = K.part(V(1, 1, 1), tp * CFrame.new(0, 9.5, 0), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Sign" })
		K.billboard(sign, {
			{ name = "Plus", text = "+" .. tostring(info.plus or "?") .. " / Steps", h = 0.55, color = c, font = K.FONT_BOLD, stroke = 4 },
			{ name = "Wins", text = tostring(info.wins or "?") .. " Wins Required", h = 0.45, color = Color3.new(1, 1, 1), stroke = 3 },
		}, { size = UDim2.fromScale(14, 5), offset = V(0, 0, 0), dist = 160 })
		local pp = prompt(top, "Upgrade", "Speed +" .. tostring(info.plus or "?"), 0.5, "SpeedUpgrade", { World = T.id, Tier = tier })
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- TREADMILL: frame + belt (ZooMapClient scrolls the belt stripes) + console with the multiplier
	------------------------------------------------------------------------------------------------------------
	function S.treadmill(cf, tier, mult, T, parent)
		-- runner faces cf's -Z (toward the console)
		local m = K.model("Treadmill" .. tier, parent)
		local c = TIER_COL[math.clamp(tier * 2 - 1, 1, #TIER_COL)]
		local dark = Color3.fromRGB(40, 42, 58)
		local metal = Color3.fromRGB(120, 126, 150)
		local L, W = 26, 11
		-- glowing floor mat
		K.part(V(W + 9, 0.4, L + 9), cf * CFrame.new(0, 0.2, 0), K.shade(c, 0.35), { parent = m, studs = true, collide = false })
		K.part(V(W + 9.6, 0.2, L + 9.6), cf * CFrame.new(0, 0.1, 0), c, { parent = m, neon = true, collide = false })
		-- deck + end rollers
		K.part(V(W + 2, 1.6, L), cf * CFrame.new(0, 1.2, 0), dark, { parent = m })
		for _, z in ipairs({ -L / 2, L / 2 }) do
			K.part(V(W + 2.4, 2.4, 2.4), cf * CFrame.new(0, 1.3, z), metal, { parent = m, shape = "cyl" })
		end
		local belt = K.part(V(W, 0.5, L), cf * CFrame.new(0, 2.2, 0), Color3.fromRGB(32, 32, 42), { parent = m, name = "Belt", touch = true })
		local g = Instance.new("SurfaceGui"); g.Face = Enum.NormalId.Top; g.Name = "BeltStripes"; g.PixelsPerStud = 8
		g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; g.LightInfluence = 1; g.Parent = belt
		local strip = Instance.new("Frame"); strip.Name = "Scroll"; strip.Size = UDim2.fromScale(1, 2); strip.BackgroundColor3 = Color3.new(1, 1, 1)
		strip.BorderSizePixel = 0; strip.Parent = g
		local gr = Instance.new("UIGradient"); gr.Rotation = 90
		local kp = {}
		for i = 0, 12 do table.insert(kp, ColorSequenceKeypoint.new(i / 12, (i % 2 == 0) and Color3.fromRGB(36, 36, 48) or K.shade(c, 0.4))) end
		gr.Color = ColorSequence.new(kp); gr.Parent = strip
		-- side steps with neon strips
		for _, sx in ipairs({ -1, 1 }) do
			K.part(V(1.8, 1.9, L), cf * CFrame.new(sx * (W / 2 + 1.1), 1.35, 0), c, { parent = m, studs = true })
			K.part(V(0.4, 0.3, L - 2), cf * CFrame.new(sx * (W / 2 + 2.05), 1.8, 0), Color3.new(1, 1, 1), { parent = m, neon = true, collide = false })
			-- uprights (lean back toward the runner) + handlebar
			local base = cf * CFrame.new(sx * (W / 2 + 1.1), 2.3, -L / 2 + 1.5)
			K.part(V(1.2, 9, 1.2), base * CFrame.Angles(math.rad(-12), 0, 0) * CFrame.new(0, 4.5, 0), metal, { parent = m, collide = false })
			K.part(V(0.9, 0.9, 8), cf * CFrame.new(sx * (W / 2 + 1.1), 9.6, -L / 2 + 6.5), metal, { parent = m, collide = false })
			K.part(V(1.1, 1.1, 3), cf * CFrame.new(sx * (W / 2 + 1.1), 9.6, -L / 2 + 9.5), c, { parent = m, collide = false })
		end
		-- slim console with a glowing screen facing the runner
		local con = cf * CFrame.new(0, 10.4, -L / 2 + 2.4) * CFrame.Angles(math.rad(35), 0, 0)
		K.part(V(W - 1, 3.2, 0.8), con, Color3.fromRGB(48, 52, 72), { parent = m, collide = false })
		K.part(V(W - 0.6, 0.5, 1), con * CFrame.new(0, 1.7, 0), c, { parent = m, collide = false, neon = true })
		K.part(V(W - 0.6, 0.5, 1), con * CFrame.new(0, -1.7, 0), c, { parent = m, collide = false })
		local screen = K.part(V(W - 3, 2.4, 0.2), con * CFrame.new(0, 0, 0.45), Color3.fromRGB(16, 20, 34), { parent = m, collide = false, name = "Screen" })
		K.textPanel(screen, Enum.NormalId.Back, { { name = "Mult", text = "x" .. tostring(mult) .. " SPEED", h = 0.8, color = c, font = K.FONT_BOLD } }, { pps = 24, stroke = 2 })
		K.light(screen, c, 12, 0.8)
		K.tag(belt, "Treadmill", { World = T.id, Tier = tier, Multiplier = mult })
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- EGG: egg (ellipsoid via SpecialMesh) on a tiered pedestal, pet previews around it, info board
	------------------------------------------------------------------------------------------------------------
	function S.egg(cf, info, T, parent, eggBuilder)
		local m = K.model("Egg_" .. (info.name or "Egg"), parent)
		local glow = info.glow or Color3.fromRGB(255, 170, 60)
		-- round stepped pedestal
		K.cyl(28, 2, (cf * CFrame.new(0, 1, 0)).Position, T.padBase or Color3.fromRGB(70, 70, 95), { parent = m, studs = true })
		K.cyl(25, 1.4, (cf * CFrame.new(0, 2.7, 0)).Position, T.padTrim or Color3.fromRGB(240, 240, 250), { parent = m, studs = true })
		K.cyl(26, 0.4, (cf * CFrame.new(0, 2.1, 0)).Position, glow, { parent = m, neon = true, collide = false })
		local stand = K.cyl(10, 4, (cf * CFrame.new(0, 5.4, 0)).Position, K.shade(glow, 0.8), { parent = m, studs = true })
		K.cyl(11, 0.6, (cf * CFrame.new(0, 7.6, 0)).Position, glow, { parent = m, neon = true, collide = false })
		for i = 0, 3 do -- little glowing posts around the pedestal
			local p = cf * CFrame.Angles(0, rad(45 + i * 90), 0) * CFrame.new(0, 0, -11.5)
			K.part(V(1.4, 4, 1.4), p * CFrame.new(0, 5.4, 0), T.padTrim or Color3.new(1, 1, 1), { parent = m, collide = false })
			K.part(V(1.8, 1.8, 1.8), p * CFrame.new(0, 8.2, 0), glow, { parent = m, shape = "ball", neon = true, collide = false })
		end
		local body = eggBuilder(info.world or "Zoo", cf * CFrame.new(0, 13.6, 0), m)
		K.tag(body, "SpinEgg")
		K.light(body.PrimaryPart, glow, 22, 1.4)
		local sign = K.part(V(1, 1, 1), cf * CFrame.new(0, 26, 0), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Sign" })
		K.billboard(sign, {
			{ name = "Name", text = (info.display or info.name or "Egg"), h = 0.55, grad = { K.shade(glow, 1.4), glow }, font = K.FONT_BOLD, stroke = 4 },
			{ name = "Price", text = info.price and ("🥚 " .. tostring(info.price)) or "", h = 0.45, color = Color3.fromRGB(255, 225, 90), stroke = 3 },
		}, { size = UDim2.fromScale(16, 5.5), offset = V(0, 0, 0), dist = 260 })
		-- the pets are NOT shown in the world: the prompt opens the egg menu (EggMenu client)
		prompt(stand, "Open", info.display or info.name, 0.3, "EggStation", { World = T.id, Egg = info.name or "" })
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- VERSION WHEEL (World 2+): big spinning wheel on a stage (ZooMapClient spins "Wheel" slowly; the real spin is
	-- the game's wheel system). Never built in the Zoo.
	------------------------------------------------------------------------------------------------------------
	function S.wheel(cf, T, parent)
		local m = K.model("VersionWheel", parent)
		local base = T.padBase or Color3.fromRGB(70, 70, 95)
		K.cyl(36, 2, (cf * CFrame.new(0, 1, 0)).Position, base, { parent = m, studs = true })
		K.cyl(30, 1.4, (cf * CFrame.new(0, 2.7, 0)).Position, T.padTrim or Color3.fromRGB(240, 240, 250), { parent = m, studs = true })
		for _, sx in ipairs({ -1, 1 }) do
			K.part(V(3, 26, 4), cf * CFrame.new(sx * 13, 16, 0) * CFrame.Angles(0, 0, rad(sx * 10)), T.metal or Color3.fromRGB(60, 60, 80), { parent = m, studs = true })
		end
		local hub = cf * CFrame.new(0, 27, 0)
		local wheel = K.model("Wheel", m)
		local cols = { Color3.fromRGB(255, 215, 40), Color3.fromRGB(255, 80, 200), Color3.fromRGB(120, 230, 255), Color3.fromRGB(40, 40, 60), Color3.fromRGB(250, 250, 255), Color3.fromRGB(140, 90, 255) }
		local names = { "GOLDEN", "RAINBOW", "DIAMOND", "SHADOW", "CELESTIAL", "COSMIC" }
		local axle = K.part(V(4, 4, 4), hub, Color3.fromRGB(255, 220, 80), { parent = wheel, shape = "ball", collide = false, name = "Axle" })
		for i = 1, 12 do
			local a = (i - 0.5) / 12 * math.pi * 2
			local c = cols[(i - 1) % 6 + 1]
			local seg = K.part(V(5.6, 10.5, 1.4), hub * CFrame.Angles(0, 0, a) * CFrame.new(0, 7, 0), c, { parent = wheel, collide = false, neon = (i % 2 == 0) })
			if i <= 6 then
				local lbl = K.part(V(5, 9, 0.2), hub * CFrame.Angles(0, 0, a) * CFrame.new(0, 7, -0.8), Color3.new(1, 1, 1), { parent = wheel, transp = 1, collide = false })
				K.textPanel(lbl, NF, { { text = names[(i - 1) % 6 + 1], h = 0.25 } }, { pps = 12, stroke = 2 })
			end
		end
		ring(hub * CFrame.new(0, 0, 0), 12.6, 1.6, 2.2, T.gateTrim or Color3.fromRGB(255, 210, 60), 24, { neon = false }, wheel)
		for i = 1, 12 do -- rim bulbs
			local a = i / 12 * math.pi * 2
			K.part(V(1.2, 1.2, 1.2), hub * CFrame.Angles(0, 0, a) * CFrame.new(0, 12.6, -1.2), Color3.fromRGB(255, 250, 220), { parent = wheel, shape = "ball", neon = true, collide = false })
		end
		wheel.PrimaryPart = axle
		K.tag(wheel, "SpinWheelDecor")
		-- pointer
		K.part(V(2, 3.5, 2), hub * CFrame.new(0, 14.2, -1.6) * CFrame.Angles(0, 0, rad(45)), Color3.fromRGB(255, 60, 60), { parent = m, neon = true, collide = false })
		local sign = K.part(V(1, 1, 1), cf * CFrame.new(0, 45, 0), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false })
		K.billboard(sign, { { text = "VERSION WHEEL", h = 1, grad = { Color3.fromRGB(255, 240, 120), Color3.fromRGB(255, 120, 220) }, font = K.FONT_BOLD, stroke = 4 } }, { size = UDim2.fromScale(26, 5), offset = V(0, 0, 0), dist = 400 })
		local trig = K.part(V(10, 6, 10), cf * CFrame.new(0, 6, -10), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Interact" })
		prompt(trig, "Spin", "Version Wheel", 0.6, "WheelStation", { World = T.id })
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- SHOP: kiosk with a striped awning, counter, display goods and a big rooftop icon. style = T.shopStyle(cf, m, info)
	------------------------------------------------------------------------------------------------------------
	-- 3D rooftop icons for shops (spun by the client: tag SpinIcon). Chunky, outlined, readable from far away.
	local function disc(m, d, th, cf, col, o) -- flat cylinder facing the icon's front (-Z)
		o = o or {}; o.parent = m; o.shape = "cyl"; o.collide = false
		return K.part(V(th, d, d), cf * CFrame.Angles(0, rad(90), 0), col, o)
	end
	local function ell(m, size, cf, col, o) -- ellipsoid
		o = o or {}; o.parent = m; o.collide = false
		local part = K.part(V(1, 1, 1), cf, col, o)
		local sm = Instance.new("SpecialMesh"); sm.MeshType = Enum.MeshType.Sphere; sm.Scale = size; sm.Parent = part
		return part
	end
	local function shopIcon(kind, cf, c, parent)
		local m = K.model("ShopIcon", parent)
		local root = K.part(V(1, 1, 1), cf, Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Root" })
		local ink = Color3.fromRGB(30, 20, 30)
		if kind == "paw" then
			-- dog paw: big heart-shaped pad + 4 toe beans, cream fur colour with pink pads and a dark outline
			local fur, pad, padL = Color3.fromRGB(255, 176, 70), Color3.fromRGB(255, 130, 160), Color3.fromRGB(255, 190, 210)
			local shapes = { { 0, -1.1, 5.2 }, { -1.5, -2.1, 3.4 }, { 1.5, -2.1, 3.4 }, { -3.1, 1.3, 2.4 }, { -1.1, 2.9, 2.4 }, { 1.1, 2.9, 2.4 }, { 3.1, 1.3, 2.4 } }
			for _, sh in ipairs(shapes) do disc(m, sh[3] + 0.9, 1.2, cf * CFrame.new(sh[1], sh[2], 0), ink) end              -- outline
			for _, sh in ipairs(shapes) do disc(m, sh[3], 1.8, cf * CFrame.new(sh[1], sh[2], 0), fur, { studs = true }) end -- fur
			for i, sh in ipairs(shapes) do                                                                                  -- pink pads + shine
				local d = (i <= 3) and sh[3] * 0.62 or sh[3] * 0.62
				disc(m, d, 2, cf * CFrame.new(sh[1], sh[2] + ((i <= 3) and 0.2 or 0), 0), pad)
				disc(m, d * 0.32, 2.1, cf * CFrame.new(sh[1] - d * 0.18, sh[2] + d * 0.2, 0), padL, { neon = true })
			end
		elseif kind == "potion" then
			-- round glass flask, glowing liquid, neck with rim, cork, shine streak, bubbles
			local glass = Color3.fromRGB(190, 240, 255)
			ell(m, V(5.2, 5.2, 5.2), cf * CFrame.new(0, -1, 0), glass, { transp = 0.6 })
			ell(m, V(4.6, 3.8, 4.6), cf * CFrame.new(0, -1.5, 0), c, { neon = true })
			ell(m, V(4.5, 0.5, 4.5), cf * CFrame.new(0, 0.2, 0), K.shade(c, 1.35), { neon = true })          -- liquid surface
			K.part(V(2.4, 1.8, 1.8), cf * CFrame.new(0, 2.2, 0) * CFrame.Angles(0, 0, rad(90)), glass, { parent = m, shape = "cyl", transp = 0.45, collide = false })
			K.part(V(0.5, 2.4, 2.4), cf * CFrame.new(0, 3.4, 0) * CFrame.Angles(0, 0, rad(90)), Color3.fromRGB(240, 250, 255), { parent = m, shape = "cyl", collide = false })
			K.part(V(1.4, 1.6, 1.6), cf * CFrame.new(0, 4.2, 0) * CFrame.Angles(0, 0, rad(90)), Color3.fromRGB(176, 112, 60), { parent = m, shape = "cyl", collide = false, studs = true })
			ell(m, V(0.6, 2, 0.4), cf * CFrame.new(-1.3, -0.2, -2.3) * CFrame.Angles(0, 0, rad(-25)), Color3.new(1, 1, 1), { neon = true }) -- shine
			for i, b in ipairs({ { 0.6, -2, 0.5 }, { -0.7, -1.2, 0.4 }, { 0.3, -0.6, 0.3 } }) do
				ell(m, V(b[3] * 2, b[3] * 2, b[3] * 2), cf * CFrame.new(b[1], b[2], -1.2), Color3.new(1, 1, 1), { neon = true, transp = 0.2 })
			end
			local bub = Instance.new("ParticleEmitter"); bub.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			bub.Color = ColorSequence.new(Color3.new(1, 1, 1)); bub.Size = NumberSequence.new(0.3, 0); bub.Rate = 5; bub.Lifetime = NumberRange.new(1, 1.5)
			bub.Speed = NumberRange.new(1, 2); bub.SpreadAngle = Vector2.new(15, 15); bub.EmissionDirection = Enum.NormalId.Top; bub.LightEmission = 1; bub.Parent = root
		else
			-- gem: stepped faceted diamond (table, crown, girdle, pavilion) in alternating light / dark facets
			local light, dark = K.shade(c, 1.15), K.shade(c, 0.7)
			local steps = { { 2.6, 1.9, light }, { 4.2, 1.1, c }, { 5.2, 0.3, light }, { 4.4, -0.5, dark }, { 3.4, -1.3, c }, { 2.3, -2.1, dark }, { 1.2, -2.9, c } }
			for i, st in ipairs(steps) do
				K.part(V(st[1], 1, st[1]), cf * CFrame.new(0, st[2], 0) * CFrame.Angles(0, rad(45), 0), st[3], { parent = m, collide = false, neon = (i == 1 or i == 3 or i == 6), refl = 0.2 })
			end
			ell(m, V(0.5, 1.6, 0.3), cf * CFrame.new(-0.9, 1.4, -1.7) * CFrame.Angles(0, 0, rad(-30)), Color3.new(1, 1, 1), { neon = true })
		end
		m.PrimaryPart = root
		m:ScaleTo(1.7)
		K.sparkle(root, c, { rate = 5, size = 0.9, shape = Enum.ParticleEmitterShape.Sphere })
		K.tag(m, "SpinIcon")
		return m
	end
	S.shopIcon = shopIcon

	function S.shop(cf, info, T, parent)
		local m = K.model("Shop_" .. info.id, parent)
		local c = info.color
		local wall = T.shopWall or Color3.fromRGB(250, 244, 232)
		local trim = Color3.new(1, 1, 1)
		local W, D, H = 30, 20, 13
		-- platform + front steps
		K.part(V(W + 8, 1.4, D + 12), cf * CFrame.new(0, 0.7, 1), T.padBase or Color3.fromRGB(90, 90, 110), { parent = m, studs = true })
		K.part(V(W + 8.4, 0.4, D + 12.4), cf * CFrame.new(0, 0.3, 1), c, { parent = m, neon = true, collide = false })
		K.part(V(W - 6, 0.7, 3), cf * CFrame.new(0, 0.35, -D / 2 - 6.5), T.padBase or Color3.fromRGB(90, 90, 110), { parent = m, studs = true })
		-- walls: back + sides with display windows
		K.part(V(W, H, 1.6), cf * CFrame.new(0, 1.4 + H / 2, D / 2), wall, { parent = m, studs = true })
		for _, sx in ipairs({ -1, 1 }) do
			K.part(V(1.6, H, D), cf * CFrame.new(sx * (W / 2 - 0.8), 1.4 + H / 2, 0), wall, { parent = m, studs = true })
			K.part(V(0.4, 5, D - 6), cf * CFrame.new(sx * (W / 2 + 0.05), 1.4 + H * 0.55, 0), Color3.fromRGB(170, 225, 255), { parent = m, glass = true, transp = 0.35, collide = false })
			-- round corner columns
			K.cyl(3, H + 2, (cf * CFrame.new(sx * W / 2, 1.4 + (H + 2) / 2, -D / 2)).Position, trim, { parent = m })
			K.cyl(3.6, 1, (cf * CFrame.new(sx * W / 2, 1.9, -D / 2)).Position, c, { parent = m, collide = false })
			K.cyl(3.6, 1, (cf * CFrame.new(sx * W / 2, 1.4 + H + 1.5, -D / 2)).Position, c, { parent = m, collide = false })
		end
		-- shelves with goods on the back wall
		for row = 0, 1 do
			local y = 1.4 + 4 + row * 3.6
			K.part(V(W - 6, 0.5, 2.2), cf * CFrame.new(0, y, D / 2 - 1.9), Color3.fromRGB(190, 130, 80), { parent = m, collide = false })
			for i = 0, 5 do
				local gc = ({ c, K.shade(c, 1.3), Color3.fromRGB(255, 220, 80), Color3.fromRGB(120, 220, 255) })[(i + row) % 4 + 1]
				K.part(V(1.6, 2, 1.4), cf * CFrame.new(-W / 2 + 5 + i * (W - 10) / 5, y + 1.25, D / 2 - 1.9), gc, { parent = m, collide = false, neon = (i + row) % 3 == 0 })
			end
		end
		-- counter with a register
		K.part(V(W - 8, 4.4, 3.2), cf * CFrame.new(0, 3.6, -D / 2 + 4), K.shade(c, 0.85), { parent = m, studs = true })
		K.part(V(W - 7.4, 0.6, 3.8), cf * CFrame.new(0, 6.1, -D / 2 + 4), Color3.fromRGB(205, 145, 85), { parent = m })
		K.part(V(3, 2, 2.2), cf * CFrame.new(W / 4, 7.4, -D / 2 + 4), Color3.fromRGB(60, 64, 90), { parent = m, collide = false })
		K.part(V(2.4, 1.2, 0.2), cf * CFrame.new(W / 4, 7.8, -D / 2 + 2.85) * CFrame.Angles(rad(-20), 0, 0), Color3.fromRGB(110, 255, 160), { parent = m, neon = true, collide = false })
		-- roof slab + gable roof (two wedges) + ridge
		K.part(V(W + 4, 1.4, D + 4), cf * CFrame.new(0, 1.4 + H + 0.7, 0), K.shade(c, 0.7), { parent = m, studs = true })
		local rh = 6
		K.part(V(W + 4, rh, (D + 4) / 2), cf * CFrame.new(0, 1.4 + H + 1.4 + rh / 2, -(D + 4) / 4), c, { parent = m, shape = "wedge" })
		K.part(V(W + 4, rh, (D + 4) / 2), cf * CFrame.new(0, 1.4 + H + 1.4 + rh / 2, (D + 4) / 4) * CFrame.Angles(0, math.pi, 0), c, { parent = m, shape = "wedge" })
		K.part(V(W + 5, 1, 1.4), cf * CFrame.new(0, 1.4 + H + 1.4 + rh + 0.3, 0), trim, { parent = m, collide = false })
		-- scalloped awning over the counter
		local stripes = 8
		for i = 1, stripes do
			local x = -W / 2 + (i - 0.5) * (W / stripes)
			local col = (i % 2 == 0) and trim or c
			K.part(V(W / stripes + 0.05, 0.8, 7), cf * CFrame.new(x, 1.4 + H - 1.2, -D / 2 - 2.8) * CFrame.Angles(rad(18), 0, 0), col, { parent = m, collide = false })
			K.part(V(W / stripes * 0.8, W / stripes * 0.8, 0.6), cf * CFrame.new(x, 1.4 + H - 3.4, -D / 2 - 6.1) * CFrame.Angles(0, 0, rad(45)), col, { parent = m, collide = false })
		end
		shopIcon(info.iconKind or "gem", cf * CFrame.new(0, 1.4 + H + 1.4 + rh + 6, 0), c, m)
		local trig = K.part(V(W - 8, 6, 4), cf * CFrame.new(0, 4, -D / 2 + 0.5), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Interact" })
		prompt(trig, "Open", info.title, 0.4, "ShopStation", { World = T.id, Shop = info.id })
		K.light(trig, c, 26, 1)
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- LEADERBOARD: raised stage, 3 framed boards, trophy statue in the middle
	------------------------------------------------------------------------------------------------------------
	function S.trophy(cf, s, parent)
		local m = K.model("Trophy", parent)
		local gold = Color3.fromRGB(255, 200, 50)
		K.part(V(6, 2, 6) * s, cf * CFrame.new(0, 1 * s, 0), Color3.fromRGB(60, 50, 70), { parent = m, studs = true })
		K.cyl(2 * s, 4 * s, (cf * CFrame.new(0, 4 * s, 0)).Position, gold, { parent = m, refl = 0.2 })
		K.cyl(4.2 * s, 1 * s, (cf * CFrame.new(0, 2.5 * s, 0)).Position, gold, { parent = m, refl = 0.2 })
		local cup = K.part(V(7, 7, 7) * s, cf * CFrame.new(0, 9 * s, 0), gold, { parent = m, shape = "ball", refl = 0.25 })
		K.cyl(7.4 * s, 1.4 * s, (cf * CFrame.new(0, 11.6 * s, 0)).Position, K.shade(gold, 1.1), { parent = m, refl = 0.2 })
		for _, sx in ipairs({ -1, 1 }) do
			K.part(V(1.2, 4, 1.2) * s, cf * CFrame.new(sx * 4.4 * s, 9.5 * s, 0), gold, { parent = m, refl = 0.2 })
			K.part(V(2, 1.2, 1.2) * s, cf * CFrame.new(sx * 3.8 * s, 11.2 * s, 0), gold, { parent = m, refl = 0.2 })
			K.part(V(2, 1.2, 1.2) * s, cf * CFrame.new(sx * 3.8 * s, 7.8 * s, 0), gold, { parent = m, refl = 0.2 })
		end
		K.part(V(3, 3, 3) * s, cf * CFrame.new(0, 13.6 * s, 0) * CFrame.Angles(0, 0, rad(45)), Color3.fromRGB(255, 255, 255), { parent = m, neon = true, collide = false })
		K.sparkle(cup, gold, { rate = 4, size = 1.2 })
		return m
	end
	function S.leaderboard(cf, boards, T, parent)
		local m = K.model("Leaderboards", parent)
		local base = T.padBase or Color3.fromRGB(70, 70, 95)
		K.part(V(96, 3, 30), cf * CFrame.new(0, 1.5, 0), base, { parent = m, studs = true })
		K.part(V(90, 1.4, 26), cf * CFrame.new(0, 3.7, 0), T.padTrim or Color3.fromRGB(235, 235, 245), { parent = m, studs = true })
		K.part(V(96.6, 0.6, 30.6), cf * CFrame.new(0, 3, 0), T.gateTrim or Color3.fromRGB(255, 200, 60), { parent = m, neon = true, collide = false })
		-- front steps
		for i = 1, 2 do K.part(V(40, 1.4, 3), cf * CFrame.new(0, 0.7 * i, -15 - (3 - i) * 3), base, { parent = m, studs = true }) end
		for i, b in ipairs(boards) do
			local x = (i - 2) * 31
			local bc = cf * CFrame.new(x, 4.4, 6)
			local frame = T.gateTrim or Color3.fromRGB(255, 200, 60)
			K.part(V(2, 30, 2), bc * CFrame.new(-13, 15, 0), frame, { parent = m, studs = true })
			K.part(V(2, 30, 2), bc * CFrame.new(13, 15, 0), frame, { parent = m, studs = true })
			local panel = K.part(V(24, 26, 1), bc * CFrame.new(0, 16, 0), Color3.fromRGB(30, 28, 50), { parent = m, name = "Board_" .. b.id })
			K.part(V(28, 4, 2.4), bc * CFrame.new(0, 31, 0), b.color, { parent = m, studs = true })
			local head = K.part(V(26, 3.6, 0.2), bc * CFrame.new(0, 31, -1.3), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false })
			K.textPanel(head, NF, { { text = b.title, h = 0.9, font = K.FONT_BOLD } }, { pps = 14, stroke = 3 })
			-- list (filled by LeaderboardService / your existing leaderboard script)
			local g = Instance.new("SurfaceGui"); g.Name = "List"; g.Face = NF; g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			g.PixelsPerStud = 14; g.LightInfluence = 0; g.Parent = panel
			local lay = Instance.new("UIListLayout"); lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Padding = UDim.new(0, 4); lay.Parent = g
			local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0, 10); pad.PaddingLeft = UDim.new(0, 14); pad.PaddingRight = UDim.new(0, 14); pad.Parent = g
			for r = 1, 10 do
				local row = Instance.new("TextLabel"); row.Name = "Row" .. r; row.LayoutOrder = r
				row.Size = UDim2.new(1, 0, 0.088, 0); row.BackgroundTransparency = (r % 2 == 0) and 0.85 or 0.75
				row.BackgroundColor3 = r == 1 and Color3.fromRGB(255, 205, 60) or (r == 2 and Color3.fromRGB(210, 220, 235) or (r == 3 and Color3.fromRGB(220, 140, 80) or Color3.new(1, 1, 1)))
				row.Font = K.FONT; row.TextScaled = true; row.TextXAlignment = Enum.TextXAlignment.Left
				row.TextColor3 = Color3.new(1, 1, 1); row.Text = "  " .. r .. ".  ---"
				local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0, 8); cr.Parent = row
				K.stroke(row, 2)
				row.Parent = g
			end
			K.tag(panel, "LeaderboardBoard", { World = T.id, Stat = b.stat })
			K.light(panel, b.color, 20, 0.8)
		end
		S.trophy(cf * CFrame.new(-46 + 0, 4.4, -6), 0.7, m)
		S.trophy(cf * CFrame.new(46, 4.4, -6), 0.7, m)
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- PORTAL: arch + glowing ring + swirling disc. big = next world (exciting), small = previous world
	------------------------------------------------------------------------------------------------------------
	function S.portal(cf, info, T, parent)
		local m = K.model("Portal_" .. info.kind, parent)
		local big = info.kind == "Next"
		local R = big and 17 or 12
		local c = info.color
		local base = T.padBase or Color3.fromRGB(70, 70, 95)
		K.part(V(R * 2 + 18, 3, 22), cf * CFrame.new(0, 1.5, 0), base, { parent = m, studs = true })
		K.part(V(R * 2 + 12, 1.2, 16), cf * CFrame.new(0, 3.6, 0), T.padTrim or Color3.fromRGB(235, 235, 245), { parent = m, studs = true })
		for i = 1, 3 do K.part(V(R * 1.6, 1, 4), cf * CFrame.new(0, 0.5 + (i - 1), -11 - (3 - i) * 4 + 4), base, { parent = m, studs = true }) end
		local center = cf * CFrame.new(0, 4.2 + R + 1, 0)
		ring(center, R + 1.8, 3.4, 5, T.portalFrame or T.gatePillar or Color3.fromRGB(80, 80, 100), 24, { studs = true, collide = true }, m)
		ring(center * CFrame.new(0, 0, -2.7), R + 0.2, 0.8, 0.6, c, 24, { neon = true }, m)
		ring(center * CFrame.new(0, 0, 2.7), R + 0.2, 0.8, 0.6, c, 24, { neon = true }, m)
		local disc = K.part(V(0.6, R * 2, R * 2), center * CFrame.Angles(0, rad(90), 0), c, { parent = m, shape = "cyl", collide = false, mat = Enum.Material.ForceField, transp = 0.1, name = "Swirl" })
		local disc2 = K.part(V(0.4, R * 2 - 1, R * 2 - 1), center * CFrame.Angles(0, rad(90), 0), K.shade(c, 0.5), { parent = m, shape = "cyl", collide = false, neon = true, transp = 0.45, name = "Core" })
		disc2.CastShadow = false; disc.CastShadow = false
		K.sparkle(disc, c, { rate = big and 30 or 12, size = big and 2 or 1.3, speed = NumberRange.new(4, 9), spread = Vector2.new(20, 20), emitDir = Enum.NormalId.Left, color2 = Color3.new(1, 1, 1) })
		K.light(disc2, c, big and 40 or 24, big and 3 or 1.6)
		K.tag(m, "PortalSpin")
		-- pillars + orbs
		for _, sx in ipairs({ -1, 1 }) do
			local px = cf * CFrame.new(sx * (R + 7), 0, 0)
			K.part(V(4, R * 2 + 8, 4), px * CFrame.new(0, 3 + R + 4, 0), T.gatePillar or base, { parent = m, studs = true })
			K.part(V(5, 5, 5), px * CFrame.new(0, 3 + R * 2 + 10.5, 0), c, { parent = m, shape = "ball", neon = true, collide = false })
		end
		local sign = K.part(V(1, 1, 1), center * CFrame.new(0, R + 9, 0), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Sign" })
		K.billboard(sign, {
			{ name = "Kind", text = big and "NEXT WORLD" or "PREVIOUS WORLD", h = 0.38, color = Color3.new(1, 1, 1), stroke = 3 },
			{ name = "World", text = info.title, h = 0.62, grad = { K.shade(c, 1.5), c }, font = K.FONT_BOLD, stroke = 5 },
		}, { size = big and UDim2.fromScale(30, 10) or UDim2.fromScale(20, 7), offset = V(0, 0, 0), dist = big and 600 or 300 })
		local trig = K.part(V(R * 2, 8, 6), cf * CFrame.new(0, 8, -6), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Interact" }) -- at walking height in front of the ring
		prompt(trig, "Travel", info.title, 0.8, "WorldPortal", { World = T.id, Target = info.target, Kind = info.kind })
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- PREMIUM ANIMAL PAD (Alpha animals): glowing pad + model + name/bonus/price billboard
	------------------------------------------------------------------------------------------------------------
	function S.premiumPad(cf, info, T, parent)
		local m = K.model("Premium_" .. info.title:gsub("%s", ""), parent)
		local c = info.color
		K.part(V(22, 1.6, 22), cf * CFrame.new(0, 0.8, 0), Color3.fromRGB(255, 160, 30), { parent = m, studs = true })
		K.part(V(23, 0.6, 23), cf * CFrame.new(0, 0.3, 0), Color3.fromRGB(255, 230, 80), { parent = m, neon = true, collide = false })
		local top = K.part(V(18, 0.8, 18), cf * CFrame.new(0, 2, 0), Color3.fromRGB(255, 225, 60), { parent = m, studs = true })
		K.sparkle(top, Color3.fromRGB(255, 240, 150), { rate = 10, size = 1, speed = NumberRange.new(2, 5), accel = V(0, 3, 0), emitDir = Enum.NormalId.Top, spread = Vector2.new(30, 30), shape = Enum.ParticleEmitterShape.Box })
		if info.model then K.display("Animals", info.model, cf * CFrame.new(0, 2.4, 0), info.scale or 1.2, { parent = m, variant = info.variant }) end
		local sign = K.part(V(1, 1, 1), cf * CFrame.new(0, 2, 0), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Sign" })
		K.billboard(sign, {
			{ text = info.title, h = 0.4, color = c, font = K.FONT_BOLD, stroke = 3 },
			{ text = info.bonus, h = 0.32, color = Color3.new(1, 1, 1), stroke = 2 },
			{ text = info.price, h = 0.28, color = Color3.fromRGB(110, 255, 120), stroke = 2 },
		}, { size = UDim2.fromScale(16, 6), offset = V(0, info.signY or 18, 0), dist = 260 })
		local pp = prompt(top, "Buy", info.title, 0.5, "PremiumAnimal", { Animal = info.model or "", Title = info.title })
		return m
	end

	return S
end
