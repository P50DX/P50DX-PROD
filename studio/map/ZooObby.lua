-- World 1 obby: "Escape the Zoo". Zoo-themed hazards (giant crates, cage walls, zookeeper nets, a giant
-- striped play-ball), zoo moat underneath, cliffs with trees on both sides. 10 stages, each longer than the last.
-- Chases: stages 3, 5, 9. Rolling ball: 6 (+ finale). Nets: 8 (+ finale).
return function(K, P, S, Obby, cfg, O, hubT)
	local V = Vector3.new
	local rad = math.rad
	local rgb = K.rgb
	local W = cfg.Worlds[1]
	local root = K.folder("World1_Zoo", workspace)
	K.seed(202)

	local T = setmetatable({}, { __index = hubT })
	T.plat = { rgb(236, 222, 196), rgb(84, 190, 178), rgb(250, 166, 80), rgb(146, 210, 118) }
	T.rim = rgb(104, 82, 72); T.trim = rgb(255, 140, 40)
	T.gateFloor = rgb(214, 204, 186); T.rewardFloor = rgb(236, 222, 190)
	function T.support(cf, w, l, parent) -- stone column with orange zoo bands, down into the moat
		local cw, cl = math.max(8, w * 0.42), math.max(8, l * 0.42)
		local depth = 46
		K.part(V(cw, depth, cl), cf * CFrame.new(0, -depth / 2, 0), K.jitter(rgb(170, 150, 130), 0.03), { parent = parent, studs = true, name = "Column" })
		K.part(V(cw + 1, 2, cl + 1), cf * CFrame.new(0, -6, 0), T.trim, { parent = parent, collide = false, name = "Band" })
		K.part(V(cw + 3, 4, cl + 3), cf * CFrame.new(0, -depth + 6, 0), rgb(130, 112, 98), { parent = parent, studs = true, collide = false, name = "Foot" })
	end
	T.hazard = rgb(255, 72, 60); T.hazardDark = rgb(62, 52, 64); T.warn = rgb(255, 60, 40); T.metal = rgb(62, 68, 92)
	T.moverCol = rgb(70, 180, 255); T.blinkCol = rgb(190, 130, 255); T.collapseCol = rgb(222, 168, 112)
	T.laneCol = rgb(214, 184, 140); T.pocketCol = rgb(90, 220, 110)
	T.titleGrad = { rgb(255, 255, 150), rgb(110, 225, 70) }
	local wood, rope = rgb(186, 124, 70), rgb(70, 56, 46)

	function T.crusher(c, w, cell, parent) -- giant shipping crate with a striped steel foot
		local m = K.model("Crusher", parent)
		local top = c * CFrame.new(0, 32, 0)
		local L = cell - 6
		local body = K.part(V(w - 6, 16, L), top * CFrame.new(0, 8, 0), wood, { parent = m, mat = Enum.Material.WoodPlanks, name = "Crate" })
		for _, sx in ipairs({ -1, 1 }) do
			K.part(V(1.2, 16.2, L + 0.2), top * CFrame.new(sx * ((w - 6) / 2 - 0.4), 8, 0), K.shade(wood, 0.65), { parent = m, collide = false })
		end
		K.part(V(w - 5.8, 1.2, L + 0.2), top * CFrame.new(0, 15.6, 0), K.shade(wood, 0.65), { parent = m, collide = false })
		local lbl = K.part(V(w - 10, 8, 0.2), top * CFrame.new(0, 9, L / 2 + 0.15), Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false })
		K.textPanel(lbl, Enum.NormalId.Back, { { text = "⚠ ZOO SUPPLIES", h = 0.5, color = rgb(255, 230, 120) } }, { pps = 10, stroke = 3 })
		local foot = K.part(V(w - 4, 2.4, L + 2), top * CFrame.new(0, -1.2, 0), rgb(255, 205, 40), { parent = m, name = "Foot", collide = false, tag = "HazardKill" })
		for i = -2, 2 do
			K.part(V(2.2, 2.5, L + 2.1), top * CFrame.new(i * (w - 4) / 5, -1.2, 0) * CFrame.Angles(0, 0, rad(30)), rgb(40, 40, 50), { parent = m, collide = false })
		end
		-- shadow marker on the floor so players can read where it lands
		local mk = K.part(V(w - 6, 0.2, L), c * CFrame.new(0, 0.12, 0), rgb(255, 80, 60), { parent = parent, collide = false, transp = 0.55, name = "CrushZone" })
		mk.CastShadow = false
		m.PrimaryPart = body
		return m
	end

	function T.slidingWall(c, w, parent) -- cage panel: frame + bars
		local m = K.model("CageWall", parent)
		local ww, hh = 22, 16
		local frame = K.part(V(ww, 1.4, 2), c * CFrame.new(0, hh, 0), T.metal, { parent = m, collide = false, tag = "HazardKill", name = "Frame" })
		K.part(V(ww, 1.4, 2), c * CFrame.new(0, 0.9, 0), T.metal, { parent = m, collide = false, tag = "HazardKill" })
		for i = 0, 8 do
			K.part(V(0.7, hh, 0.7), c * CFrame.new(-ww / 2 + 0.6 + i * (ww - 1.2) / 8, hh / 2 + 0.5, 0), rgb(200, 205, 220), { parent = m, collide = false, tag = "HazardKill" })
		end
		K.part(V(3, 3, 3), c * CFrame.new(0, hh + 2, 0), T.hazard, { parent = m, neon = true, collide = false })
		-- rails it slides on
		K.part(V(w, 0.6, 3), c * CFrame.new(0, 0.3, 0), rgb(40, 40, 50), { parent = parent, collide = false })
		m.PrimaryPart = frame
		return m
	end

	function T.net(c, arm, parent) -- giant zookeeper net on a pendulum (pivot on top, swings across the path)
		local m = K.model("GiantNet", parent)
		local hoopR = 11
		local pivotY = arm + 12
		local pivot = c * CFrame.new(0, pivotY, 0)
		-- support frame (static, not in the model)
		for _, sx in ipairs({ -1, 1 }) do
			K.part(V(5, pivotY + 56, 5), c * CFrame.new(sx * 40, (pivotY + 6) / 2 - 25, 0), T.metal, { parent = parent, studs = true }) -- down into the moat, no floating towers
			K.part(V(7, 3, 7), c * CFrame.new(sx * 40, pivotY + 7.5, 0), T.trim, { parent = parent, studs = true })
		end
		K.part(V(86, 4, 5), c * CFrame.new(0, pivotY + 4, 0), T.metal, { parent = parent, studs = true })
		local hinge = K.part(V(4, 4, 4), pivot, T.trim, { parent = m, name = "Hinge", collide = false })
		hinge.Shape = Enum.PartType.Ball
		-- pole (the handle)
		local poleLen = arm - hoopR
		K.part(V(1.8, poleLen, 1.8), pivot * CFrame.new(0, -poleLen / 2, 0), wood, { parent = m, collide = false })
		K.part(V(2.4, 3, 2.4), pivot * CFrame.new(0, -poleLen + 1.5, 0), T.metal, { parent = m, collide = false })
		-- ropes from the hinge to the hoop sides
		for _, sz in ipairs({ -1, 1 }) do
			local a, b = pivot.Position, (pivot * CFrame.new(0, -arm, sz * hoopR * 0.9)).Position
			K.part(V(0.35, 0.35, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), rope, { parent = m, collide = false })
		end
		-- hoop in the path's cross-section (YZ plane), then the net bag trailing sideways
		local hc = pivot * CFrame.new(0, -arm, 0)
		local n = 16
		for i = 1, n do
			local ang = (i - 0.5) / n * math.pi * 2
			local seg = 2 * hoopR * math.tan(math.pi / n) + 0.2
			K.part(V(1.4, 1.4, seg), hc * CFrame.Angles(ang, 0, 0) * CFrame.new(0, hoopR, 0), T.trim, { parent = m, collide = false, tag = "HazardKill", name = "Hoop" })
		end
		for k = -3, 3 do -- mesh across the hoop
			local half = math.sqrt(math.max(0, hoopR * hoopR - (k * 3) ^ 2))
			K.part(V(0.3, half * 2, 0.3), hc * CFrame.new(0, 0, k * 3), rgb(245, 245, 240), { parent = m, collide = false, tag = "HazardKill", name = "Mesh" })
			K.part(V(0.3, 0.3, half * 2), hc * CFrame.new(0, k * 3, 0), rgb(245, 245, 240), { parent = m, collide = false, tag = "HazardKill", name = "Mesh" })
		end
		for d = 1, 3 do -- bag: shrinking rings + lines
			local rr = hoopR * (1 - d * 0.24)
			for _, sx in ipairs({ -1, 1 }) do
				local bc = hc * CFrame.new(sx * d * 3.2, 0, 0)
				for i = 1, 10 do
					local ang = (i - 0.5) / 10 * math.pi * 2
					K.part(V(0.3, 0.3, 2 * rr * math.tan(math.pi / 10) + 0.1), bc * CFrame.Angles(ang, 0, 0) * CFrame.new(0, rr, 0), rgb(240, 240, 235), { parent = m, collide = false })
				end
			end
		end
		m.PrimaryPart = hinge
		return m
	end

	function T.boulder(cf, r, parent) -- giant red/white/blue play-ball
		local m = K.model("GiantBall", parent)
		local ball = K.part(V(r * 2, r * 2, r * 2), cf, rgb(235, 60, 60), { parent = m, shape = "ball", collide = false, name = "Ball", tag = "HazardKill" })
		for i, c in ipairs({ rgb(250, 250, 250), rgb(60, 140, 255) }) do
			K.part(V(r * 0.5, r * 2 + 0.15, r * 2 + 0.15), cf * CFrame.Angles(0, 0, rad(i == 1 and 0 or 90)), c, { parent = m, shape = "cyl", collide = false })
		end
		K.part(V(r * 0.5, r * 2 + 0.3, r * 2 + 0.3), cf * CFrame.Angles(0, rad(90), 0), rgb(255, 215, 40), { parent = m, shape = "cyl", collide = false })
		m.PrimaryPart = ball
		return m
	end

	function T.dispenser(c, laneW, r, parent) -- elephant-enclosure toy chute where the ball appears
		local m = K.model("BallDispenser", parent)
		for _, sx in ipairs({ -1, 1 }) do
			K.part(V(8, 110, 10), c * CFrame.new(sx * (laneW / 2 + 5), 5, 6), T.gatePillar, { parent = m, studs = true })
			K.part(V(10, 3, 12), c * CFrame.new(sx * (laneW / 2 + 5), 61.5, 6), T.trim, { parent = m, studs = true })
		end
		local top = K.part(V(laneW + 20, 10, 12), c * CFrame.new(0, 56, 6), T.hazard, { parent = m, studs = true })
		K.textPanel(top, Enum.NormalId.Front, { { text = "⚠ GIANT BALL ⚠", h = 0.8, color = rgb(255, 240, 120), font = K.FONT_BOLD } }, { pps = 8, stroke = 4 })
		local glow = K.part(V(laneW - 4, 1, 4), c * CFrame.new(0, 50.5, 4), rgb(255, 220, 80), { parent = m, neon = true, collide = false, name = "SpawnGlow" })
		K.tag(glow, "BallSpawnGlow")
	end

	function T.bridge(cf, l, w, parent) -- wooden rope bridge (continuous planks so the Zookeeper can follow)
		local n = math.floor(l / 3.2)
		for i = 0, n - 1 do
			local z = -(i + 0.5) * (l / n)
			K.part(V(w, 1.6, l / n - 0.25), cf * CFrame.new(0, -0.8, z) * CFrame.Angles(0, rad((i % 3 - 1) * 1.2), 0), K.jitter(wood, 0.04), { parent = parent, mat = Enum.Material.WoodPlanks, name = "Plank" })
		end
		K.part(V(w + 2, 1, l), cf * CFrame.new(0, -2, -l / 2), rope, { parent = parent, name = "BridgeBase" })
		for _, sx in ipairs({ -1, 1 }) do
			for i = 0, math.floor(l / 16) do
				K.part(V(1.4, 7, 1.4), cf * CFrame.new(sx * (w / 2 + 0.5), 3.5, -i * l / math.floor(l / 16)), rgb(120, 82, 52), { parent = parent })
			end
			K.part(V(0.5, 0.5, l), cf * CFrame.new(sx * (w / 2 + 0.5), 6.4, -l / 2), rope, { parent = parent, collide = false })
			K.part(V(0.5, 0.5, l), cf * CFrame.new(sx * (w / 2 + 0.5), 3.6, -l / 2), rope, { parent = parent, collide = false })
		end
	end

	function T.edgeProps(cf, l, w, parent)
		for i = 1, math.max(1, math.floor(l / 40)) do
			local sx = K.chance(0.5) and 1 or -1
			local c = cf * CFrame.new(sx * (w / 2 - 5), 0, -K.rand(6, l - 6)) * CFrame.Angles(0, rad(K.rand(0, 40)), 0)
			if K.chance(0.5) then P.crate(c, K.rand(0.9, 1.3), T, parent) else P.barrel(c.Position, T, parent) end
		end
	end

	function T.rewardDecor(cf, parent)
		for _, sx in ipairs({ -1, 1 }) do
			P.banner((cf * CFrame.new(sx * 50, 0, -40)).Position, sx > 0 and 180 or 0, sx > 0 and T.accent2 or T.accent, "🏆", T, parent)
			for i = 1, 3 do -- balloon bunches
				local p = (cf * CFrame.new(sx * 52, 0, 30 - i * 6)).Position
				K.part(V(0.2, 14 + i * 2, 0.2), CFrame.new(p + V(0, 7 + i, 0)), rgb(240, 240, 240), { parent = parent, collide = false })
				K.part(V(4, 4.8, 4), CFrame.new(p + V(0, 15 + i * 2, 0)), K.pick({ rgb(255, 80, 120), rgb(255, 210, 60), rgb(80, 180, 255), rgb(150, 230, 100) }), { parent = parent, shape = "ball", collide = false })
			end
		end
	end

	function T.startDecor(cf, parent) -- Alpha (premium) animals before Stage 1, like the original
		local pads = {
			{ title = "Alpha Ostrich", bonus = "2x Best Animal Speed", price = "R$ 99", model = "Ostrich", color = rgb(255, 210, 60), x = -52, z = -30 },
			{ title = "Alpha Wolf", bonus = "5x Best Animal Speed", price = "R$ 299", model = "Wolf", color = rgb(170, 110, 255), x = -52, z = -62 },
			{ title = "Alpha Raptor", bonus = "10x Best Animal Speed", price = "R$ 799", model = "SandLizard", scale = 2.2, color = rgb(80, 180, 255), x = -52, z = -94 },
			{ title = "Alpha Trex", bonus = "25x Best Animal Speed", price = "R$ 1699", model = "TRex", color = rgb(255, 90, 160), x = 52, z = -40 },
			{ title = "Alpha Dragon", bonus = "50x Best Animal Speed", price = "R$ 2999", model = "Dragon", color = rgb(255, 200, 40), x = 52, z = -84, signY = 20 },
		}
		for _, p in ipairs(pads) do
			S.premiumPad(cf * CFrame.new(p.x, 0, p.z) * CFrame.Angles(0, rad(p.x < 0 and -90 or 90), 0), p, T, parent)
		end
		local sign = K.part(V(1, 1, 1), cf * CFrame.new(0, 64, -100), Color3.new(1, 1, 1), { parent = parent, transp = 1, collide = false })
		K.billboard(sign, { { text = "ESCAPE THE ZOO!", h = 1, grad = { rgb(255, 250, 160), rgb(255, 140, 40) }, font = K.FONT_BOLD, stroke = 5 } }, { size = UDim2.fromScale(50, 8), offset = V(0, 0, 0), dist = 500 })
	end

	function T.underlay(centre, from, y, parent) -- the zoo moat
		local water = rgb(70, 190, 210)
		for i = math.max(1, from), #centre - 1 do
			local a, b = centre[i].cf.Position, centre[i + 1].cf.Position
			local d = V(b.X - a.X, 0, b.Z - a.Z)
			if d.Magnitude > 4 then
				local m = V((a.X + b.X) / 2, y, (a.Z + b.Z) / 2)
				local p = K.part(V(170, 2, d.Magnitude + 40), CFrame.lookAt(m, m + d), water, { parent = parent, collide = false, transp = 0.15, mat = Enum.Material.Glass, name = "Moat" })
				p.CastShadow = false
			end
		end
	end

	local wallPal = { height = 95, depth = 30, step = 26, rock = T.rock, top = T.top, trees = 0.18, bushes = 0.35, treeKind = { "oak", "pine", "round" }, treePal = T.treePal, overhang = 0.35 }
	function T.walls(centre, parent)
		local Y = V(0, 1, 0)
		local pts = {}
		for i = 1, #centre, 6 do table.insert(pts, centre[i].cf.Position) end
		table.insert(pts, centre[#centre].cf.Position)
		P.backdrop(pts, T.hills, parent.Parent)
		for i = 1, #centre - 1 do
			local A, B = centre[i], centre[i + 1]
			local a, b = A.cf.Position, B.cf.Position
			local d = V(b.X - a.X, 0, b.Z - a.Z)
			local hw = math.max(A.hw, B.hw)
			if d.Magnitude > 4 then
				local r = d.Unit:Cross(Y)
				local base = math.min(a.Y, b.Y) - 55
				local h = math.max(a.Y, b.Y) - base + 30
				local o = table.clone(wallPal); o.height = h
				o.inward = r
				P.cliff(V(a.X, base, a.Z) - r * hw, V(b.X, base, b.Z) - r * hw, o, parent)
				o.inward = -r
				P.cliff(V(b.X, base, b.Z) + r * hw, V(a.X, base, a.Z) + r * hw, o, parent)
			elseif A.cf.LookVector:Dot(B.cf.LookVector) < 0.995 then -- a turn: rock columns close the outside corners
				for _, sx in ipairs({ -1, 1 }) do
					local p = A.cf * CFrame.new(sx * (hw + 14), 0, 0)
					K.part(V(36, a.Y - (a.Y - 55) + 30, 36), CFrame.new(p.Position + V(0, -12.5, 0)) * CFrame.Angles(0, rad(K.rand(0, 45)), 0), T.rock[1], { parent = parent, studs = true })
					K.part(V(38, 2.4, 38), CFrame.new(p.Position + V(0, 31, 0)) * CFrame.Angles(0, rad(K.rand(0, 45)), 0), T.top, { parent = parent, studs = true })
				end
			end
		end
	end

	function T.finish(cf, parent, addCentre)
		K.slab(V(140, 4, 120), cf * CFrame.new(0, -2, -60), rgb(255, 230, 140), { parent = parent, rim = T.rim })
		S.trophy(cf * CFrame.new(0, 0, -70), 2.6, parent)
		local sign = K.part(V(1, 1, 1), cf * CFrame.new(0, 50, -70), Color3.new(1, 1, 1), { parent = parent, transp = 1, collide = false })
		K.billboard(sign, { { text = "YOU ESCAPED THE ZOO!", h = 1, grad = { rgb(255, 255, 170), rgb(255, 170, 40) }, font = K.FONT_BOLD, stroke = 5 } }, { size = UDim2.fromScale(60, 9), offset = V(0, 0, 0), dist = 700 })
		local pad = K.part(V(24, 1, 24), cf * CFrame.new(0, 0.5, -110), rgb(80, 210, 255), { parent = parent, neon = true, name = "ReturnPad", touch = true })
		K.tag(pad, "ReturnPad", { World = T.id })
		K.billboard(pad, { { text = "BACK TO THE ZOO", h = 1, color = Color3.new(1, 1, 1), font = K.FONT_BOLD, stroke = 3 } }, { size = UDim2.fromScale(20, 3), offset = V(0, 8, 0) })
		addCentre(cf, 80)
		addCentre(cf * CFrame.new(0, 0, -120), 80)
	end

	--------------------------------------------------------------------------------------------------------------
	-- The 10 stages
	--------------------------------------------------------------------------------------------------------------
	local plan = {
		{ kind = "Course", sections = { -- 1: introduction (~260)
			{ "run", { len = 24, props = true } },
			{ "jumps", { n = 3, gap = 5, l = 40, w = 46 } },
			{ "jumps", { n = 1, gap = 6, l = 36, w = 44, dy = 4 } },
		} },
		{ kind = "Course", sections = { -- 2: moving platform + first sweeper (~400)
			{ "run", { len = 30 } },
			{ "jumps", { n = 2, gap = 7, l = 38, dx = 8 } },
			{ "mover", { gap = 56, axis = "z", period = 4.5 } },
			{ "sweeper", { len = 64, speed = 60 } },
			{ "ramp", { len = 50, rise = 12 } },
			{ "jumps", { n = 3, gap = 7, l = 36, dy = 4 } },
		} },
		{ kind = "Chase", sections = { -- 3: Zookeeper chase #1 (~520)
			{ "chase", { route = {
				{ "run", 90, 48, props = true }, { "turn", 30 }, { "run", 70 }, { "ramp", 50, 14 }, { "run", 50 },
				{ "turn", -45 }, { "bridge", 80, 32 }, { "run", 40 }, { "turn", 15 }, { "run", 70, 48, props = true },
			} } },
		} },
		{ kind = "Course", sections = { -- 4: crushers, blinking + collapsing platforms (~640)
			{ "jumps", { n = 2, gap = 7, l = 40 } },
			{ "crushers", { n = 3, period = 3.4 } },
			{ "blink", { n = 5, period = 4 } },
			{ "ramp", { len = 40, rise = 10 } },
			{ "sweeper", { len = 70, speed = 75, arms = 2 } },
			{ "collapse", { n = 4 } },
			{ "climb", { n = 4, step = 5 } },
		} },
		{ kind = "Chase", sections = { -- 5: Zookeeper chase #2 (~760)
			{ "chase", { route = {
				{ "run", 70, 48 }, { "sweeper", 64, 55 }, { "turn", -35 }, { "ramp", 60, 16 }, { "run", 60 }, { "bridge", 90, 32 },
				{ "turn", 40 }, { "walls", 2 }, { "run", 60 }, { "ramp", 50, -10 }, { "turn", -20 }, { "run", 80, 48, props = true },
			} } },
		} },
		{ kind = "Ball", sections = { -- 6: giant rolling ball with safe pockets (~820)
			{ "run", { len = 30 } },
			{ "ball", { len = 680, rise = 64, speed = 80, pocketEvery = 72 } },
			{ "jumps", { n = 3, gap = 7, l = 40, dx = 8 } },
		} },
		{ kind = "Course", sections = { -- 7: long mixed course (~1000)
			{ "climb", { n = 5, step = 5, dx = 8 } },
			{ "jumps", { n = 3, gap = 7, l = 36, dx = 10 } },
			{ "turn", { deg = 25 } },
			{ "mover", { gap = 60, axis = "x", amp = 20, period = 3.6 } },
			{ "crushers", { n = 4, period = 3, offset = 0.25 } },
			{ "blink", { n = 5, period = 3.6 } },
			{ "turn", { deg = -25 } },
			{ "collapse", { n = 4, delay = 0.6 } },
			{ "walls", { n = 3 } },
		} },
		{ kind = "Nets", sections = { -- 8: giant swinging zookeeper nets (~1080)
			{ "nets", { n = 8, gap = 7, l = 46, period = 3.4 } },
			{ "turn", { deg = -20 } },
			{ "mover", { gap = 56, axis = "z", period = 4.2 } },
			{ "nets", { n = 7, gap = 7, l = 42, period = 2.9, offset = 0.37 } },
			{ "climb", { n = 4, step = 5 } },
		} },
		{ kind = "Chase", sections = { -- 9: hard chase with combined hazards (~1200)
			{ "chase", { route = {
				{ "run", 60, 48 }, { "sweeper", 64, 70 }, { "ramp", 60, 18 }, { "turn", 35 }, { "walls", 3 }, { "bridge", 100, 30 },
				{ "turn", -50 }, { "run", 50 }, { "sweeper", 64, 80 }, { "ramp", 60, -14 }, { "turn", 25 }, { "walls", 2 },
				{ "run", 60 }, { "bridge", 80, 30 }, { "turn", -10 }, { "run", 80 }, { "sweeper", 64, 85 }, { "bridge", 90, 30 },
				{ "turn", 20 }, { "run", 90, 48, props = true },
			} } },
		} },
		{ kind = "Finale", sections = { -- 10: massive finale, everything together (~1500)
			{ "jumps", { n = 3, gap = 7, l = 38, dx = 10, dy = 4 } },
			{ "crushers", { n = 4, period = 2.8, offset = 0.22 } },
			{ "jumps", { n = 3, gap = 7, l = 36, dx = 10 } },
			{ "nets", { n = 5, gap = 7, l = 44, period = 3 } },
			{ "turn", { deg = 30 } },
			{ "ball", { len = 340, rise = 34, speed = 85, pocketEvery = 66 } },
			{ "mover", { gap = 64, axis = "z", period = 4 } },
			{ "blink", { n = 4, period = 3.2 } },
			{ "collapse", { n = 4, delay = 0.55 } },
			{ "turn", { deg = -30 } },
			{ "walls", { n = 3, period = 3.2 } },
			{ "sweeper", { len = 72, speed = 90, arms = 2 } },
			{ "climb", { n = 6, step = 5, dx = 6 } },
		} },
	}

	local startCf = CFrame.new(O + V(0, 0, -170))
	local endCf = Obby.build(T, W, startCf, plan, root)
	return T, endCf
end
