-- Eggs2: two voxel egg designs per world.
--   version 2 = built from the user's reference pictures; version 1 = my own take on the same theme.
-- build(world, version, cf, parent) -> Model "<World>Egg_v<n>" (PrimaryPart = invisible Core at the centre).
-- Front of every egg = cf's -Z. Egg body is ~10 wide, ~11 tall; wings / rings stick out further.
return function(K)
	local V = Vector3.new
	local rad = math.rad
	local rgb = K.rgb
	local N, LH = 10, 1.1
	local BOTTOM = -N * LH / 2

	------------------------------------------------------------------------------------------------------------
	-- helpers
	------------------------------------------------------------------------------------------------------------
	local function width(i, scale)
		local t = (i + 0.5) / N
		local s = t < 0.42 and t / 0.42 * 0.5 or 0.5 + (t - 0.42) / 0.58 * 0.5
		local r = 5 * (scale or 1) * math.sqrt(math.max(0, 1 - (2 * s - 1) ^ 2))
		return math.max(2.4, math.floor(2 * r / 0.8 + 0.5) * 0.8)
	end
	local function rowY(i) return BOTTOM + (i + 0.5) * LH end
	-- stacked studded layers; colFn(i) -> colour (or {colour, material})
	local function body(m, cf, colFn, o)
		o = o or {}
		local widths = {}
		for i = 0, N - 1 do
			local w = width(i, o.scale)
			widths[i] = w
			local c = colFn(i)
			K.part(V(w, LH, w), cf * CFrame.new(0, rowY(i), 0), c, { parent = m, collide = false, studs = true, name = "Layer", mat = o.mat and o.mat(i) or nil, neon = o.neon and o.neon(i) })
			if i > 0 and o.seams ~= false then K.part(V(w + 0.05, 0.1, w + 0.05), cf * CFrame.new(0, rowY(i) - LH / 2 + 0.03, 0), K.shade(c, 0.62), { parent = m, collide = false }) end
		end
		return widths
	end
	local function p(m, size, cf, col, o) o = o or {}; o.parent = m; if o.collide == nil then o.collide = false end; return K.part(size, cf, col, o) end
	-- little raised squares on the sides (the "bumps" in the references)
	local function bumps(m, cf, widths, rows, col, seed, count)
		local rr = Random.new(seed)
		for k = 1, count do
			local i = rows[rr:NextInteger(1, #rows)]
			local f = rr:NextInteger(0, 3)
			local half = widths[i] / 2
			local x = (rr:NextNumber() - 0.5) * (widths[i] - 2)
			p(m, V(1.1, 0.7, 0.25), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new(x, rowY(i), -(half + 0.1)), col)
		end
	end
	local function frontZ(widths, i) return -(widths[i] / 2) end

	------------------------------------------------------------------------------------------------------------
	-- ZOO
	------------------------------------------------------------------------------------------------------------
	local sand, sandD = rgb(232, 192, 140), rgb(206, 160, 110)
	local leaf, leafL, leafD = rgb(86, 190, 70), rgb(130, 222, 96), rgb(60, 150, 52)
	local function palmSprout(m, cf, lean)
		local c = cf
		for k = 0, 3 do
			c = c * CFrame.Angles(0, 0, rad(lean)) * CFrame.new(0, 0.8, 0)
			p(m, V(0.9, 0.9, 0.9), c, (k % 2 == 0) and rgb(170, 95, 45) or rgb(150, 82, 40))
		end
		local top = c * CFrame.new(0, 0.6, 0)
		for k = 0, 3 do
			local l = top * CFrame.Angles(0, rad(k * 90 + 45), 0) * CFrame.Angles(rad(25), 0, 0) * CFrame.new(0, 0, -1.4)
			p(m, V(1.2, 0.35, 2.6), l, (k % 2 == 0) and leaf or leafL, { studs = true })
			p(m, V(0.7, 0.3, 1.2), l * CFrame.new(0, -0.3, -1.6) * CFrame.Angles(rad(-30), 0, 0), leafD)
		end
	end
	local B = {}
	B["Zoo2"] = function(m, cf) -- reference: sandy base, grass cap dripping over, palm sprouts, leaf spikes
		local w = body(m, cf, function(i) return i <= 5 and ((i % 2 == 0) and sand or K.shade(sand, 0.95)) or ((i % 2 == 0) and leaf or K.shade(leaf, 0.93)) end)
		bumps(m, cf, w, { 1, 2, 3, 4 }, sandD, 3, 10)
		-- grass drips hanging over the sand on every side
		local rr = Random.new(5)
		for f = 0, 3 do
			for k = 0, 3 do
				local len = 1 + rr:NextInteger(0, 3) * 0.9
				local x = -3.4 + k * 2.3 + rr:NextNumber() * 0.4
				p(m, V(1.6, len, 0.6), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new(x, rowY(6) - len / 2 + 0.4, frontZ(w, 5) - 0.25), (k % 2 == 0) and leaf or leafD)
			end
		end
		-- leaf spikes over the cap
		for k = 0, 9 do
			local a = k * 36
			local c = cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, rowY(7), -(w[7] / 2 - 0.4)) * CFrame.Angles(rad(-40), 0, 0)
			p(m, V(1.3, 0.4, 2.2), c * CFrame.new(0, 0, -0.8), (k % 2 == 0) and leafL or leaf, { shape = "wedge" })
		end
		palmSprout(m, cf * CFrame.new(-1.6, rowY(9) + 0.3, 0.6), 14)
		palmSprout(m, cf * CFrame.new(1.8, rowY(9) + 0.3, -0.4), -12)
		return rgb(150, 230, 90)
	end
	B["Zoo1"] = function(m, cf) -- my take: jungle explorer egg - leafy canopy, vines, paw badge and a safari hat
		local w = body(m, cf, function(i) return i <= 6 and ((i % 2 == 0) and rgb(240, 214, 160) or rgb(226, 196, 140)) or leaf end)
		bumps(m, cf, w, { 1, 2, 5 }, rgb(200, 150, 90), 9, 8)
		-- leopard spots
		local rr = Random.new(11)
		for k = 1, 10 do
			local i = rr:NextInteger(1, 5); local f = rr:NextInteger(0, 3)
			p(m, V(0.9, 0.9, 0.2), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new((rr:NextNumber() - 0.5) * (w[i] - 2), rowY(i), frontZ(w, i) - 0.12), rgb(150, 95, 50))
		end
		-- paw badge on the front
		local fz = frontZ(w, 3) - 0.3
		p(m, V(3.6, 3.6, 0.4), cf * CFrame.new(0, rowY(3), fz + 0.1), rgb(255, 150, 40), { studs = true })
		p(m, V(1.6, 1.3, 0.3), cf * CFrame.new(0, rowY(3) - 0.5, fz - 0.15), rgb(110, 70, 40))
		for k, x in ipairs({ -1.1, -0.4, 0.4, 1.1 }) do p(m, V(0.55, 0.55, 0.3), cf * CFrame.new(x, rowY(3) + 0.7 + ((k == 2 or k == 3) and 0.3 or 0), fz - 0.15), rgb(110, 70, 40)) end
		-- vines down the sides
		for f = 1, 3 do
			for k = 0, 4 do p(m, V(0.5, 1.1, 0.4), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new((k % 2 == 0) and -1.5 or -1.1, rowY(7 - k), frontZ(w, 7 - k) - 0.15), (k % 2 == 0) and leafD or leaf) end
		end
		-- safari hat (pith helmet)
		local top = cf * CFrame.new(0, rowY(9) + LH / 2, 0)
		p(m, V(0.4, 6.4, 6.4), top * CFrame.new(0, 0.3, 0) * CFrame.Angles(0, 0, rad(90)), rgb(214, 186, 130), { shape = "cyl" })
		p(m, V(3.8, 1.8, 3.8), top * CFrame.new(0, 1.3, 0), rgb(226, 200, 146), { studs = true })
		p(m, V(3.9, 0.5, 3.9), top * CFrame.new(0, 0.7, 0), rgb(120, 80, 50))
		p(m, V(2.4, 0.8, 2.4), top * CFrame.new(0, 2.5, 0), rgb(226, 200, 146), { studs = true })
		return rgb(255, 180, 70)
	end

	------------------------------------------------------------------------------------------------------------
	-- DESERT
	------------------------------------------------------------------------------------------------------------
	local gold, goldD = rgb(255, 196, 50), rgb(220, 150, 30)
	local turq, red = rgb(60, 170, 255), rgb(170, 40, 40)
	local function wings(m, cf, w, col, colD, tips, spikes)
		-- tiers of studded plates fanning out on both sides, with feather tips along the bottom
		for _, sx in ipairs({ -1, 1 }) do
			for tier = 0, 2 do
				local len = 5 + tier * 1.6
				local base = cf * CFrame.new(sx * (w / 2 + 0.6), 1.2 - tier * 1.5, 1) * CFrame.Angles(0, 0, rad(sx * (25 - tier * 18)))
				local plate = base * CFrame.new(sx * len / 2, 0, 0)
				p(m, V(len, 2.2, 1), plate, (tier % 2 == 0) and col or colD, { studs = true })
				for k = 0, 3 do
					local tx = sx * (len * 0.35 + k * len * 0.18)
					local tc = tips[(k + tier) % #tips + 1]
					p(m, V(0.8, spikes and 2.4 or 0.7, spikes and 0.6 or 0.7), base * CFrame.new(tx, -1.6, 0) * CFrame.Angles(0, 0, rad(sx * 15)) * (spikes and CFrame.identity or CFrame.new(0, 0, 0)), tc)
					if not spikes then p(m, V(0.7, 0.7, 2.2), base * CFrame.new(tx, -1.5, 0.6) * CFrame.Angles(rad(-20), 0, 0), tc) end
				end
			end
		end
	end
	B["Desert2"] = function(m, cf) -- reference: brown box egg with a turquoise slot, gold wings with blue/red feathers
		local w = body(m, cf, function(i) return i <= 6 and ((i % 2 == 0) and rgb(150, 110, 70) or rgb(138, 100, 64)) or ((i % 2 == 0) and rgb(240, 200, 140) or rgb(226, 186, 126)) end, { scale = 0.9 })
		p(m, V(w[4] + 0.4, 0.8, w[4] + 0.4), cf * CFrame.new(0, rowY(6) + 0.6, 0), gold, { studs = true })
		p(m, V(w[1] + 0.3, 0.8, w[1] + 0.3), cf * CFrame.new(0, rowY(0), 0), goldD, { studs = true })
		p(m, V(0.9, 2.4, 0.3), cf * CFrame.new(0, rowY(3), frontZ(w, 3) - 0.1), turq, { neon = true })
		p(m, V(w[8] * 0.7, 1, 0.4), cf * CFrame.new(0, rowY(8), frontZ(w, 8)), rgb(40, 60, 110))
		wings(m, cf * CFrame.new(0, rowY(5), 0), w[5], gold, goldD, { turq, red, turq, red }, false)
		return rgb(255, 210, 90)
	end
	B["Desert1"] = function(m, cf) -- my take: pharaoh egg - nemes headdress stripes, eye of Horus, gold cobra
		local w = body(m, cf, function(i) return i >= 4 and ((i % 2 == 0) and gold or rgb(40, 90, 200)) or rgb(236, 200, 140) end)
		for _, sx in ipairs({ -1, 1 }) do -- headdress flaps
			for k = 0, 3 do p(m, V(2, 1.1, 2.6), cf * CFrame.new(sx * (w[4] / 2 + 0.5), rowY(4) - k * 1.1, -1), (k % 2 == 0) and gold or rgb(40, 90, 200), { studs = true }) end
		end
		local fz = frontZ(w, 2) - 0.2
		local eye = { "..####..", ".#....#.", "#..##..#", ".#....#.", "..####..", ".....#..", "....#..." }
		for r, row in ipairs(eye) do for c = 1, #row do if row:sub(c, c) == "#" then p(m, V(0.45, 0.45, 0.3), cf * CFrame.new((c - 4.5) * 0.45, rowY(2) + (4 - r) * 0.45, fz), rgb(30, 110, 200), { neon = r == 3 }) end end end
		-- gold cobra on the forehead
		local cb = cf * CFrame.new(0, rowY(7), frontZ(w, 7) - 0.4)
		p(m, V(0.8, 2.4, 0.8), cb, gold)
		p(m, V(1.6, 1, 0.6), cb * CFrame.new(0, 1.4, 0), gold, { studs = true })
		p(m, V(0.5, 0.5, 0.3), cb * CFrame.new(0, 1.4, -0.4), red, { neon = true })
		p(m, V(1.4, 1.4, 1.4), cf * CFrame.new(0, rowY(9) + 1, 0) * CFrame.Angles(rad(45), 0, rad(45)), turq, { neon = true })
		return rgb(255, 210, 90)
	end

	------------------------------------------------------------------------------------------------------------
	-- SNOW (penguin)
	------------------------------------------------------------------------------------------------------------
	local black, white, orange = rgb(40, 44, 58), rgb(245, 248, 255), rgb(255, 150, 40)
	local function penguinFace(m, cf, w, i)
		local fz = frontZ(w, i) - 0.15
		for _, sx in ipairs({ -1, 1 }) do
			p(m, V(1.2, 1.2, 0.3), cf * CFrame.new(sx * 1.6, rowY(i) + 0.6, fz), white)
			p(m, V(0.6, 0.7, 0.3), cf * CFrame.new(sx * 1.6, rowY(i) + 0.6, fz - 0.15), rgb(20, 20, 30))
			p(m, V(0.25, 0.25, 0.2), cf * CFrame.new(sx * 1.5, rowY(i) + 0.8, fz - 0.3), white)
		end
		p(m, V(1.6, 0.8, 1.4), cf * CFrame.new(0, rowY(i) - 0.3, fz - 0.6), orange, { studs = true })
	end
	B["Snow2"] = function(m, cf) -- reference style (banded egg with horns) as a penguin: red scarf band, ice-white "horns" = crest feathers
		local w = body(m, cf, function(i) return (i == 5) and rgb(170, 30, 40) or ((i >= 6) and black or ((i % 2 == 0) and rgb(52, 58, 76) or black)) end)
		-- white belly panel on the front
		for i = 0, 4 do p(m, V(w[i] * 0.62, LH, 0.6), cf * CFrame.new(0, rowY(i), frontZ(w, i) + 0.2), (i % 2 == 0) and white or rgb(230, 236, 248), { studs = true }) end
		penguinFace(m, cf, w, 7)
		bumps(m, cf, w, { 5 }, rgb(120, 20, 30), 4, 8)
		-- scarf tail
		p(m, V(1.6, 3, 0.5), cf * CFrame.new(2.2, rowY(4), frontZ(w, 4) - 0.3) * CFrame.Angles(0, 0, rad(10)), rgb(170, 30, 40), { studs = true })
		-- two curved ice crest feathers on top (the reference's "horns")
		for _, sx in ipairs({ -1, 1 }) do
			local c = cf * CFrame.new(sx * 1.2, rowY(9) + 0.5, 0)
			for k = 0, 2 do
				c = c * CFrame.Angles(0, 0, rad(-sx * 18)) * CFrame.new(0, 1, 0)
				p(m, V(1.1, 1.3, 1.1), c, (k == 2) and rgb(200, 235, 255) or rgb(230, 245, 255), { studs = true })
			end
		end
		-- flippers + feet
		for _, sx in ipairs({ -1, 1 }) do
			p(m, V(0.6, 3.6, 1.8), cf * CFrame.new(sx * (w[4] / 2 + 0.3), rowY(3), 0) * CFrame.Angles(0, 0, rad(sx * 15)), black)
			p(m, V(1.8, 0.5, 2.2), cf * CFrame.new(sx * 1.4, rowY(0) - 0.6, -1.4), orange, { studs = true })
		end
		return rgb(150, 220, 255)
	end
	B["Snow1"] = function(m, cf) -- my take: frosty penguin with earmuffs, snow cap and icicles
		local w = body(m, cf, function(i) return (i >= 3) and black or rgb(52, 58, 76) end)
		for i = 0, 6 do p(m, V(w[i] * 0.66, LH, 0.6), cf * CFrame.new(0, rowY(i), frontZ(w, i) + 0.2), white, { studs = true }) end
		penguinFace(m, cf, w, 6)
		p(m, V(w[9] + 0.6, 1.2, w[9] + 0.6), cf * CFrame.new(0, rowY(9) + 0.4, 0), white, { studs = true, mat = Enum.Material.Snow })
		for _, sx in ipairs({ -1, 1 }) do -- earmuffs
			p(m, V(1.2, 2.4, 2.4), cf * CFrame.new(sx * (w[7] / 2 + 0.5), rowY(7), 0), rgb(120, 200, 255), { studs = true })
			p(m, V(1.4, 1.6, 1.6), cf * CFrame.new(sx * (w[7] / 2 + 0.6), rowY(7), 0), white)
		end
		p(m, V(w[9] + 1.6, 0.5, 0.5), cf * CFrame.new(0, rowY(9) + 1.3, 0), rgb(120, 200, 255))
		for k = 0, 7 do -- icicles under the belly line
			local a = k * 45
			local len = 1 + (k % 3) * 0.6
			p(m, V(0.5, len, 0.5), cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, rowY(2) - len / 2, -(w[2] / 2 + 0.1)), rgb(190, 235, 255), { glass = true, transp = 0.1 })
		end
		for _, sx in ipairs({ -1, 1 }) do p(m, V(1.8, 0.5, 2.2), cf * CFrame.new(sx * 1.4, rowY(0) - 0.6, -1.4), orange, { studs = true }) end
		return rgb(150, 220, 255)
	end

	------------------------------------------------------------------------------------------------------------
	-- FOREST (bee)
	------------------------------------------------------------------------------------------------------------
	local bee, beeD, ink = rgb(255, 150, 40), rgb(235, 120, 30), rgb(30, 30, 34)
	local function beeWings(m, cf, w)
		for _, sx in ipairs({ -1, 1 }) do
			for k = 0, 1 do
				local c = cf * CFrame.new(sx * 2, rowY(7 - k * 2), 2.6) * CFrame.Angles(rad(-20), rad(sx * (30 + k * 15)), rad(sx * (35 - k * 30)))
				p(m, V(0.3, 3.6 - k, 5.6 - k), c * CFrame.new(0, 0, 2.4), rgb(220, 240, 255), { glass = true, transp = 0.35 })
				p(m, V(0.35, 3.8 - k, 0.4), c * CFrame.new(0, 0, 0), rgb(200, 220, 240))
			end
		end
	end
	local function antennae(m, cf, w)
		for _, sx in ipairs({ -1, 1 }) do
			local c = cf * CFrame.new(sx * 1, rowY(9) + 0.5, -0.6)
			for k = 0, 2 do c = c * CFrame.Angles(0, 0, rad(-sx * 15)) * CFrame.new(0, 0.9, 0); p(m, V(0.4, 1, 0.4), c, ink) end
			p(m, V(0.9, 0.9, 0.9), c * CFrame.new(0, 0.7, 0), ink, { shape = "ball" })
		end
	end
	B["Forest2"] = function(m, cf) -- reference: orange/black striped panel egg -> bee
		local w = body(m, cf, function(i) return (i == 3 or i == 6) and ink or ((i % 2 == 0) and bee or beeD) end)
		-- raised panel blocks with slots (reference look)
		for f = 0, 3 do
			for _, i in ipairs({ 1, 4, 7 }) do
				for k = -1, 1 do p(m, V(1.8, 0.8, 0.3), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new(k * 2.2, rowY(i), frontZ(w, i) - 0.12), (i == 4) and K.shade(bee, 1.06) or beeD, { studs = true }) end
			end
			for k = -1, 1 do p(m, V(1.4, 0.3, 0.25), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new(k * 2.2, rowY(3), frontZ(w, 3) - 0.12), rgb(70, 70, 80)) end
		end
		beeWings(m, cf, w); antennae(m, cf, w)
		p(m, V(1, 1.4, 1), cf * CFrame.new(0, rowY(0) - 0.9, 0.4) * CFrame.Angles(rad(30), 0, 0), ink)
		return rgb(255, 190, 60)
	end
	B["Forest1"] = function(m, cf) -- my take: beehive egg with honey drips and tiny bees buzzing around
		local w = body(m, cf, function(i) return (i % 2 == 0) and rgb(250, 196, 70) or rgb(214, 150, 40) end, { seams = true })
		for k = 0, 5 do -- honey drips
			local len = 1 + (k % 3) * 0.8
			p(m, V(1, len, 0.5), cf * CFrame.Angles(0, rad(k * 60 + 15), 0) * CFrame.new(0, rowY(8) - len / 2, -(w[8] / 2 + 0.05)), rgb(255, 170, 30), { glass = true, transp = 0.1 })
		end
		local fz = frontZ(w, 3) - 0.1
		p(m, V(2.6, 2.2, 0.8), cf * CFrame.new(0, rowY(3), fz + 0.25), rgb(80, 50, 30)) -- hive door
		for _, sx in ipairs({ -1, 1 }) do -- leaves on top
			p(m, V(2.8, 0.4, 1.4), cf * CFrame.new(sx * 1.4, rowY(9) + 0.8, 0) * CFrame.Angles(0, 0, rad(sx * 25)), leaf, { studs = true })
		end
		p(m, V(0.5, 1.2, 0.5), cf * CFrame.new(0, rowY(9) + 0.9, 0), rgb(110, 76, 46))
		for k = 0, 2 do -- little bees orbiting
			local c = cf * CFrame.Angles(0, rad(k * 120 + 30), 0) * CFrame.new(0, rowY(2 + k * 3), -(w[2 + k * 3] / 2 + 2.2))
			p(m, V(1.2, 0.9, 0.9), c, rgb(255, 200, 50), { studs = true })
			p(m, V(0.3, 0.92, 0.92), c, ink)
			p(m, V(0.2, 0.8, 1.2), c * CFrame.new(0, 0.7, 0.1) * CFrame.Angles(0, 0, rad(30)), rgb(220, 240, 255), { glass = true, transp = 0.3 })
		end
		return rgb(255, 190, 60)
	end

	------------------------------------------------------------------------------------------------------------
	-- VOLCANO (devilish)
	------------------------------------------------------------------------------------------------------------
	local maroon, maroonD, crimson = rgb(120, 50, 50), rgb(70, 36, 40), rgb(170, 30, 30)
	local function horns(m, cf, w, col, tip)
		for _, sx in ipairs({ -1, 1 }) do
			local c = cf * CFrame.new(sx * 1.8, rowY(9) + 0.2, 0)
			for k = 0, 4 do
				c = c * CFrame.Angles(0, 0, rad(-sx * (k < 2 and 8 or 26))) * CFrame.new(0, 0.95, 0)
				p(m, V(1.3 - k * 0.15, 1.1, 1.3 - k * 0.15), c, (k == 4 and tip) or col, { studs = true, neon = k == 4 and tip ~= nil })
			end
		end
	end
	B["Volcano2"] = function(m, cf) -- reference: maroon diamond-pattern egg, dark bands, curved black horns, red spiky wings
		local w = body(m, cf, function(i) return (i == 2 or i == 6) and crimson or ((i % 2 == 0) and maroon or maroonD) end)
		for f = 0, 3 do -- diamond (X) pattern lines
			for _, i in ipairs({ 1, 4, 8 }) do
				for k = -1, 1 do
					p(m, V(0.25, 1.4, 0.2), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new(k * 2.2, rowY(i), frontZ(w, i) - 0.1) * CFrame.Angles(0, 0, rad(45)), K.shade(maroon, 0.6))
					p(m, V(0.25, 1.4, 0.2), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new(k * 2.2, rowY(i), frontZ(w, i) - 0.1) * CFrame.Angles(0, 0, rad(-45)), K.shade(maroon, 0.6))
				end
			end
		end
		horns(m, cf, w, rgb(40, 40, 46))
		wings(m, cf * CFrame.new(0, rowY(6), 0), w[6], rgb(140, 44, 44), rgb(110, 34, 36), { crimson, rgb(200, 40, 40), crimson }, true)
		return rgb(255, 80, 50)
	end
	B["Volcano1"] = function(m, cf) -- my take: lava demon - obsidian shell, glowing cracks, demon face, red-tipped horns, arrow tail
		local w = body(m, cf, function(i) return (i % 2 == 0) and rgb(40, 34, 38) or rgb(54, 44, 46) end, { mat = function() return Enum.Material.Basalt end })
		local rr = Random.new(13)
		for c = 1, 6 do
			local f = rr:NextInteger(0, 3); local x = (rr:NextNumber() - 0.5) * 6; local i = rr:NextInteger(1, 8)
			for k = 0, 2 do p(m, V(0.3, 1.2, 0.2), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new(x + k * 0.4, rowY(math.max(0, i - k)), frontZ(w, math.max(0, i - k)) - 0.1) * CFrame.Angles(0, 0, rad((k % 2 == 0) and 25 or -25)), rgb(255, 120, 30), { neon = true }) end
		end
		local fz = frontZ(w, 5) - 0.15
		for _, sx in ipairs({ -1, 1 }) do -- angry glowing eyes + brows
			p(m, V(1.4, 0.7, 0.3), cf * CFrame.new(sx * 1.5, rowY(5) + 0.5, fz), rgb(255, 220, 60), { neon = true })
			p(m, V(1.8, 0.4, 0.3), cf * CFrame.new(sx * 1.5, rowY(5) + 1.2, fz) * CFrame.Angles(0, 0, rad(sx * -20)), rgb(20, 16, 20))
		end
		p(m, V(3.4, 0.6, 0.3), cf * CFrame.new(0, rowY(3) + 0.4, frontZ(w, 3) - 0.15), rgb(20, 16, 20))
		for k = -1, 1, 2 do p(m, V(0.5, 0.8, 0.3), cf * CFrame.new(k * 1, rowY(3) - 0.1, frontZ(w, 3) - 0.2) * CFrame.Angles(0, 0, rad(45)), rgb(245, 240, 230)) end
		horns(m, cf, w, rgb(30, 26, 30), rgb(255, 60, 40))
		local tc = cf * CFrame.new(0, rowY(1), w[1] / 2 + 0.3)
		for k = 0, 3 do tc = tc * CFrame.Angles(rad(-25), 0, 0) * CFrame.new(0, 0, 0.9); p(m, V(0.5, 0.5, 1), tc, crimson) end
		p(m, V(1.2, 1.2, 0.4), tc * CFrame.new(0, 0, 0.8) * CFrame.Angles(0, 0, rad(45)), crimson)
		local core = p(m, V(1, 1, 1), cf, crimson, { transp = 1 })
		K.sparkle(core, rgb(255, 110, 40), { rate = 6, size = 0.4, accel = V(0, 4, 0), name = "Embers" })
		return rgb(255, 100, 40)
	end

	------------------------------------------------------------------------------------------------------------
	-- SPACE (planet)
	------------------------------------------------------------------------------------------------------------
	local function ring(m, cf, r, thick, col, edge, n)
		n = n or 28
		for k = 1, n do
			local a = (k - 0.5) / n * math.pi * 2
			local seg = 2 * r * math.tan(math.pi / n) + 0.1
			p(m, V(thick, 0.45, seg), cf * CFrame.Angles(0, -a, 0) * CFrame.new(r, 0, 0), col, { neon = true })
			if edge then p(m, V(0.4, 0.5, seg), cf * CFrame.Angles(0, -a, 0) * CFrame.new(r + thick / 2 + 0.15, 0, 0), edge) end
		end
	end
	B["Space2"] = function(m, cf) -- reference: pastel teal / tan / pink bands with bumps, big cyan ring
		local cols = { rgb(240, 150, 200), rgb(214, 180, 130), rgb(240, 150, 200), rgb(214, 180, 130), rgb(240, 150, 200), rgb(60, 170, 180), rgb(214, 180, 130), rgb(60, 170, 180), rgb(214, 180, 130), rgb(60, 170, 180) }
		local w = body(m, cf, function(i) return cols[i + 1] end)
		for f = 0, 3 do for _, i in ipairs({ 2, 4, 6, 8 }) do
			for k = -1, 1, 2 do p(m, V(1.1, 0.7, 0.25), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new(k * 1.6, rowY(i), frontZ(w, i) - 0.1), K.shade(cols[i + 1], 0.85)) end
		end end
		ring(m, cf * CFrame.new(0, rowY(3), 0) * CFrame.Angles(rad(-12), 0, rad(8)), 8.4, 2.6, rgb(90, 230, 255), rgb(245, 250, 255))
		return rgb(110, 230, 255)
	end
	B["Space1"] = function(m, cf) -- my take: gas-giant egg with two crossing neon rings, a moon and craters
		local cols = { rgb(70, 40, 140), rgb(110, 60, 190), rgb(150, 90, 220), rgb(110, 60, 190), rgb(200, 120, 230), rgb(150, 90, 220), rgb(110, 60, 190), rgb(70, 140, 220), rgb(110, 60, 190), rgb(70, 40, 140) }
		local w = body(m, cf, function(i) return cols[i + 1] end)
		local rr = Random.new(23)
		for k = 1, 6 do -- craters
			local i = rr:NextInteger(1, 8); local f = rr:NextInteger(0, 3)
			local c = cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new((rr:NextNumber() - 0.5) * (w[i] - 2.5), rowY(i), frontZ(w, i) - 0.1)
			p(m, V(1.4, 1.4, 0.2), c, K.shade(cols[i + 1], 0.7)); p(m, V(0.8, 0.8, 0.25), c, K.shade(cols[i + 1], 0.55))
		end
		for k = 1, 10 do p(m, V(0.3, 0.3, 0.3), cf * CFrame.Angles(0, rad(rr:NextNumber() * 360), 0) * CFrame.new(0, rowY(rr:NextInteger(0, 9)), -5.3), rgb(255, 255, 255), { neon = true }) end
		ring(m, cf * CFrame.new(0, rowY(4), 0) * CFrame.Angles(rad(18), 0, rad(-10)), 7.6, 1.4, rgb(255, 120, 220), nil, 24)
		ring(m, cf * CFrame.new(0, rowY(5), 0) * CFrame.Angles(rad(-25), rad(40), rad(15)), 8.2, 1, rgb(120, 230, 255), nil, 24)
		p(m, V(2.4, 2.4, 2.4), cf * CFrame.new(6.6, rowY(8), -1.5), rgb(220, 220, 235), { shape = "ball" })
		p(m, V(0.8, 0.8, 0.8), cf * CFrame.new(6.2, rowY(8) + 0.5, -2.5), rgb(180, 180, 195), { shape = "ball" })
		return rgb(180, 110, 255)
	end

	return function(world, version, cf, parent)
		local m = K.model(world .. "Egg_v" .. version, parent)
		local core = K.part(V(1, 1, 1), cf, Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Core" })
		local glow = B[world .. version](m, cf)
		m.PrimaryPart = core
		m:SetAttribute("Glow", glow)
		return m, glow
	end
end
