-- Eggs: one unique egg per world (Zoo, Desert, Snow, Forest, Volcano, Space). Built from Parts; the shell is an
-- ellipsoid (SpecialMesh sphere). Returns a function (world, cf, parent) -> Model "<World>Egg" (PrimaryPart = Shell).
return function(K)
	local V = Vector3.new
	local rad = math.rad
	local rgb = K.rgb
	local R = 4 -- shell radius (egg is 8 wide, ~11 tall)
	local SY = 1.38

	local function shell(m, cf, col, mat)
		local p = K.part(V(R * 2, R * 2, R * 2), cf, col, { parent = m, name = "Shell", collide = false, mat = mat })
		local mesh = Instance.new("SpecialMesh"); mesh.MeshType = Enum.MeshType.Sphere; mesh.Scale = V(1.05, SY, 1.05); mesh.Parent = p
		return p
	end
	-- a point on the shell surface: a = angle around, e = height (-1 bottom .. 1 top)
	local function surf(cf, a, e, out)
		local y = e * R * SY
		local rr = R * 1.05 * math.sqrt(math.max(0, 1 - e * e))
		local pos = cf * V(math.cos(a) * rr, y, math.sin(a) * rr)
		local n = (cf * V(math.cos(a) * rr, y / (SY * SY), math.sin(a) * rr) - cf.Position).Unit
		return CFrame.lookAt(pos + n * (out or 0), pos + n * 2)
	end
	-- flattened blob stuck to the shell
	local function spot(m, cf, a, e, size, col, o)
		o = o or {}
		local p = K.part(V(1, 1, 1), surf(cf, a, e, -0.15), col, { parent = m, collide = false, neon = o.neon })
		local sm = Instance.new("SpecialMesh"); sm.MeshType = Enum.MeshType.Sphere; sm.Scale = V(size, size * (o.tall or 1), 0.6); sm.Parent = p
		return p
	end
	-- ring band around the egg at height e
	local function band(m, cf, e, thick, col, o)
		o = o or {}
		local n = 16
		local y = e * R * SY
		local rr = R * 1.05 * math.sqrt(1 - e * e) + 0.1
		for i = 1, n do
			local a = (i - 0.5) / n * math.pi * 2
			local seg = 2 * rr * math.tan(math.pi / n) + 0.15
			K.part(V(0.5, thick, seg), cf * CFrame.Angles(0, -a, 0) * CFrame.new(rr, y, 0) * CFrame.Angles(0, 0, 0) * (o.zig and CFrame.new(0, (i % 2 == 0) and 0.4 or -0.4, 0) or CFrame.identity), col, { parent = m, collide = false, neon = o.neon })
		end
	end

	local B = {}
	B.Zoo = function(m, cf) -- cream shell, orange leopard spots, leafy green band, little paw on top
		local s = shell(m, cf, rgb(255, 246, 222))
		local rr = Random.new(11)
		for i = 1, 12 do spot(m, cf, rr:NextNumber() * 6.28, rr:NextNumber() * 1.5 - 0.65, 1.6 + rr:NextNumber(), rgb(255, 160, 50)) end
		band(m, cf, -0.15, 0.9, rgb(110, 205, 80), { zig = true })
		for i = 1, 6 do -- leaves on the band
			local c = surf(cf, i * 1.047, -0.15, 0.2)
			K.part(V(1.4, 0.3, 2.2), c * CFrame.Angles(rad(90), 0, rad(30)), rgb(80, 180, 70), { parent = m, collide = false })
		end
		local top = cf * CFrame.new(0, R * SY + 0.1, 0)
		K.part(V(0.4, 1.8, 1.8), top * CFrame.Angles(0, 0, rad(90)), rgb(120, 70, 40), { parent = m, shape = "cyl", collide = false })
		return s, rgb(255, 170, 60)
	end
	B.Desert = function(m, cf) -- golden sandstone with a turquoise zig-zag band, hieroglyph dots and a scarab gem
		local s = shell(m, cf, rgb(238, 196, 112))
		band(m, cf, 0.25, 0.8, rgb(40, 190, 190), { zig = true })
		band(m, cf, -0.25, 0.8, rgb(40, 190, 190), { zig = true })
		band(m, cf, 0, 0.5, rgb(180, 110, 50))
		for i = 1, 8 do spot(m, cf, i * 0.785, 0.55, 0.9, rgb(160, 95, 40)) end
		for i = 1, 8 do spot(m, cf, i * 0.785 + 0.39, -0.55, 0.9, rgb(160, 95, 40)) end
		local g = surf(cf, -math.pi / 2, 0, 0.3)
		K.part(V(1.6, 1.6, 1), g * CFrame.Angles(0, 0, rad(45)), rgb(60, 230, 220), { parent = m, collide = false, neon = true })
		return s, rgb(255, 200, 80)
	end
	B.Snow = function(m, cf) -- frosty glass-blue egg with snowflake spots and ice crystals at the base
		local s = shell(m, cf, rgb(205, 235, 255), Enum.Material.Ice)
		local rr = Random.new(7)
		for i = 1, 10 do
			local a, e = rr:NextNumber() * 6.28, rr:NextNumber() * 1.4 - 0.6
			local c = surf(cf, a, e, 0.05)
			for k = 0, 2 do K.part(V(0.25, 1.6, 0.2), c * CFrame.Angles(0, 0, rad(k * 60)), rgb(255, 255, 255), { parent = m, collide = false, neon = true }) end
		end
		band(m, cf, 0.62, 0.6, rgb(255, 255, 255))
		for i = 1, 6 do
			local a = i * 1.047
			local c = cf * CFrame.new(math.cos(a) * 3.6, -R * SY + 1.2, math.sin(a) * 3.6)
			K.part(V(1, 3 + (i % 2) * 1.5, 1), c * CFrame.Angles(rad(math.cos(a) * 25), 0, rad(-math.sin(a) * 25)) * CFrame.Angles(0, rad(45), 0), rgb(150, 220, 255), { parent = m, collide = false, glass = true, transp = 0.2 })
		end
		return s, rgb(120, 210, 255)
	end
	B.Forest = function(m, cf) -- mossy green egg with mushroom-cap spots, vines and a sprout on top
		local s = shell(m, cf, rgb(120, 180, 90))
		local rr = Random.new(5)
		for i = 1, 9 do spot(m, cf, rr:NextNumber() * 6.28, rr:NextNumber() * 1.3 - 0.5, 1.4 + rr:NextNumber() * 0.8, rgb(230, 70, 60)) end
		for i = 1, 9 do spot(m, cf, rr:NextNumber() * 6.28, rr:NextNumber() * 1.3 - 0.5, 0.6, rgb(255, 250, 240)) end
		for v = 0, 2 do -- vines spiralling down
			for i = 0, 6 do
				local e = 0.8 - i * 0.25
				local c = surf(cf, v * 2.09 + i * 0.35, e, 0.1)
				K.part(V(0.5, 1.8, 0.4), c, rgb(60, 140, 50), { parent = m, collide = false })
			end
		end
		local top = cf * CFrame.new(0, R * SY - 0.2, 0)
		K.part(V(0.4, 2, 0.4), top * CFrame.new(0, 1, 0), rgb(80, 150, 60), { parent = m, collide = false })
		for _, sx in ipairs({ -1, 1 }) do K.part(V(1.8, 0.3, 1), top * CFrame.new(sx * 0.9, 2, 0) * CFrame.Angles(0, 0, rad(sx * -20)), rgb(110, 210, 80), { parent = m, collide = false }) end
		return s, rgb(120, 230, 90)
	end
	B.Volcano = function(m, cf) -- black basalt egg with glowing lava cracks and ember spots
		local s = shell(m, cf, rgb(45, 40, 44), Enum.Material.Slate)
		local rr = Random.new(3)
		for c = 1, 5 do -- jagged crack lines
			local a, e = rr:NextNumber() * 6.28, 0.7
			for i = 1, 5 do
				local cfp = surf(cf, a, e, 0.05)
				K.part(V(0.35, 1.9, 0.3), cfp * CFrame.Angles(0, 0, rad((i % 2 == 0) and 25 or -25)), rgb(255, 120, 30), { parent = m, collide = false, neon = true })
				a += (rr:NextNumber() - 0.5) * 0.4; e -= 0.3
			end
		end
		for i = 1, 6 do spot(m, cf, rr:NextNumber() * 6.28, rr:NextNumber() * 1.4 - 0.7, 0.8, rgb(255, 200, 60), { neon = true }) end
		K.sparkle(s, rgb(255, 120, 40), { rate = 6, size = 0.5, accel = V(0, 4, 0), name = "Embers" })
		return s, rgb(255, 110, 40)
	end
	B.Space = function(m, cf) -- deep purple egg with stars and a tilted planet ring
		local s = shell(m, cf, rgb(70, 40, 140))
		local rr = Random.new(9)
		for i = 1, 18 do spot(m, cf, rr:NextNumber() * 6.28, rr:NextNumber() * 1.6 - 0.8, 0.4 + rr:NextNumber() * 0.4, rgb(255, 255, 255), { neon = true }) end
		for i = 1, 4 do spot(m, cf, rr:NextNumber() * 6.28, rr:NextNumber() * 1.2 - 0.6, 1.6, rgb(120, 220, 255), { neon = true }) end
		local ringCf = cf * CFrame.Angles(rad(18), 0, rad(12))
		local n = 24
		for i = 1, n do
			local a = (i - 0.5) / n * math.pi * 2
			local rr2 = 6.4
			K.part(V(0.5, 0.25, 2 * rr2 * math.tan(math.pi / n) + 0.1), ringCf * CFrame.Angles(0, -a, 0) * CFrame.new(rr2, 0, 0), (i % 2 == 0) and rgb(255, 120, 220) or rgb(120, 220, 255), { parent = m, collide = false, neon = true })
		end
		return s, rgb(180, 110, 255)
	end

	return function(world, cf, parent)
		local m = K.model(world .. "Egg", parent)
		local s, glow = B[world](m, cf)
		m.PrimaryPart = s
		m:SetAttribute("Glow", glow)
		return m, glow
	end
end
