-- Eggs: one detailed voxel egg per world, in the style of the reference eggs: stacked studded layers that step
-- in to an egg silhouette, framed panels on all four sides, a pixel-art emblem on the front, a collar of
-- leaves / spikes / shards around the lower body, a themed topper and small inset pixel details.
-- Returns build(world, cf, parent) -> Model "<World>Egg" (PrimaryPart = invisible Core at the egg's centre).
return function(K)
	local V = Vector3.new
	local rad = math.rad
	local rgb = K.rgb

	-- pixel emblems ('#' = main colour, 'o' = second colour, '.' = empty)
	local ART = {
		paw = { ".##.##.", ".##.##.", "#.....#", "#.###.#", "..###..", ".#####.", ".#####." },
		eye = { ".......", "..###..", ".#...#.", "#..o..#", ".#...#.", "..###..", "...#.#." },
		flake = { "#..#..#", ".#.#.#.", "..###..", "###o###", "..###..", ".#.#.#.", "#..#..#" },
		leaf = { "....###", "..#####", ".###o##", "###o###", "##o####", "#o####.", "o......" },
		skull = { ".#####.", "#######", "#..#..#", "#..#..#", "###.###", ".#####.", ".#.#.#." },
		star = { "...#...", "..###..", "###o###", ".##o##.", "..###..", ".##.##.", "#.....#" },
	}

	local PAL = {
		Zoo = { body = rgb(92, 186, 70), frame = rgb(240, 140, 50), panel = rgb(126, 208, 92), art = "paw", a1 = rgb(255, 240, 205), a2 = rgb(255, 240, 205), collar = "leaf", c1 = rgb(62, 140, 50), c2 = rgb(120, 200, 80), top = "palm", glow = rgb(255, 170, 60) },
		Desert = { body = rgb(232, 192, 112), frame = rgb(46, 176, 176), panel = rgb(246, 214, 146), art = "eye", a1 = rgb(110, 62, 30), a2 = rgb(46, 200, 200), collar = "spike", c1 = rgb(196, 146, 86), c2 = rgb(255, 214, 90), top = "pyramid", glow = rgb(255, 200, 80) },
		Snow = { body = rgb(214, 236, 252), frame = rgb(90, 165, 235), panel = rgb(240, 249, 255), art = "flake", a1 = rgb(110, 195, 255), a2 = rgb(255, 255, 255), collar = "ice", c1 = rgb(160, 220, 255), c2 = rgb(235, 250, 255), top = "crystals", glow = rgb(120, 210, 255), neonArt = true },
		Forest = { body = rgb(108, 148, 70), frame = rgb(122, 80, 46), panel = rgb(138, 178, 90), art = "leaf", a1 = rgb(200, 240, 120), a2 = rgb(80, 130, 50), collar = "leaf", c1 = rgb(60, 120, 45), c2 = rgb(150, 205, 90), top = "mushroom", glow = rgb(140, 230, 90) },
		Volcano = { body = rgb(58, 52, 54), frame = rgb(255, 118, 36), panel = rgb(80, 70, 70), art = "skull", a1 = rgb(240, 234, 222), a2 = rgb(240, 234, 222), collar = "rock", c1 = rgb(70, 62, 60), c2 = rgb(255, 130, 40), top = "volcano", glow = rgb(255, 110, 40), neonFrame = true },
		Space = { body = rgb(62, 42, 132), frame = rgb(120, 220, 255), panel = rgb(92, 62, 170), art = "star", a1 = rgb(255, 228, 110), a2 = rgb(255, 120, 220), collar = "crystal", c1 = rgb(190, 120, 255), c2 = rgb(120, 230, 255), top = "planet", glow = rgb(180, 110, 255), neonArt = true, neonFrame = true },
	}

	local N, LH = 10, 1.1 -- layers, layer height (egg is ~10 wide, 11 tall)

	local function build(world, cf, parent)
		local P = PAL[world]
		local m = K.model(world .. "Egg", parent)
		local core = K.part(V(1, 1, 1), cf, Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Core" })
		local o = { parent = m, collide = false }
		local bottom = -N * LH / 2
		local widths = {}
		-- stepped body
		for i = 0, N - 1 do
			local t = (i + 0.5) / N
			local s = t < 0.42 and t / 0.42 * 0.5 or 0.5 + (t - 0.42) / 0.58 * 0.5
			local r = 5 * math.sqrt(math.max(0, 1 - (2 * s - 1) ^ 2))
			local w = math.max(2.4, math.floor(2 * r / 0.8 + 0.5) * 0.8)
			widths[i] = w
			local y = bottom + (i + 0.5) * LH
			K.part(V(w, LH, w), cf * CFrame.new(0, y, 0), (i % 2 == 0) and P.body or K.shade(P.body, 0.92), { parent = m, collide = false, studs = true, name = "Layer" })
			-- dark seam under each layer (the grooves in the references)
			if i > 0 then K.part(V(w + 0.05, 0.12, w + 0.05), cf * CFrame.new(0, y - LH / 2 + 0.03, 0), K.shade(P.body, 0.65), o) end
		end
		-- framed panels on the four sides (rows 3..6); the front one carries the emblem
		local halfW = 0
		for i = 3, 6 do halfW = math.max(halfW, widths[i] / 2) end
		local pw, ph = 6.6, 4.4
		local frameOpt = { parent = m, collide = false, neon = P.neonFrame, studs = not P.neonFrame }
		for f = 0, 3 do
			local fc = cf * CFrame.Angles(0, rad(f * 90), 0)
			K.part(V(pw, ph, 1.2), fc * CFrame.new(0, 0, -(halfW - 0.25)), P.panel, { parent = m, collide = false, studs = true })
			for _, sy in ipairs({ -1, 1 }) do K.part(V(pw + 0.9, 0.55, 0.6), fc * CFrame.new(0, sy * (ph / 2 + 0.05), -(halfW + 0.45)), P.frame, frameOpt) end
			for _, sx in ipairs({ -1, 1 }) do K.part(V(0.55, ph + 0.6, 0.6), fc * CFrame.new(sx * (pw / 2 + 0.15), 0, -(halfW + 0.45)), P.frame, frameOpt) end
			if f == 0 then
				local art = ART[P.art]
				local ps = 0.55
				for r, row in ipairs(art) do
					for c = 1, #row do
						local ch = row:sub(c, c)
						if ch ~= "." then
							K.part(V(ps, ps, 0.3), fc * CFrame.new((c - 4) * ps, (4 - r) * ps, -(halfW + 0.5)), ch == "#" and P.a1 or P.a2, { parent = m, collide = false, neon = P.neonArt and ch == "o" or (P.neonArt and world == "Snow") })
						end
					end
				end
			else
				-- corner tiles with little notches + a centre stud block
				for _, sx in ipairs({ -1, 1 }) do
					for _, sy in ipairs({ -1, 1 }) do
						K.part(V(1.5, 1.2, 0.25), fc * CFrame.new(sx * 2.1, sy * 1.2, -(halfW + 0.42)), K.shade(P.panel, 0.85), o)
						K.part(V(0.5, 0.5, 0.25), fc * CFrame.new(sx * 1.5, sy * 0.85, -(halfW + 0.55)), P.frame, o)
					end
				end
				K.part(V(1.4, 1.4, 0.4), fc * CFrame.new(0, 0, -(halfW + 0.45)) * CFrame.Angles(0, 0, rad(45)), P.frame, frameOpt)
			end
		end
		-- small inset pixel details on the other layers (like the little squares in the references)
		local rr = Random.new(#world * 7)
		for _, i in ipairs({ 1, 2, 7, 8, 1, 2, 7, 8, 2, 7, 1, 8 }) do
			local f = rr:NextInteger(0, 3)
			local half = widths[i] / 2
			local x = (rr:NextNumber() - 0.5) * (widths[i] - 1.6)
			local y = bottom + (i + 0.5) * LH
			K.part(V(0.7, 0.55, 0.2), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new(x, y, -(half + 0.05)), K.shade(P.body, 0.72), o)
		end
		-- collar around the lower body (row 2)
		local cy = bottom + 2.6 * LH
		local cr = widths[2] / 2
		for i = 0, 11 do
			local a = i * 30 + 15
			local base = cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, cy, -(cr + 0.6))
			if P.collar == "leaf" then
				local blade = base * CFrame.Angles(rad(-28), 0, 0) * CFrame.new(0, 0, -1.6)
				K.part(V(1.7, 0.45, 3.4), blade, (i % 2 == 0) and P.c1 or P.c2, o)
				K.part(V(1.1, 0.4, 1.6), blade * CFrame.new(0, -0.35, -2.2) * CFrame.Angles(rad(-20), 0, 0), P.c2, o)
				K.part(V(0.3, 0.5, 2.6), blade * CFrame.new(0, 0.1, 0), K.shade(P.c1, 0.8), o)
			else
				local spike = base * CFrame.Angles(rad(-22), 0, 0) * CFrame.new(0, 0, -1.4)
				local col = (i % 2 == 0) and P.c1 or K.shade(P.c1, 1.1)
				local glass = P.collar == "ice" or P.collar == "crystal"
				K.part(V(1.3, 1.3, 2.8), spike * CFrame.Angles(0, 0, rad(45)), col, { parent = m, collide = false, glass = glass, transp = glass and 0.15 or 0, neon = P.collar == "crystal" and i % 2 == 1 })
				K.part(V(0.8, 0.8, 1.2), spike * CFrame.new(0, 0, -1.9) * CFrame.Angles(0, 0, rad(45)), P.c2, { parent = m, collide = false, neon = P.collar ~= "spike" and P.collar ~= "ice", glass = P.collar == "ice" })
			end
		end
		-- topper
		local top = cf * CFrame.new(0, bottom + N * LH, 0)
		if P.top == "palm" then
			K.part(V(1.6, 1.4, 1.6), top * CFrame.new(0, 0.7, 0), rgb(150, 100, 55), o)
			for i = 0, 5 do
				local l = top * CFrame.new(0, 1.4, 0) * CFrame.Angles(0, rad(i * 60), 0) * CFrame.Angles(rad(35), 0, 0) * CFrame.new(0, 0, -1.6)
				K.part(V(1.4, 0.45, 3.2), l, (i % 2 == 0) and P.c1 or P.c2, o)
				K.part(V(0.9, 0.4, 1.4), l * CFrame.new(0, -0.4, -1.9) * CFrame.Angles(rad(-35), 0, 0), P.c2, o)
			end
			K.part(V(1.4, 1.6, 1.4), top * CFrame.new(0, 2.2, 0) * CFrame.Angles(0, rad(45), 0), P.c2, o)
		elseif P.top == "pyramid" then
			for k = 0, 2 do K.part(V(3.2 - k, 0.7, 3.2 - k), top * CFrame.new(0, 0.35 + k * 0.7, 0), rgb(255, 205, 70), { parent = m, collide = false, studs = true }) end
			K.part(V(0.9, 0.9, 0.9), top * CFrame.new(0, 2.6, 0) * CFrame.Angles(rad(45), 0, rad(45)), P.frame, { parent = m, collide = false, neon = true })
		elseif P.top == "crystals" then
			for k = 0, 2 do
				local h = 3 - k * 0.6
				K.part(V(0.9, h, 0.9), top * CFrame.Angles(0, rad(k * 120), 0) * CFrame.new(k == 0 and 0 or 0.7, h / 2, 0) * CFrame.Angles(0, 0, rad(k == 0 and 0 or -18)) * CFrame.Angles(0, rad(45), 0), P.c1, { parent = m, collide = false, glass = true, transp = 0.1 })
			end
		elseif P.top == "mushroom" then
			K.part(V(1, 1.6, 1), top * CFrame.new(0, 0.8, 0), rgb(245, 235, 210), o)
			K.part(V(3.2, 0.9, 3.2), top * CFrame.new(0, 1.9, 0), rgb(220, 60, 50), { parent = m, collide = false, studs = true })
			K.part(V(2, 0.7, 2), top * CFrame.new(0, 2.6, 0), rgb(220, 60, 50), o)
			for k = 0, 3 do K.part(V(0.5, 0.2, 0.5), top * CFrame.Angles(0, rad(k * 90 + 20), 0) * CFrame.new(0, 2.4, -1.25), rgb(255, 255, 255), o) end
		elseif P.top == "volcano" then
			K.part(V(2.6, 1, 2.6), top * CFrame.new(0, 0.5, 0), rgb(70, 60, 58), { parent = m, collide = false, studs = true })
			K.part(V(1.8, 0.8, 1.8), top * CFrame.new(0, 1.4, 0), rgb(85, 72, 68), o)
			local lava = K.part(V(1.1, 0.4, 1.1), top * CFrame.new(0, 1.85, 0), rgb(255, 140, 40), { parent = m, collide = false, neon = true })
			for k = 0, 3 do K.part(V(0.35, 1.2, 0.3), top * CFrame.Angles(0, rad(k * 90 + 45), 0) * CFrame.new(0, 1.1, -1), rgb(255, 120, 40), { parent = m, collide = false, neon = true }) end
			K.sparkle(lava, rgb(255, 120, 40), { rate = 6, size = 0.4, accel = V(0, 5, 0), speed = NumberRange.new(1, 3), name = "Embers" })
		elseif P.top == "planet" then
			K.part(V(1.4, 1.4, 1.4), top * CFrame.new(0, 0.7, 0), rgb(150, 120, 230), o)
			local pc = top * CFrame.new(0, 2, 0)
			K.part(V(2, 2, 2), pc, rgb(255, 150, 220), { parent = m, collide = false, shape = "ball" })
			for k = 0, 11 do
				K.part(V(0.35, 0.2, 0.75), pc * CFrame.Angles(rad(20), 0, 0) * CFrame.Angles(0, rad(k * 30), 0) * CFrame.new(1.7, 0, 0), P.c2, { parent = m, collide = false, neon = true })
			end
		end
		m.PrimaryPart = core
		m:SetAttribute("Glow", P.glow)
		return m, P.glow
	end
	return build
end
