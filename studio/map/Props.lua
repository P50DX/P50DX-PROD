-- Props: reusable scenery for every world (trees, rocks, cliffs, lamps, fences, crates, signs ...).
-- Every prop takes a palette table so the same shapes re-skin per world without looking copy-pasted.
return function(K)
	local P = {}
	local V = Vector3.new
	local rad = math.rad

	local function ground(pos) return CFrame.new(pos) end
	local function rotY(deg) return CFrame.Angles(0, rad(deg), 0) end

	------------------------------------------------------------------------------------------------------------
	-- Trees. kinds: oak (voxel canopy), pine (stacked tiers), palm, round (ball canopy), dead, giant (forest),
	-- cactus, crystal, mushroom, icepine. pal = { trunk=, leaf=, leaf2=, extra= }
	------------------------------------------------------------------------------------------------------------
	function P.tree(pos, kind, s, pal, parent)
		s = s or 1
		local m = K.model("Tree_" .. kind, parent)
		local o = { parent = m, collide = false }
		local oc = { parent = m } -- trunk collides
		local yaw = K.rand(0, 90)
		local base = CFrame.new(pos) * rotY(yaw)
		local trunkC = K.jitter(pal.trunk or Color3.fromRGB(110, 80, 60), 0.04)
		local leaf = K.jitter(pal.leaf, 0.05)
		local leaf2 = pal.leaf2 and K.jitter(pal.leaf2, 0.05) or K.shade(leaf, 1.18)
		if kind == "oak" then
			local th = K.rand(7, 10) * s
			K.part(V(3.2, 1.2, 3.2) * V(s, 1, s), base * CFrame.new(0, 0.6, 0), K.shade(trunkC, 0.85), oc)
			K.part(V(2.4 * s, th, 2.4 * s), base * CFrame.new(0, th / 2, 0), trunkC, oc)
			K.part(V(1.2, 3, 1.2) * s, base * CFrame.new(1.3 * s, th * 0.7, 0) * CFrame.Angles(0, 0, rad(-40)), trunkC, o)
			local w = K.rand(10, 13) * s
			local c1 = base * CFrame.new(0, th + w * 0.3, 0)
			K.part(V(w, w * 0.62, w), c1, leaf, { parent = m, studs = true, collide = false })
			K.part(V(w * 0.72, w * 0.5, w * 0.72), c1 * CFrame.new(w * 0.18, w * 0.42, -w * 0.1) * rotY(45), leaf2, { parent = m, studs = true, collide = false })
			K.part(V(w * 0.55, w * 0.45, w * 0.55), c1 * CFrame.new(-w * 0.42, -w * 0.05, w * 0.25) * rotY(20), K.shade(leaf, 0.92), { parent = m, studs = true, collide = false })
			K.part(V(w * 0.5, w * 0.4, w * 0.5), c1 * CFrame.new(w * 0.35, -w * 0.12, w * 0.38) * rotY(60), leaf, { parent = m, studs = true, collide = false })
		elseif kind == "pine" or kind == "icepine" then
			local th = 4 * s
			K.part(V(2.2 * s, th, 2.2 * s), base * CFrame.new(0, th / 2, 0), trunkC, oc)
			local y = th - 0.5 * s
			local tiers = 4
			for i = 1, tiers do
				local f = 1 - (i - 1) / tiers
				local w = (4 + 10 * f) * s
				local h = (3.2 + 0.6 * f) * s
				local c = (i % 2 == 0) and leaf2 or leaf
				K.part(V(w, h, w), base * CFrame.new(0, y + h / 2, 0) * rotY(i * 45), c, { parent = m, studs = true, collide = false })
				if kind == "icepine" or pal.snowcap then
					K.part(V(w * 0.8, 0.6 * s, w * 0.8), base * CFrame.new(0, y + h + 0.3 * s, 0) * rotY(i * 45), pal.extra or Color3.new(1, 1, 1), { parent = m, studs = true, collide = false })
				end
				y = y + h * 0.82
			end
			K.part(V(2 * s, 2.4 * s, 2 * s), base * CFrame.new(0, y + 1.2 * s, 0) * rotY(45), leaf2, o)
		elseif kind == "palm" then
			local seg = 6
			local cf = base
			local lean = K.rand(6, 11)
			for i = 1, seg do
				local h = 3 * s
				cf = cf * CFrame.Angles(0, 0, rad(lean / seg * 1.6))
				K.part(V(1.9 * s * (1 - i * 0.04), h, 1.9 * s * (1 - i * 0.04)), cf * CFrame.new(0, h / 2, 0), i % 2 == 0 and trunkC or K.shade(trunkC, 0.85), i <= 2 and oc or o)
				cf = cf * CFrame.new(0, h * 0.92, 0)
			end
			for i = 1, 7 do
				local fr = cf * rotY(i * (360 / 7) + K.rand(-8, 8)) * CFrame.Angles(rad(-18 - K.rand(0, 14)), 0, 0)
				K.part(V(2.4 * s, 0.5 * s, 9 * s), fr * CFrame.new(0, 0, -4.5 * s), i % 2 == 0 and leaf or leaf2, { parent = m, studs = true, collide = false })
				K.part(V(1.4 * s, 0.4 * s, 4 * s), fr * CFrame.new(0, -0.6 * s, -9.6 * s) * CFrame.Angles(rad(-25), 0, 0), leaf, o)
			end
			for i = 1, 3 do
				K.part(V(1.4, 1.4, 1.4) * s, cf * rotY(i * 120) * CFrame.new(0.9 * s, -0.8 * s, 0), K.rgb(120, 82, 46), { parent = m, collide = false, shape = "ball" })
			end
		elseif kind == "round" then
			local th = K.rand(6, 8) * s
			K.part(V(2 * s, th, 2 * s), base * CFrame.new(0, th / 2, 0), trunkC, oc)
			local r = K.rand(8, 10) * s
			K.part(V(r, r, r), base * CFrame.new(0, th + r * 0.35, 0), leaf, { parent = m, shape = "ball", collide = false })
			K.part(V(r, r, r) * 0.7, base * CFrame.new(r * 0.38, th + r * 0.15, r * 0.2), leaf2, { parent = m, shape = "ball", collide = false })
			K.part(V(r, r, r) * 0.6, base * CFrame.new(-r * 0.35, th + r * 0.2, -r * 0.25), K.shade(leaf, 0.9), { parent = m, shape = "ball", collide = false })
		elseif kind == "dead" then
			local th = K.rand(8, 12) * s
			K.part(V(1.8 * s, th, 1.8 * s), base * CFrame.new(0, th / 2, 0), trunkC, oc)
			for i = 1, 3 do
				local a = i * 120 + K.rand(-20, 20)
				local cf = base * CFrame.new(0, th * (0.5 + i * 0.13), 0) * rotY(a) * CFrame.Angles(0, 0, rad(-50))
				K.part(V(1 * s, 5 * s, 1 * s), cf * CFrame.new(0, 2.5 * s, 0), trunkC, o)
			end
		elseif kind == "giant" then
			local th = K.rand(34, 44) * s
			local tw = 8 * s
			for i = 1, 4 do -- root buttresses
				K.part(V(3 * s, 7 * s, 6 * s), base * rotY(i * 90 + 45) * CFrame.new(0, 3.5 * s, -tw * 0.55), K.shade(trunkC, 0.9), { parent = m, shape = "wedge" })
			end
			K.part(V(tw, th, tw), base * CFrame.new(0, th / 2, 0), trunkC, oc)
			K.part(V(tw * 0.9, 1.2 * s, tw * 1.04), base * CFrame.new(0, th * 0.4, 0), pal.extra or K.shade(trunkC, 0.8), o)
			local w = K.rand(30, 38) * s
			local c1 = base * CFrame.new(0, th + w * 0.12, 0)
			K.part(V(w, w * 0.34, w), c1, leaf, { parent = m, studs = true, collide = false })
			K.part(V(w * 0.75, w * 0.3, w * 0.75), c1 * CFrame.new(0, w * 0.28, 0) * rotY(45), leaf2, { parent = m, studs = true, collide = false })
			K.part(V(w * 0.45, w * 0.25, w * 0.45), c1 * CFrame.new(w * 0.1, w * 0.5, 0) * rotY(20), leaf, { parent = m, studs = true, collide = false })
			for i = 1, 4 do -- hanging vines
				local vl = K.rand(6, 14) * s
				K.part(V(0.6, vl, 0.6), c1 * rotY(i * 90 + 20) * CFrame.new(0, -w * 0.17 - vl / 2, -w * 0.42), K.shade(leaf, 0.8), o)
			end
		elseif kind == "cactus" then
			local th = K.rand(8, 13) * s
			K.part(V(2.6 * s, th, 2.6 * s), base * CFrame.new(0, th / 2, 0), leaf, { parent = m, studs = true })
			K.part(V(2.2 * s, 1, 2.2 * s), base * CFrame.new(0, th + 0.5, 0), leaf2, { parent = m, studs = true, collide = false })
			for i = 1, (K.chance(0.5) and 2 or 1) do
				local side = i == 1 and 1 or -1
				local ay = th * K.rand(0.35, 0.6)
				K.part(V(3 * s, 1.8 * s, 1.8 * s), base * CFrame.new(side * 2.2 * s, ay, 0), leaf, o)
				local ah = K.rand(3, 5) * s
				K.part(V(1.8 * s, ah, 1.8 * s), base * CFrame.new(side * 3.2 * s, ay + ah / 2 - 0.9 * s, 0), leaf, { parent = m, studs = true, collide = false })
			end
			if pal.extra and K.chance(0.6) then
				K.part(V(1.2, 1.2, 1.2) * s, base * CFrame.new(0.5 * s, th + 1.4 * s, 0), pal.extra, { parent = m, shape = "ball", collide = false })
			end
		elseif kind == "crystal" then
			for i = 1, K.chance(0.5) and 4 or 3 do
				local h = K.rand(6, 14) * s * (i == 1 and 1.3 or 0.8)
				local cf = base * rotY(i * 97) * CFrame.new(i == 1 and 0 or 2.2 * s, 0, 0) * CFrame.Angles(rad(i == 1 and 0 or K.rand(-25, 25)), 0, rad(i == 1 and 0 or K.rand(-25, 25)))
				K.part(V(2.4 * s, h, 2.4 * s), cf * CFrame.new(0, h / 2, 0) * rotY(45), i % 2 == 0 and leaf2 or leaf, { parent = m, neon = pal.neon, mat = not pal.neon and Enum.Material.Glass or nil, transp = pal.neon and 0 or 0.15, collide = i == 1 })
				K.part(V(1.7 * s, 1.7 * s, 1.7 * s), cf * CFrame.new(0, h, 0) * CFrame.Angles(rad(45), rad(45), 0), i % 2 == 0 and leaf2 or leaf, { parent = m, neon = pal.neon, collide = false })
			end
		elseif kind == "mushroom" then
			local th = K.rand(4, 7) * s
			K.part(V(2 * s, th, 2 * s), base * CFrame.new(0, th / 2, 0), trunkC, oc)
			local w = K.rand(7, 10) * s
			K.part(V(w, w * 0.32, w), base * CFrame.new(0, th + w * 0.12, 0) * rotY(45), leaf, { parent = m, studs = true, collide = false })
			K.part(V(w * 0.6, w * 0.25, w * 0.6), base * CFrame.new(0, th + w * 0.36, 0), leaf, { parent = m, studs = true, collide = false })
			for i = 1, 4 do
				K.part(V(1, 0.4, 1) * s, base * rotY(i * 90 + 20) * CFrame.new(0, th + w * 0.29, -w * 0.32), pal.leaf2 or Color3.new(1, 1, 1), { parent = m, collide = false })
			end
		end
		return m
	end

	function P.bush(pos, s, pal, parent)
		local m = K.model("Bush", parent)
		local leaf = K.jitter(pal.leaf, 0.05)
		local base = CFrame.new(pos) * rotY(K.rand(0, 90))
		K.part(V(5, 3.2, 4.6) * s, base * CFrame.new(0, 1.6 * s, 0), leaf, { parent = m, studs = true, collide = false })
		K.part(V(3.6, 2.6, 3.6) * s, base * CFrame.new(1.6 * s, 2.6 * s, 0.4 * s) * rotY(40), K.shade(leaf, 1.12), { parent = m, studs = true, collide = false })
		K.part(V(3, 2.2, 3) * s, base * CFrame.new(-1.9 * s, 1.1 * s, 1 * s) * rotY(20), K.shade(leaf, 0.9), { parent = m, studs = true, collide = false })
		if pal.flower and K.chance(0.6) then
			for i = 1, 3 do
				K.part(V(0.8, 0.8, 0.8), base * CFrame.new(K.rand(-2, 2) * s, 3.3 * s, K.rand(-1.5, 1.5) * s), pal.flower, { parent = m, collide = false })
			end
		end
		return m
	end

	function P.rock(pos, s, pal, parent)
		local m = K.model("Rock", parent)
		local c = K.jitter(pal.rock or K.rgb(130, 128, 140), 0.05)
		local n = K.chance(0.5) and 3 or 2
		for i = 1, n do
			local sz = V(K.rand(4, 7), K.rand(3, 5), K.rand(4, 6)) * s * (i == 1 and 1 or 0.65)
			local off = i == 1 and V(0, 0, 0) or V(K.rand(-3, 3), 0, K.rand(-3, 3)) * s
			K.part(sz, CFrame.new(pos + off + V(0, sz.Y * 0.32, 0)) * CFrame.Angles(rad(K.rand(-14, 14)), rad(K.rand(0, 90)), rad(K.rand(-14, 14))),
				i == 2 and K.shade(c, 1.1) or c, { parent = m, studs = i == 1 and pal.studRock, collide = i == 1 })
		end
		return m
	end

	function P.flowers(pos, w, d, pal, parent)
		local m = K.model("Flowers", parent)
		local cols = pal.flowers or { K.rgb(255, 90, 120), K.rgb(255, 215, 70), K.rgb(250, 250, 255), K.rgb(170, 110, 255) }
		for i = 1, math.floor(w * d / 10) do
			local p = pos + V(K.rand(-w / 2, w / 2), 0, K.rand(-d / 2, d / 2))
			K.part(V(0.3, 1.2, 0.3), CFrame.new(p + V(0, 0.6, 0)), K.rgb(70, 150, 60), { parent = m, collide = false, shadow = false })
			K.part(V(1, 0.6, 1), CFrame.new(p + V(0, 1.4, 0)) * rotY(45), K.pick(cols), { parent = m, collide = false, shadow = false })
		end
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- Cliffs: layered, studded rock wall from a to b (ground points). o.inward = unit vector toward the playable
	-- side. o.height, o.depth, o.rock = {dark, light}, o.top = grass colour (or nil), o.trees = chance per
	-- block, o.treeKind, o.treePal, o.drips (grass overhang on the inner lip)
	------------------------------------------------------------------------------------------------------------
	function P.cliff(a, b, o, parent)
		local m = K.model("Cliff", parent)
		local d = b - a
		local len = V(d.X, 0, d.Z).Magnitude
		local u = V(d.X, 0, d.Z).Unit
		local n = o.inward
		local step = o.step or 18
		local H, D = o.height or 30, o.depth or 24
		local yaw = math.atan2(-n.X, -n.Z) -- local -Z faces the playable side, local X runs along the wall
		local s = 0
		while s < len do
			local w = step * K.rand(1.1, 1.45)
			local h = H * K.rand(0.72, 1.25)
			local dd = D * K.rand(0.85, 1.15)
			local base = a + u * (s + step / 2) - n * (dd / 2 - K.rand(-2.5, 2.5))
			local cfb = CFrame.new(base) * CFrame.Angles(0, yaw + rad(K.rand(-5, 5)), 0)
			local layers = h > 26 and 3 or 2
			local y = 0
			for L = 1, layers do
				local lh = (h / layers) * (L == layers and 1 or K.rand(0.85, 1.15))
				if L == layers then lh = h - y end
				local inset = K.rand(-1.8, 1.8)
				local c = (L % 2 == 1) and o.rock[1] or o.rock[2]
				K.part(V(w * K.rand(0.94, 1.04), lh, dd), cfb * CFrame.new(0, y + lh / 2, inset), K.jitter(c, 0.035), { parent = m, studs = o.studs ~= false })
				y = y + lh
			end
			if K.chance(o.overhang or 0.25) then -- jutting ledge partway up
				local ly = h * K.rand(0.45, 0.8)
				K.part(V(w * K.rand(0.4, 0.7), K.rand(3, 5), 6), cfb * CFrame.new(K.rand(-w / 4, w / 4), ly, -dd / 2 - 2), K.jitter(o.rock[2], 0.04), { parent = m, studs = true })
			end
			if o.top then
				local gc = K.jitter(o.top, 0.04)
				K.part(V(w + 1.6, 2.4, dd + 1.6), cfb * CFrame.new(0, h + 1.2, 0), gc, { parent = m, studs = true })
				if o.drips ~= false then
					for i = 1, (K.chance(0.5) and 2 or 1) do
						local dw = K.rand(3, 7)
						local dh = K.rand(2, 5)
						K.part(V(dw, dh, 1.4), cfb * CFrame.new(K.rand(-w / 2 + dw / 2, w / 2 - dw / 2), h - dh / 2 + 0.4, -dd / 2 - 0.6), gc, { parent = m, collide = false })
					end
				end
				if o.trees and K.chance(o.trees) then
					local tp = (cfb * CFrame.new(K.rand(-w / 3, w / 3), h + 2.4, K.rand(-dd / 4, dd / 4))).Position
					P.tree(tp, K.pick(o.treeKind or { "oak" }), K.rand(0.9, 1.4), o.treePal, m)
				elseif o.bushes and K.chance(o.bushes) then
					local bp = (cfb * CFrame.new(K.rand(-w / 3, w / 3), h + 2.4, K.rand(-dd / 4, dd / 4))).Position
					P.bush(bp, K.rand(1, 1.5), o.treePal, m)
				end
			end
			s = s + w * 0.82
		end
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- Furniture
	------------------------------------------------------------------------------------------------------------
	function P.lamp(pos, pal, withLight, parent)
		local m = K.model("Lamp", parent)
		local metal = pal.metal or K.rgb(45, 50, 70)
		K.part(V(2.4, 1, 2.4), CFrame.new(pos + V(0, 0.5, 0)), metal, { parent = m, studs = true })
		K.cyl(0.9, 11, pos + V(0, 6.5, 0), metal, { parent = m })
		K.part(V(2.6, 0.5, 2.6), CFrame.new(pos + V(0, 12.2, 0)), metal, { parent = m, collide = false })
		local glow = K.part(V(1.8, 2.2, 1.8), CFrame.new(pos + V(0, 13.6, 0)), pal.glow or K.rgb(255, 225, 150), { parent = m, neon = true, collide = false })
		K.part(V(2.8, 0.6, 2.8), CFrame.new(pos + V(0, 15, 0)), metal, { parent = m, collide = false })
		K.part(V(1.4, 0.8, 1.4), CFrame.new(pos + V(0, 15.7, 0)) * rotY(45), metal, { parent = m, collide = false })
		if withLight then K.light(glow, pal.glow or K.rgb(255, 225, 150), 22, 1.2) end
		return m
	end

	function P.bench(cf, pal, parent)
		local m = K.model("Bench", parent)
		local wood = pal.wood or K.rgb(170, 110, 60)
		local metal = pal.metal or K.rgb(45, 50, 70)
		for _, x in ipairs({ -3, 3 }) do
			K.part(V(0.6, 2, 2.4), cf * CFrame.new(x, 1, 0), metal, { parent = m })
		end
		for i = 0, 2 do
			K.part(V(8, 0.4, 0.8), cf * CFrame.new(0, 2.2, -0.9 + i * 0.9), K.shade(wood, 1 - i * 0.05), { parent = m })
		end
		K.part(V(8, 0.4, 0.8), cf * CFrame.new(0, 3.4, 1.3) * CFrame.Angles(rad(-75), 0, 0), wood, { parent = m, collide = false })
		K.part(V(8, 0.4, 0.8), cf * CFrame.new(0, 4.3, 1.5) * CFrame.Angles(rad(-75), 0, 0), wood, { parent = m, collide = false })
		return m
	end

	-- zoo fence from a to b: posts + 2 rails (+ optional post caps)
	function P.fence(a, b, pal, parent, height)
		local m = K.model("Fence", parent)
		height = height or 5
		local d = b - a
		local len = d.Magnitude
		local u = d.Unit
		local cf0 = CFrame.lookAt(a, b)
		local post = pal.post or K.rgb(120, 80, 50)
		local rail = pal.rail or K.rgb(160, 110, 65)
		local nPosts = math.max(1, math.floor(len / 8))
		for i = 0, nPosts do
			local p = cf0 * CFrame.new(0, height / 2, -len * i / nPosts)
			K.part(V(1, height, 1), p, post, { parent = m })
			K.part(V(1.3, 0.5, 1.3), p * CFrame.new(0, height / 2 + 0.25, 0), pal.cap or K.shade(post, 1.2), { parent = m, collide = false })
		end
		for _, y in ipairs({ height * 0.38, height * 0.78 }) do
			K.part(V(0.5, 0.7, len), cf0 * CFrame.new(0, y, -len / 2), rail, { parent = m })
		end
		return m
	end

	function P.crate(cf, s, pal, parent)
		local m = K.model("Crate", parent)
		local wood = K.jitter(pal.wood or K.rgb(196, 140, 80), 0.04)
		local dark = K.shade(wood, 0.7)
		K.part(V(4, 4, 4) * s, cf * CFrame.new(0, 2 * s, 0), wood, { parent = m, mat = Enum.Material.WoodPlanks })
		for _, x in ipairs({ -1, 1 }) do for _, z in ipairs({ -1, 1 }) do
			K.part(V(0.5, 4.1, 0.5) * s, cf * CFrame.new(x * 1.85 * s, 2 * s, z * 1.85 * s), dark, { parent = m, collide = false })
		end end
		K.part(V(4.1, 0.5, 4.1) * s, cf * CFrame.new(0, 3.85 * s, 0), dark, { parent = m, collide = false })
		K.part(V(0.4, 5.2, 0.6) * s, cf * CFrame.new(0, 2 * s, -2.05 * s) * CFrame.Angles(0, 0, rad(45)), dark, { parent = m, collide = false })
		return m
	end

	function P.barrel(pos, pal, parent)
		local m = K.model("Barrel", parent)
		local wood = pal.wood or K.rgb(150, 95, 55)
		K.cyl(3.6, 4.6, pos + V(0, 2.3, 0), wood, { parent = m, mat = Enum.Material.WoodPlanks })
		for _, y in ipairs({ 0.9, 3.7 }) do K.cyl(3.8, 0.4, pos + V(0, y, 0), pal.metal or K.rgb(70, 70, 80), { parent = m, collide = false }) end
		return m
	end

	-- pole + hanging cloth banner with a symbol
	function P.banner(pos, yaw, color, symbol, pal, parent)
		local m = K.model("Banner", parent)
		local base = CFrame.new(pos) * rotY(yaw)
		local metal = pal.metal or K.rgb(60, 60, 80)
		K.part(V(2, 1, 2), base * CFrame.new(0, 0.5, 0), metal, { parent = m, studs = true })
		K.cyl(0.8, 20, (base * CFrame.new(0, 10.5, 0)).Position, metal, { parent = m })
		K.part(V(0.9, 0.9, 0.9), base * CFrame.new(0, 21, 0), pal.gold or K.rgb(255, 205, 60), { parent = m, shape = "ball", collide = false })
		K.part(V(5.2, 0.5, 0.5), base * CFrame.new(2.5, 19.5, 0), metal, { parent = m, collide = false })
		local cloth = K.part(V(4.4, 8, 0.25), base * CFrame.new(2.6, 15.2, 0), color, { parent = m, collide = false })
		K.part(V(4.4, 0.6, 0.3), base * CFrame.new(2.6, 11, 0), pal.gold or K.rgb(255, 205, 60), { parent = m, collide = false })
		K.part(V(3.1, 3.1, 0.25), base * CFrame.new(2.6, 10.3, 0) * CFrame.Angles(0, 0, rad(45)), color, { parent = m, collide = false })
		for _, f in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
			K.textPanel(cloth, f, { { text = symbol, h = 0.5 } }, { pps = 20, stroke = 2 })
		end
		return m
	end

	-- directional signpost: arrows = { {text, yaw, color}, ... }
	function P.signpost(pos, arrows, pal, parent)
		local m = K.model("Signpost", parent)
		local wood = pal.wood or K.rgb(150, 95, 55)
		K.part(V(1.2, 12, 1.2), CFrame.new(pos + V(0, 6, 0)), K.shade(wood, 0.85), { parent = m })
		for i, a in ipairs(arrows) do
			local cf = CFrame.new(pos + V(0, 11.2 - i * 2.2, 0)) * rotY(a[2]) * CFrame.new(-3.6, 0, 0)
			local board = K.part(V(7, 1.8, 0.4), cf, a[3] or wood, { parent = m, collide = false })
			K.part(V(1.3, 1.3, 0.4), cf * CFrame.new(-3.5, 0, 0) * CFrame.Angles(0, 0, rad(45)), a[3] or wood, { parent = m, collide = false })
			for _, f in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
				K.textPanel(board, f, { { text = a[1], h = 0.9 } }, { pps = 24, stroke = 2 })
			end
		end
		return m
	end

	-- big rounded arch frame (two pillars + lintel); returns model and the opening's centre CFrame
	function P.arch(cf, w, h, pal, parent)
		local m = K.model("Arch", parent)
		local pc = pal.pillar or K.rgb(230, 225, 210)
		local tc = pal.trim or K.rgb(255, 200, 60)
		local pw = pal.pillarW or 7
		for _, sx in ipairs({ -1, 1 }) do
			local x = sx * (w / 2 + pw / 2)
			K.part(V(pw + 2, 3, pw + 2), cf * CFrame.new(x, 1.5, 0), K.shade(pc, 0.8), { parent = m, studs = true })
			K.part(V(pw, h, pw), cf * CFrame.new(x, 3 + h / 2, 0), pc, { parent = m, studs = true })
			for k = 1, 3 do
				K.part(V(pw + 0.6, 0.8, pw + 0.6), cf * CFrame.new(x, 3 + h * k / 4, 0), tc, { parent = m, collide = false })
			end
			K.part(V(pw + 2, 2, pw + 2), cf * CFrame.new(x, 3 + h + 1, 0), K.shade(pc, 0.85), { parent = m, studs = true })
		end
		local top = K.part(V(w + pw * 2 + 4, 6, pw + 1), cf * CFrame.new(0, 3 + h + 5, 0), pc, { parent = m, studs = true })
		K.part(V(w + pw * 2 + 4.6, 1, pw + 1.6), cf * CFrame.new(0, 3 + h + 2.3, 0), tc, { parent = m, collide = false })
		return m, top
	end

	------------------------------------------------------------------------------------------------------------
	-- Backdrop: big blocky hills / mountains 250-650 studs out from a path (list of points), plus a valley floor
	-- far below. Only a few huge parts each, and the Atmosphere haze turns them into soft silhouettes.
	------------------------------------------------------------------------------------------------------------
	function P.backdrop(pts, pal, parent, sides)
		local m = K.model("Backdrop", parent)
		local Y = V(0, 1, 0)
		local minY = math.huge
		for _, p in ipairs(pts) do minY = math.min(minY, p.Y) end
		local floorY = minY + (pal.floorY or -160)
		for i = 1, #pts - 1 do
			local a, b = pts[i], pts[i + 1]
			local d = V(b.X - a.X, 0, b.Z - a.Z)
			local len = d.Magnitude
			if len > 1 then
				local u = d.Unit
				local r = u:Cross(Y)
				local s = 0
				while s < len do
					for _, side in ipairs(sides or { -1, 1 }) do
						local off = K.rand(260, 560)
						local c = a + u * s + r * side * off
						local w = K.rand(150, 260)
						local h = K.rand(110, 260) + (pal.extraH or 0)
						local base = V(c.X, floorY, c.Z)
						local yaw = CFrame.Angles(0, math.rad(K.rand(0, 90)), 0)
						local tiers = 3
						local y = 0
						for t = 1, tiers do
							local f = 1 - (t - 1) * 0.28
							local th = h / tiers
							K.part(V(w * f, th, w * f * K.rand(0.8, 1.1)), CFrame.new(base + V(0, y + th / 2, 0)) * yaw * CFrame.Angles(0, math.rad(t * 17), 0), K.jitter(pal.base, 0.04), { parent = m, collide = false, shadow = false, studs = pal.studs })
							y = y + th
							K.part(V(w * f + 4, 6, w * f * 0.95 + 4), CFrame.new(base + V(0, y + 1, 0)) * yaw * CFrame.Angles(0, math.rad(t * 17), 0), K.jitter(t == tiers and (pal.peak or pal.grass) or pal.grass2, 0.04), { parent = m, collide = false, shadow = false, studs = true })
						end
					end
					s = s + K.rand(170, 260)
				end
				-- valley floor strip
				local mid = (a + b) / 2
				K.part(V(1800, 4, len + 400), CFrame.lookAt(V(mid.X, floorY, mid.Z), V(mid.X, floorY, mid.Z) + u), pal.floor, { parent = m, collide = false, shadow = false })
			end
		end
		return m
	end

	return P
end
