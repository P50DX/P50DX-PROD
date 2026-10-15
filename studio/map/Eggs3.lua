-- Eggs3: the chosen egg for each world, polished, with VFX.
--   Zoo: jungle egg (reference style, own colours + flowers)   Desert: pharaoh egg (smooth headdress + big eye emblem)
--   Snow: cute penguin (scarf, beanie)                         Forest: straw beehive with real-looking bees
--   Volcano: demon egg with bat wings, spikes, lava (no face)  Space: gas giant with rings and little worlds
-- build(world, cf, parent) -> Model "<World>Egg" (PrimaryPart = invisible Core). Front = cf's -Z.
return function(K)
	local V = Vector3.new
	local rad = math.rad
	local rgb = K.rgb

	local function p(m, size, cf, col, o) o = o or {}; o.parent = m; if o.collide == nil then o.collide = false end; return K.part(size, cf, col, o) end
	local function ellipsoid(m, size, cf, col, o)
		local part = p(m, V(1, 1, 1), cf, col, o)
		local sm = Instance.new("SpecialMesh"); sm.MeshType = Enum.MeshType.Sphere; sm.Scale = size; sm.Parent = part
		return part
	end
	-- solid triangle from two wedges (thickness th)
	local function tri(m, a, b, c, col, th, o)
		local ab, ac, bc = b - a, c - a, c - b
		local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
		if abd > acd and abd > bcd then c, a = a, c elseif acd > bcd and acd > abd then a, b = b, a end
		ab, ac, bc = b - a, c - a, c - b
		local right = ac:Cross(ab).Unit
		local up = bc:Cross(right).Unit
		local back = bc.Unit
		local height = math.abs(ab:Dot(up))
		o = o or {}
		local w1 = p(m, V(th, height, math.abs(ab:Dot(back))), CFrame.fromMatrix((a + b) / 2, right, up, back), col, { shape = "wedge", transp = o.transp })
		local w2 = p(m, V(th, height, math.abs(ac:Dot(back))), CFrame.fromMatrix((a + c) / 2, -right, up, -back), col, { shape = "wedge", transp = o.transp })
		return w1, w2
	end
	-- stacked layered shell. n layers of height lh; returns widths (index 0..n-1) and the y of each row
	local function shell(m, cf, n, lh, R, colFn, o)
		o = o or {}
		local widths, ys = {}, {}
		local bottom = -n * lh / 2
		for i = 0, n - 1 do
			local t = (i + 0.5) / n
			local s = t < 0.42 and t / 0.42 * 0.5 or 0.5 + (t - 0.42) / 0.58 * 0.5
			local r = R * math.sqrt(math.max(0, 1 - (2 * s - 1) ^ 2))
			local step = o.step or 0.4
			local w = math.max(1.6, math.floor(2 * r / step + 0.5) * step)
			widths[i] = w; ys[i] = bottom + (i + 0.5) * lh
			local c = colFn(i)
			if o.round then
				p(m, V(lh, w, w), cf * CFrame.new(0, ys[i], 0) * CFrame.Angles(0, 0, rad(90)), c, { shape = "cyl", mat = o.mat })
			else
				p(m, V(w, lh, w), cf * CFrame.new(0, ys[i], 0), c, { studs = o.studs ~= false, mat = o.mat })
			end
		end
		return widths, ys
	end
	-- smooth particle effect (fades in and out, gentle motion)
	local function fx(part, o)
		local e = Instance.new("ParticleEmitter")
		e.Name = o.name or "FX"
		e.Texture = o.texture or "rbxasset://textures/particles/sparkles_main.dds"
		e.Color = o.colorSeq or ColorSequence.new(o.color, o.color2 or o.color)
		e.LightEmission = o.emission or 0.7
		e.LightInfluence = 0
		local s = o.size or 0.6
		e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, s), NumberSequenceKeypoint.new(0.75, s * 0.8), NumberSequenceKeypoint.new(1, 0) })
		e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, o.alpha or 0.15), NumberSequenceKeypoint.new(0.8, o.alpha or 0.15), NumberSequenceKeypoint.new(1, 1) })
		e.Lifetime = o.life or NumberRange.new(1.8, 2.8)
		e.Rate = o.rate or 6
		e.Speed = o.speed or NumberRange.new(0.5, 1.5)
		e.SpreadAngle = o.spread or Vector2.new(180, 180)
		e.Acceleration = o.accel or V(0, 0.6, 0)
		e.Drag = o.drag or 1
		e.Rotation = NumberRange.new(0, 360)
		e.RotSpeed = o.rot or NumberRange.new(-40, 40)
		e.Shape = o.shape or Enum.ParticleEmitterShape.Sphere
		e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		e.LockedToPart = o.locked or false
		if o.flip then e.FlipbookLayout = o.flip end
		e.Parent = part
		return e
	end
	local function aura(m, cf, r, col) -- soft glow sphere around the egg + light
		local a = p(m, V(1, 1, 1), cf, col, { transp = 1, name = "Aura" })
		K.light(a, col, 18, 1.2)
		return a
	end
	local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
	local SPARK = "rbxasset://textures/particles/sparkles_main.dds"
	local FIRE = "rbxasset://textures/particles/fire_main.dds"

	local B = {}

	------------------------------------------------------------------------------------------------------------
	-- ZOO: warm sand base, rich jungle cap with soft drips, flowers, one palm + a leafy sprout with a coconut
	------------------------------------------------------------------------------------------------------------
	B.Zoo = function(m, cf, core)
		local sandA, sandB = rgb(246, 214, 160), rgb(236, 198, 140)
		local g1, g2, g3 = rgb(64, 186, 92), rgb(104, 214, 110), rgb(40, 150, 76)
		local w, y = shell(m, cf, 12, 0.92, 5, function(i) return i <= 6 and ((i % 2 == 0) and sandA or sandB) or ((i % 2 == 0) and g1 or g2) end)
		-- soft grass drips (rounded ends) all round
		local rr = Random.new(7)
		for k = 0, 13 do
			local a = k * (360 / 14) + rr:NextNumber() * 8
			local len = 0.8 + rr:NextNumber() * 1.8
			local c = cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y[7] - len / 2, -(w[6] / 2 + 0.15))
			p(m, V(1.3, len, 0.5), c, (k % 2 == 0) and g1 or g3)
			p(m, V(1.3, 1.3, 0.5), c * CFrame.new(0, -len / 2, 0), (k % 2 == 0) and g1 or g3, { shape = "cyl" }).CFrame = c * CFrame.new(0, -len / 2, 0) * CFrame.Angles(0, rad(90), 0)
		end
		-- sand texture dots
		for k = 1, 14 do
			local i = rr:NextInteger(1, 5); local a = rr:NextNumber() * 360
			p(m, V(0.7, 0.45, 0.2), cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y[i], -(w[i] / 2 + 0.05)), rgb(214, 170, 112))
		end
		-- flowers on the cap and at the base
		local fcol = { rgb(255, 110, 150), rgb(255, 220, 70), rgb(255, 255, 255), rgb(190, 120, 255), rgb(255, 150, 60) }
		local function flower(c, col)
			for k = 0, 4 do p(m, V(0.45, 0.2, 0.45), c * CFrame.Angles(0, rad(k * 72), 0) * CFrame.new(0, 0, -0.32), col) end
			p(m, V(0.3, 0.25, 0.3), c * CFrame.new(0, 0.05, 0), rgb(255, 230, 90))
		end
		for k = 0, 9 do
			local i = (k % 2 == 0) and 8 or 10
			local a = k * 36 + 10
			local c = cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y[i] + 0.5, -(w[i] / 2 - 0.3)) * CFrame.Angles(rad(-25), 0, 0)
			flower(c, fcol[k % #fcol + 1])
		end
		-- palm on one side, a leafy sprout with a coconut on the other
		local function palm(c, lean)
			for k = 0, 4 do
				c = c * CFrame.Angles(0, 0, rad(lean)) * CFrame.new(0, 0.7, 0)
				p(m, V(0.8, 0.75, 0.8), c, (k % 2 == 0) and rgb(176, 108, 56) or rgb(150, 90, 46))
			end
			for k = 0, 5 do
				local l = c * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, rad(k * 60), 0) * CFrame.Angles(rad(30), 0, 0) * CFrame.new(0, 0, -1.3)
				p(m, V(1, 0.25, 2.6), l, (k % 2 == 0) and g2 or g1)
				p(m, V(0.6, 0.22, 1.2), l * CFrame.new(0, -0.3, -1.6) * CFrame.Angles(rad(-35), 0, 0), g3)
			end
			for k = 0, 2 do p(m, V(0.6, 0.6, 0.6), c * CFrame.Angles(0, rad(k * 120), 0) * CFrame.new(0.4, 0.1, 0), rgb(120, 76, 40), { shape = "ball" }) end
		end
		palm(cf * CFrame.new(-1.4, y[11] + 0.4, 0.4), 12)
		local sp = cf * CFrame.new(1.6, y[11] + 0.5, -0.2)
		for k = 0, 2 do p(m, V(1.6, 0.25, 0.8), sp * CFrame.Angles(0, rad(k * 120), rad(-40)) * CFrame.new(0.8, 0.3, 0), g2) end
		-- butterfly
		local bcf = cf * CFrame.new(3.4, y[9] + 1.6, -2.4) * CFrame.Angles(0, rad(30), 0)
		for _, sx in ipairs({ -1, 1 }) do p(m, V(0.9, 0.1, 0.7), bcf * CFrame.new(sx * 0.5, 0, 0) * CFrame.Angles(0, 0, rad(sx * 25)), rgb(255, 150, 60)) end
		p(m, V(0.15, 0.15, 0.7), bcf, rgb(40, 30, 30))
		-- VFX: drifting pollen + floating leaves
		fx(core, { color = rgb(255, 245, 160), color2 = rgb(200, 255, 140), rate = 7, size = 0.35, speed = NumberRange.new(0.6, 1.4), accel = V(0, 0.8, 0), name = "Pollen" })
		fx(core, { texture = SPARK, color = rgb(110, 220, 110), rate = 3, size = 0.7, life = NumberRange.new(2.5, 3.5), accel = V(0.3, -0.8, 0), speed = NumberRange.new(1, 2), emission = 0.2, name = "Leaves" })
		return rgb(150, 230, 110)
	end

	------------------------------------------------------------------------------------------------------------
	-- DESERT: smooth white-gold shell wearing a real striped nemes headdress, big readable eye-of-Horus emblem
	------------------------------------------------------------------------------------------------------------
	B.Desert = function(m, cf, core)
		local gold, goldD, blue, blueD = rgb(255, 200, 60), rgb(220, 150, 30), rgb(36, 84, 200), rgb(24, 56, 150)
		local w, y = shell(m, cf, 16, 0.69, 5, function(i) return (i % 2 == 0) and rgb(246, 226, 186) or rgb(238, 214, 170) end, { step = 0.3, studs = false })
		-- headdress: thin stripes hugging the top of the shell, slightly larger so it sits ON the head
		for i = 8, 15 do
			local ww = w[i] + 0.5
			p(m, V(ww, 0.69, ww), cf * CFrame.new(0, y[i], 0.15), (i % 2 == 0) and gold or blue, { refl = 0.05 })
		end
		-- front opening of the headdress (face area stays shell-coloured): a shell panel in front of the stripes
		for i = 8, 11 do p(m, V(w[i] * 0.5, 0.69, 0.3), cf * CFrame.new(0, y[i], -(w[i] / 2 + 0.2)), rgb(246, 226, 186)) end
		-- gold headband across the forehead
		p(m, V(w[11] * 0.62, 0.55, 0.4), cf * CFrame.new(0, y[12] - 0.15, -(w[12] / 2 + 0.35)), gold, { refl = 0.1 })
		-- side lappets: striped cloth falling from the headband down past the shoulders, flaring out
		for _, sx in ipairs({ -1, 1 }) do
			for k = 0, 9 do
				local yy = y[11] - k * 0.62
				local flare = 0.25 * k
				local c = cf * CFrame.new(sx * (w[8] / 2 + 0.25 + flare * 0.25), yy, -1.4) * CFrame.Angles(0, 0, rad(sx * 6))
				p(m, V(0.55, 0.6, 3.2 + flare * 0.25), c, (k % 2 == 0) and gold or blue)
			end
			p(m, V(0.7, 0.5, 3.8), cf * CFrame.new(sx * (w[8] / 2 + 0.9), y[11] - 6.4, -1.4), goldD)
		end
		-- braided tail at the back
		for k = 0, 5 do p(m, V(1.1 - k * 0.08, 0.6, 1.1 - k * 0.08), cf * CFrame.new(0, y[9] - k * 0.6, w[9] / 2 + 0.35), (k % 2 == 0) and gold or blue) end
		-- EMBLEM: gold oval plaque framing a large eye of Horus (fine pixels, deep blue outline, glowing iris)
		local fz = -(w[5] / 2 + 0.3)
		local pc = cf * CFrame.new(0, y[5], fz)
		local plaque = ellipsoid(m, V(4.6, 3.4, 0.5), pc, gold, { refl = 0.15 })
		ellipsoid(m, V(4.0, 2.8, 0.55), pc * CFrame.new(0, 0, -0.02), rgb(255, 238, 190))
		local EYE = {
			"..............",
			"...########...",
			"..##......##..",
			".#....oo....#.",
			"#....oooo....#",
			".#....oo....#.",
			"..##......##..",
			"...#######....",
			"......#..#....",
			".....#....#...",
		}
		local ps = 0.27
		for r, row in ipairs(EYE) do
			for c = 1, #row do
				local ch = row:sub(c, c)
				if ch ~= "." then
					p(m, V(ps, ps, 0.25), pc * CFrame.new((c - 7.5) * ps, (5.5 - r) * ps, -0.32), ch == "#" and rgb(20, 40, 120) or rgb(40, 220, 230), { neon = ch == "o" })
				end
			end
		end
		-- golden cobra on the headband
		local cb = cf * CFrame.new(0, y[12] + 0.2, -(w[12] / 2 + 0.6))
		p(m, V(0.5, 1.4, 0.5), cb, gold)
		ellipsoid(m, V(1.2, 0.9, 0.5), cb * CFrame.new(0, 0.9, -0.1), gold)
		p(m, V(0.3, 0.3, 0.2), cb * CFrame.new(0, 0.9, -0.4), rgb(255, 60, 60), { neon = true })
		-- VFX: golden sand sparkles swirling + a warm glow
		fx(core, { color = rgb(255, 220, 120), color2 = rgb(255, 180, 60), rate = 10, size = 0.35, speed = NumberRange.new(1, 2), accel = V(0, 0.5, 0), name = "GoldDust" })
		fx(core, { texture = SMOKE, color = rgb(240, 200, 140), rate = 2, size = 2.5, alpha = 0.75, life = NumberRange.new(3, 4), speed = NumberRange.new(0.5, 1), emission = 0, name = "SandHaze" })
		return rgb(255, 200, 90)
	end

	------------------------------------------------------------------------------------------------------------
	-- SNOW: cute round penguin - big sparkly eyes, rosy cheeks, tiny beak, red scarf, beanie with a pompom
	------------------------------------------------------------------------------------------------------------
	B.Snow = function(m, cf, core)
		local navy, navy2, white, orange, red = rgb(40, 48, 74), rgb(52, 62, 92), rgb(250, 252, 255), rgb(255, 160, 50), rgb(220, 50, 60)
		local w, y = shell(m, cf, 14, 0.79, 5.1, function(i) return (i % 2 == 0) and navy or navy2 end, { step = 0.3 })
		-- white belly / face patch (heart-ish shape) on the front
		for i = 0, 11 do
			local bw = w[i] * ((i <= 7) and 0.66 or (0.66 - (i - 7) * 0.08))
			p(m, V(bw, 0.79, 0.6), cf * CFrame.new(0, y[i], -(w[i] / 2 - 0.2)), white, { studs = true })
		end
		-- eyes: big, glossy, two shines each
		local fz = -(w[9] / 2 + 0.15)
		for _, sx in ipairs({ -1, 1 }) do
			local ec = cf * CFrame.new(sx * 1.25, y[9], fz)
			ellipsoid(m, V(1.2, 1.5, 0.4), ec, rgb(20, 22, 34))
			ellipsoid(m, V(0.45, 0.45, 0.3), ec * CFrame.new(sx * -0.2, 0.3, -0.15), white, { neon = true })
			ellipsoid(m, V(0.2, 0.2, 0.3), ec * CFrame.new(sx * 0.2, -0.3, -0.15), white, { neon = true })
			ellipsoid(m, V(0.9, 0.5, 0.2), cf * CFrame.new(sx * 1.9, y[8] - 0.1, -(w[8] / 2 + 0.05)), rgb(255, 150, 170)) -- rosy cheek
		end
		ellipsoid(m, V(0.9, 0.6, 0.9), cf * CFrame.new(0, y[8], -(w[8] / 2 + 0.3)), orange) -- tiny beak
		-- red scarf (smooth band + knot + hanging tail with fringe)
		local sw = w[6] + 0.6
		p(m, V(0.9, sw, sw), cf * CFrame.new(0, y[6] + 0.2, 0) * CFrame.Angles(0, 0, rad(90)), red, { shape = "cyl" })
		p(m, V(0.95, sw - 0.3, sw - 0.3), cf * CFrame.new(0, y[6] + 0.2, 0) * CFrame.Angles(0, 0, rad(90)), rgb(255, 255, 255), { shape = "cyl", transp = 0.0 }).Size = V(0.2, sw + 0.02, sw + 0.02)
		local knot = cf * CFrame.new(1.6, y[6], -(w[6] / 2 + 0.2))
		ellipsoid(m, V(1, 1, 0.8), knot, red)
		p(m, V(1, 2.6, 0.35), knot * CFrame.new(0.2, -1.5, -0.1) * CFrame.Angles(0, 0, rad(-12)), red)
		for k = 0, 2 do p(m, V(0.25, 0.4, 0.3), knot * CFrame.new(-0.15 + k * 0.33, -2.9, -0.1), rgb(255, 255, 255)) end
		-- beanie with a pompom (instead of horns)
		local top = cf * CFrame.new(0, y[13] + 0.3, 0)
		p(m, V(1.2, w[12] + 0.5, w[12] + 0.5), top * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, 0, rad(90)), rgb(120, 200, 255), { shape = "cyl" })
		ellipsoid(m, V(w[12] + 0.1, 2.4, w[12] + 0.1), top * CFrame.new(0, 0.3, 0), rgb(80, 160, 240))
		for k = 0, 3 do p(m, V(0.3, 1.6, 0.3), top * CFrame.Angles(0, rad(k * 45), 0) * CFrame.new(0, 0.3, -(w[12] / 2 + 0.02)), rgb(120, 200, 255)) end
		p(m, V(1.5, 1.5, 1.5), top * CFrame.new(0, 1.7, 0), white, { shape = "ball" })
		-- flippers (little wave) + feet
		for _, sx in ipairs({ -1, 1 }) do
			ellipsoid(m, V(0.7, 3.2, 1.6), cf * CFrame.new(sx * (w[4] / 2 + 0.2), y[4], 0) * CFrame.Angles(0, 0, rad(sx * (sx > 0 and 35 or 15))), navy)
			ellipsoid(m, V(1.8, 0.6, 2.2), cf * CFrame.new(sx * 1.2, y[0] - 0.4, -1), orange)
		end
		-- VFX: soft snowfall + icy twinkles
		fx(core, { color = rgb(255, 255, 255), rate = 9, size = 0.4, life = NumberRange.new(2.5, 3.5), speed = NumberRange.new(0.3, 0.8), accel = V(0, -1.2, 0), name = "Snow", shape = Enum.ParticleEmitterShape.Box })
		fx(core, { color = rgb(170, 230, 255), rate = 4, size = 0.5, emission = 1, name = "Twinkle" })
		return rgb(150, 220, 255)
	end

	------------------------------------------------------------------------------------------------------------
	-- FOREST: straw beehive (skep) with coiled rings, honey, a door + ledge, and real-looking bees around it
	------------------------------------------------------------------------------------------------------------
	local function bee(m, cf, s)
		s = s or 1
		local yellow, ink = rgb(255, 205, 50), rgb(30, 28, 34)
		ellipsoid(m, V(1.5, 1.1, 1.1) * s, cf, yellow)                                     -- abdomen
		for _, x in ipairs({ -0.15, 0.3 }) do ellipsoid(m, V(0.22, 1.12, 1.12) * s, cf * CFrame.new(x * s, 0, 0), ink) end -- stripes
		ellipsoid(m, V(0.4, 0.4, 0.4) * s, cf * CFrame.new(0.85 * s, 0, 0), ink)              -- stinger tip
		ellipsoid(m, V(0.85, 0.85, 0.85) * s, cf * CFrame.new(-0.85 * s, 0.05 * s, 0), ink) -- head
		for _, sz in ipairs({ -1, 1 }) do
			ellipsoid(m, V(0.18, 0.18, 0.18) * s, cf * CFrame.new(-1.15 * s, 0.15 * s, sz * 0.22 * s), rgb(255, 255, 255), { neon = true }) -- eye shine
			p(m, V(0.08, 0.6, 0.08) * s, cf * CFrame.new(-1.1 * s, 0.55 * s, sz * 0.2 * s) * CFrame.Angles(rad(sz * -20), 0, rad(30)), ink) -- antenna
			ellipsoid(m, V(1.1, 0.08, 0.7) * s, cf * CFrame.new(-0.1 * s, 0.62 * s, sz * 0.45 * s) * CFrame.Angles(rad(sz * -25), rad(sz * 15), 0), rgb(220, 240, 255), { transp = 0.35 }) -- wings
		end
	end
	B.Forest = function(m, cf, core)
		local straw, straw2, honey = rgb(232, 176, 70), rgb(204, 146, 50), rgb(255, 170, 30)
		local w, y = shell(m, cf, 11, 1.0, 5.2, function(i) return (i % 2 == 0) and straw or straw2 end, { round = true, step = 0.2 })
		-- coil bands between rings (rounded rope look)
		for i = 1, 10 do
			p(m, V(0.35, w[i] + 0.35, w[i] + 0.35), cf * CFrame.new(0, y[i] - 0.5, 0) * CFrame.Angles(0, 0, rad(90)), rgb(176, 120, 40), { shape = "cyl" })
		end
		-- top knob
		p(m, V(0.8, 1.6, 1.6), cf * CFrame.new(0, y[10] + 0.7, 0) * CFrame.Angles(0, 0, rad(90)), straw2, { shape = "cyl" })
		ellipsoid(m, V(1, 0.7, 1), cf * CFrame.new(0, y[10] + 1.2, 0), straw)
		-- entrance: dark round door with a little wooden landing ledge
		local dz = -(w[2] / 2 + 0.05)
		p(m, V(0.3, 2.2, 2.2), cf * CFrame.new(0, y[2], dz) * CFrame.Angles(0, rad(90), 0), rgb(60, 36, 20), { shape = "cyl" })
		p(m, V(2.6, 0.3, 1.2), cf * CFrame.new(0, y[2] - 1.15, dz - 0.5), rgb(150, 100, 56), { mat = Enum.Material.WoodPlanks })
		-- honey dripping from the rings
		local rr = Random.new(3)
		for k = 0, 7 do
			local i = ({ 7, 5, 8, 4, 6, 7, 5, 8 })[k + 1]
			local len = 0.6 + rr:NextNumber() * 1.4
			local c = cf * CFrame.Angles(0, rad(k * 45 + 20), 0) * CFrame.new(0, y[i] - 0.5 - len / 2, -(w[i] / 2 + 0.05))
			p(m, V(0.6, len, 0.4), c, honey, { glass = true, transp = 0.05 })
			ellipsoid(m, V(0.75, 0.85, 0.75), c * CFrame.new(0, -len / 2, 0), honey, { glass = true, transp = 0.05 })
		end
		-- leaves + a little flower on the side
		for k = 0, 2 do p(m, V(2.2, 0.25, 1.1), cf * CFrame.new(-2.2, y[9] + 0.3, 1) * CFrame.Angles(0, rad(k * 50), rad(20)) * CFrame.new(0.8, 0, 0), rgb(100, 190, 80)) end
		-- bees flying around the hive
		bee(m, cf * CFrame.new(-4.6, y[7], -2.4) * CFrame.Angles(0, rad(-60), rad(10)), 1)
		bee(m, cf * CFrame.new(4.4, y[4], -2.8) * CFrame.Angles(0, rad(-130), rad(-8)), 0.9)
		bee(m, cf * CFrame.new(1.2, y[10] + 1.8, -2.6) * CFrame.Angles(0, rad(-95), 0), 0.8)
		bee(m, cf * CFrame.new(-1.6, y[2] - 0.2, -4) * CFrame.Angles(0, rad(-80), rad(5)), 0.75)
		-- VFX: honey sparkles + golden pollen
		fx(core, { color = rgb(255, 200, 60), color2 = rgb(255, 150, 30), rate = 8, size = 0.35, accel = V(0, 0.4, 0), name = "Pollen" })
		fx(core, { color = rgb(255, 240, 150), rate = 3, size = 0.6, emission = 1, name = "Glow" })
		return rgb(255, 190, 60)
	end

	------------------------------------------------------------------------------------------------------------
	-- VOLCANO: dark demon egg - real bat wings (bones + membrane), big ridged horns, back spikes, lava cracks
	------------------------------------------------------------------------------------------------------------
	B.Volcano = function(m, cf, core)
		local maroon, maroonD, crimson, bone = rgb(72, 22, 28), rgb(46, 16, 22), rgb(130, 18, 24), rgb(22, 18, 22)
		local w, y = shell(m, cf, 12, 0.92, 5, function(i) return (i == 3 or i == 8) and crimson or ((i % 2 == 0) and maroon or maroonD) end)
		-- diamond scale pattern
		for f = 0, 3 do for _, i in ipairs({ 2, 5, 6, 10 }) do for k = -1, 1 do
			for _, a in ipairs({ 45, -45 }) do p(m, V(0.2, 1.3, 0.15), cf * CFrame.Angles(0, rad(f * 90), 0) * CFrame.new(k * 2, y[i], -(w[i] / 2 + 0.05)) * CFrame.Angles(0, 0, rad(a)), rgb(40, 12, 16)) end
		end end end
		-- glowing lava cracks
		local rr = Random.new(17)
		for c = 1, 7 do
			local a = rr:NextNumber() * 360; local i = rr:NextInteger(2, 10)
			for k = 0, 2 do
				local ii = math.max(0, i - k)
				p(m, V(0.25, 1, 0.15), cf * CFrame.Angles(0, rad(a + k * 4), 0) * CFrame.new(0, y[ii], -(w[ii] / 2 + 0.08)) * CFrame.Angles(0, 0, rad((k % 2 == 0) and 25 or -25)), rgb(255, 110, 30), { neon = true })
			end
		end
		-- big ridged horns curving up and out, glowing tips
		for _, sx in ipairs({ -1, 1 }) do
			local c = cf * CFrame.new(sx * 1.6, y[11] + 0.2, -0.3)
			for k = 0, 6 do
				c = c * CFrame.Angles(rad(-4), 0, rad(-sx * ({ 22, 18, 10, 0, -14, -26, -34 })[k + 1])) * CFrame.new(0, 0.85, 0)
				local s = 1.3 - k * 0.15
				p(m, V(s, 0.9, s), c, (k == 6) and rgb(255, 80, 40) or bone, { neon = k == 6 })
				if k < 6 then p(m, V(s + 0.12, 0.15, s + 0.12), c * CFrame.new(0, 0.38, 0), rgb(60, 50, 56)) end -- ridges
			end
		end
		-- spikes down the back
		for k = 0, 5 do
			local i = 10 - k
			p(m, V(0.7, 1.5 - k * 0.12, 0.7), cf * CFrame.new(0, y[i] + 0.2, w[i] / 2 + 0.35) * CFrame.Angles(rad(45), 0, 0) * CFrame.Angles(0, rad(45), 0), bone)
		end
		-- BAT WINGS: arm bone, three finger bones fanning out, membrane panels between them, claw at the wrist
		for _, sx in ipairs({ -1, 1 }) do
			local shoulder = cf * CFrame.new(sx * (w[7] / 2 - 0.2), y[7], 1.6)
			local wrist = shoulder * CFrame.new(sx * 4.2, 2.6, 0.8)
			local function bonePart(a, b, th)
				local d = (b - a).Magnitude
				p(m, V(th, th, d), CFrame.lookAt((a + b) / 2, b), bone)
			end
			bonePart(shoulder.Position, wrist.Position, 0.6)
			p(m, V(0.5, 1.2, 0.5), wrist * CFrame.new(sx * 0.2, 0.7, 0) * CFrame.Angles(0, 0, rad(-sx * 30)), rgb(230, 220, 210)) -- claw
			local tips = { wrist * CFrame.new(sx * 5.2, 0.6, 0.6), wrist * CFrame.new(sx * 5.4, -2.6, 0.8), wrist * CFrame.new(sx * 3.4, -5, 0.8), wrist * CFrame.new(sx * 0.6, -5.6, 0.6) }
			for _, t in ipairs(tips) do bonePart(wrist.Position, t.Position, 0.35) end
			-- membrane: solid triangles between the fingers with a scalloped trailing edge
			local anchors = { tips[1].Position, tips[2].Position, tips[3].Position, tips[4].Position, (shoulder * CFrame.new(0, -3.2, 0.6)).Position }
			local wp = wrist.Position + V(0, 0, 0.05)
			for k = 1, #anchors - 1 do
				local b1, c1 = anchors[k], anchors[k + 1]
				local notch = ((b1 + c1) / 2):Lerp(wp, 0.22)
				local col = (k % 2 == 0) and crimson or rgb(110, 14, 20)
				tri(m, wp, b1, notch, col, 0.14)
				tri(m, wp, notch, c1, col, 0.14)
			end
			tri(m, shoulder.Position, wp, anchors[5], rgb(110, 14, 20), 0.14)
		end
		-- VFX: embers rising, dark smoke, red heat glow
		fx(core, { texture = FIRE, color = rgb(255, 140, 40), color2 = rgb(255, 60, 30), rate = 10, size = 0.5, speed = NumberRange.new(1, 2.5), accel = V(0, 3, 0), emission = 1, name = "Embers" })
		fx(core, { texture = SMOKE, color = rgb(40, 30, 32), rate = 3, size = 3, alpha = 0.6, life = NumberRange.new(2.5, 3.5), accel = V(0, 1.5, 0), emission = 0, name = "Smoke" })
		return rgb(255, 70, 40)
	end

	------------------------------------------------------------------------------------------------------------
	-- SPACE: purple gas-giant egg with craters + two rings carrying little worlds (earth, ringed planet, mars, moon, sun)
	------------------------------------------------------------------------------------------------------------
	local function miniWorld(m0, cf, kind)
		local m = K.model("World_" .. kind, m0)
		if kind == "earth" then
			p(m, V(2, 2, 2), cf, rgb(50, 120, 230), { shape = "ball" })
			for k = 0, 3 do p(m, V(0.9, 0.7, 0.4), cf * CFrame.Angles(rad(k * 50), rad(k * 95), 0) * CFrame.new(0, 0, -0.85), rgb(80, 190, 90)) end
			p(m, V(1, 0.4, 0.4), cf * CFrame.new(0, 0.9, 0), rgb(255, 255, 255))
		elseif kind == "ringed" then
			p(m, V(1.7, 1.7, 1.7), cf, rgb(240, 196, 120), { shape = "ball" })
			p(m, V(0.12, 3.2, 3.2), cf * CFrame.Angles(rad(20), 0, rad(90)), rgb(255, 230, 170), { shape = "cyl", transp = 0.2 })
		elseif kind == "mars" then
			p(m, V(1.4, 1.4, 1.4), cf, rgb(220, 90, 50), { shape = "ball" })
			p(m, V(0.5, 0.5, 0.2), cf * CFrame.new(0.3, 0.2, -0.62), rgb(170, 60, 36))
		elseif kind == "moon" then
			p(m, V(1.1, 1.1, 1.1), cf, rgb(210, 210, 220), { shape = "ball" })
			p(m, V(0.35, 0.35, 0.2), cf * CFrame.new(-0.2, 0.1, -0.5), rgb(170, 170, 185))
		elseif kind == "sun" then
			local s = p(m, V(1.8, 1.8, 1.8), cf, rgb(255, 210, 80), { shape = "ball", neon = true })
			K.light(s, rgb(255, 210, 100), 10, 1)
		elseif kind == "ice" then
			p(m, V(1.3, 1.3, 1.3), cf, rgb(150, 230, 255), { shape = "ball" })
			p(m, V(0.5, 0.5, 0.5), cf * CFrame.new(0, 0.5, -0.4), rgb(255, 255, 255), { shape = "ball" })
		end
		m:ScaleTo(1.35)
	end
	B.Space = function(m, cf, core)
		local cols = { rgb(70, 40, 140), rgb(100, 56, 180), rgb(140, 84, 214), rgb(100, 56, 180), rgb(196, 116, 226), rgb(150, 92, 220), rgb(110, 62, 196), rgb(80, 140, 226), rgb(110, 62, 196), rgb(150, 92, 220), rgb(96, 54, 170), rgb(70, 40, 140) }
		local w, y = shell(m, cf, 12, 0.92, 5, function(i) return cols[i + 1] end, { step = 0.3 })
		local rr = Random.new(23)
		for k = 1, 7 do
			local i = rr:NextInteger(1, 10); local a = rr:NextNumber() * 360
			local c = cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y[i], -(w[i] / 2 + 0.05))
			ellipsoid(m, V(1.3, 1.3, 0.2), c, K.shade(cols[i + 1], 0.7)); ellipsoid(m, V(0.7, 0.7, 0.25), c, K.shade(cols[i + 1], 0.55))
		end
		for k = 1, 14 do p(m, V(0.25, 0.25, 0.25), cf * CFrame.Angles(0, rad(rr:NextNumber() * 360), 0) * CFrame.new(0, y[rr:NextInteger(0, 11)], -5.2), rgb(255, 255, 255), { neon = true }) end
		-- two rings
		local function ring(rcf, r, thick, col)
			local n = 30
			for k = 1, n do
				local a = (k - 0.5) / n * math.pi * 2
				p(m, V(thick, 0.3, 2 * r * math.tan(math.pi / n) + 0.08), rcf * CFrame.Angles(0, -a, 0) * CFrame.new(r, 0, 0), col, { neon = true, transp = 0.1 })
			end
		end
		local r1 = cf * CFrame.new(0, y[5], 0) * CFrame.Angles(rad(16), 0, rad(-10))
		local r2 = cf * CFrame.new(0, y[6], 0) * CFrame.Angles(rad(-24), rad(40), rad(14))
		ring(r1, 7.4, 1.2, rgb(255, 130, 220)); ring(r2, 8.4, 0.8, rgb(120, 230, 255))
		-- little worlds riding on the rings + floating near the top
		local worlds = { { r1, 7.4, 30, "earth" }, { r1, 7.4, 150, "mars" }, { r1, 7.4, 250, "moon" }, { r2, 8.4, 80, "ringed" }, { r2, 8.4, 200, "ice" }, { r2, 8.4, 320, "sun" } }
		for _, wd in ipairs(worlds) do
			miniWorld(m, wd[1] * CFrame.Angles(0, -rad(wd[3]), 0) * CFrame.new(wd[2], 0.4, 0), wd[4])
		end
		miniWorld(m, cf * CFrame.new(-2.2, y[11] + 1.8, 0.6), "moon")
		-- VFX: twinkling stars + soft nebula haze
		fx(core, { color = rgb(255, 255, 255), color2 = rgb(170, 220, 255), rate = 10, size = 0.35, emission = 1, speed = NumberRange.new(0.2, 0.6), accel = V(0, 0, 0), name = "Stars" })
		fx(core, { texture = SMOKE, colorSeq = ColorSequence.new(rgb(190, 110, 255), rgb(90, 200, 255)), rate = 2, size = 3.5, alpha = 0.7, life = NumberRange.new(3, 4.5), speed = NumberRange.new(0.3, 0.8), accel = V(0, 0.2, 0), emission = 0.6, name = "Nebula" })
		return rgb(180, 110, 255)
	end

	return function(world, cf, parent)
		local m = K.model(world .. "Egg", parent)
		local core = K.part(V(1, 1, 1), cf, Color3.new(1, 1, 1), { parent = m, transp = 1, collide = false, name = "Core" })
		local glow = B[world](m, cf, core)
		aura(m, cf, 5.4, glow)
		m.PrimaryPart = core
		m:SetAttribute("Glow", glow)
		return m, glow
	end
end
