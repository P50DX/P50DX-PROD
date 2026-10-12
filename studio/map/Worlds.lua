-- Worlds: themes for worlds 2-6 (Desert, Snow, Forest, Volcano, Space). Each theme = hub look (WorldHub) +
-- obby look (hazard models for Obby.lua) + a generated 10-stage plan. Every world has its own terrain, buildings,
-- cliffs, vegetation, props, hazards, moat/void and centrepiece - no recoloured copies of the Zoo.
return function(K, P, S)
	local V = Vector3.new
	local rad = math.rad
	local rgb = K.rgb
	local W = {}

	------------------------------------------------------------------------------------------------------------
	-- shared builders that take colours / a style
	------------------------------------------------------------------------------------------------------------
	local function lampFor(T)
		return function(pos, light, parent)
			local m = K.model("Lamp", parent)
			local st = T.lampStyle
			if st == "brazier" then -- stone pillar with a fire bowl (Desert / Volcano)
				K.part(V(2.8, 1, 2.8), CFrame.new(pos + V(0, 0.5, 0)), K.shade(T.lampCol, 0.8), { parent = m, studs = true })
				K.part(V(2, 9, 2), CFrame.new(pos + V(0, 5.5, 0)), T.lampCol, { parent = m, studs = true })
				K.part(V(3.6, 1.4, 3.6), CFrame.new(pos + V(0, 10.7, 0)), K.shade(T.lampCol, 0.7), { parent = m, collide = false })
				local f = K.part(V(2.4, 1.6, 2.4), CFrame.new(pos + V(0, 12, 0)), T.glow, { parent = m, neon = true, collide = false })
				K.sparkle(f, T.glow, { rate = 8, size = 0.9, accel = V(0, 7, 0), speed = NumberRange.new(1, 3), name = "Fire" })
				if light then K.light(f, T.glow, 22, 1.4) end
			elseif st == "neon" then -- sci-fi light pole (Space)
				K.part(V(2.4, 0.8, 2.4), CFrame.new(pos + V(0, 0.4, 0)), T.lampCol, { parent = m })
				K.part(V(0.8, 12, 0.8), CFrame.new(pos + V(0, 6.8, 0)), T.lampCol, { parent = m })
				K.part(V(0.3, 10, 0.3), CFrame.new(pos + V(0.5, 6.8, 0)), T.glow, { parent = m, neon = true, collide = false })
				local f = K.part(V(2, 2, 2), CFrame.new(pos + V(0, 13.6, 0)) * CFrame.Angles(rad(45), 0, rad(45)), T.glow, { parent = m, neon = true, collide = false })
				if light then K.light(f, T.glow, 22, 1.4) end
			else
				P.lamp(pos, { metal = T.lampCol, glow = T.glow }, light, m)
			end
			return m
		end
	end

	local function frameBuilding(T, signFace)
		-- open frame with columns, beams and a big two-sided sign on one long side (pavilion / gym)
		return function(cf, w, d, text, parent, signSide)
			local hw, hd = w / 2 - 2, d / 2 - 2
			local col = T.frameCol
			for _, c in ipairs({ { -hw, -hd }, { hw, -hd }, { -hw, hd }, { hw, hd } }) do
				if T.frameStyle == "round" then
					K.cyl(5, 34, (cf * CFrame.new(c[1], 17, c[2])).Position, col, { parent = parent })
					K.part(V(6.5, 2, 6.5), cf * CFrame.new(c[1], 34.6, c[2]), T.frameTrim, { parent = parent, studs = true })
				else
					K.part(V(5, 34, 5), cf * CFrame.new(c[1], 17, c[2]), col, { parent = parent, studs = true, mat = T.frameMat })
					K.part(V(6, 2, 6), cf * CFrame.new(c[1], 34.6, c[2]), T.frameTrim, { parent = parent, studs = true, neon = T.neonTrim })
				end
			end
			for _, z in ipairs({ -hd, hd }) do K.part(V(w - 2, 2.4, 3), cf * CFrame.new(0, 35, z), col, { parent = parent, studs = true, mat = T.frameMat }) end
			for _, x in ipairs({ -hw, hw }) do K.part(V(3, 2.4, d - 2), cf * CFrame.new(x, 35, 0), col, { parent = parent, studs = true, mat = T.frameMat }) end
			local sx = signSide or 1
			local sign = K.part(V(4, 10, d * 0.5), cf * CFrame.new(sx * hw, 29, 0), T.accent, { parent = parent, studs = true })
			K.part(V(3.6, 11, d * 0.5 + 1), cf * CFrame.new(sx * hw, 29, 0), T.frameTrim, { parent = parent, collide = false, neon = T.neonTrim })
			for _, f in ipairs({ Enum.NormalId.Right, Enum.NormalId.Left }) do
				K.textPanel(sign, f, { { text = text, h = 0.85, color = Color3.new(1, 1, 1), font = K.FONT_BOLD } }, { pps = 10, stroke = 4 })
			end
			K.part(V(4, 34, 4), cf * CFrame.new(sx * hw, 17, 0), col, { parent = parent, studs = true, mat = T.frameMat })
		end
	end

	local function hubCommon(T)
		T.lamp = lampFor(T)
		T.pavilion = function(cf, w, d, text, parent) frameBuilding(T)(cf, w, d, text, parent, 1) end
		T.gym = function(cf, w, d, text, parent) frameBuilding(T)(cf, w, d, text, parent, -1) end
		T.backdrop = T.backdrop or function(pts, parent, sides) P.backdrop(pts, T.hills, parent, sides) end
		T.metal = T.metal or rgb(60, 64, 86)
		T.portalFrame = T.portalFrame or T.gatePillar
		return T
	end

	------------------------------------------------------------------------------------------------------------
	-- generic obby hazard looks, driven by T.style
	------------------------------------------------------------------------------------------------------------
	local function obbyCommon(T)
		local st = T.style
		T.support = function(cf, w, l, parent)
			if st == "space" then -- floating island underside
				K.part(V(w * 0.8, 5, l * 0.8), cf * CFrame.new(0, -2.5, 0), T.supCol, { parent = parent, studs = true, name = "Underside" })
				K.part(V(w * 0.5, 6, l * 0.5), cf * CFrame.new(0, -8, 0) * CFrame.Angles(0, rad(20), 0), K.shade(T.supCol, 0.85), { parent = parent, name = "Underside" })
				K.part(V(w * 0.22, 5, l * 0.22), cf * CFrame.new(0, -13, 0) * CFrame.Angles(0, rad(40), 0), K.shade(T.supCol, 0.7), { parent = parent, name = "Underside" })
				return
			end
			local cw, cl = math.max(8, w * 0.42), math.max(8, l * 0.42)
			local depth = 46
			if st == "forest" then
				K.cyl(math.min(cw, cl) * 1.1, depth, (cf * CFrame.new(0, -depth / 2, 0)).Position, T.supCol, { parent = parent, name = "Column", mat = Enum.Material.Wood })
				K.part(V(cw * 1.2, 2, 2), cf * CFrame.new(0, -10, 0) * CFrame.Angles(0, rad(30), rad(20)), K.shade(T.supCol, 0.8), { parent = parent, collide = false, name = "Root" })
			else
				K.part(V(cw, depth, cl), cf * CFrame.new(0, -depth / 2, 0), K.jitter(T.supCol, 0.03), { parent = parent, studs = true, name = "Column", mat = T.supMat })
				K.part(V(cw + 1, 2, cl + 1), cf * CFrame.new(0, -6, 0), T.trim, { parent = parent, collide = false, name = "Band", neon = T.neonTrim })
			end
		end

		T.crusher = function(c, w, cell, parent)
			local m = K.model("Crusher", parent)
			local top = c * CFrame.new(0, 32, 0)
			local L = cell - 6
			local body
			if st == "forest" then -- bundle of logs
				body = K.part(V(w - 6, 6, L), top * CFrame.new(0, 3, 0), T.crushCol, { parent = m, name = "Crate", mat = Enum.Material.Wood })
				for k = 0, 2 do K.part(V(w - 5, 5.4, 5.4), top * CFrame.new(0, 8 + k * 0.1, -L / 3 + k * L / 3), K.shade(T.crushCol, 1 - k * 0.06), { parent = m, collide = false, shape = "cyl", mat = Enum.Material.Wood }) end
			else
				body = K.part(V(w - 6, 16, L), top * CFrame.new(0, 8, 0), T.crushCol, { parent = m, name = "Crate", mat = T.crushMat, glass = st == "snow", transp = st == "snow" and 0.15 or 0, studs = st ~= "snow" and st ~= "space" })
				for _, sx in ipairs({ -1, 1 }) do K.part(V(1.2, 16.2, L + 0.2), top * CFrame.new(sx * ((w - 6) / 2 - 0.4), 8, 0), T.crushTrim, { parent = m, collide = false, neon = T.neonTrim }) end
				if st == "desert" then -- carved face
					for _, sx in ipairs({ -1, 1 }) do K.part(V(3, 2, 0.4), top * CFrame.new(sx * 5, 10, L / 2 + 0.1), rgb(60, 36, 20), { parent = m, collide = false }) end
					K.part(V(10, 1.2, 0.4), top * CFrame.new(0, 5, L / 2 + 0.1), rgb(60, 36, 20), { parent = m, collide = false })
				elseif st == "space" then
					for k = -1, 1 do K.part(V(w - 5.8, 0.6, 0.4), top * CFrame.new(0, 8 + k * 4, L / 2 + 0.1), T.glow, { parent = m, collide = false, neon = true }) end
				end
			end
			K.part(V(w - 4, 2.4, L + 2), top * CFrame.new(0, -1.2, 0), T.hazard, { parent = m, name = "Foot", collide = false, tag = "HazardKill", neon = st == "volcano" })
			local mk = K.part(V(w - 6, 0.2, L), c * CFrame.new(0, 0.12, 0), T.hazard, { parent = parent, collide = false, transp = 0.55, name = "CrushZone" })
			mk.CastShadow = false
			m.PrimaryPart = body
			return m
		end

		T.slidingWall = function(c, w, parent)
			local m = K.model("SlidingWall", parent)
			local ww, hh = 22, 16
			local frame = K.part(V(ww, 1.4, 2), c * CFrame.new(0, hh, 0), T.metal, { parent = m, collide = false, tag = "HazardKill", name = "Frame" })
			if st == "space" then -- laser gate
				for _, sx in ipairs({ -1, 1 }) do K.part(V(1.6, hh, 1.6), c * CFrame.new(sx * ww / 2, hh / 2, 0), T.metal, { parent = m, collide = false, tag = "HazardKill" }) end
				for k = 1, 5 do K.part(V(ww - 1.6, 0.4, 0.4), c * CFrame.new(0, k * hh / 6, 0), T.hazard, { parent = m, collide = false, neon = true, tag = "HazardKill" }) end
			elseif st == "volcano" then -- wall of fire
				for k = 0, 5 do
					local f = K.part(V(3.4, hh - 2 - (k % 2) * 3, 1.2), c * CFrame.new(-ww / 2 + 1.9 + k * (ww - 3.8) / 5, (hh - 2 - (k % 2) * 3) / 2, 0), (k % 2 == 0) and rgb(255, 120, 30) or rgb(255, 200, 60), { parent = m, collide = false, neon = true, tag = "HazardKill" })
					if k == 2 then K.sparkle(f, rgb(255, 140, 40), { rate = 10, size = 1, accel = V(0, 8, 0), name = "Fire" }) end
				end
			elseif st == "forest" then -- vertical logs with sharpened tips
				for k = 0, 6 do
					local x = -ww / 2 + 1.6 + k * (ww - 3.2) / 6
					K.part(V(2.6, hh, 2.6), c * CFrame.new(x, hh / 2, 0) * CFrame.Angles(0, 0, rad(90)), T.crushCol, { parent = m, collide = false, shape = "cyl", tag = "HazardKill", mat = Enum.Material.Wood })
				end
			else -- sandstone / ice wall with spikes
				K.part(V(ww, hh - 1, 2.4), c * CFrame.new(0, hh / 2, 0), T.crushCol, { parent = m, collide = false, tag = "HazardKill", glass = st == "snow", transp = st == "snow" and 0.2 or 0, studs = st == "desert" })
				for k = 0, 4 do
					for _, sz in ipairs({ -1, 1 }) do
						K.part(V(1.4, 1.4, 2.6), c * CFrame.new(-ww / 2 + 2.4 + k * (ww - 4.8) / 4, hh * 0.5, sz * 2.2) * CFrame.Angles(0, 0, rad(45)), T.hazard, { parent = m, collide = false, tag = "HazardKill" })
					end
				end
			end
			K.part(V(w, 0.6, 3), c * CFrame.new(0, 0.3, 0), K.shade(T.metal, 0.8), { parent = parent, collide = false })
			m.PrimaryPart = frame
			return m
		end

		T.net = function(c, arm, parent) -- the world's giant pendulum
			local m = K.model("Pendulum", parent)
			local pivotY = arm + 12
			local pivot = c * CFrame.new(0, pivotY, 0)
			for _, sx in ipairs({ -1, 1 }) do
				K.part(V(5, pivotY + 56, 5), c * CFrame.new(sx * 40, (pivotY + 6) / 2 - 25, 0), T.frameCol, { parent = parent, studs = true, mat = T.frameMat })
				K.part(V(7, 3, 7), c * CFrame.new(sx * 40, pivotY + 7.5, 0), T.frameTrim, { parent = parent, studs = true, neon = T.neonTrim })
			end
			K.part(V(86, 4, 5), c * CFrame.new(0, pivotY + 4, 0), T.frameCol, { parent = parent, studs = true, mat = T.frameMat })
			local hinge = K.part(V(4, 4, 4), pivot, T.frameTrim, { parent = m, name = "Hinge", collide = false, shape = "ball" })
			local hc = pivot * CFrame.new(0, -arm, 0)
			local chainLen = arm - 8
			for k = 0, math.floor(chainLen / 3) - 1 do -- chain / rope links
				K.part(V(0.7, 2.4, 1.2), pivot * CFrame.new(0, -1.5 - k * 3, 0) * CFrame.Angles(0, rad((k % 2) * 90), 0), T.chainCol or T.metal, { parent = m, collide = false })
			end
			local o = { parent = m, collide = false, tag = "HazardKill" }
			if st == "desert" then -- golden ancient hammer
				o.studs = true
				K.part(V(16, 10, 9), hc, rgb(240, 190, 70), o)
				for _, sx in ipairs({ -1, 1 }) do K.part(V(1.6, 11, 10), hc * CFrame.new(sx * 8.4, 0, 0), rgb(46, 176, 176), o) end
				K.part(V(3, 4, 3), hc * CFrame.new(0, 6, 0), rgb(200, 150, 60), { parent = m, collide = false })
			elseif st == "snow" then -- huge icicle mace
				K.part(V(11, 11, 11), hc, rgb(170, 225, 255), { parent = m, collide = false, tag = "HazardKill", glass = true, transp = 0.15, shape = "ball" })
				for k = 0, 5 do
					local d = ({ V(1, 0, 0), V(-1, 0, 0), V(0, 1, 0), V(0, -1, 0), V(0, 0, 1), V(0, 0, -1) })[k + 1]
					K.part(V(2, 2, 6), CFrame.lookAt(hc.Position + d * 6, hc.Position + d * 12), rgb(230, 248, 255), { parent = m, collide = false, tag = "HazardKill", glass = true })
				end
			elseif st == "forest" then -- swinging log
				K.part(V(22, 7, 7), hc, T.crushCol, { parent = m, collide = false, tag = "HazardKill", shape = "cyl", mat = Enum.Material.Wood })
				for _, sx in ipairs({ -1, 1 }) do K.part(V(0.6, 7.4, 7.4), hc * CFrame.new(sx * 11, 0, 0), rgb(210, 170, 110), { parent = m, collide = false, shape = "cyl" }) end
				K.part(V(10, 2, 2), hc * CFrame.new(0, 4, 0), rgb(80, 120, 50), { parent = m, collide = false })
			elseif st == "volcano" then -- magma ball
				K.part(V(12, 12, 12), hc, rgb(60, 40, 36), { parent = m, collide = false, tag = "HazardKill", shape = "ball", mat = Enum.Material.Basalt })
				for k = 0, 3 do K.part(V(12.3, 1, 12.3), hc * CFrame.Angles(0, rad(k * 45), rad(90)), rgb(255, 120, 30), { parent = m, collide = false, neon = true, shape = "cyl" }) end
				local f = K.part(V(1, 1, 1), hc, rgb(255, 120, 30), { parent = m, collide = false, transp = 1 })
				K.sparkle(f, rgb(255, 120, 30), { rate = 12, size = 1.2, accel = V(0, 6, 0), name = "Fire", shape = Enum.ParticleEmitterShape.Sphere })
			else -- space: energy orb in a ring
				K.part(V(10, 10, 10), hc, rgb(150, 90, 255), { parent = m, collide = false, tag = "HazardKill", shape = "ball", neon = true })
				S.ring(hc * CFrame.Angles(0, rad(90), 0), 7.5, 1, 1, rgb(120, 230, 255), 16, { neon = true }, m)
				for _, p in m:GetChildren() do if p:IsA("BasePart") and p.Size.Y == 1 then K.tag(p, "HazardKill") end end
			end
			m.PrimaryPart = hinge
			return m
		end

		T.boulder = function(cf, r, parent)
			local m = K.model("GiantBall", parent)
			local col = T.ballCol
			local ball = K.part(V(r * 2, r * 2, r * 2), cf, col, { parent = m, shape = "ball", collide = false, name = "Ball", tag = "HazardKill", mat = T.ballMat })
			local rr = Random.new(T.id * 13)
			for k = 1, (st == "space" and 6 or 8) do
				local d = V(rr:NextNumber() - 0.5, rr:NextNumber() - 0.5, rr:NextNumber() - 0.5).Unit
				if st == "space" then -- craters
					K.part(V(1.2, r * 0.6, r * 0.6), CFrame.lookAt(cf.Position + d * (r - 0.3), cf.Position + d * r * 2) * CFrame.Angles(0, rad(90), 0), K.shade(col, 0.75), { parent = m, shape = "cyl", collide = false })
				elseif st == "snow" then -- snow chunks
					K.part(V(r * 0.5, r * 0.5, r * 0.5), CFrame.new(cf.Position + d * (r - 1)), rgb(250, 252, 255), { parent = m, shape = "ball", collide = false })
				else -- rock lumps
					K.part(V(r * 0.6, r * 0.45, r * 0.6), CFrame.lookAt(cf.Position + d * (r - 2), cf.Position + d * r * 2), K.shade(col, 0.9 + rr:NextNumber() * 0.2), { parent = m, collide = false, studs = true })
				end
			end
			if st == "volcano" then
				for k = 0, 2 do K.part(V(r * 2 + 0.2, 0.8, 0.8), cf * CFrame.Angles(rad(k * 60), rad(k * 37), 0), rgb(255, 120, 30), { parent = m, collide = false, neon = true }) end
			end
			m.PrimaryPart = ball
			return m
		end

		T.dispenser = function(c, laneW, r, parent)
			local m = K.model("BallDispenser", parent)
			for _, sx in ipairs({ -1, 1 }) do
				K.part(V(8, 110, 10), c * CFrame.new(sx * (laneW / 2 + 5), 5, 6), T.gatePillar, { parent = m, studs = true, mat = T.frameMat })
				K.part(V(10, 3, 12), c * CFrame.new(sx * (laneW / 2 + 5), 61.5, 6), T.gateTrim, { parent = m, studs = true, neon = T.neonTrim })
			end
			local top = K.part(V(laneW + 20, 10, 12), c * CFrame.new(0, 56, 6), T.hazard, { parent = m, studs = true })
			K.textPanel(top, Enum.NormalId.Front, { { text = "⚠ " .. T.ballName .. " ⚠", h = 0.8, color = rgb(255, 240, 120), font = K.FONT_BOLD } }, { pps = 8, stroke = 4 })
			local glow = K.part(V(laneW - 4, 1, 4), c * CFrame.new(0, 50.5, 4), T.glow, { parent = m, neon = true, collide = false, name = "SpawnGlow" })
			K.tag(glow, "BallSpawnGlow")
		end

		T.bridge = function(cf, l, w, parent)
			local n = math.floor(l / 3.2)
			for i = 0, n - 1 do
				local z = -(i + 0.5) * (l / n)
				local col = (i % 2 == 0) and T.bridgeCol or K.shade(T.bridgeCol, 0.92)
				K.part(V(w, 1.6, l / n - 0.2), cf * CFrame.new(0, -0.8, z), col, { parent = parent, name = "Plank", mat = T.bridgeMat, glass = st == "snow", transp = (st == "snow" or st == "space") and 0.25 or 0, neon = false })
			end
			K.part(V(w + 2, 1, l), cf * CFrame.new(0, -2, -l / 2), K.shade(T.bridgeCol, 0.6), { parent = parent, name = "BridgeBase", neon = st == "volcano" or st == "space" })
			for _, sx in ipairs({ -1, 1 }) do
				for i = 0, math.floor(l / 16) do
					K.part(V(1.4, 6, 1.4), cf * CFrame.new(sx * (w / 2 + 0.5), 3, -i * l / math.floor(l / 16)), T.frameCol, { parent = parent, mat = T.frameMat })
				end
				K.part(V(0.6, 0.6, l), cf * CFrame.new(sx * (w / 2 + 0.5), 5.8, -l / 2), (st == "space" or st == "volcano") and T.glow or K.shade(T.frameCol, 0.8), { parent = parent, collide = false, neon = st == "space" or st == "volcano" })
			end
		end

		T.edgeProps = function(cf, l, w, parent)
			for i = 1, math.max(1, math.floor(l / 40)) do
				local sx = K.chance(0.5) and 1 or -1
				local c = cf * CFrame.new(sx * (w / 2 - 5), 0, -K.rand(6, l - 6)) * CFrame.Angles(0, rad(K.rand(0, 40)), 0)
				T.small(c.Position, parent)
			end
		end

		T.rewardDecor = function(cf, parent)
			for _, sx in ipairs({ -1, 1 }) do
				P.banner((cf * CFrame.new(sx * 50, 0, -40)).Position, sx > 0 and 180 or 0, sx > 0 and T.accent2 or T.accent, "🏆", T, parent)
			end
		end
		T.startDecor = function(cf, parent)
			local sign = K.part(V(1, 1, 1), cf * CFrame.new(0, 64, -100), Color3.new(1, 1, 1), { parent = parent, transp = 1, collide = false })
			K.billboard(sign, { { text = T.escapeText, h = 1, grad = T.titleGrad, font = K.FONT_BOLD, stroke = 5 } }, { size = UDim2.fromScale(54, 8), offset = V(0, 0, 0), dist = 500 })
			for _, sx in ipairs({ -1, 1 }) do for k = 0, 2 do T.small((cf * CFrame.new(sx * 58, 0, -20 - k * 34)).Position, parent) end end
		end

		T.underlay = function(centre, from, y, parent)
			if st == "space" then return end
			for i = math.max(1, from), #centre - 1 do
				local a, b = centre[i].cf.Position, centre[i + 1].cf.Position
				local d = V(b.X - a.X, 0, b.Z - a.Z)
				if d.Magnitude > 4 then
					local mpos = V((a.X + b.X) / 2, y, (a.Z + b.Z) / 2)
					local p = K.part(V(170, 2, d.Magnitude + 40), CFrame.lookAt(mpos, mpos + d), T.moatCol, { parent = parent, collide = false, transp = T.moatTransp or 0, mat = T.moatMat, neon = T.moatNeon, name = "Moat" })
					p.CastShadow = false
				end
			end
		end

		T.walls = function(centre, parent)
			local Y = V(0, 1, 0)
			local pts = {}
			for i = 1, #centre, 6 do table.insert(pts, centre[i].cf.Position) end
			table.insert(pts, centre[#centre].cf.Position)
			T.backdrop(pts, parent.Parent)
			for i = 1, #centre - 1 do
				local A, B = centre[i], centre[i + 1]
				local a, b = A.cf.Position, B.cf.Position
				local d = V(b.X - a.X, 0, b.Z - a.Z)
				local hw = math.max(A.hw, B.hw)
				if d.Magnitude > 4 then
					local r = d.Unit:Cross(Y)
					if st == "space" then -- invisible walls + floating rocks with crystals now and then
						for _, sx in ipairs({ -1, 1 }) do
							local mid = (a + b) / 2 + r * sx * (hw + 6)
							K.part(V(4, 200, d.Magnitude + 2), CFrame.lookAt(mid, mid + d), Color3.new(1, 1, 1), { parent = parent, transp = 1, name = "Boundary" })
							if K.chance(0.5) then
								local rp = (a + b) / 2 + r * sx * K.rand(hw + 30, hw + 90) + V(0, K.rand(-30, 40), 0)
								K.part(V(K.rand(14, 30), K.rand(8, 14), K.rand(14, 30)), CFrame.new(rp) * CFrame.Angles(0, rad(K.rand(0, 90)), 0), K.jitter(T.rock[1], 0.04), { parent = parent, studs = true, collide = false })
								if K.chance(0.6) then P.tree(rp + V(0, 5, 0), "crystal", K.rand(0.8, 1.3), T.treePal, parent) end
							end
						end
					else
						local base = math.min(a.Y, b.Y) - 55
						local o = { height = math.max(a.Y, b.Y) - base + 30, depth = 30, step = 26, rock = T.rock, top = T.top, trees = T.wallTrees or 0.15, bushes = 0.3, treeKind = T.treeKinds, treePal = T.treePal, overhang = 0.35, inward = r }
						P.cliff(V(a.X, base, a.Z) - r * hw, V(b.X, base, b.Z) - r * hw, o, parent)
						o.inward = -r
						P.cliff(V(b.X, base, b.Z) + r * hw, V(a.X, base, a.Z) + r * hw, o, parent)
					end
				elseif A.cf.LookVector:Dot(B.cf.LookVector) < 0.995 and st ~= "space" then
					for _, sx in ipairs({ -1, 1 }) do
						local p = A.cf * CFrame.new(sx * (hw + 14), 0, 0)
						K.part(V(36, 85, 36), CFrame.new(p.Position + V(0, -12.5, 0)) * CFrame.Angles(0, rad(K.rand(0, 45)), 0), T.rock[1], { parent = parent, studs = true })
						if T.top then K.part(V(38, 2.4, 38), CFrame.new(p.Position + V(0, 31, 0)) * CFrame.Angles(0, rad(K.rand(0, 45)), 0), T.top, { parent = parent, studs = true }) end
					end
				end
			end
		end

		T.finish = function(cf, parent, addCentre)
			K.slab(V(140, 4, 120), cf * CFrame.new(0, -2, -60), T.rewardFloor, { parent = parent, rim = T.rim })
			S.trophy(cf * CFrame.new(0, 0, -70), 2.6, parent)
			local sign = K.part(V(1, 1, 1), cf * CFrame.new(0, 50, -70), Color3.new(1, 1, 1), { parent = parent, transp = 1, collide = false })
			K.billboard(sign, { { text = T.finishText, h = 1, grad = T.titleGrad, font = K.FONT_BOLD, stroke = 5 } }, { size = UDim2.fromScale(60, 9), offset = V(0, 0, 0), dist = 700 })
			local pad = K.part(V(24, 1, 24), cf * CFrame.new(0, 0.5, -110), T.glow, { parent = parent, neon = true, name = "ReturnPad", touch = true })
			K.tag(pad, "ReturnPad", { World = T.id })
			K.billboard(pad, { { text = "BACK TO THE " .. T.key:upper(), h = 1, color = Color3.new(1, 1, 1), font = K.FONT_BOLD, stroke = 3 } }, { size = UDim2.fromScale(20, 3), offset = V(0, 8, 0) })
			addCentre(cf, 80); addCentre(cf * CFrame.new(0, 0, -120), 80)
		end
		return T
	end

	------------------------------------------------------------------------------------------------------------
	-- stage plan generator: lengths grow every stage, 3 chases, a rolling-ball stage, a pendulum stage, a finale
	------------------------------------------------------------------------------------------------------------
	function W.plan(seed, kinds, mult)
		local rr = Random.new(seed)
		local function pick(t) return t[rr:NextInteger(1, #t)] end
		local plan = {}
		for i = 1, 10 do
			local m = (mult and mult[i]) or 1
			local kind = kinds[i]
			local secs = {}
			local gap = i <= 2 and 5 or (i <= 5 and 6 or 7)
			if kind == "Chase" then
				local route = { { "run", 70 + i * 4, 48, props = true } }
				local steps = math.floor((5 + i * 1.1) * m)
				local opts = { { "turn", 30 }, { "turn", -30 }, { "ramp", 50, 12 }, { "bridge", 80, 32 }, { "run", 60 } }
				if i >= 5 then table.insert(opts, { "sweeper", 64, 50 + i * 4 }); table.insert(opts, { "walls", 2 }) end
				if i >= 8 then table.insert(opts, { "ramp", 50, -10 }) end
				local lastTurn = 0
				for s = 1, steps do
					local o = pick(opts)
					if o[1] == "turn" then o = { "turn", (lastTurn > 0) and -rr:NextInteger(15, 40) or rr:NextInteger(15, 40) }; lastTurn = o[2] end
					table.insert(route, o)
				end
				table.insert(route, { "run", 70, 48, props = true })
				secs = { { "chase", { route = route } } }
			elseif kind == "Ball" then
				local len = math.floor((380 + i * 50) * m)
				secs = { { "run", { len = 30 } }, { "ball", { len = len, rise = math.floor(len * 0.095), speed = 70 + i * 2, pocketEvery = 74 - i } }, { "jumps", { n = 2 + math.floor(i / 4), gap = gap, l = 40, dx = 8 } } }
			elseif kind == "Nets" then
				local n = math.floor((4 + i * 0.9) * m)
				secs = { { "nets", { n = math.ceil(n / 2), gap = gap, l = 46, period = 3.6 - i * 0.06 } }, { "turn", { deg = rr:NextInteger(-25, 25) } }, { "mover", { gap = 56, axis = "z", period = 4.2 } }, { "nets", { n = math.floor(n / 2) + 1, gap = gap, l = 42, period = 3.2 - i * 0.05, offset = 0.37 } } }
			else
				local pool = { { "jumps", { n = 3, gap = gap, l = 40, w = 46 } }, { "ramp", { len = 50, rise = 10 } }, { "mover", { gap = 56, axis = "z", period = 4.5 } } }
				if i >= 2 then table.insert(pool, { "sweeper", { len = 64, speed = 55 + i * 4 } }); table.insert(pool, { "jumps", { n = 3, gap = gap, l = 38, dx = 8, dy = 4 } }) end
				if i >= 3 then table.insert(pool, { "crushers", { n = 3, period = 3.4 - i * 0.05 } }); table.insert(pool, { "blink", { n = 4, period = 4 } }); table.insert(pool, { "climb", { n = 4, step = 5, dx = 6 } }) end
				if i >= 4 then table.insert(pool, { "collapse", { n = 3, delay = 0.7 } }); table.insert(pool, { "turn", { deg = 25 } }); table.insert(pool, { "turn", { deg = -25 } }); table.insert(pool, { "mover", { gap = 60, axis = "x", amp = 20, period = 3.6 } }) end
				if i >= 6 then table.insert(pool, { "walls", { n = 3 } }); table.insert(pool, { "sweeper", { len = 70, speed = 70 + i * 3, arms = 2 } }) end
				local n = math.floor((2.5 + i * 0.85) * m)
				local last
				for s = 1, n do
					local o
					repeat o = pick(pool) until o ~= last
					last = o
					table.insert(secs, o)
				end
				if kind == "Finale" then
					table.insert(secs, 3, { "nets", { n = 4, gap = 7, l = 44, period = 3 } })
					table.insert(secs, 5, { "ball", { len = 340, rise = 32, speed = 85, pocketEvery = 66 } })
				end
				if i == 1 then secs[1] = { "run", { len = 24, props = true } } end
			end
			plan[i] = { kind = kind, sections = secs }
		end
		return plan
	end

	------------------------------------------------------------------------------------------------------------
	-- WORLD 2: DESERT
	------------------------------------------------------------------------------------------------------------
	local sand, sand2, stone = rgb(232, 196, 130), rgb(222, 182, 112), rgb(214, 170, 110)
	W.Desert = function()
		local T = { id = 2, key = "Desert", style = "desert", obbyTitle = "OBBY", escapeText = "ESCAPE THE DESERT!", finishText = "YOU CROSSED THE DESERT!", ballName = "BOULDER",
			floor = sand, floor2 = rgb(240, 208, 146), floorMat = Enum.Material.Plastic, path = rgb(196, 150, 96), path2 = rgb(182, 136, 84), curb = rgb(250, 232, 190),
			plaza1 = rgb(226, 190, 130), plaza2 = rgb(240, 214, 160),
			rock = { rgb(214, 140, 80), rgb(232, 168, 100) }, rock2 = { rgb(196, 120, 70), rgb(222, 150, 90) }, top = rgb(240, 206, 140), top2 = rgb(236, 200, 132),
			cliffTrees = 0.25, cliffBushes = 0.2, treeKinds = { "cactus", "palm", "dead" }, lawnTrees = { "cactus", "palm" },
			treePal = { trunk = rgb(160, 112, 70), leaf = rgb(90, 170, 80), leaf2 = rgb(120, 196, 96), extra = rgb(255, 120, 160), flower = rgb(255, 120, 160) },
			gatePillar = rgb(232, 196, 130), gateTrim = rgb(46, 176, 176), gateField = rgb(255, 200, 90), titleGrad = { rgb(255, 245, 170), rgb(255, 160, 40) },
			padBase = rgb(150, 100, 64), padTrim = rgb(250, 232, 190), accent = rgb(46, 176, 176), accent2 = rgb(255, 170, 50), gymFloor = rgb(150, 100, 64),
			frameCol = rgb(232, 196, 130), frameTrim = rgb(46, 176, 176), frameStyle = "round", lampStyle = "brazier", lampCol = stone, glow = rgb(255, 170, 60),
			eggGlow = rgb(255, 200, 80), shopCols = { rgb(230, 120, 50), rgb(46, 176, 176), rgb(180, 85, 200) }, shopWall = rgb(244, 224, 182),
			prevCol = rgb(110, 220, 120), nextCol = rgb(140, 210, 255), wood = rgb(170, 110, 60), metal = rgb(120, 86, 56),
			hills = { base = rgb(214, 150, 90), grass = rgb(238, 200, 130), grass2 = rgb(244, 214, 150), floor = rgb(226, 186, 120), floorY = -150, extraH = -40 },
			-- obby
			plat = { rgb(236, 206, 146), rgb(214, 160, 100), rgb(80, 186, 186), rgb(244, 222, 170) }, rim = rgb(150, 100, 64), trim = rgb(46, 176, 176),
			gateFloor = rgb(226, 196, 140), rewardFloor = rgb(244, 224, 180), hazard = rgb(255, 80, 50), hazardDark = rgb(110, 70, 40), warn = rgb(255, 80, 40),
			moverCol = rgb(80, 200, 200), blinkCol = rgb(255, 210, 90), collapseCol = rgb(200, 150, 100), laneCol = rgb(226, 190, 128), pocketCol = rgb(90, 210, 120),
			supCol = rgb(214, 170, 110), crushCol = rgb(222, 180, 116), crushTrim = rgb(46, 176, 176), chainCol = rgb(120, 90, 60),
			ballCol = rgb(206, 150, 92), bridgeCol = rgb(222, 184, 120), moatCol = rgb(236, 196, 124), moatMat = Enum.Material.Sand,
		}
		T.centrepiece = function(cf, parent) -- oasis: octagonal basin, water, palms and a golden obelisk
			for i = 0, 7 do K.part(V(14.6, 3.4, 3), cf * CFrame.Angles(0, rad(i * 45), 0) * CFrame.new(0, 1.7, -16.5), stone, { parent = parent, studs = true }) end
			K.cyl(32, 2.4, (cf * CFrame.new(0, 1.2, 0)).Position, rgb(60, 170, 200), { parent = parent, collide = false })
			K.cyl(31.6, 0.4, (cf * CFrame.new(0, 2.5, 0)).Position, rgb(90, 210, 230), { parent = parent, collide = false, transp = 0.2, glass = true })
			K.part(V(7, 3, 7), cf * CFrame.new(0, 1.5, 0), stone, { parent = parent, studs = true })
			for k = 0, 3 do K.part(V(5.4 - k, 7, 5.4 - k), cf * CFrame.new(0, 6.5 + k * 7, 0), rgb(240, 196, 80), { parent = parent, studs = true }) end
			K.part(V(2.6, 2.6, 2.6), cf * CFrame.new(0, 35, 0) * CFrame.Angles(rad(45), 0, rad(45)), rgb(60, 230, 220), { parent = parent, neon = true, collide = false })
			for k = 0, 3 do P.tree((cf * CFrame.Angles(0, rad(k * 90 + 45), 0) * CFrame.new(0, 0, -24)).Position, "palm", 1.1, T.treePal, parent) end
		end
		T.decorA = function(cf, parent) -- ancient ruins: broken columns, fallen pillar, stairs
			K.part(V(50, 1, 44), cf * CFrame.new(0, 0.5, 0), stone, { parent = parent, studs = true })
			for k = 0, 5 do
				local h = ({ 18, 9, 14, 6, 20, 11 })[k + 1]
				local p = cf * CFrame.new(-18 + (k % 3) * 18, 1, (k < 3) and -12 or 12)
				K.cyl(5, h, (p * CFrame.new(0, h / 2, 0)).Position, rgb(240, 214, 160), { parent = parent })
				K.part(V(6.4, 1.4, 6.4), p * CFrame.new(0, 0.7, 0), K.shade(stone, 0.9), { parent = parent, studs = true })
				if h > 15 then K.part(V(7, 1.6, 7), p * CFrame.new(0, h + 0.8, 0), K.shade(stone, 0.9), { parent = parent, studs = true }) end
			end
			K.part(V(18, 4.4, 4.4), cf * CFrame.new(4, 3.2, 0) * CFrame.Angles(0, rad(25), 0), rgb(236, 208, 150), { parent = parent, shape = "cyl" })
			for k = 0, 3 do K.part(V(14 - k * 3, 1.4, 4), cf * CFrame.new(-24 + 2, 1.7 + k * 1.4, 0) * CFrame.Angles(0, rad(90), 0), K.shade(stone, 0.95), { parent = parent, studs = true }) end
		end
		T.decorB = function(cf, parent) -- market tents with pots
			for k = 0, 1 do
				local c = cf * CFrame.new(-10 + k * 22, 0, -6 + k * 10)
				for _, sx in ipairs({ -1, 1 }) do for _, sz in ipairs({ -1, 1 }) do K.part(V(0.8, 9, 0.8), c * CFrame.new(sx * 6, 4.5, sz * 5), rgb(150, 100, 60), { parent = parent }) end end
				local col = (k == 0) and rgb(220, 70, 70) or rgb(60, 140, 220)
				for s = 0, 5 do K.part(V(2.2, 0.4, 11.6), c * CFrame.new(-5.5 + s * 2.2, 9.6 - math.abs(s - 2.5) * 0.4, 0), (s % 2 == 0) and col or rgb(250, 240, 220), { parent = parent, collide = false }) end
				K.part(V(10, 3, 4), c * CFrame.new(0, 1.5, 3), rgb(180, 120, 70), { parent = parent, mat = Enum.Material.WoodPlanks })
				for p = 0, 2 do K.cyl(2.4, 2.6, (c * CFrame.new(-3 + p * 3, 4.3, 3)).Position, ({ rgb(200, 110, 60), rgb(46, 176, 176), rgb(230, 190, 90) })[p + 1], { parent = parent, collide = false }) end
			end
			for p = 0, 3 do K.cyl(3, 4, (cf * CFrame.new(-18 + p * 4, 2, 16)).Position, rgb(196, 110, 60), { parent = parent }) end
		end
		T.small = function(p, parent) if K.chance(0.5) then P.tree(p, "cactus", K.rand(0.6, 0.9), T.treePal, parent) else P.rock(p, K.rand(0.7, 1), { rock = rgb(214, 160, 100), studRock = true }, parent) end end
		T.bed = function(cf, parent) K.part(V(22, 1.4, 12), cf * CFrame.new(0, 0.7, 0), rgb(250, 232, 190), { parent = parent, studs = true }); for k = -1, 1 do P.tree((cf * CFrame.new(k * 7, 1.4, 0)).Position, "cactus", 0.55, T.treePal, parent) end end
		T.archDecor = function(cf, parent) for _, sx in ipairs({ -1, 1 }) do K.part(V(6, 6, 6), cf * CFrame.new(sx * 46, 52, 0) * CFrame.Angles(rad(45), 0, rad(45)), rgb(60, 230, 220), { parent = parent, neon = true, collide = false }) end end
		return obbyCommon(hubCommon(T))
	end

	------------------------------------------------------------------------------------------------------------
	-- WORLD 3: SNOW
	------------------------------------------------------------------------------------------------------------
	W.Snow = function()
		local T = { id = 3, key = "Snow", style = "snow", escapeText = "ESCAPE THE GLACIER!", finishText = "YOU CONQUERED THE SNOW!", ballName = "GIANT SNOWBALL",
			floor = rgb(240, 247, 255), floor2 = rgb(222, 236, 250), path = rgb(170, 210, 240), path2 = rgb(150, 196, 232), pathMat = Enum.Material.Ice, curb = rgb(255, 255, 255),
			plaza1 = rgb(196, 228, 252), plaza2 = rgb(226, 242, 255),
			rock = { rgb(120, 150, 190), rgb(150, 180, 214) }, rock2 = { rgb(104, 130, 172), rgb(136, 164, 200) }, top = rgb(250, 252, 255), top2 = rgb(245, 250, 255),
			cliffTrees = 0.4, treeKinds = { "icepine", "icepine", "pine" }, lawnTrees = { "icepine" },
			treePal = { trunk = rgb(110, 80, 60), leaf = rgb(60, 130, 100), leaf2 = rgb(80, 160, 120), extra = rgb(255, 255, 255), snowcap = true, neon = false },
			gatePillar = rgb(200, 230, 252), gateTrim = rgb(90, 165, 235), gateField = rgb(140, 220, 255), titleGrad = { rgb(255, 255, 255), rgb(110, 200, 255) },
			padBase = rgb(80, 110, 160), padTrim = rgb(240, 248, 255), accent = rgb(90, 165, 235), accent2 = rgb(140, 220, 255), gymFloor = rgb(70, 96, 140),
			frameCol = rgb(150, 205, 245), frameTrim = rgb(255, 255, 255), frameMat = Enum.Material.Ice, lampStyle = "lamp", lampCol = rgb(70, 96, 140), glow = rgb(170, 230, 255),
			eggGlow = rgb(120, 210, 255), shopCols = { rgb(230, 80, 80), rgb(80, 160, 240), rgb(160, 110, 240) }, shopWall = rgb(240, 248, 255),
			prevCol = rgb(255, 190, 90), nextCol = rgb(110, 220, 90), wood = rgb(150, 100, 70), metal = rgb(80, 100, 140),
			hills = { base = rgb(140, 166, 200), grass = rgb(232, 242, 255), grass2 = rgb(214, 230, 248), peak = rgb(255, 255, 255), floor = rgb(220, 236, 250), floorY = -150, extraH = 80 },
			plat = { rgb(236, 246, 255), rgb(150, 210, 245), rgb(110, 170, 230), rgb(200, 232, 255) }, rim = rgb(80, 110, 160), trim = rgb(90, 165, 235),
			gateFloor = rgb(220, 236, 250), rewardFloor = rgb(240, 248, 255), hazard = rgb(255, 80, 90), hazardDark = rgb(60, 80, 120), warn = rgb(255, 70, 70),
			moverCol = rgb(110, 200, 255), blinkCol = rgb(190, 150, 255), collapseCol = rgb(170, 220, 250), laneCol = rgb(230, 242, 255), pocketCol = rgb(90, 220, 140),
			supCol = rgb(140, 170, 210), supMat = Enum.Material.Ice, crushCol = rgb(160, 220, 255), crushTrim = rgb(255, 255, 255), chainCol = rgb(80, 100, 140),
			ballCol = rgb(245, 250, 255), ballMat = Enum.Material.Snow, bridgeCol = rgb(170, 220, 250), moatCol = rgb(60, 130, 190), moatTransp = 0.1, moatMat = Enum.Material.Glass,
		}
		T.centrepiece = function(cf, parent) -- frozen pond with a giant ice crystal
			K.cyl(40, 1, (cf * CFrame.new(0, 0.5, 0)).Position, rgb(170, 220, 250), { parent = parent, glass = true, transp = 0.1 })
			K.cyl(42, 0.8, (cf * CFrame.new(0, 0.4, 0)).Position, rgb(255, 255, 255), { parent = parent })
			for k = 0, 4 do
				local h = ({ 34, 20, 24, 16, 22 })[k + 1]
				local c = cf * CFrame.Angles(0, rad(k * 72), 0) * CFrame.new(0, 0, k == 0 and 0 or -5) * CFrame.Angles(rad(k == 0 and 0 or 22), 0, 0)
				K.part(V(5.5, h, 5.5), c * CFrame.new(0, h / 2, 0) * CFrame.Angles(0, rad(45), 0), (k % 2 == 0) and rgb(150, 220, 255) or rgb(210, 240, 255), { parent = parent, glass = true, transp = 0.1 })
				K.part(V(3.9, 3.9, 3.9), c * CFrame.new(0, h, 0) * CFrame.Angles(rad(45), rad(45), 0), rgb(200, 240, 255), { parent = parent, neon = true, collide = false })
			end
			for k = 0, 5 do P.rock((cf * CFrame.Angles(0, rad(k * 60), 0) * CFrame.new(0, 0, -22)).Position, 0.6, { rock = rgb(235, 245, 255) }, parent) end
		end
		T.decorA = function(cf, parent) -- igloo + snowman
			local ic = cf * CFrame.new(-6, 0, 0)
			K.part(V(22, 22, 22), ic, rgb(245, 250, 255), { parent = parent, shape = "ball", mat = Enum.Material.Snow })
			for k = 0, 3 do K.part(V(22.4, 0.3, 22.4), ic * CFrame.new(0, 2 + k * 2.4, 0), rgb(220, 232, 245), { parent = parent, shape = "cyl", collide = false }) end
			K.part(V(8, 8, 10), ic * CFrame.new(10, 3, 0), rgb(245, 250, 255), { parent = parent, mat = Enum.Material.Snow })
			K.part(V(0.3, 5.6, 6), ic * CFrame.new(14.1, 2.8, 0), rgb(40, 50, 70), { parent = parent, collide = false })
			local sm = cf * CFrame.new(16, 0, 14)
			for k, r in ipairs({ 7, 5.4, 4 }) do K.part(V(r, r, r), sm * CFrame.new(0, ({ 3.5, 9, 13.4 })[k], 0), rgb(250, 252, 255), { parent = parent, shape = "ball", mat = Enum.Material.Snow }) end
			K.part(V(0.8, 0.8, 2.4), sm * CFrame.new(0, 13.4, -2.4), rgb(255, 140, 40), { parent = parent, collide = false })
			K.part(V(4.6, 0.6, 4.6), sm * CFrame.new(0, 15.4, 0), rgb(40, 40, 50), { parent = parent, collide = false, shape = "cyl" })
			K.part(V(3, 3, 3), sm * CFrame.new(0, 17, 0), rgb(40, 40, 50), { parent = parent, collide = false })
			K.part(V(5.4, 1, 5.4), sm * CFrame.new(0, 11.3, 0), rgb(220, 60, 60), { parent = parent, collide = false })
		end
		T.decorB = function(cf, parent) -- frozen lake with an ice-fishing hut
			K.cyl(44, 0.6, (cf * CFrame.new(0, 0.3, 0)).Position, rgb(170, 220, 250), { parent = parent, glass = true, transp = 0.15 })
			local h = cf * CFrame.new(8, 0.6, -6)
			K.part(V(10, 8, 8), h * CFrame.new(0, 4, 0), rgb(170, 90, 60), { parent = parent, mat = Enum.Material.WoodPlanks })
			K.part(V(11, 1, 9), h * CFrame.new(0, 8.5, 0), rgb(250, 252, 255), { parent = parent, mat = Enum.Material.Snow })
			K.cyl(3, 0.4, (cf * CFrame.new(-8, 0.7, 6)).Position, rgb(30, 60, 110), { parent = parent, collide = false })
			for k = 0, 4 do K.part(V(K.rand(3, 6), K.rand(1.5, 3), K.rand(3, 6)), cf * CFrame.new(K.rand(-18, 18), 1, K.rand(-18, 18)) * CFrame.Angles(0, rad(K.rand(0, 90)), 0), rgb(220, 240, 255), { parent = parent, glass = true, transp = 0.1 }) end
		end
		T.small = function(p, parent) if K.chance(0.5) then P.rock(p, K.rand(0.6, 0.9), { rock = rgb(235, 245, 255) }, parent) else P.tree(p, "crystal", K.rand(0.4, 0.6), { leaf = rgb(150, 220, 255), leaf2 = rgb(220, 245, 255) }, parent) end end
		T.bed = function(cf, parent) K.part(V(22, 2, 12), cf * CFrame.new(0, 1, 0), rgb(250, 252, 255), { parent = parent, mat = Enum.Material.Snow }); P.tree((cf * CFrame.new(0, 2, 0)).Position, "crystal", 0.5, { leaf = rgb(150, 220, 255), leaf2 = rgb(220, 245, 255) }, parent) end
		return obbyCommon(hubCommon(T))
	end

	------------------------------------------------------------------------------------------------------------
	-- WORLD 4: FOREST
	------------------------------------------------------------------------------------------------------------
	W.Forest = function()
		local T = { id = 4, key = "Forest", style = "forest", escapeText = "ESCAPE THE FOREST!", finishText = "YOU MADE IT THROUGH THE FOREST!", ballName = "BOULDER",
			floor = rgb(70, 150, 60), floor2 = rgb(90, 168, 70), path = rgb(150, 108, 70), path2 = rgb(134, 96, 62), curb = rgb(110, 84, 60),
			plaza1 = rgb(140, 132, 116), plaza2 = rgb(160, 152, 134),
			rock = { rgb(96, 100, 92), rgb(118, 124, 110) }, rock2 = { rgb(84, 90, 80), rgb(104, 110, 98) }, top = rgb(70, 150, 60), top2 = rgb(60, 136, 54),
			cliffTrees = 0.55, cliffBushes = 0.6, treeKinds = { "pine", "oak", "round", "mushroom" }, lawnTrees = { "oak", "pine", "mushroom" },
			treePal = { trunk = rgb(110, 76, 46), leaf = rgb(50, 130, 60), leaf2 = rgb(80, 160, 70), flower = rgb(255, 230, 100), extra = rgb(90, 60, 40) },
			gatePillar = rgb(120, 84, 52), gateTrim = rgb(140, 210, 90), gateField = rgb(140, 255, 160), titleGrad = { rgb(230, 255, 170), rgb(90, 200, 80) },
			padBase = rgb(90, 70, 50), padTrim = rgb(200, 180, 140), accent = rgb(110, 190, 70), accent2 = rgb(255, 200, 70), gymFloor = rgb(96, 74, 54),
			frameCol = rgb(120, 84, 52), frameTrim = rgb(110, 190, 70), frameMat = Enum.Material.Wood, lampStyle = "lamp", lampCol = rgb(96, 70, 46), glow = rgb(255, 230, 140),
			eggGlow = rgb(140, 230, 90), shopCols = { rgb(220, 110, 50), rgb(70, 160, 90), rgb(170, 90, 200) }, shopWall = rgb(232, 214, 180),
			prevCol = rgb(140, 210, 255), nextCol = rgb(255, 110, 50), wood = rgb(140, 96, 56), metal = rgb(80, 70, 56),
			hills = { base = rgb(92, 96, 86), grass = rgb(60, 136, 58), grass2 = rgb(76, 152, 66), floor = rgb(56, 120, 56), floorY = -150, extraH = 40 },
			wallTrees = 0.35,
			plat = { rgb(150, 110, 70), rgb(96, 170, 76), rgb(180, 140, 96), rgb(120, 190, 96) }, rim = rgb(90, 64, 42), trim = rgb(110, 190, 70),
			gateFloor = rgb(140, 132, 116), rewardFloor = rgb(200, 182, 140), hazard = rgb(255, 90, 60), hazardDark = rgb(80, 60, 40), warn = rgb(255, 80, 40),
			moverCol = rgb(110, 200, 140), blinkCol = rgb(200, 160, 255), collapseCol = rgb(170, 130, 90), laneCol = rgb(150, 130, 100), pocketCol = rgb(110, 220, 110),
			supCol = rgb(110, 76, 46), crushCol = rgb(130, 90, 54), crushTrim = rgb(90, 64, 42), chainCol = rgb(90, 140, 60),
			ballCol = rgb(110, 116, 100), ballMat = Enum.Material.Slate, bridgeCol = rgb(160, 110, 66), bridgeMat = Enum.Material.WoodPlanks, moatCol = rgb(60, 150, 170), moatTransp = 0.15, moatMat = Enum.Material.Glass,
		}
		T.centrepiece = function(cf, parent) -- great tree on a mossy mound with a stone ring
			K.cyl(36, 3, (cf * CFrame.new(0, 1.5, 0)).Position, rgb(80, 150, 66), { parent = parent, studs = true })
			for k = 0, 9 do K.part(V(5, 2.6, 3), cf * CFrame.Angles(0, rad(k * 36), 0) * CFrame.new(0, 1.3, -19), rgb(130, 130, 120), { parent = parent, studs = true }) end
			P.tree((cf * CFrame.new(0, 3, 0)).Position, "giant", 0.7, T.treePal, parent)
			for k = 0, 5 do
				local l = K.part(V(1, 1, 1), cf * CFrame.Angles(0, rad(k * 60), 0) * CFrame.new(0, K.rand(8, 22), -K.rand(8, 14)), rgb(255, 240, 140), { parent = parent, neon = true, collide = false, shape = "ball" })
			end
		end
		T.decorA = function(cf, parent) -- treehouse on stilts with a ladder
			for _, sx in ipairs({ -1, 1 }) do for _, sz in ipairs({ -1, 1 }) do K.cyl(2, 16, (cf * CFrame.new(sx * 9, 8, sz * 8)).Position, rgb(110, 76, 46), { parent = parent }) end end
			K.part(V(24, 1.4, 22), cf * CFrame.new(0, 16.7, 0), rgb(150, 104, 62), { parent = parent, mat = Enum.Material.WoodPlanks })
			K.part(V(16, 9, 14), cf * CFrame.new(0, 21.9, 2), rgb(170, 120, 72), { parent = parent, mat = Enum.Material.WoodPlanks })
			K.part(V(18, 5, 8.4), cf * CFrame.new(0, 28.4, -1.8) * CFrame.Angles(0, math.pi, 0), rgb(60, 130, 60), { parent = parent, shape = "wedge" })
			K.part(V(18, 5, 8.4), cf * CFrame.new(0, 28.4, 5.8), rgb(60, 130, 60), { parent = parent, shape = "wedge" })
			for k = 0, 7 do K.part(V(4, 0.5, 0.5), cf * CFrame.new(0, 1.5 + k * 2, -11.4), rgb(120, 84, 52), { parent = parent }) end
			for _, sx in ipairs({ -1, 1 }) do K.part(V(0.6, 17, 0.6), cf * CFrame.new(sx * 2, 8.5, -11.4), rgb(110, 76, 46), { parent = parent }) end
			P.tree((cf * CFrame.new(16, 0, 14)).Position, "oak", 1.3, T.treePal, parent)
		end
		T.decorB = function(cf, parent) -- campsite: fire, logs, two tents
			local f = cf * CFrame.new(0, 0, 0)
			for k = 0, 7 do K.part(V(2, 1.6, 2.4), f * CFrame.Angles(0, rad(k * 45), 0) * CFrame.new(0, 0.8, -3.6), rgb(120, 120, 116), { parent = parent }) end
			local fire = K.part(V(3, 2.4, 3), f * CFrame.new(0, 1.4, 0), rgb(255, 150, 40), { parent = parent, neon = true, collide = false })
			K.sparkle(fire, rgb(255, 140, 40), { rate = 12, size = 1, accel = V(0, 8, 0), name = "Fire" }); K.light(fire, rgb(255, 160, 80), 24, 2)
			for k = 0, 2 do K.part(V(8, 2.2, 2.2), f * CFrame.Angles(0, rad(k * 120), 0) * CFrame.new(0, 1.1, -9), rgb(120, 82, 50), { parent = parent, shape = "cyl", mat = Enum.Material.Wood }) end
			for k = 0, 1 do
				local t = cf * CFrame.new(-16 + k * 32, 0, 14) * CFrame.Angles(0, rad(k * 40 - 20), 0)
				K.part(V(8, 6, 5), t * CFrame.new(0, 3, -2.5), (k == 0) and rgb(230, 120, 50) or rgb(60, 140, 200), { parent = parent, shape = "wedge" })
				K.part(V(8, 6, 5), t * CFrame.new(0, 3, 2.5) * CFrame.Angles(0, math.pi, 0), (k == 0) and rgb(230, 120, 50) or rgb(60, 140, 200), { parent = parent, shape = "wedge" })
			end
		end
		T.small = function(p, parent) if K.chance(0.5) then P.bush(p, K.rand(0.9, 1.2), T.treePal, parent) else P.tree(p, "mushroom", K.rand(0.5, 0.8), { trunk = rgb(240, 230, 210), leaf = rgb(220, 60, 50), leaf2 = rgb(255, 255, 255) }, parent) end end
		T.bed = function(cf, parent) K.part(V(22, 1.4, 12), cf * CFrame.new(0, 0.7, 0), rgb(110, 84, 60), { parent = parent, studs = true }); P.flowers((cf * CFrame.new(0, 1.4, 0)).Position, 18, 8, { flowers = { rgb(255, 230, 100), rgb(255, 255, 255), rgb(200, 120, 255) } }, parent) end
		T.cliffExtras = function(hub, at) -- a waterfall pouring down the north-east cliff
			local wf = K.model("Waterfall", hub)
			K.part(V(18, 50, 2), CFrame.new(at(120, 25, -172)), rgb(110, 200, 240), { parent = wf, collide = false, transp = 0.25, glass = true })
			K.part(V(30, 0.6, 16), CFrame.new(at(120, 0.4, -162)), rgb(90, 180, 220), { parent = wf, collide = false, transp = 0.2, glass = true })
			local mist = K.part(V(18, 1, 6), CFrame.new(at(120, 2, -164)), Color3.new(1, 1, 1), { parent = wf, transp = 1, collide = false })
			K.sparkle(mist, rgb(230, 245, 255), { texture = "rbxasset://textures/particles/smoke_main.dds", rate = 12, size = 4, accel = V(0, 2, 0), speed = NumberRange.new(2, 4), emission = 0.1, name = "Mist" })
		end
		return obbyCommon(hubCommon(T))
	end

	------------------------------------------------------------------------------------------------------------
	-- WORLD 5: VOLCANO
	------------------------------------------------------------------------------------------------------------
	W.Volcano = function()
		local T = { id = 5, key = "Volcano", style = "volcano", escapeText = "ESCAPE THE VOLCANO!", finishText = "YOU SURVIVED THE VOLCANO!", ballName = "MAGMA BOULDER", neonTrim = false,
			floor = rgb(92, 80, 78), floor2 = rgb(108, 92, 86), floorMat = Enum.Material.Basalt, path = rgb(140, 120, 108), path2 = rgb(124, 106, 96), curb = rgb(255, 120, 40), neonCurb = true,
			plaza1 = rgb(120, 104, 98), plaza2 = rgb(140, 124, 116),
			rock = { rgb(70, 60, 62), rgb(92, 78, 76) }, rock2 = { rgb(44, 38, 40), rgb(60, 52, 52) }, top = rgb(80, 66, 62), top2 = rgb(70, 58, 56),
			cliffTrees = 0.2, treeKinds = { "dead", "crystal" }, lawnTrees = { "dead" },
			treePal = { trunk = rgb(40, 34, 34), leaf = rgb(255, 120, 40), leaf2 = rgb(255, 200, 70), neon = true },
			gatePillar = rgb(60, 52, 54), gateTrim = rgb(255, 120, 40), gateField = rgb(255, 120, 60), titleGrad = { rgb(255, 230, 120), rgb(255, 80, 30) },
			padBase = rgb(50, 44, 46), padTrim = rgb(110, 98, 94), accent = rgb(255, 110, 40), accent2 = rgb(255, 190, 60), gymFloor = rgb(44, 40, 42),
			frameCol = rgb(60, 52, 54), frameTrim = rgb(255, 120, 40), neonTrim = true, frameMat = Enum.Material.Basalt, lampStyle = "brazier", lampCol = rgb(70, 60, 60), glow = rgb(255, 130, 40),
			eggGlow = rgb(255, 110, 40), shopCols = { rgb(230, 90, 40), rgb(80, 140, 230), rgb(190, 80, 220) }, shopWall = rgb(110, 98, 94),
			prevCol = rgb(110, 220, 90), nextCol = rgb(180, 110, 255), wood = rgb(90, 60, 40), metal = rgb(70, 60, 60),
			hills = { base = rgb(56, 48, 50), grass = rgb(80, 66, 62), grass2 = rgb(70, 58, 56), peak = rgb(255, 110, 40), floor = rgb(255, 100, 30), floorY = -150, extraH = 70 },
			plat = { rgb(90, 80, 78), rgb(120, 100, 90), rgb(70, 62, 62), rgb(140, 110, 96) }, rim = rgb(40, 34, 34), trim = rgb(255, 120, 40),
			gateFloor = rgb(90, 80, 78), rewardFloor = rgb(120, 104, 98), hazard = rgb(255, 120, 30), hazardDark = rgb(40, 34, 34), warn = rgb(255, 60, 30),
			moverCol = rgb(255, 170, 60), blinkCol = rgb(255, 110, 60), collapseCol = rgb(110, 80, 70), laneCol = rgb(96, 84, 80), pocketCol = rgb(90, 200, 120),
			supCol = rgb(56, 50, 52), supMat = Enum.Material.Basalt, crushCol = rgb(70, 60, 60), crushMat = Enum.Material.Basalt, crushTrim = rgb(255, 120, 40), chainCol = rgb(40, 36, 36),
			ballCol = rgb(60, 44, 40), ballMat = Enum.Material.Basalt, bridgeCol = rgb(80, 70, 68), bridgeMat = Enum.Material.Basalt, moatCol = rgb(255, 110, 30), moatNeon = true,
		}
		T.centrepiece = function(cf, parent) -- lava fountain: basalt basin, lava pool, spire with fire
			for i = 0, 7 do K.part(V(14.6, 3.4, 3), cf * CFrame.Angles(0, rad(i * 45), 0) * CFrame.new(0, 1.7, -16.5), rgb(60, 52, 54), { parent = parent, studs = true, mat = Enum.Material.Basalt }) end
			K.cyl(31.6, 2.6, (cf * CFrame.new(0, 1.3, 0)).Position, rgb(255, 110, 30), { parent = parent, neon = true, collide = false })
			for k = 0, 3 do K.part(V(7 - k * 1.4, 8, 7 - k * 1.4), cf * CFrame.new(0, 4 + k * 8, 0) * CFrame.Angles(0, rad(k * 20), 0), rgb(60, 50, 50), { parent = parent, studs = true, mat = Enum.Material.Basalt }) end
			for k = 0, 3 do K.part(V(0.6, 30, 0.6), cf * CFrame.Angles(0, rad(k * 90), 0) * CFrame.new(0, 17, -3.2 + k * 0.2), rgb(255, 130, 40), { parent = parent, neon = true, collide = false }) end
			local top = K.part(V(3, 2, 3), cf * CFrame.new(0, 35, 0), rgb(255, 160, 50), { parent = parent, neon = true, collide = false })
			K.sparkle(top, rgb(255, 120, 30), { rate = 30, size = 2, speed = NumberRange.new(10, 16), accel = V(0, -20, 0), spread = Vector2.new(30, 30), emitDir = Enum.NormalId.Top, name = "Lava" })
			K.light(top, rgb(255, 120, 40), 40, 2.5)
		end
		T.decorA = function(cf, parent) -- obsidian crystals around a lava pool
			K.cyl(26, 0.8, (cf * CFrame.new(0, 0.4, 0)).Position, rgb(255, 110, 30), { parent = parent, neon = true, collide = false })
			K.cyl(30, 0.6, (cf * CFrame.new(0, 0.3, 0)).Position, rgb(40, 34, 34), { parent = parent })
			for k = 0, 5 do P.tree((cf * CFrame.Angles(0, rad(k * 60), 0) * CFrame.new(0, 0, -18)).Position, "crystal", K.rand(0.9, 1.4), { leaf = rgb(40, 30, 50), leaf2 = rgb(90, 50, 110) }, parent) end
		end
		T.decorB = function(cf, parent) -- forge: anvil, furnace, lava channel
			K.part(V(16, 12, 12), cf * CFrame.new(-8, 6, 0), rgb(70, 60, 60), { parent = parent, studs = true, mat = Enum.Material.Basalt })
			local mouth = K.part(V(8, 6, 0.4), cf * CFrame.new(-8, 4, -6.1), rgb(255, 140, 40), { parent = parent, neon = true, collide = false })
			K.light(mouth, rgb(255, 130, 40), 26, 2)
			K.part(V(4, 10, 4), cf * CFrame.new(-12, 17, 2), rgb(60, 52, 54), { parent = parent, studs = true })
			K.part(V(4, 3, 6), cf * CFrame.new(8, 1.5, 0), rgb(60, 60, 70), { parent = parent })
			K.part(V(6, 2, 3), cf * CFrame.new(8, 4, 0), rgb(80, 80, 90), { parent = parent })
			K.part(V(40, 0.6, 3), cf * CFrame.new(0, 0.3, 12), rgb(255, 120, 30), { parent = parent, neon = true, collide = false })
		end
		T.small = function(p, parent) local r = P.rock(p, K.rand(0.6, 1), { rock = rgb(60, 52, 54) }, parent); if K.chance(0.4) then local e = K.part(V(1.2, 1.2, 1.2), CFrame.new(p + V(0, 1, 0)), rgb(255, 120, 30), { parent = r, neon = true, collide = false }) end end
		T.bed = function(cf, parent) K.part(V(22, 1.2, 12), cf * CFrame.new(0, 0.6, 0), rgb(40, 34, 34), { parent = parent }); K.part(V(18, 1.3, 8), cf * CFrame.new(0, 0.65, 0), rgb(255, 110, 30), { parent = parent, neon = true, collide = false }) end
		T.cliffExtras = function(hub, at) -- lava falls down the cliffs
			local lf = K.model("LavaFalls", hub)
			for _, x in ipairs({ -120, 110 }) do
				K.part(V(10, 50, 2), CFrame.new(at(x, 25, 172)), rgb(255, 120, 30), { parent = lf, neon = true, collide = false })
				K.part(V(20, 0.6, 12), CFrame.new(at(x, 0.4, 164)), rgb(255, 110, 30), { parent = lf, neon = true, collide = false })
			end
		end
		return obbyCommon(hubCommon(T))
	end

	------------------------------------------------------------------------------------------------------------
	-- WORLD 6: SPACE (the most impressive one: floating islands, planets, neon)
	------------------------------------------------------------------------------------------------------------
	W.Space = function()
		local T = { id = 6, key = "Space", style = "space", escapeText = "ESCAPE THE GALAXY!", finishText = "YOU ESCAPED THE GALAXY!", ballName = "ASTEROID", neonTrim = true,
			floor = rgb(50, 44, 90), floor2 = rgb(60, 52, 108), floorMat = Enum.Material.Plastic, path = rgb(90, 80, 150), path2 = rgb(78, 68, 134), curb = rgb(120, 230, 255), neonCurb = true,
			plaza1 = rgb(70, 60, 130), plaza2 = rgb(96, 84, 160),
			rock = { rgb(84, 70, 130), rgb(104, 88, 156) }, rock2 = { rgb(70, 58, 112), rgb(90, 76, 140) }, top = rgb(120, 104, 180), top2 = rgb(104, 90, 164),
			cliffTrees = 0.35, cliffBushes = 0, cliffH = 18, treeKinds = { "crystal" }, lawnTrees = { "crystal" },
			treePal = { trunk = rgb(60, 50, 90), leaf = rgb(120, 230, 255), leaf2 = rgb(220, 120, 255), neon = true },
			gatePillar = rgb(70, 60, 120), gateTrim = rgb(120, 230, 255), gateField = rgb(190, 120, 255), titleGrad = { rgb(200, 240, 255), rgb(200, 110, 255) },
			padBase = rgb(40, 36, 70), padTrim = rgb(110, 100, 170), accent = rgb(170, 100, 255), accent2 = rgb(110, 230, 255), gymFloor = rgb(34, 30, 60),
			frameCol = rgb(70, 64, 110), frameTrim = rgb(120, 230, 255), lampStyle = "neon", lampCol = rgb(70, 64, 110), glow = rgb(120, 230, 255),
			eggGlow = rgb(180, 110, 255), shopCols = { rgb(255, 110, 200), rgb(80, 200, 255), rgb(170, 100, 255) }, shopWall = rgb(90, 84, 140),
			prevCol = rgb(255, 120, 40), metal = rgb(70, 64, 110),
			plat = { rgb(90, 80, 150), rgb(60, 140, 200), rgb(130, 90, 200), rgb(70, 60, 120) }, rim = rgb(40, 36, 70), trim = rgb(120, 230, 255),
			gateFloor = rgb(70, 60, 120), rewardFloor = rgb(96, 84, 160), hazard = rgb(255, 70, 160), hazardDark = rgb(40, 36, 70), warn = rgb(255, 60, 160),
			moverCol = rgb(110, 230, 255), blinkCol = rgb(255, 120, 220), collapseCol = rgb(120, 100, 170), laneCol = rgb(80, 72, 130), pocketCol = rgb(90, 230, 160),
			supCol = rgb(84, 70, 130), crushCol = rgb(90, 90, 120), crushTrim = rgb(120, 230, 255), chainCol = rgb(120, 230, 255),
			ballCol = rgb(120, 112, 120), ballMat = Enum.Material.Slate, bridgeCol = rgb(120, 230, 255), moatCol = rgb(0, 0, 0),
		}
		T.backdrop = function(pts, parent, sides) -- planets, rings and asteroid belts instead of hills
			local m = K.model("SpaceBackdrop", parent)
			for i = 1, #pts do
				local p = pts[i]
				if i % 2 == 1 then
					local off = V(K.rand(-1, 1), 0, K.rand(-1, 1)).Unit * K.rand(900, 1400) + V(0, K.rand(150, 450), 0)
					local r = K.rand(60, 160)
					local col = K.pick({ rgb(255, 140, 200), rgb(120, 200, 255), rgb(255, 200, 110), rgb(160, 110, 255), rgb(110, 230, 180) })
					local pl = K.part(V(r, r, r), CFrame.new(p + off), col, { parent = m, shape = "ball", collide = false, shadow = false })
					if K.chance(0.5) then
						S.ring(CFrame.new(p + off) * CFrame.Angles(rad(70), rad(K.rand(0, 90)), 0), r * 0.8, 2, r * 0.15, K.shade(col, 1.3), 28, { neon = true }, m)
					end
				end
				for k = 1, 6 do
					local a = V(K.rand(-1, 1), 0, K.rand(-1, 1)).Unit * K.rand(200, 420) + V(0, K.rand(-120, 60), 0)
					K.part(V(K.rand(6, 20), K.rand(6, 16), K.rand(6, 20)), CFrame.new(p + a) * CFrame.Angles(rad(K.rand(0, 90)), rad(K.rand(0, 90)), 0), rgb(110, 100, 120), { parent = m, collide = false, shadow = false, studs = true })
				end
			end
		end
		T.centrepiece = function(cf, parent) -- hologram planet: pedestal, spinning rings, glowing core
			K.cyl(30, 2, (cf * CFrame.new(0, 1, 0)).Position, rgb(40, 36, 70), { parent = parent })
			K.cyl(31, 0.4, (cf * CFrame.new(0, 2.1, 0)).Position, rgb(120, 230, 255), { parent = parent, neon = true, collide = false })
			K.cyl(10, 8, (cf * CFrame.new(0, 6, 0)).Position, rgb(70, 64, 110), { parent = parent })
			local holo = K.model("Hologram", parent)
			local core = K.part(V(14, 14, 14), cf * CFrame.new(0, 22, 0), rgb(170, 110, 255), { parent = holo, shape = "ball", neon = true, collide = false, transp = 0.2 })
			S.ring(cf * CFrame.new(0, 22, 0) * CFrame.Angles(rad(70), 0, 0), 12, 1, 1.6, rgb(120, 230, 255), 24, { neon = true }, holo)
			S.ring(cf * CFrame.new(0, 22, 0) * CFrame.Angles(rad(110), rad(40), 0), 10, 0.8, 1.2, rgb(255, 120, 220), 24, { neon = true }, holo)
			holo.PrimaryPart = core
			K.tag(holo, "SpinIcon")
			K.light(core, rgb(170, 110, 255), 50, 2.5)
			K.sparkle(core, rgb(200, 160, 255), { rate = 10, size = 1.2, shape = Enum.ParticleEmitterShape.Sphere })
		end
		T.decorA = function(cf, parent) -- satellite dish
			K.part(V(10, 2, 10), cf * CFrame.new(0, 1, 0), rgb(70, 64, 110), { parent = parent })
			K.part(V(2, 12, 2), cf * CFrame.new(0, 8, 0), rgb(140, 140, 170), { parent = parent })
			local dish = cf * CFrame.new(0, 16, 0) * CFrame.Angles(rad(-40), rad(30), 0)
			K.part(V(1, 18, 18), dish * CFrame.Angles(0, rad(90), 0), rgb(220, 224, 240), { parent = parent, shape = "cyl", collide = false })
			K.part(V(0.6, 0.6, 9), dish * CFrame.new(0, 0, -4.5), rgb(140, 140, 170), { parent = parent, collide = false })
			K.part(V(1.6, 1.6, 1.6), dish * CFrame.new(0, 0, -9), rgb(255, 80, 160), { parent = parent, neon = true, collide = false, shape = "ball" })
		end
		T.decorB = function(cf, parent) -- landed UFO
			local u = cf * CFrame.new(0, 5, 0)
			K.part(V(4, 28, 28), u * CFrame.Angles(0, 0, rad(90)), rgb(190, 196, 220), { parent = parent, shape = "cyl" })
			K.part(V(12, 12, 12), u * CFrame.new(0, 3, 0), rgb(140, 230, 255), { parent = parent, shape = "ball", glass = true, transp = 0.3 })
			for k = 0, 7 do K.part(V(1.6, 1.6, 1.6), u * CFrame.Angles(0, rad(k * 45), 0) * CFrame.new(0, -0.5, -13.5), rgb(255, 230, 100), { parent = parent, neon = true, collide = false, shape = "ball" }) end
			for k = 0, 2 do K.part(V(1, 5, 1), u * CFrame.Angles(0, rad(k * 120), 0) * CFrame.new(0, -4, -8) * CFrame.Angles(rad(-20), 0, 0), rgb(120, 120, 150), { parent = parent }) end
			local beam = K.part(V(10, 4.5, 10), u * CFrame.new(0, -4.5, 0), rgb(140, 255, 180), { parent = parent, collide = false, transp = 0.7, neon = true, shape = "ball" })
		end
		T.decorC = function(cf, parent) -- rocket on its launch pad (Space has no next world)
			K.cyl(26, 2, (cf * CFrame.new(0, 1, 0)).Position, rgb(60, 56, 90), { parent = parent })
			K.cyl(8, 26, (cf * CFrame.new(0, 15, 0)).Position, rgb(240, 240, 250), { parent = parent })
			K.part(V(8, 8, 8), cf * CFrame.new(0, 30, 0), rgb(255, 80, 80), { parent = parent, shape = "ball" })
			for k = 0, 3 do K.part(V(1, 8, 5), cf * CFrame.Angles(0, rad(k * 90), 0) * CFrame.new(0, 6, -5.5), rgb(255, 80, 80), { parent = parent, shape = "wedge" }) end
			for k = 0, 2 do K.part(V(2.4, 2.4, 0.4), cf * CFrame.new(0, 12 + k * 5, -4), rgb(120, 230, 255), { parent = parent, neon = true, collide = false, shape = "cyl" }) end
			local sign = K.part(V(1, 1, 1), cf * CFrame.new(0, 40, 0), Color3.new(1, 1, 1), { parent = parent, transp = 1, collide = false })
			K.billboard(sign, { { text = "🚀 FINAL WORLD", h = 1, grad = T.titleGrad, font = K.FONT_BOLD, stroke = 4 } }, { size = UDim2.fromScale(24, 4), offset = V(0, 0, 0), dist = 400 })
		end
		T.small = function(p, parent) P.tree(p, "crystal", K.rand(0.5, 0.8), T.treePal, parent) end
		T.bed = function(cf, parent) K.part(V(22, 1.4, 12), cf * CFrame.new(0, 0.7, 0), rgb(40, 36, 70), { parent = parent }); K.part(V(22.4, 0.3, 12.4), cf * CFrame.new(0, 0.2, 0), rgb(120, 230, 255), { parent = parent, neon = true, collide = false }); for k = -1, 1 do P.tree((cf * CFrame.new(k * 7, 1.4, 0)).Position, "crystal", 0.5, T.treePal, parent) end end
		return obbyCommon(hubCommon(T))
	end

	return W
end
