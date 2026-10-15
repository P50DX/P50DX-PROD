-- Shops2: shop designs in every world theme, two versions.
--   version 2 = the reference look: chunky studded toy-brick market stall (posts, counter, striped awning with a
--               scalloped edge, framed navy sign board, goods on the counter)
--   version 1 = my take: a themed little shop building per world (safari hut, desert bazaar, snowy cabin,
--               mossy log cabin, obsidian forge, sci-fi dome kiosk)
-- build(theme, version, cf, info, parent): info = { id, title, color, iconKind }. Front = cf's -Z.
return function(K, P, S)
	local V = Vector3.new
	local rad = math.rad
	local rgb = K.rgb
	local function p(m, size, cf, col, o) o = o or {}; o.parent = m; return K.part(size, cf, col, o) end
	local function lego(m, size, cf, col, o) o = o or {}; o.lego = true; o.parent = m; return K.part(size, cf, col, o) end

	local TH = {
		Zoo = { frame = rgb(255, 140, 30), frameD = rgb(220, 110, 20), stripe2 = rgb(250, 250, 255), ground = rgb(80, 200, 70), panel = rgb(26, 40, 90), cap = rgb(40, 140, 230), wood = rgb(186, 124, 70) },
		Desert = { frame = rgb(232, 190, 120), frameD = rgb(200, 150, 90), stripe2 = rgb(255, 245, 220), ground = rgb(240, 208, 146), panel = rgb(40, 50, 90), cap = rgb(46, 176, 176), wood = rgb(170, 110, 60) },
		Snow = { frame = rgb(120, 200, 255), frameD = rgb(80, 160, 230), stripe2 = rgb(255, 255, 255), ground = rgb(236, 246, 255), panel = rgb(30, 50, 100), cap = rgb(230, 70, 80), wood = rgb(150, 100, 70) },
		Forest = { frame = rgb(150, 100, 56), frameD = rgb(120, 78, 42), stripe2 = rgb(250, 245, 225), ground = rgb(76, 160, 64), panel = rgb(30, 50, 40), cap = rgb(110, 190, 70), wood = rgb(140, 96, 56) },
		Volcano = { frame = rgb(60, 52, 54), frameD = rgb(40, 34, 36), stripe2 = rgb(255, 150, 40), ground = rgb(90, 80, 78), panel = rgb(30, 20, 24), cap = rgb(255, 110, 30), wood = rgb(80, 60, 50), neon = true },
		Space = { frame = rgb(80, 70, 140), frameD = rgb(56, 48, 104), stripe2 = rgb(120, 230, 255), ground = rgb(60, 52, 108), panel = rgb(20, 16, 44), cap = rgb(120, 230, 255), wood = rgb(90, 84, 140), neon = true },
	}

	-- goods on a counter (themed little items)
	local function goods(m, cf, theme, c, n)
		for i = 0, n - 1 do
			local x = (i - (n - 1) / 2) * 2.6
			local g = cf * CFrame.new(x, 0, 0)
			local k = i % 3
			if k == 0 then lego(m, V(1.6, 1.6, 1.6), g * CFrame.new(0, 0.8, 0), c)
			elseif k == 1 then
				p(m, V(1.6, 1.6, 1.6), g * CFrame.new(0, 0.8, 0), K.shade(c, 1.25), { shape = "ball", glass = true, transp = 0.2 })
				p(m, V(0.6, 0.8, 0.6), g * CFrame.new(0, 1.9, 0), rgb(170, 110, 60))
			else p(m, V(1.3, 1.3, 1.3), g * CFrame.new(0, 1, 0) * CFrame.Angles(rad(45), 0, rad(45)), rgb(255, 210, 60), { neon = theme == "Space" or theme == "Volcano" }) end
		end
	end

	-- framed sign board (navy panel, chunky frame, caps) with title + icon text
	local function board(m, cf, w, h, t, title, icon, c)
		lego(m, V(w + 1.6, h + 1.6, 1), cf, t.frame)
		local panel = p(m, V(w, h, 0.4), cf * CFrame.new(0, 0, -0.55), t.panel)
		K.textPanel(panel, Enum.NormalId.Front, {
			{ text = icon, h = 0.42, stroke = 0 },
			{ text = title, h = 0.45, grad = { Color3.new(1, 1, 1), K.shade(c, 1.4) }, font = K.FONT_BOLD },
		}, { pps = 16, stroke = 3 })
		for _, sx in ipairs({ -1, 1 }) do lego(m, V(2, 1.4, 2), cf * CFrame.new(sx * (w / 2 + 0.4), h / 2 + 1.2, 0), t.cap, { neon = t.neon }) end
		return panel
	end

	------------------------------------------------------------------------------------------------------------
	-- VERSION 2: toy-brick market stall (reference)
	------------------------------------------------------------------------------------------------------------
	local function stall(theme, cf, info, parent)
		local t = TH[theme]
		local c = info.color
		local m = K.model("Shop_" .. info.id, parent)
		local W, D, H = 26, 12, 10
		lego(m, V(W + 8, 1.2, D + 12), cf * CFrame.new(0, 0.6, 1), t.ground)
		-- posts (2x2 bricks)
		for _, sx in ipairs({ -1, 1 }) do for _, sz in ipairs({ -1, 1 }) do
			lego(m, V(2, H, 2), cf * CFrame.new(sx * (W / 2 - 1), 1.2 + H / 2, sz * (D / 2 - 1)), t.frame)
		end end
		-- top rails
		for _, sz in ipairs({ -1, 1 }) do lego(m, V(W, 1.2, 1.6), cf * CFrame.new(0, 1.2 + H - 0.6, sz * (D / 2 - 1)), t.frameD) end
		-- counter (front) + low back wall
		lego(m, V(W - 4, 4, 3), cf * CFrame.new(0, 3.2, -D / 2 + 1.5), t.frame)
		lego(m, V(W - 3.4, 0.8, 3.8), cf * CFrame.new(0, 5.6, -D / 2 + 1.5), t.frameD)
		for k = -1, 1 do lego(m, V(W - 4.4, 0.6, 0.3), cf * CFrame.new(0, 3.2 + k * 1.2, -D / 2 - 0.05), t.frameD) end
		lego(m, V(W - 4, 5, 1.2), cf * CFrame.new(0, 3.7, D / 2 - 1), t.frameD)
		goods(m, cf * CFrame.new(0, 6, -D / 2 + 1.5), theme, c, 5)
		-- striped awning sloping to the front, scalloped lip
		local stripes = 8
		for i = 1, stripes do
			local x = -W / 2 + (i - 0.5) * (W / stripes)
			local col = (i % 2 == 0) and t.stripe2 or c
			lego(m, V(W / stripes + 0.02, 1, D + 3), cf * CFrame.new(x, 1.2 + H + 1.6, -0.5) * CFrame.Angles(rad(14), 0, 0), col, { neon = t.neon and i % 2 == 0 })
			lego(m, V(W / stripes + 0.02, 1.6, 0.8), cf * CFrame.new(x, 1.2 + H + 0.2, -D / 2 - 2.3), col, { neon = t.neon and i % 2 == 0 })
			p(m, V(0.8, W / stripes - 0.2, W / stripes - 0.2), cf * CFrame.new(x, 1.2 + H - 0.6, -D / 2 - 2.3) * CFrame.Angles(0, rad(90), 0), col, { shape = "cyl" })
		end
		-- sign board standing on the awning ridge
		board(m, cf * CFrame.new(0, 1.2 + H + 6.6, D / 2 - 1), 15, 5, t, info.title, ({ paw = "🐾", potion = "🧪", gem = "💎" })[info.iconKind] or "⭐", c)
		for _, sx in ipairs({ -1, 1 }) do lego(m, V(1.2, 4, 1.2), cf * CFrame.new(sx * 6, 1.2 + H + 3.4, D / 2 - 1), t.frame) end
		-- little flowers / props at the corners
		for _, sx in ipairs({ -1, 1 }) do
			lego(m, V(3, 2, 3), cf * CFrame.new(sx * (W / 2 + 2.2), 2.2, -D / 2 - 3), K.shade(t.ground, 0.85))
			for k = 0, 2 do p(m, V(0.8, 0.8, 0.8), cf * CFrame.new(sx * (W / 2 + 2.2) + (k - 1) * 0.8, 3.6, -D / 2 - 3), ({ rgb(255, 90, 140), rgb(255, 220, 70), rgb(190, 110, 255) })[k + 1], { shape = "ball", neon = t.neon }) end
		end
		return m
	end

	------------------------------------------------------------------------------------------------------------
	-- VERSION 1: themed shop building
	------------------------------------------------------------------------------------------------------------
	local function building(theme, cf, info, parent)
		local t = TH[theme]
		local c = info.color
		local m = K.model("Shop_" .. info.id, parent)
		local W, D, H = 26, 18, 11
		local floorY = 1.2
		lego(m, V(W + 8, 1.2, D + 10), cf * CFrame.new(0, 0.6, 1), t.ground)
		local function walls(wallCol, mat)
			p(m, V(W, H, 1.4), cf * CFrame.new(0, floorY + H / 2, D / 2), wallCol, { studs = true, mat = mat })
			for _, sx in ipairs({ -1, 1 }) do
				p(m, V(1.4, H, D), cf * CFrame.new(sx * (W / 2 - 0.7), floorY + H / 2, 0), wallCol, { studs = true, mat = mat })
				p(m, V(0.3, 4, D - 7), cf * CFrame.new(sx * (W / 2 + 0.05), floorY + H * 0.55, 0), rgb(255, 230, 160), { neon = true, transp = 0.2 }) -- warm window glow
			end
			for _, sx in ipairs({ -1, 1 }) do p(m, V(5, H, 1.4), cf * CFrame.new(sx * (W / 2 - 2.5), floorY + H / 2, -D / 2), wallCol, { studs = true, mat = mat }) end
		end
		local function counter(col)
			lego(m, V(W - 10, 4, 2.6), cf * CFrame.new(0, floorY + 2, -D / 2 + 2), col)
			lego(m, V(W - 9.4, 0.6, 3.2), cf * CFrame.new(0, floorY + 4.3, -D / 2 + 2), K.shade(col, 0.8))
			goods(m, cf * CFrame.new(0, floorY + 4.6, -D / 2 + 2), theme, c, 4)
		end
		local signY = floorY + H + 3
		if theme == "Zoo" then -- safari hut: bamboo walls, layered straw roof, wooden sign
			walls(rgb(220, 190, 120), Enum.Material.Wood)
			for k = 0, 8 do p(m, V(0.8, H, 0.8), cf * CFrame.new(-W / 2 + 1.5 + k * (W - 3) / 8, floorY + H / 2, -D / 2 - 0.6), rgb(170, 200, 90)) end
			counter(t.frame)
			for k = 0, 4 do
				local s = 1 - k * 0.2
				p(m, V((W + 6) * s, 1.6, (D + 6) * s), cf * CFrame.new(0, floorY + H + 0.8 + k * 1.6, 0) * CFrame.Angles(0, rad(k * 8), 0), (k % 2 == 0) and rgb(222, 186, 100) or rgb(200, 160, 80), { studs = true })
			end
			signY = floorY + H + 10.5
		elseif theme == "Desert" then -- bazaar: sandstone, striped canopy on poles, dome with a gold top
			walls(rgb(236, 206, 150))
			counter(rgb(200, 150, 90))
			p(m, V(W + 2, 1.4, D + 2), cf * CFrame.new(0, floorY + H + 0.7, 0), rgb(214, 170, 110), { studs = true })
			local dome = p(m, V(12, 12, 12), cf * CFrame.new(0, floorY + H + 1.4, 2), c, { shape = "ball" })
			p(m, V(1.2, 3, 1.2), cf * CFrame.new(0, floorY + H + 8.6, 2), rgb(255, 205, 60))
			p(m, V(1.6, 1.6, 1.6), cf * CFrame.new(0, floorY + H + 10.4, 2), rgb(255, 205, 60), { shape = "ball" })
			for i = 1, 8 do p(m, V(W / 8 + 0.02, 0.5, 6), cf * CFrame.new(-W / 2 + (i - 0.5) * W / 8, floorY + H - 1, -D / 2 - 3) * CFrame.Angles(rad(15), 0, 0), (i % 2 == 0) and rgb(255, 245, 220) or c) end
			for _, sx in ipairs({ -1, 1 }) do p(m, V(0.7, H - 1, 0.7), cf * CFrame.new(sx * (W / 2 - 0.5), floorY + (H - 1) / 2, -D / 2 - 5.6), rgb(170, 110, 60)) end
			signY = floorY + H + 1
		elseif theme == "Snow" then -- log cabin, thick snowy gable roof, icicles, chimney
			walls(rgb(170, 110, 72), Enum.Material.Wood)
			for k = 0, 4 do for _, sx in ipairs({ -1, 1 }) do p(m, V(1.5, 1.6, D + 1), cf * CFrame.new(sx * (W / 2 - 0.4), floorY + 1 + k * 2.2, 0), rgb(150, 96, 60), { shape = "cyl" }).CFrame = cf * CFrame.new(sx * (W / 2 - 0.4), floorY + 1 + k * 2.2, 0) * CFrame.Angles(0, rad(90), 0) end end
			counter(rgb(120, 200, 255))
			for _, sz in ipairs({ -1, 1 }) do
				p(m, V(W + 4, 6, (D + 4) / 2), cf * CFrame.new(0, floorY + H + 3, sz * (D + 4) / 4) * (sz > 0 and CFrame.Angles(0, math.pi, 0) or CFrame.identity), rgb(250, 252, 255), { shape = "wedge", mat = Enum.Material.Snow })
			end
			for k = 0, 9 do p(m, V(0.5, 1 + (k % 3) * 0.6, 0.5), cf * CFrame.new(-W / 2 + 1 + k * (W - 2) / 9, floorY + H - 0.6, -D / 2 - 2), rgb(200, 240, 255), { glass = true, transp = 0.1 }) end
			p(m, V(3, 7, 3), cf * CFrame.new(W / 3, floorY + H + 5, 4), rgb(130, 120, 120), { studs = true })
			signY = floorY + H + 7.5
		elseif theme == "Forest" then -- mossy log cabin with mushrooms and a lantern
			walls(rgb(150, 104, 62), Enum.Material.Wood)
			counter(rgb(110, 180, 70))
			for _, sz in ipairs({ -1, 1 }) do
				p(m, V(W + 4, 6, (D + 4) / 2), cf * CFrame.new(0, floorY + H + 3, sz * (D + 4) / 4) * (sz > 0 and CFrame.Angles(0, math.pi, 0) or CFrame.identity), rgb(80, 150, 60), { shape = "wedge" })
			end
			for k = 0, 2 do P.tree((cf * CFrame.new(-W / 2 - 2 + k * 1.5, floorY, -D / 2 - 1 - k)).Position, "mushroom", 0.35 + k * 0.1, { trunk = rgb(240, 230, 210), leaf = rgb(220, 60, 50), leaf2 = rgb(255, 255, 255) }, m) end
			local lan = p(m, V(1.2, 1.6, 1.2), cf * CFrame.new(W / 2 - 3, floorY + H - 2, -D / 2 - 1), rgb(255, 220, 120), { neon = true })
			K.light(lan, rgb(255, 210, 120), 16, 1)
			signY = floorY + H + 7.5
		elseif theme == "Volcano" then -- obsidian forge shop: jagged roof spikes, lava trims, braziers
			walls(rgb(50, 44, 46), Enum.Material.Basalt)
			counter(rgb(80, 70, 70))
			p(m, V(W + 2, 1.4, D + 2), cf * CFrame.new(0, floorY + H + 0.7, 0), rgb(40, 34, 36), { studs = true })
			p(m, V(W + 2.2, 0.4, D + 2.2), cf * CFrame.new(0, floorY + H, 0), rgb(255, 110, 30), { neon = true })
			for k = 0, 6 do
				local h = 3 + (k % 3) * 2
				p(m, V(2, h, 2), cf * CFrame.new(-W / 2 + 2 + k * (W - 4) / 6, floorY + H + 1.4 + h / 2, -D / 2 + 1) * CFrame.Angles(0, rad(45), rad((k % 2 == 0) and 10 or -10)), rgb(30, 26, 30))
			end
			for _, sx in ipairs({ -1, 1 }) do
				local b = cf * CFrame.new(sx * (W / 2 + 2.5), floorY, -D / 2 - 2)
				p(m, V(2, 5, 2), b * CFrame.new(0, 2.5, 0), rgb(60, 52, 54), { studs = true })
				local f = p(m, V(2, 1.4, 2), b * CFrame.new(0, 5.7, 0), rgb(255, 140, 40), { neon = true })
				K.sparkle(f, rgb(255, 130, 40), { rate = 8, size = 0.8, accel = V(0, 6, 0), name = "Fire" })
			end
			signY = floorY + H + 4
		else -- Space: sci-fi kiosk with a glass dome, neon rings and a floating holo sign
			walls(rgb(80, 74, 130))
			counter(rgb(60, 50, 110))
			p(m, V(W + 2, 1.2, D + 2), cf * CFrame.new(0, floorY + H + 0.6, 0), rgb(50, 44, 90))
			local dome = p(m, V(1, 1, 1), cf * CFrame.new(0, floorY + H + 1.2, 1), rgb(140, 230, 255), { glass = true, transp = 0.4 })
			local sm = Instance.new("SpecialMesh"); sm.MeshType = Enum.MeshType.Sphere; sm.Scale = V(18, 10, 14); sm.Parent = dome
			S.ring(cf * CFrame.new(0, floorY + H + 1.4, 1) * CFrame.Angles(rad(90), 0, 0), 10, 0.6, 0.6, rgb(120, 230, 255), 24, { neon = true }, m)
			for _, sx in ipairs({ -1, 1 }) do p(m, V(0.4, H, 0.4), cf * CFrame.new(sx * (W / 2 - 4.6), floorY + H / 2, -D / 2 - 0.8), rgb(255, 120, 220), { neon = true }) end
			signY = floorY + H + 9
		end
		-- sign above the entrance
		for _, sx in ipairs({ -1, 1 }) do -- posts holding the sign up from the roof
			local h = signY - (floorY + H)
			lego(m, V(1.2, h, 1.2), cf * CFrame.new(sx * 5.5, floorY + H + h / 2 - 1, -D / 2 - 0.6), t.frame)
		end
		board(m, cf * CFrame.new(0, signY, -D / 2 - 1.2), 14, 4.4, t, info.title, ({ paw = "🐾", potion = "🧪", gem = "💎" })[info.iconKind] or "⭐", c)
		return m
	end

	return function(theme, version, cf, info, parent)
		local m = (version == 2) and stall(theme, cf, info, parent) or building(theme, cf, info, parent)
		-- interaction prompt (same as before) + a soft light
		local trig = p(m, V(16, 6, 4), cf * CFrame.new(0, 4, -9), Color3.new(1, 1, 1), { transp = 1, collide = false, name = "Interact" })
		S.prompt(trig, "Open", info.title, 0.4, "ShopStation", { Shop = info.id, World = ({ Zoo = 1, Desert = 2, Snow = 3, Forest = 4, Volcano = 5, Space = 6 })[theme] })
		K.light(trig, info.color, 22, 0.8)
		return m
	end
end
