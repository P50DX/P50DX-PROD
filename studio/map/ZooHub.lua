-- World 1 hub: the Zoo. Layout follows the overhead screenshot: obby north, speed upgrades north-west,
-- leaderboards north, zoo entrance (previous-world slot) south-west, eggs west of the fountain, shops south,
-- golden Cheetah statue east of the fountain (the Zoo has NO Version Wheel), treadmills east, next world south-east.
return function(K, P, S, cfg, O)
	local V = Vector3.new
	local rad = math.rad
	local W = cfg.Worlds[1]
	local rgb = K.rgb
	local root = K.folder("World1_Zoo", workspace)
	for _, c in root:GetChildren() do if c.Name == "Hub" then c:Destroy() end end
	local hub = K.folder("Hub", root)
	K.seed(101)

	local T = {
		id = 1,
		grass = rgb(92, 188, 74), grass2 = rgb(118, 206, 88),
		path = rgb(236, 214, 170), path2 = rgb(222, 196, 150), curb = rgb(250, 246, 236),
		rock = { rgb(158, 112, 82), rgb(186, 138, 100) }, top = rgb(96, 192, 76),
		wood = rgb(186, 124, 70), metal = rgb(52, 58, 82), gold = rgb(255, 200, 50),
		accent = rgb(255, 140, 40), accent2 = rgb(40, 170, 230),
		gatePillar = rgb(238, 226, 200), gateTrim = rgb(255, 150, 40), gateField = rgb(80, 210, 255),
		padBase = rgb(84, 92, 118), padTrim = rgb(244, 240, 230), metal2 = rgb(80, 86, 110),
		shopWall = rgb(250, 244, 230), portalFrame = rgb(238, 226, 200),
		treePal = { trunk = rgb(132, 86, 52), leaf = rgb(72, 172, 66), leaf2 = rgb(116, 206, 84), flower = rgb(255, 120, 150) },
		palmPal = { trunk = rgb(160, 112, 70), leaf = rgb(70, 180, 80), leaf2 = rgb(110, 210, 90) },
	}
	T.gateCrown = function(cf, m) -- paw lantern on top of zoo gate pillars
		K.part(V(6, 6, 6), cf * CFrame.new(0, 3, 0), T.gateTrim, { parent = m, studs = true, collide = false })
		K.part(V(4.4, 4.4, 4.4), cf * CFrame.new(0, 3, 0), rgb(255, 230, 150), { parent = m, neon = true, collide = false })
		K.part(V(7, 1.2, 7), cf * CFrame.new(0, 6.6, 0), T.gatePillar, { parent = m, studs = true, collide = false })
	end
	T.hills = { base = rgb(150, 112, 84), grass = rgb(98, 182, 82), grass2 = rgb(120, 196, 96), floor = rgb(84, 158, 92), floorY = -160, tree = { "pine", "oak" } }
	S.ZooTheme = T

	local function at(x, y, z) return O + V(x, y, z) end
	local function cfAt(x, z, yaw, y) return CFrame.new(at(x, y or 0, z)) * CFrame.Angles(0, rad(yaw or 0), 0) end
	local function face(x, z, tx, tz) -- cf at (x,z) whose -Z points toward (tx,tz)
		return CFrame.lookAt(at(x, 0, z), at(tx, 0, tz))
	end

	local HX, HZ = 210, 170 -- half extents of the playable hub
	------------------------------------------------------------------------------------------------------------
	-- Ground: grass, paths with curbs, plaza
	------------------------------------------------------------------------------------------------------------
	K.parent = K.folder("Ground", hub)
	K.part(V(HX * 2 + 80, 24, HZ * 2 + 80), CFrame.new(at(0, -12, 0)), T.grass, { studs = true, name = "Grass" })
	for i = 1, 22 do -- lighter / darker grass patches so the lawn is not one flat colour
		local w, d = K.rand(18, 40), K.rand(18, 40)
		local x, z = K.rand(-HX + 20, HX - 20), K.rand(-HZ + 20, HZ - 20)
		if math.abs(x) > 24 and math.abs(z) > 20 then
			K.block(V(w, 0.3, d), at(x, 0.15, z), K.jitter(K.chance(0.5) and T.grass2 or K.shade(T.grass, 0.94), 0.02), { studs = true, ry = K.rand(0, 90), collide = false, name = "Patch" })
		end
	end
	local function path(x1, z1, x2, z2, w)
		local a, b = at(x1, 0, z1), at(x2, 0, z2)
		local len = (b - a).Magnitude
		local cf = CFrame.lookAt((a + b) / 2, b)
		local tiles = math.floor(len / 12)
		for i = 0, tiles - 1 do
			for j = 0, 1 do
				local c = ((i + j) % 2 == 0) and T.path or T.path2
				K.part(V(w / 2, 0.6, len / tiles), cf * CFrame.new((j - 0.5) * w / 2, 0.3, -len / 2 + (i + 0.5) * len / tiles), c, { studs = true, name = "Path" })
			end
		end
		for _, sx in ipairs({ -1, 1 }) do
			K.part(V(1.6, 1, len), cf * CFrame.new(sx * (w / 2 + 0.8), 0.5, 0), T.curb, { studs = true, name = "Curb", collide = false })
		end
	end
	path(0, 110, 0, 52, 34)   -- spawn / shops to plaza
	path(0, -52, 0, -HZ - 6, 34) -- plaza to obby
	path(-52, 0, -140, 0, 26) -- west (to the savanna pen)
	path(52, 0, 104, 0, 26)   -- east (to the training centre)
	-- diagonal side paths to the corners
	path(-36, 36, -128, 112, 20)
	path(36, 36, 128, 112, 20)
	path(-36, -36, -110, -98, 20)
	path(36, -36, 110, -88, 20)
	-- plaza discs (fountain square)
	K.cyl(112, 0.7, at(0, 0.35, 0), T.curb, { name = "PlazaRim" })
	K.cyl(108, 0.75, at(0, 0.4, 0), T.path, { name = "Plaza" })
	K.cyl(84, 0.8, at(0, 0.45, 0), rgb(214, 220, 232), { name = "PlazaInner" })
	K.cyl(80, 0.85, at(0, 0.48, 0), rgb(240, 240, 246), { name = "PlazaInner2" })
	for i = 0, 7 do -- radial stone spokes
		K.part(V(1.4, 0.9, 40), CFrame.new(at(0, 0.5, 0)) * CFrame.Angles(0, rad(i * 45 + 22.5), 0) * CFrame.new(0, 0, -34), T.path2, { collide = false, name = "Spoke" })
	end

	------------------------------------------------------------------------------------------------------------
	-- Fountain with the golden Cheetah (face of the game)
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("Fountain", hub)
	local stone, gold = rgb(236, 230, 218), T.gold
	for i = 0, 7 do -- octagonal basin wall
		K.part(V(14.6, 3.6, 3), CFrame.new(at(0, 1.8, 0)) * CFrame.Angles(0, rad(i * 45), 0) * CFrame.new(0, 0, -16.5), stone, { studs = true })
		K.part(V(15, 0.7, 3.6), CFrame.new(at(0, 3.9, 0)) * CFrame.Angles(0, rad(i * 45), 0) * CFrame.new(0, 0, -16.5), T.accent2, { collide = false })
	end
	K.cyl(32, 2.6, at(0, 1.3, 0), rgb(70, 160, 210), { collide = false })
	local water = K.cyl(31.6, 0.4, at(0, 2.75, 0), rgb(90, 200, 255), { collide = false, transp = 0.25, mat = Enum.Material.Glass, name = "Water" })
	K.cyl(9, 7, at(0, 5.6, 0), stone, { studs = true })
	K.cyl(10.4, 0.8, at(0, 3, 0), gold, { collide = false })
	K.cyl(18, 1.6, at(0, 9.6, 0), stone, { studs = true })
	K.cyl(16.4, 0.4, at(0, 10.5, 0), rgb(90, 200, 255), { collide = false, transp = 0.2, mat = Enum.Material.Glass })
	K.cyl(18.6, 0.6, at(0, 9.1, 0), gold, { collide = false })
	K.cyl(6, 3, at(0, 12, 0), stone, { studs = true })
	K.part(V(7, 1, 7), CFrame.new(at(0, 14, 0)) * CFrame.Angles(0, rad(45), 0), gold, { studs = true })
	K.display("Animals", "Cheetah", CFrame.new(at(0, 14.5, 0)) * CFrame.Angles(0, rad(180 + 25), 0), 1.5, { variant = "Golden", parent = K.parent, name = "GoldenCheetahStatue" })
	local spray = K.part(V(1, 1, 1), CFrame.new(at(0, 10.6, 0)), Color3.new(1, 1, 1), { transp = 1, collide = false, name = "Spray" })
	K.sparkle(spray, rgb(200, 240, 255), { texture = "rbxasset://textures/particles/smoke_main.dds", rate = 40, size = 1.4, life = NumberRange.new(0.8, 1.2), speed = NumberRange.new(14, 18), spread = Vector2.new(25, 25), accel = V(0, -30, 0), emitDir = Enum.NormalId.Top, color2 = Color3.new(1, 1, 1), emission = 0.2, name = "Water" })
	local ring = K.part(V(1, 1, 1), CFrame.new(at(0, 4.6, 0)), Color3.new(1, 1, 1), { transp = 1, collide = false })
	for i = 0, 3 do -- 4 arcing jets from the basin rim into the middle
		local a = K.part(V(1, 1, 1), CFrame.lookAt(at(math.cos(i * math.pi / 2) * 13, 4.5, math.sin(i * math.pi / 2) * 13), at(0, 14, 0)), Color3.new(1, 1, 1), { transp = 1, collide = false })
		K.sparkle(a, rgb(200, 240, 255), { texture = "rbxasset://textures/particles/smoke_main.dds", rate = 18, size = 0.9, life = NumberRange.new(0.9, 1.1), speed = NumberRange.new(12, 13), spread = Vector2.new(3, 3), accel = V(0, -26, 0), emitDir = Enum.NormalId.Front, emission = 0.2, name = "Jet" })
	end
	K.tag(water, "AmbientSound", { Sound = "Fountain" })

	------------------------------------------------------------------------------------------------------------
	-- Cliffs around the hub (two tiers for depth), opening to the north for the obby
	------------------------------------------------------------------------------------------------------------
	K.parent = K.folder("Cliffs", hub)
	local inner = { height = 30, depth = 26, rock = T.rock, top = T.top, trees = 0.4, bushes = 0.5, treeKind = { "oak", "oak", "pine", "round" }, treePal = T.treePal }
	local outer = { height = 58, depth = 34, rock = { rgb(140, 100, 76), rgb(166, 122, 90) }, top = rgb(84, 172, 70), trees = 0.3, bushes = 0.3, treeKind = { "pine", "oak" }, treePal = T.treePal, drips = false }
	local function wall(x1, z1, x2, z2, n)
		local a, b = at(x1, 0, z1), at(x2, 0, z2)
		inner.inward = n; outer.inward = n
		P.cliff(a, b, inner, K.parent)
		P.cliff(a - n * 24, b - n * 24, outer, K.parent)
	end
	wall(-HX, -HZ, -HX, HZ, V(1, 0, 0))
	wall(HX, HZ, HX, -HZ, V(-1, 0, 0))
	wall(-HX, HZ, HX, HZ, V(0, 0, -1))
	wall(-HX, -HZ, -60, -HZ, V(0, 0, 1))
	wall(60, -HZ, HX, -HZ, V(0, 0, 1))

	------------------------------------------------------------------------------------------------------------
	-- Obby entrance (north): giant zoo arch "OBBY"
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("ObbyEntrance", hub)
	local arch, top = P.arch(cfAt(0, -HZ + 4, 0), 80, 40, { pillar = T.gatePillar, trim = T.accent, pillarW = 12 }, K.parent)
	K.textPanel(top, Enum.NormalId.Back, { { text = "🐾 OBBY 🐾", h = 0.95, grad = { rgb(255, 250, 150), rgb(255, 150, 40) }, font = K.FONT_BOLD } }, { pps = 6, stroke = 6 })
	for _, sx in ipairs({ -1, 1 }) do
		P.banner(at(sx * 52, 0, -HZ + 16), sx > 0 and 180 or 0, T.accent, "🐾", T, K.parent)
	end

	------------------------------------------------------------------------------------------------------------
	-- Speed upgrades (north-west): 2 columns x 5 rows under a "SPEED LAB" frame
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("SpeedUpgrades", hub)
	local sx0, sz0 = -150, -102
	K.part(V(80, 1.2, 120), CFrame.new(at(sx0, 0.6, sz0)), T.padBase, { studs = true, name = "Floor" })
	K.part(V(82, 0.5, 122), CFrame.new(at(sx0, 0.4, sz0)), T.accent, { neon = true, collide = false })
	for i = 1, 10 do
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		S.speedUpgrade(cfAt(sx0 - 18 + col * 36, sz0 + 50 - row * 25, -90, 1.2), i, W.speedUpgrades[i] or {}, T, K.parent)
	end
	for _, c in ipairs({ { -38, -58 }, { 38, -58 }, { -38, 58 }, { 38, 58 } }) do
		K.part(V(4, 34, 4), CFrame.new(at(sx0 + c[1], 17, sz0 + c[2])), T.metal, { studs = true })
		K.part(V(5, 2, 5), CFrame.new(at(sx0 + c[1], 34.5, sz0 + c[2])), T.accent, { studs = true })
	end
	K.part(V(80, 3, 4), CFrame.new(at(sx0, 34, sz0 - 58)), T.metal, { studs = true })
	K.part(V(80, 3, 4), CFrame.new(at(sx0, 34, sz0 + 58)), T.metal, { studs = true })
	K.part(V(4, 3, 120), CFrame.new(at(sx0 - 38, 34, sz0)), T.metal, { studs = true })
	K.part(V(4, 3, 120), CFrame.new(at(sx0 + 38, 34, sz0)), T.metal, { studs = true }) -- (title floats above: MenuStyle)

	------------------------------------------------------------------------------------------------------------
	-- Leaderboards (north, west of the obby path), facing the plaza
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("LeaderboardArea", hub)
	S.leaderboard(CFrame.new(at(-62, 0, -138)) * CFrame.Angles(0, math.pi, 0) * CFrame.Angles(0, 0, 0), {
		{ id = "Speed", title = "⚡ TOP SPEED", stat = "Speed", color = rgb(60, 190, 255) },
		{ id = "Wins", title = "🏆 TOP WINS", stat = "Wins", color = rgb(255, 190, 40) },
		{ id = "Rebirths", title = "🔁 REBIRTHS", stat = "Rebirths", color = rgb(190, 100, 255) },
	}, T, K.parent)

	------------------------------------------------------------------------------------------------------------
	-- Treadmill training centre (east)
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("Treadmills", hub)
	local tx0, tz0 = 150, -50
	K.part(V(92, 1, 150), CFrame.new(at(tx0, 0.5, tz0)), rgb(60, 66, 90), { studs = true, name = "Floor" })
	K.part(V(94, 0.5, 152), CFrame.new(at(tx0, 0.3, tz0)), T.accent2, { neon = true, collide = false })
	for r = 0, 1 do -- runners face the TRAINING CENTER sign (west)
		for i = 1, 4 do
			local tier = i
			S.treadmill(cfAt(tx0 - 13 + r * 36, tz0 + 51 - (i - 1) * 34, 90, 1), tier, W.treadmills[tier] or 1, T, K.parent)
		end
	end
	-- facility frame: corner columns, roof beams, a big sign facing the plaza
	for _, c in ipairs({ { -44, -73 }, { 44, -73 }, { -44, 73 }, { 44, 73 } }) do
		K.part(V(5, 36, 5), CFrame.new(at(tx0 + c[1], 18, tz0 + c[2])), T.metal, { studs = true })
		K.part(V(6, 2, 6), CFrame.new(at(tx0 + c[1], 36.5, tz0 + c[2])), T.accent2, { studs = true })
	end
	for _, z in ipairs({ -73, -24, 24, 73 }) do K.part(V(92, 2.4, 3), CFrame.new(at(tx0, 35.5, tz0 + z)), T.metal, { studs = true }) end
	K.part(V(3, 2.4, 150), CFrame.new(at(tx0 + 44, 35.5, tz0)), T.metal, { studs = true })
	K.part(V(3, 2.4, 150), CFrame.new(at(tx0 - 44, 35.5, tz0)), T.metal, { studs = true }) -- (title floats above: MenuStyle)
	for _, z in ipairs({ -70, 70 }) do -- water cooler + dumbbell racks as props
		local p = at(tx0 + 40, 1, tz0 + z * 0.97)
		K.part(V(3, 5, 3), CFrame.new(p + V(0, 2.5, 0)), rgb(240, 240, 250), {})
		K.part(V(2.6, 3, 2.6), CFrame.new(p + V(0, 6.5, 0)), rgb(110, 200, 255), { transp = 0.3, mat = Enum.Material.Glass, collide = false })
	end

	------------------------------------------------------------------------------------------------------------
	-- Egg station (west of the fountain) facing the plaza. The pets are only shown in the egg menu.
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("Eggs", hub)
	S.egg(face(-92, 40, 0, 40), { name = W.egg.name, display = W.egg.display, price = W.egg.price, world = "Zoo", glow = rgb(255, 170, 60) }, T, K.parent, S.eggBuilder)

	------------------------------------------------------------------------------------------------------------
	-- Fastest Runner statue (east of the fountain; the Zoo has no Version Wheel). FastestStatue (server) puts the
	-- fastest player's own animal on the plinth and writes their name.
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("FastestStatue", hub)
	local mc = face(84, 40, 0, 40)
	K.cyl(28, 1.6, (mc * CFrame.new(0, 0.8, 0)).Position, T.padBase, { studs = true })
	K.cyl(22, 1.2, (mc * CFrame.new(0, 2.2, 0)).Position, T.padTrim, { studs = true })
	K.cyl(23, 0.3, (mc * CFrame.new(0, 1.7, 0)).Position, gold, { neon = true, collide = false })
	K.part(V(14, 5, 14), mc * CFrame.new(0, 5.3, 0), stone, { studs = true })
	K.part(V(15, 0.8, 15), mc * CFrame.new(0, 8.2, 0), gold, { studs = true })
	K.part(V(14.4, 0.6, 14.4), mc * CFrame.new(0, 3.1, 0), gold, { collide = false })
	for _, sx in ipairs({ -1, 1 }) do -- two torches
		local tp = mc * CFrame.new(sx * 11.5, 2.8, -3)
		K.part(V(1.4, 7, 1.4), tp * CFrame.new(0, 3.5, 0), T.metal, { collide = false })
		local fl = K.part(V(2, 2, 2), tp * CFrame.new(0, 7.6, 0), rgb(255, 200, 80), { neon = true, collide = false, shape = "ball" })
		K.sparkle(fl, rgb(255, 170, 60), { rate = 8, size = 0.8, accel = V(0, 6, 0), speed = NumberRange.new(1, 2) })
	end
	local plaque = K.part(V(10, 3.6, 0.4), mc * CFrame.new(0, 5.3, -7.2), rgb(60, 50, 44), { collide = false, name = "Plaque" })
	K.textPanel(plaque, Enum.NormalId.Front, { { name = "Title", text = "👑 FASTEST RUNNER", h = 0.5, color = T.gold, font = K.FONT_BOLD }, { name = "Who", text = "...", h = 0.5 } }, { pps = 30, stroke = 2 })
	local spot = K.part(V(12, 1, 12), mc * CFrame.new(0, 9.1, 0), Color3.new(1, 1, 1), { transp = 1, collide = false, name = "StatueSpot" })
	K.tag(spot, "FastestStatue", { World = 1 })
	K.light(spot, rgb(255, 230, 160), 24, 1.2)

	------------------------------------------------------------------------------------------------------------
	-- Shops (south)
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("Shops", hub)
	local shops = {
		{ id = "Animals", title = "ANIMAL SHOP", iconKind = "paw", color = rgb(255, 130, 40) },
		{ id = "Boosts", title = "BOOST SHOP", iconKind = "potion", color = rgb(50, 175, 255) },
		{ id = "Premium", title = "PREMIUM SHOP", iconKind = "gem", color = rgb(180, 85, 255) },
	}
	for i, sh in ipairs(shops) do
		S.shop(face(-66 + (i - 1) * 66, 132, -66 + (i - 1) * 66, 0), sh, T, K.parent)
	end

	------------------------------------------------------------------------------------------------------------
	-- Zoo garden (south-west): pond with a wooden footbridge, gazebo, flower beds
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("Garden", hub)
	do
		local gx, gz = -150, 112
		K.cyl(56, 1.2, at(gx, 0.6, gz), rgb(150, 140, 130), { studs = true })
		K.cyl(52, 1.3, at(gx, 0.65, gz), rgb(70, 170, 220), { transp = 0.1, mat = Enum.Material.Glass, collide = false })
		for i = 1, 7 do -- lily pads
			local a = i * 0.9
			K.cyl(4 + (i % 3), 0.2, at(gx + math.cos(a) * (14 + i), 1.35, gz + math.sin(a) * (12 + i)), rgb(90, 190, 80), { collide = false })
		end
		for i = 1, 10 do -- rocks + reeds around the rim
			local a = i / 10 * math.pi * 2 + 0.3
			if math.abs(math.sin(a)) > 0.3 then
				P.rock(at(gx + math.cos(a) * 29, 0, gz + math.sin(a) * 29), 0.55, { rock = rgb(160, 155, 150) }, K.parent)
				for k = 1, 3 do K.part(V(0.4, 4 + k, 0.4), CFrame.new(at(gx + math.cos(a) * 25 + k, 2.5, gz + math.sin(a) * 25)), rgb(90, 160, 70), { collide = false }) end
			end
		end
		-- arched wooden footbridge across the pond (east-west)
		for i = -6, 6 do
			local y = 2.4 + (36 - i * i) * 0.12
			K.part(V(4.2, 0.8, 10), CFrame.new(at(gx + i * 4.2, y, gz)), rgb(186, 124, 70), { mat = Enum.Material.WoodPlanks })
			for _, sz in ipairs({ -1, 1 }) do
				K.part(V(0.7, 3.6, 0.7), CFrame.new(at(gx + i * 4.2, y + 1.8, gz + sz * 4.8)), rgb(130, 85, 50), { collide = false })
			end
		end
		for _, sz in ipairs({ -1, 1 }) do
			for i = -6, 5 do
				local y1, y2 = 2.4 + (36 - i * i) * 0.12, 2.4 + (36 - (i + 1) * (i + 1)) * 0.12
				local a, b = at(gx + i * 4.2, y1 + 3.6, gz + sz * 4.8), at(gx + (i + 1) * 4.2, y2 + 3.6, gz + sz * 4.8)
				K.part(V(0.6, 0.6, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), rgb(160, 105, 60), { collide = false })
			end
		end
		-- gazebo on the far side
		local gc = CFrame.new(at(gx + 10, 0, gz + 40))
		K.cyl(22, 1.2, (gc * CFrame.new(0, 0.6, 0)).Position, rgb(240, 236, 226), { studs = true })
		for i = 0, 5 do
			local p = gc * CFrame.Angles(0, rad(i * 60), 0) * CFrame.new(0, 0, -9)
			K.cyl(1.4, 11, (p * CFrame.new(0, 6.7, 0)).Position, rgb(250, 250, 250), {})
		end
		for i = 0, 5 do
			K.part(V(10.6, 1, 4), gc * CFrame.Angles(0, rad(i * 60 + 30), 0) * CFrame.new(0, 12.6, -7.6) * CFrame.Angles(rad(28), 0, 0), T.accent, { collide = false })
		end
		K.part(V(3, 3, 3), gc * CFrame.new(0, 15.2, 0) * CFrame.Angles(0, rad(45), 0), T.gold, { collide = false })
		K.part(V(6, 1, 2), gc * CFrame.new(0, 1.7, 3), rgb(186, 124, 70), {})
		P.flowers(at(gx - 24, 0.2, gz + 36), 14, 10, T, K.parent)
		P.flowers(at(gx + 36, 0.2, gz + 30), 12, 10, T, K.parent)
	end

	------------------------------------------------------------------------------------------------------------
	-- Next world portal (south-east)
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("NextWorld", hub)
	S.portal(face(158, 118, 60, 40), { kind = "Next", title = "DESERT", target = "Desert", color = rgb(255, 170, 60) }, T, K.parent)

	------------------------------------------------------------------------------------------------------------
	-- Snack court (west wall) and picnic lawn (east wall) instead of animal pens
	------------------------------------------------------------------------------------------------------------
	K.parent = K.model("SnackCourt", hub)
	do
		local x0, z0 = -168, -14
		K.part(V(54, 0.6, 48), CFrame.new(at(x0, 0.3, z0)), rgb(236, 214, 170), { studs = true })
		local function cart(cf, col, label)
			K.part(V(9, 4, 5), cf * CFrame.new(0, 3.6, 0), col, { studs = true })
			K.part(V(9.4, 0.5, 5.4), cf * CFrame.new(0, 5.8, 0), rgb(250, 250, 250), {})
			for _, sx in ipairs({ -1, 1 }) do K.part(V(0.8, 2.8, 2.8), cf * CFrame.new(sx * 3.4, 1.4, 2.6), rgb(50, 50, 60), { shape = "cyl", collide = false }) end
			K.part(V(0.5, 6, 0.5), cf * CFrame.new(0, 9, 0), rgb(240, 240, 240), { collide = false })
			for i = 0, 7 do -- umbrella
				K.part(V(5.4, 0.4, 3), cf * CFrame.new(0, 12, 0) * CFrame.Angles(0, rad(i * 45), 0) * CFrame.new(0, -0.6, -2.4) * CFrame.Angles(rad(-18), 0, 0), (i % 2 == 0) and col or rgb(255, 255, 255), { collide = false })
			end
			local sg = K.part(V(8, 2, 0.3), cf * CFrame.new(0, 7, -2.6), rgb(255, 255, 255), { collide = false })
			K.textPanel(sg, Enum.NormalId.Front, { { text = label, h = 0.9, color = col } }, { pps = 24, stroke = 2 })
		end
		cart(CFrame.new(at(x0 - 12, 0.6, z0 - 12)) * CFrame.Angles(0, rad(-90), 0), rgb(255, 120, 150), "🍦 ICE CREAM")
		cart(CFrame.new(at(x0 - 12, 0.6, z0 + 12)) * CFrame.Angles(0, rad(-90), 0), rgb(255, 190, 50), "🍿 POPCORN")
		for _, zz in ipairs({ -12, 12 }) do -- picnic tables with umbrellas
			local tc = CFrame.new(at(x0 + 12, 0.6, z0 + zz))
			K.part(V(8, 0.6, 4), tc * CFrame.new(0, 3, 0), rgb(186, 124, 70), {})
			for _, sz in ipairs({ -1, 1 }) do K.part(V(8, 0.5, 1.6), tc * CFrame.new(0, 1.8, sz * 3.4), rgb(170, 110, 62), {}) end
			K.part(V(0.5, 3, 0.5), tc * CFrame.new(0, 1.5, 0), rgb(120, 80, 50), {})
			K.part(V(0.4, 7, 0.4), tc * CFrame.new(0, 6.8, 0), rgb(240, 240, 240), { collide = false })
			for i = 0, 7 do
				K.part(V(5.8, 0.4, 3.2), tc * CFrame.new(0, 10.6, 0) * CFrame.Angles(0, rad(i * 45), 0) * CFrame.new(0, -0.6, -2.6) * CFrame.Angles(rad(-18), 0, 0), (i % 2 == 0) and T.accent2 or rgb(255, 255, 255), { collide = false })
			end
		end
	end
	K.parent = K.model("PicnicLawn", hub)
	do
		local x0, z0 = 168, 64
		P.tree(at(x0 + 12, 0, z0 + 24), "oak", 1.2, T.treePal, K.parent)
		P.tree(at(x0 - 12, 0, z0 + 10), "round", 1, T.treePal, K.parent)
		for i = 0, 2 do -- picnic blankets + baskets
			local c = CFrame.new(at(x0 - 14 + i * 12, 0.15, z0 - 10 + (i % 2) * 8)) * CFrame.Angles(0, rad(i * 25), 0)
			K.part(V(8, 0.2, 6), c, (i % 2 == 0) and rgb(255, 90, 90) or rgb(90, 160, 255), { collide = false })
			K.part(V(2, 1.4, 1.4), c * CFrame.new(2, 0.8, 1), rgb(186, 124, 70), { collide = false, mat = Enum.Material.WoodPlanks })
		end
		P.bush(at(x0 + 18, 0, z0 + 16), 1.2, T.treePal, K.parent)
		P.flowers(at(x0 - 2, 0.2, z0 + 18), 14, 8, T, K.parent)
	end

	------------------------------------------------------------------------------------------------------------
	-- Decoration: lamps along the paths, benches, flower beds, bushes, signpost
	------------------------------------------------------------------------------------------------------------
	K.parent = K.folder("Decor", hub)
	local lampN = 0
	for _, z in ipairs({ 70, 100, 140, -70, -100 }) do
		for _, sx in ipairs({ -1, 1 }) do
			lampN += 1
			P.lamp(at(sx * 22, 0, z), T, lampN % 2 == 0, K.parent)
		end
	end
	for _, x in ipairs({ 75, -75, -110 }) do
		for _, sz in ipairs({ -1, 1 }) do P.lamp(at(x, 0, sz * 18), T, false, K.parent) end
	end
	for i = 0, 7 do -- lamps around the plaza ring
		local a = rad(i * 45 + 22.5)
		P.lamp(at(math.cos(a) * 58, 0, math.sin(a) * 58), T, i % 2 == 0, K.parent)
	end
	for _, b in ipairs({ { 30, 60, 90 }, { -30, 60, -90 }, { 30, -60, 90 }, { -30, -60, -90 } }) do
		P.bench(cfAt(b[1], b[2], b[3]), T, K.parent)
	end
	-- flower beds in the four lawn quarters around the plaza
	for _, q in ipairs({ { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }) do
		local x, z = q[1] * 46, q[2] * 70
		K.part(V(22, 1.4, 12), CFrame.new(at(x, 0.7, z)), rgb(250, 246, 236), { studs = true })
		K.part(V(20, 1.5, 10), CFrame.new(at(x, 0.75, z)), rgb(110, 75, 50), { collide = false })
		P.flowers(at(x, 1.5, z), 18, 8, T, K.parent)
	end
	-- bushes and small trees on the open lawn: never inside paths or any building / station footprint
	local boxes = {}
	for _, ch in hub:GetChildren() do
		if ch:IsA("Model") or (ch:IsA("Folder") and ch.Name == "Decor") then
			for _, m in (ch:IsA("Folder") and ch:GetChildren() or { ch }) do
				if m:IsA("Model") then
					local cf, size = m:GetBoundingBox()
					table.insert(boxes, { c = cf.Position, h = Vector3.new(size.X, 0, size.Z).Magnitude / 2 })
				end
			end
		end
	end
	local function free(p, r)
		local lx, lz = p.X - O.X, p.Z - O.Z
		if math.abs(lx) < 30 or math.abs(lz) < 24 or (lx * lx + lz * lz) < 72 * 72 then return false end
		for _, b in ipairs(boxes) do
			if (Vector3.new(p.X, 0, p.Z) - Vector3.new(b.c.X, 0, b.c.Z)).Magnitude < b.h + r then return false end
		end
		return true
	end
	local placed = 0
	for i = 1, 200 do
		if placed >= 22 then break end
		local p = at(K.rand(-HX + 34, HX - 34), 0, K.rand(-HZ + 34, HZ - 34))
		local tree = K.chance(0.4)
		if free(p, tree and 11 or 6) then
			if tree then P.tree(p, K.pick({ "oak", "round" }), K.rand(0.8, 1.05), T.treePal, K.parent)
			else P.bush(p, K.rand(0.9, 1.3), T.treePal, K.parent) end
			table.insert(boxes, { c = p, h = tree and 9 or 5 })
			placed += 1
		end
	end
	P.signpost(at(-42, 0, 44), {
		{ "OBBY ⬆", 90, rgb(80, 200, 90) }, { "EGGS", 180, rgb(255, 170, 60) }, { "TRAINING", 0, rgb(60, 180, 255) }, { "SHOPS", -90, rgb(190, 90, 255) },
	}, T, K.parent)

	------------------------------------------------------------------------------------------------------------
	-- Spawn + safety: kill floor far below, invisible boundary walls behind the cliffs
	------------------------------------------------------------------------------------------------------------
	K.parent = K.folder("Gameplay", hub)
	local spawn = workspace:FindFirstChildOfClass("SpawnLocation") or Instance.new("SpawnLocation")
	spawn.Anchored = true; spawn.Size = V(16, 1, 16); spawn.CFrame = CFrame.new(at(0, 0.6, 84)) * CFrame.Angles(0, 0, 0)
	spawn.Transparency = 1; spawn.CanCollide = false; spawn.Neutral = true; spawn.Duration = 0; spawn.Name = "SpawnLocation"
	for _, d in spawn:GetChildren() do if d:IsA("Decal") then d:Destroy() end end
	spawn.Parent = workspace
	K.tag(K.part(V(10, 1, 10), CFrame.new(at(0, 1, 84)), Color3.new(1, 1, 1), { transp = 1, collide = false, name = "WorldSpawn" }), "WorldSpawn", { World = 1 })
	for _, b in ipairs({ { 0, -HZ - 60, HX * 2 + 200, 20 }, { 0, HZ + 60, HX * 2 + 200, 20 } }) do
		K.part(V(b[3], 300, b[4]), CFrame.new(at(b[1], 140, b[2])), Color3.new(1, 1, 1), { transp = 1, name = "Boundary" })
	end
	for _, sx in ipairs({ -1, 1 }) do
		K.part(V(20, 300, HZ * 2 + 140), CFrame.new(at(sx * (HX + 60), 140, 0)), Color3.new(1, 1, 1), { transp = 1, name = "Boundary" })
	end
	-- the north boundary has a gap for the obby (the obby has its own walls)
	local nb = hub.Gameplay:GetChildren()
	for _, p in nb do if p.Name == "Boundary" and math.abs(p.Position.Z - at(0, 0, -HZ - 60).Z) < 1 then p:Destroy() end end
	for _, sx in ipairs({ -1, 1 }) do
		K.part(V(HX - 40, 300, 20), CFrame.new(at(sx * (HX / 2 + 50), 140, -HZ - 60)), Color3.new(1, 1, 1), { transp = 1, name = "Boundary" })
	end
	-- distant scenery so the hub never floats in an empty sky: rolling hills + valley floor far below
	K.parent = K.folder("Backdrop", hub)
	P.backdrop({ O + V(-HX - 60, 0, -HZ), O + V(-HX - 60, 0, HZ), O + V(HX + 60, 0, HZ), O + V(HX + 60, 0, -HZ) }, T.hills, K.parent, { 1 })
	K.parent = workspace
	return T
end
