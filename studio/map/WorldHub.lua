-- WorldHub: hub builder for worlds 2-6. Same system locations as the Zoo (so players learn the map), but every
-- surface, building style, centrepiece, vegetation and decoration comes from the world theme T (see Worlds.lua).
-- Worlds 2+ have the Version Wheel (east of the plaza). Previous-world portal south-west, next-world south-east.
return function(K, P, S, cfg, O, T)
	local V = Vector3.new
	local rad = math.rad
	local rgb = K.rgb
	local W = cfg.Worlds[T.id]
	local root = K.folder("World" .. T.id .. "_" .. T.key, workspace)
	for _, c in root:GetChildren() do if c.Name == "Hub" then c:Destroy() end end
	local hub = K.folder("Hub", root)
	K.seed(1000 + T.id)

	local function at(x, y, z) return O + V(x, y, z) end
	local function cfAt(x, z, yaw, y) return CFrame.new(at(x, y or 0, z)) * CFrame.Angles(0, rad(yaw or 0), 0) end
	local function face(x, z, tx, tz) return CFrame.lookAt(at(x, 0, z), at(tx, 0, tz)) end
	local HX, HZ = 210, 170

	-- ground -----------------------------------------------------------------------------------------------------
	K.parent = K.folder("Ground", hub)
	K.part(V(HX * 2 + 80, 24, HZ * 2 + 80), CFrame.new(at(0, -12, 0)), T.floor, { studs = true, name = "Floor", mat = T.floorMat })
	for i = 1, 20 do
		local x, z = K.rand(-HX + 20, HX - 20), K.rand(-HZ + 20, HZ - 20)
		if math.abs(x) > 24 and math.abs(z) > 20 then
			K.block(V(K.rand(18, 40), 0.3, K.rand(18, 40)), at(x, 0.15, z), K.jitter(K.chance(0.5) and T.floor2 or K.shade(T.floor, 0.94), 0.02), { studs = true, ry = K.rand(0, 90), collide = false, name = "Patch", mat = T.floorMat })
		end
	end
	local function path(x1, z1, x2, z2, w)
		local a, b = at(x1, 0, z1), at(x2, 0, z2)
		local len = (b - a).Magnitude
		local cf = CFrame.lookAt((a + b) / 2, b)
		local tiles = math.max(1, math.floor(len / 12))
		for i = 0, tiles - 1 do
			for j = 0, 1 do
				K.part(V(w / 2, 0.6, len / tiles), cf * CFrame.new((j - 0.5) * w / 2, 0.3, -len / 2 + (i + 0.5) * len / tiles), ((i + j) % 2 == 0) and T.path or T.path2, { studs = true, name = "Path", mat = T.pathMat })
			end
		end
		for _, sx in ipairs({ -1, 1 }) do
			K.part(V(1.6, 1, len), cf * CFrame.new(sx * (w / 2 + 0.8), 0.5, 0), T.curb, { studs = true, name = "Curb", collide = false, neon = T.neonCurb })
		end
	end
	path(0, 110, 0, 52, 34); path(0, -52, 0, -HZ - 6, 34); path(-52, 0, -140, 0, 26); path(52, 0, 104, 0, 26)
	path(-36, 36, -128, 112, 20); path(36, 36, 128, 112, 20); path(-36, -36, -110, -98, 20); path(36, -36, 110, -88, 20)
	K.cyl(112, 0.7, at(0, 0.35, 0), T.curb, { name = "PlazaRim", neon = T.neonCurb })
	K.cyl(108, 0.75, at(0, 0.4, 0), T.path, { name = "Plaza", mat = T.pathMat })
	K.cyl(84, 0.8, at(0, 0.45, 0), T.plaza1, { name = "PlazaInner", mat = T.pathMat })
	K.cyl(80, 0.85, at(0, 0.48, 0), T.plaza2, { name = "PlazaInner2", mat = T.pathMat })
	for i = 0, 7 do
		K.part(V(1.4, 0.9, 40), CFrame.new(at(0, 0.5, 0)) * CFrame.Angles(0, rad(i * 45 + 22.5), 0) * CFrame.new(0, 0, -34), T.path2, { collide = false, name = "Spoke", neon = T.neonCurb })
	end

	-- centrepiece ------------------------------------------------------------------------------------------------
	K.parent = K.model("Centrepiece", hub)
	T.centrepiece(CFrame.new(at(0, 0, 0)), K.parent)

	-- cliffs (two tiers) or the theme's own border -------------------------------------------------------------
	K.parent = K.folder("Cliffs", hub)
	local inner = { height = T.cliffH or 30, depth = 26, rock = T.rock, top = T.top, trees = T.cliffTrees or 0.3, bushes = T.cliffBushes or 0.4, treeKind = T.treeKinds, treePal = T.treePal, studs = true }
	local outer = { height = (T.cliffH or 30) * 1.9, depth = 34, rock = T.rock2 or T.rock, top = T.top2 or T.top, trees = (T.cliffTrees or 0.3) * 0.7, bushes = 0.2, treeKind = T.treeKinds, treePal = T.treePal, drips = false }
	local function wall(x1, z1, x2, z2, n)
		local a, b = at(x1, 0, z1), at(x2, 0, z2)
		inner.inward = n; outer.inward = n
		P.cliff(a, b, inner, K.parent)
		P.cliff(a - n * 24, b - n * 24, outer, K.parent)
	end
	wall(-HX, -HZ, -HX, HZ, V(1, 0, 0)); wall(HX, HZ, HX, -HZ, V(-1, 0, 0)); wall(-HX, HZ, HX, HZ, V(0, 0, -1))
	wall(-HX, -HZ, -60, -HZ, V(0, 0, 1)); wall(60, -HZ, HX, -HZ, V(0, 0, 1))
	if T.cliffExtras then T.cliffExtras(hub, at, HX, HZ) end

	-- obby entrance ----------------------------------------------------------------------------------------------
	K.parent = K.model("ObbyEntrance", hub)
	local _, top = P.arch(cfAt(0, -HZ + 4, 0), 80, 40, { pillar = T.gatePillar, trim = T.gateTrim, pillarW = 12 }, K.parent)
	K.textPanel(top, Enum.NormalId.Back, { { text = T.obbyTitle or "OBBY", h = 0.95, grad = T.titleGrad, font = K.FONT_BOLD } }, { pps = 6, stroke = 6 })
	if T.archDecor then T.archDecor(cfAt(0, -HZ + 4, 0), K.parent) end

	-- speed upgrades ---------------------------------------------------------------------------------------------
	K.parent = K.model("SpeedUpgrades", hub)
	local sx0, sz0 = -150, -102
	K.part(V(80, 1.2, 120), CFrame.new(at(sx0, 0.6, sz0)), T.padBase, { studs = true, name = "Floor" })
	K.part(V(82, 0.5, 122), CFrame.new(at(sx0, 0.4, sz0)), T.accent, { neon = true, collide = false })
	for i = 1, 10 do
		local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
		S.speedUpgrade(cfAt(sx0 - 18 + col * 36, sz0 + 50 - row * 25, -90, 1.2), i, W.speedUpgrades[i] or {}, T, K.parent)
	end
	T.pavilion(CFrame.new(at(sx0, 0, sz0)), 80, 120, "⚡ SPEED UPGRADES ⚡", K.parent)

	-- leaderboards -----------------------------------------------------------------------------------------------
	K.parent = K.model("LeaderboardArea", hub)
	S.leaderboard(CFrame.new(at(-64, 0, -138)) * CFrame.Angles(0, math.pi, 0), {
		{ id = "Speed", title = "⚡ TOP SPEED", stat = "Speed", color = rgb(60, 190, 255) },
		{ id = "Wins", title = "🏆 TOP WINS", stat = "Wins", color = rgb(255, 190, 40) },
		{ id = "Rebirths", title = "🔁 REBIRTHS", stat = "Rebirths", color = rgb(190, 100, 255) },
	}, T, K.parent)

	-- treadmills (runners face the sign, west) -------------------------------------------------------------------
	K.parent = K.model("Treadmills", hub)
	local tx0, tz0 = 150, -50
	K.part(V(92, 1, 150), CFrame.new(at(tx0, 0.5, tz0)), T.gymFloor or rgb(60, 66, 90), { studs = true, name = "Floor" })
	K.part(V(94, 0.5, 152), CFrame.new(at(tx0, 0.3, tz0)), T.accent2, { neon = true, collide = false })
	for r = 0, 1 do
		for i = 1, 4 do
			S.treadmill(cfAt(tx0 - 13 + r * 36, tz0 + 51 - (i - 1) * 34, 90, 1), i, W.treadmills[i] or 1, T, K.parent)
		end
	end
	T.gym(CFrame.new(at(tx0, 0, tz0)), 92, 150, "🏃 TRAINING CENTER", K.parent)

	-- egg ----------------------------------------------------------------------------------------------------------
	K.parent = K.model("Eggs", hub)
	S.egg(face(-92, 40, 0, 40), { name = W.egg.name, display = W.egg.display, price = W.egg.price, world = T.key, glow = T.eggGlow }, T, K.parent, S.eggBuilder)

	-- version wheel (World 2+) -------------------------------------------------------------------------------------
	K.parent = K.model("Wheel", hub)
	S.wheel(face(86, 40, 0, 40), T, K.parent)

	-- shops ----------------------------------------------------------------------------------------------------------
	K.parent = K.model("Shops", hub)
	local shops = {
		{ id = "Animals", title = "ANIMAL SHOP", iconKind = "paw", color = T.shopCols[1] },
		{ id = "Boosts", title = "BOOST SHOP", iconKind = "potion", color = T.shopCols[2] },
		{ id = "Premium", title = "PREMIUM SHOP", iconKind = "gem", color = T.shopCols[3] },
	}
	for i, sh in ipairs(shops) do
		local cf = face(-66 + (i - 1) * 66, 132, -66 + (i - 1) * 66, 0)
		if S.shopBuilder then S.shopBuilder(T.key, 2, cf * CFrame.Angles(0, math.pi, 0), sh, K.parent) else S.shop(cf, sh, T, K.parent) end
		if T.shopDecor then T.shopDecor(cf, sh.color, K.parent) end
	end

	-- portals ----------------------------------------------------------------------------------------------------
	K.parent = K.model("Portals", hub)
	if W.prevWorld then S.portal(face(-152, 116, -60, 40), { kind = "Prev", title = W.prevWorld:upper(), target = W.prevWorld, color = T.prevCol or rgb(120, 200, 255) }, T, K.parent) end
	if W.nextWorld then S.portal(face(158, 118, 60, 40), { kind = "Next", title = W.nextWorld:upper(), target = W.nextWorld, color = T.nextCol or rgb(255, 170, 60) }, T, K.parent) end

	-- world decoration slots (west wall + east wall + the south-east corner when there is no next world) --------
	K.parent = K.model("DecorWest", hub); T.decorA(CFrame.new(at(-168, 0, -14)), K.parent)
	K.parent = K.model("DecorEast", hub); T.decorB(CFrame.new(at(168, 0, 64)), K.parent)
	if not W.nextWorld and T.decorC then K.parent = K.model("DecorCorner", hub); T.decorC(CFrame.new(at(158, 0, 118)), K.parent) end

	-- lamps, benches, beds, random vegetation (kept clear of everything) ------------------------------------------
	K.parent = K.folder("Decor", hub)
	local n = 0
	for _, z in ipairs({ 70, 100, 140, -70, -100 }) do for _, sx in ipairs({ -1, 1 }) do n += 1; T.lamp(at(sx * 22, 0, z), n % 2 == 0, K.parent) end end
	for _, x in ipairs({ 75, -75, -110 }) do for _, sz in ipairs({ -1, 1 }) do T.lamp(at(x, 0, sz * 18), false, K.parent) end end
	for i = 0, 7 do local a = rad(i * 45 + 22.5); T.lamp(at(math.cos(a) * 58, 0, math.sin(a) * 58), i % 2 == 0, K.parent) end
	for _, b in ipairs({ { 30, 60, 90 }, { -30, 60, -90 }, { 30, -60, 90 }, { -30, -60, -90 } }) do P.bench(cfAt(b[1], b[2], b[3]), T, K.parent) end
	for _, q in ipairs({ { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }) do T.bed(CFrame.new(at(q[1] * 46, 0, q[2] * 70)), K.parent) end
	P.signpost(at(-42, 0, 44), { { "OBBY ⬆", 90, rgb(80, 200, 90) }, { "EGGS", 180, rgb(255, 170, 60) }, { "TRAINING", 0, rgb(60, 180, 255) }, { "SHOPS", -90, rgb(190, 90, 255) } }, T, K.parent)
	local boxes = {}
	for _, ch in hub:GetChildren() do
		local list = ch:IsA("Folder") and (ch.Name == "Decor" and ch:GetChildren() or {}) or { ch }
		for _, m in list do
			if m:IsA("Model") then local cf, size = m:GetBoundingBox(); table.insert(boxes, { c = cf.Position, h = V(size.X, 0, size.Z).Magnitude / 2 }) end
		end
	end
	local function free(p, r)
		local lx, lz = p.X - O.X, p.Z - O.Z
		if math.abs(lx) < 30 or math.abs(lz) < 24 or (lx * lx + lz * lz) < 72 * 72 then return false end
		for _, b in ipairs(boxes) do if (V(p.X, 0, p.Z) - V(b.c.X, 0, b.c.Z)).Magnitude < b.h + r then return false end end
		return true
	end
	local placed = 0
	for i = 1, 200 do
		if placed >= 20 then break end
		local p = at(K.rand(-HX + 34, HX - 34), 0, K.rand(-HZ + 34, HZ - 34))
		local tree = K.chance(0.45)
		if free(p, tree and 11 or 6) then
			if tree then P.tree(p, K.pick(T.lawnTrees or T.treeKinds), K.rand(0.8, 1.05), T.treePal, K.parent)
			else T.small(p, K.parent) end
			table.insert(boxes, { c = p, h = tree and 9 or 5 })
			placed += 1
		end
	end

	-- spawn, boundaries, backdrop --------------------------------------------------------------------------------
	K.parent = K.folder("Gameplay", hub)
	K.tag(K.part(V(10, 1, 10), CFrame.new(at(0, 1, 84)), Color3.new(1, 1, 1), { transp = 1, collide = false, name = "WorldSpawn" }), "WorldSpawn", { World = T.id })
	K.part(V(HX * 2 + 200, 300, 20), CFrame.new(at(0, 140, HZ + 60)), Color3.new(1, 1, 1), { transp = 1, name = "Boundary" })
	for _, sx in ipairs({ -1, 1 }) do
		K.part(V(20, 300, HZ * 2 + 140), CFrame.new(at(sx * (HX + 60), 140, 0)), Color3.new(1, 1, 1), { transp = 1, name = "Boundary" })
		K.part(V(HX - 40, 300, 20), CFrame.new(at(sx * (HX / 2 + 50), 140, -HZ - 60)), Color3.new(1, 1, 1), { transp = 1, name = "Boundary" })
	end
	K.parent = K.folder("Backdrop", hub)
	T.backdrop({ O + V(-HX - 60, 0, -HZ), O + V(-HX - 60, 0, HZ), O + V(HX + 60, 0, HZ), O + V(HX + 60, 0, -HZ) }, K.parent, { 1 })
	K.parent = workspace
	return T
end
