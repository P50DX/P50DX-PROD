-- Obby: builds a world's 10-stage course with a "turtle" (cur = CFrame on the floor centre, -Z = forward).
-- Every section is big (animals up to T-Rex / Dragon size) and the hazards are tagged for the runtime:
--   Mover / Spinner / Pendulum / Crusher / Blink / Collapse / RollingBall / MovingWall  (ObbyHazards client)
--   HazardKill (touch = back to checkpoint), StageGate, Checkpoint, RewardPad, ChaseRoute (ObbyService server)
-- T = world theme. plan = list of stages, each { kind = "...", sections = { {fn, args}, ... } }.
return function(K, P, S)
	local O = {}
	local V = Vector3.new
	local rad = math.rad

	function O.build(T, cfg, startCf, plan, root)
		local course = K.folder("Obby", root)
		course:ClearAllChildren()
		local cur = startCf
		local stageFolder
		local stageNo = 0
		local centre = {} -- centreline samples for the side walls: { cf, halfWidth, stage }
		local minY = math.huge
		local pathLen = 0
		local function mark(hw)
			local last = centre[#centre]
			if last then pathLen += (cur.Position - last.cf.Position).Magnitude end
			table.insert(centre, { cf = cur, hw = hw or 60 })
		end
		local function adv(d) cur = cur * CFrame.new(0, 0, -d) end
		local function rise(h) cur = cur + V(0, h, 0) end
		local function note(cf) minY = math.min(minY, cf.Position.Y) end
		local colours = T.plat
		local ci = 0
		local function nextCol() ci += 1; return colours[(ci - 1) % #colours + 1] end

		-- platform whose TOP centre is cf: studded top with an inset lighter panel, side trims, and (unless it moves)
		-- a support column down into the moat so nothing looks like it floats
		local function plat(cf, w, l, col, o)
			o = o or {}
			note(cf)
			col = col or nextCol()
			local h = o.h or 4
			local parent = o.parent or stageFolder
			local p = K.slab(V(w, h, l), cf * CFrame.new(0, -h / 2, 0), col, { parent = parent, rim = (not o.dynamic) and T.rim or false, name = o.name or "Platform", tag = o.tag })
			if o.dynamic then return p end -- moving / blinking / collapsing: one part only, the client animates it
			if w > 14 and l > 14 and o.panel ~= false then
				K.part(V(w - 6, 0.2, l - 6), cf * CFrame.new(0, 0.1, 0), K.shade(col, 1.08), { parent = parent, studs = true, name = "Panel", collide = false })
			end
			if o.trim ~= false then
				for _, sx in ipairs({ -1, 1 }) do
					K.part(V(1.2, h + 0.2, l + 0.2), cf * CFrame.new(sx * (w / 2 + 0.3), -h / 2, 0), T.trim, { parent = parent, collide = false, name = "Trim" })
				end
			end
			if o.support ~= false and T.support then T.support(cf * CFrame.new(0, -h, 0), w, l, parent) end
			return p
		end
		O.plat = plat

		----------------------------------------------------------------------------------------------------------
		-- sections (each advances cur)
		----------------------------------------------------------------------------------------------------------
		local SEC = {}
		function SEC.run(a) -- solid floor
			local l, w = a.len or 60, a.w or 64
			plat(cur * CFrame.new(0, 0, -l / 2), w, l)
			if a.props then T.edgeProps(cur, l, w, stageFolder) end
			mark(); adv(l); mark()
		end
		function SEC.jumps(a) -- big platforms with gaps, small side offsets and height steps
			for i = 1, a.n do
				local gap = a.gap or 8
				adv(gap)
				local dx = (a.dx or 0) * ((i % 2 == 0) and 1 or -1)
				local dy = a.dy and ((i % 2 == 0) and a.dy or -a.dy * 0.5) or 0
				rise(dy)
				local l = a.l or 40
				plat(cur * CFrame.new(dx, 0, -l / 2), a.w or 40, l)
				mark(); adv(l); mark()
			end
		end
		function SEC.ramp(a) -- WedgePart is low at its -Z end: rotate it for an up-ramp
			local l, h, w = a.len or 60, a.rise or 20, a.w or 56
			local cf = cur * CFrame.new(0, h / 2, -l / 2) * (h > 0 and CFrame.Angles(0, math.pi, 0) or CFrame.identity)
			K.part(V(w, math.abs(h), l), cf, nextCol(), { parent = stageFolder, shape = "wedge", studs = true, name = "Ramp" })
			K.part(V(w, 4, l), cur * CFrame.new(0, math.min(0, h) - 2, -l / 2), T.rim, { parent = stageFolder, name = "RampBase" })
			note(cur + V(0, math.min(0, h), 0))
			mark(); adv(l); rise(h); mark()
		end
		function SEC.climb(a) -- staircase of big blocks (each step <= 5 high so every animal can jump it)
			for i = 1, a.n do
				adv(a.gap or 0)
				rise(a.step or 5)
				local l = a.l or 22
				plat(cur * CFrame.new(((i % 2 == 0) and 1 or -1) * (a.dx or 0), 0, -l / 2), a.w or 44, l, nil, { h = (a.step or 5) + 6 })
				mark(); adv(l)
			end
			mark()
		end
		function SEC.mover(a) -- a gap crossed on a moving platform
			local gap, w, l = a.gap or 60, a.w or 30, a.l or 30
			adv(6)
			local axis = a.axis or "z"
			local mid = cur * CFrame.new(0, 0, -gap / 2)
			local p = plat(mid, w, l, T.moverCol, { name = "MovingPlatform", trim = false, dynamic = true })
			local amp = axis == "z" and V(0, 0, (gap - l) / 2) or V(a.amp or 22, 0, 0)
			K.tag(p, "Mover", { Amp = amp, Period = a.period or 4, Phase = a.phase or 0, BaseCF = p.CFrame })
			mark(); adv(gap); mark()
			adv(6)
			plat(cur * CFrame.new(0, 0, -15), 40, 30)
			mark(); adv(30); mark()
		end
		function SEC.sweeper(a) -- wide platform with a rotating beam you jump over
			local l, w = a.len or 64, a.w or 64
			plat(cur * CFrame.new(0, 0, -l / 2), w, l)
			local c = cur * CFrame.new(0, 0, -l / 2)
			local m = K.model("Sweeper", stageFolder)
			local hubp = K.cyl(6, 7, (c * CFrame.new(0, 3.5, 0)).Position, T.hazardDark, { parent = m, name = "Hub" })
			K.cyl(7, 1, (c * CFrame.new(0, 7.2, 0)).Position, T.hazard, { parent = m, neon = true, collide = false })
			for k = 0, (a.arms or 1) do
				local beam = K.part(V(w * 0.47, 3, 3), c * CFrame.Angles(0, rad(k * 180), 0) * CFrame.new(w * 0.24, 2.4, 0), T.hazard, { parent = m, collide = false, name = "Beam", tag = "HazardKill", studs = true })
				K.part(V(w * 0.47, 0.6, 3.4), c * CFrame.Angles(0, rad(k * 180), 0) * CFrame.new(w * 0.24, 4.1, 0), T.hazardDark, { parent = m, collide = false, name = "BeamTop" })
				if a.arms == 1 and k == 1 then break end
			end
			m.PrimaryPart = hubp
			K.tag(m, "Spinner", { Speed = a.speed or 70, BaseCF = hubp.CFrame })
			mark(); adv(l); mark()
		end
		function SEC.crushers(a) -- corridor under slamming crates
			local n, cell, w = a.n or 3, a.cell or 34, a.w or 48
			plat(cur * CFrame.new(0, 0, -n * cell / 2), w, n * cell)
			for i = 1, n do
				local c = cur * CFrame.new(0, 0, -(i - 0.5) * cell)
				local m = T.crusher(c, w, cell, stageFolder)
				K.tag(m, "Crusher", { Height = 29.4, Period = a.period or 3.2, Phase = (i - 1) * (a.offset or 0.33), BaseCF = m:GetPivot() })
				-- frame posts either side
				for _, sx in ipairs({ -1, 1 }) do
					K.part(V(4, 44, 4), c * CFrame.new(sx * (w / 2 + 3), 22, 0), T.metal, { parent = stageFolder, studs = true })
				end
				K.part(V(w + 10, 4, 6), c * CFrame.new(0, 45, 0), T.metal, { parent = stageFolder, studs = true })
			end
			mark(); adv(n * cell); mark()
		end
		function SEC.blink(a) -- platforms that fade in and out (two alternating groups)
			for i = 1, a.n do
				adv(a.gap or 6)
				local l = a.l or 30
				local p = plat(cur * CFrame.new(((i % 2 == 0) and 1 or -1) * (a.dx or 8), 0, -l / 2), a.w or 34, l, T.blinkCol, { name = "BlinkPlatform", trim = false, dynamic = true })
				K.tag(p, "Blink", { Period = a.period or 4, Phase = (i % 2) * 0.5, OnFrac = 0.62 })
				mark(); adv(l); mark()
			end
			adv(a.gap or 6)
		end
		function SEC.collapse(a) -- platforms that drop shortly after you land on them
			for i = 1, a.n do
				adv(a.gap or 6)
				local l = a.l or 30
				local p = plat(cur * CFrame.new(((i % 2 == 0) and 1 or -1) * (a.dx or 6), 0, -l / 2), a.w or 36, l, T.collapseCol, { name = "CollapsePlatform", trim = false, dynamic = true })
				K.tag(p, "Collapse", { Delay = a.delay or 0.7, Respawn = 3 })
				mark(); adv(l); mark()
			end
			adv(a.gap or 6)
		end
		function SEC.walls(a) -- corridor with sliding cage walls (touch = caught)
			local n, cell, w = a.n or 3, a.cell or 40, a.w or 60
			plat(cur * CFrame.new(0, 0, -n * cell / 2), w, n * cell)
			for i = 1, n do
				local c = cur * CFrame.new(0, 0, -(i - 0.5) * cell)
				local m = T.slidingWall(c, w, stageFolder)
				K.tag(m, "MovingWall", { Amp = V(w * 0.3, 0, 0), Period = a.period or 3.6, Phase = (i - 1) * 0.37, BaseCF = m:GetPivot() })
			end
			mark(); adv(n * cell); mark()
		end
		function SEC.turn(a) -- round platform that changes heading
			local r = a.r or 40
			adv(a.gap or 0)
			local c = cur * CFrame.new(0, 0, -r)
			note(c)
			K.cyl(r * 2, 4, (c * CFrame.new(0, -2, 0)).Position, nextCol(), { parent = stageFolder, studs = true, name = "TurnPad" })
			K.cyl(r * 2 + 1.5, 1.2, (c * CFrame.new(0, -3.4, 0)).Position, T.rim, { parent = stageFolder, collide = false })
			mark(r + 10)
			cur = c * CFrame.Angles(0, rad(a.deg), 0)
			mark(r + 10)
			adv(r)
		end
		function SEC.nets(a) -- platform -> swinging net -> platform ...
			local n, gap, pl, w = a.n or 3, a.gap or 8, a.l or 46, a.w or 50
			plat(cur * CFrame.new(0, 0, -pl / 2), w, pl); mark(); adv(pl)
			for i = 1, n do
				adv(gap / 2)
				local c = cur
				local m = T.net(c, a.armLen or 54, stageFolder)
				K.tag(m, "Pendulum", { Amp = a.amp or 58, Period = a.period or 3.4, Phase = (i - 1) * (a.offset or 0.29), BaseCF = m:GetPivot() })
				adv(gap / 2)
				plat(cur * CFrame.new(0, 0, -pl / 2), w, pl); mark(); adv(pl); mark()
			end
		end
		function SEC.ball(a) -- uphill lane, rolling ball from the top, safe pockets left/right
			local L, laneW, rise_ = a.len or 420, 54, a.rise or 44
			local r = a.r or 19
			local slope = math.atan2(rise_, L)
			local start = cur
			local mid = start * CFrame.new(0, rise_ / 2, -L / 2) * CFrame.Angles(slope, 0, 0)
			local lane = K.part(V(laneW, 4, L / math.cos(slope)), mid * CFrame.new(0, -2, 0), T.laneCol, { parent = stageFolder, studs = true, name = "BallLane" })
			note(start)
			K.part(V(laneW + 2, 1.4, L / math.cos(slope)), mid * CFrame.new(0, -4.2, 0), T.rim, { parent = stageFolder, collide = false })
			-- pockets alternate sides; low walls on the lane edges except at the openings
			local pocketL, pocketD = 34, 28
			local pockets = {}
			local step = a.pocketEvery or 70
			local zs = {}
			local z = step * 0.8
			local side = 1
			while z < L - 40 do table.insert(zs, { z = z, side = side }); side = -side; z += step end
			local function onLane(dz, dx, dy) -- point on the incline dz along, dx sideways, dy above
				local pt = start * CFrame.new(0, 0, -dz) + V(0, rise_ * dz / L, 0)
				return pt * CFrame.new(dx, dy or 0, 0)
			end
			for _, pk in ipairs(zs) do
				local c = onLane(pk.z, pk.side * (laneW / 2 + pocketD / 2), 0)
				local pp = K.part(V(pocketD, 4, pocketL), c * CFrame.new(0, -2, 0), T.pocketCol, { parent = stageFolder, studs = true, name = "SafePocket" })
				note(c)
				-- pocket back wall + roof stripe so it reads as shelter
				K.part(V(3, 14, pocketL), c * CFrame.new(pk.side * (pocketD / 2 + 1.5), 7, 0), T.metal, { parent = stageFolder, studs = true })
				local sign = K.part(V(0.4, 4, 14), c * CFrame.new(pk.side * (pocketD / 2), 11, 0), T.pocketCol, { parent = stageFolder, collide = false, neon = true })
				K.textPanel(sign, pk.side > 0 and Enum.NormalId.Left or Enum.NormalId.Right, { { text = "SAFE", h = 0.9 } }, { pps = 16, stroke = 3 })
				table.insert(pockets, pk)
			end
			-- edge walls (segments between pockets)
			local function edge(sideSign, z0, z1)
				if z1 - z0 < 2 then return end
				local zc = (z0 + z1) / 2
				local c = onLane(zc, sideSign * (laneW / 2 + 1), 2.5)
				K.part(V(2, 5, (z1 - z0) / math.cos(slope)), c * CFrame.Angles(slope, 0, 0), T.trim, { parent = stageFolder, studs = true, name = "LaneEdge" })
			end
			for _, sgn in ipairs({ -1, 1 }) do
				local z0 = 0
				for _, pk in ipairs(zs) do
					if pk.side == sgn then edge(sgn, z0, pk.z - pocketL / 2); z0 = pk.z + pocketL / 2 end
				end
				edge(sgn, z0, L)
			end
			-- warning lights along the lane (flash while the ball rolls)
			for i = 1, math.floor(L / 60) do
				for _, sgn in ipairs({ -1, 1 }) do
					local c = onLane(i * 60 - 30, sgn * (laneW / 2 + 1), 6)
					local l = K.part(V(2, 2, 2), c, T.warn, { parent = stageFolder, neon = true, collide = false, name = "WarnLight" })
					K.tag(l, "BallWarnLight")
				end
			end
			-- the ball + its dispenser at the top
			local top = onLane(L - 6, 0, r)
			local bottom = onLane(26, 0, r)
			local ball = T.boulder(top, r, stageFolder) -- Model, PrimaryPart = the ball (tagged HazardKill by the theme)
			K.tag(ball, "RollingBall", { Top = top, Bottom = bottom, Speed = a.speed or 75, Spawn = 1.6, Warn = 2.2, Cooldown = 1.6, Radius = r })
			T.dispenser(onLane(L - 6, 0, 0), laneW, r, stageFolder)
			mark(70)
			cur = CFrame.new((onLane(L, 0, 0)).Position) * (start - start.Position)
			mark(70)
			-- landing at the top beside the dispenser
			plat(cur * CFrame.new(0, 0, -20), 70, 40); mark(70); adv(40); mark(70)
			return ball
		end
		function SEC.chase(a) -- continuous route (no gaps) so the Zookeeper can follow; waypoints in ChaseRoute
			local route = K.folder("ChaseRoute", stageFolder)
			K.tag(route, "ChaseRoute", { World = T.id, Stage = stageNo })
			local wp = 0
			local function point()
				wp += 1
				local p = K.part(V(2, 2, 2), cur * CFrame.new(0, 2, 0), Color3.new(1, 0, 0), { parent = route, transp = 1, collide = false, name = string.format("WP%03d", wp) })
				p:SetAttribute("Index", wp)
			end
			point()
			for _, step in ipairs(a.route) do
				local kind = step[1]
				if kind == "run" then
					local l = step[2]
					plat(cur * CFrame.new(0, 0, -l / 2), step[3] or 44, l)
					if step.props then T.edgeProps(cur, l, step[3] or 44, stageFolder) end
					mark(); adv(l); mark(); point()
				elseif kind == "ramp" then
					SEC.ramp({ len = step[2], rise = step[3], w = step[4] or 44 }); point()
				elseif kind == "turn" then
					SEC.turn({ r = step[3] or 30, deg = step[2] }); point()
				elseif kind == "bridge" then
					local l = step[2]
					T.bridge(cur, l, step[3] or 30, stageFolder)
					note(cur)
					mark(); adv(l); mark(); point()
				elseif kind == "sweeper" then
					SEC.sweeper({ len = step[2], w = 50, speed = step[3] or 60 }); point()
				elseif kind == "walls" then
					SEC.walls({ n = step[2], w = 52 }); point()
				end
			end
		end

		----------------------------------------------------------------------------------------------------------
		-- stage frame: gate + checkpoint + skip pad, ..., reward area
		----------------------------------------------------------------------------------------------------------
		local function gateArea(stage)
			local info = cfg.stages[stage] or {}
			-- landing / gate platform
			plat(cur * CFrame.new(0, 0, -30), 96, 60, T.gateFloor)
			mark(70)
			S.stageGate(cur * CFrame.new(0, 0, -12), 64, 46, stage, info, T, stageFolder)
			local cp = K.part(V(30, 1, 16), cur * CFrame.new(0, 0.6, -34), Color3.new(1, 1, 1), { parent = stageFolder, transp = 1, collide = false, name = "Checkpoint" })
			K.tag(cp, "Checkpoint", { World = T.id, Stage = stage })
			-- skip pad on the side (skips THIS stage)
			S.rewardPad(cur * CFrame.new(-34, 0, -38), "Skip", stage, "to the end of Stage " .. stage, T, stageFolder)
			adv(60)
			mark(70)
		end
		local function rewardArea(stage)
			local info = cfg.stages[stage] or {}
			adv(8)
			plat(cur * CFrame.new(0, 0, -45), 110, 90, T.rewardFloor)
			mark(70)
			local wins = info.wins
			S.rewardPad(cur * CFrame.new(28, 0, -46), "Normal", stage, wins and ("+" .. wins .. (wins == 1 and " Win" or " Wins")) or "Stage reward", T, stageFolder)
			S.rewardPad(cur * CFrame.new(-28, 0, -46), "Double", stage, wins and ("+" .. (wins * 2) .. " Wins") or "x2 reward", T, stageFolder)
			local endcp = K.part(V(30, 1, 16), cur * CFrame.new(0, 0.6, -14), Color3.new(1, 1, 1), { parent = stageFolder, transp = 1, collide = false, name = "StageEnd" })
			K.tag(endcp, "StageEnd", { World = T.id, Stage = stage })
			T.rewardDecor(cur * CFrame.new(0, 0, -45), stageFolder)
			adv(90)
			mark(70)
		end

		-- starting area (premium Alpha animal pads before the Stage 1 gate)
		local startFolder = K.folder("Start", course)
		stageFolder = startFolder
		plat(cur * CFrame.new(0, 0, -60), 150, 120, T.gateFloor)
		mark(80)
		if T.startDecor then T.startDecor(cur, startFolder) end
		adv(120)

		for i, st in ipairs(plan) do
			stageNo = i
			stageFolder = K.folder("Stage" .. i, course)
			minY = math.huge
			local startZ = #centre
			pathLen = 0
			gateArea(i)
			for _, sec in ipairs(st.sections) do
				SEC[sec[1]](sec[2] or {})
			end
			rewardArea(i)
			stageFolder:SetAttribute("Kind", st.kind or "Course")
			stageFolder:SetAttribute("PathLength", math.floor(pathLen))
			stageFolder:SetAttribute("KillY", minY - 28)
			K.tag(stageFolder, "ObbyStage", { World = T.id, Stage = i, Kind = st.kind or "Course" })
			-- water / void floor under the stage (visible moat)
			T.underlay(centre, startZ, minY - 40, stageFolder)
		end
		-- finale: the last reward area leads to a trophy plaza (built by the world file)
		stageFolder = K.folder("Finish", course)
		if T.finish then T.finish(cur, stageFolder, function(cf, hw) table.insert(centre, { cf = cf, hw = hw }) end) end
		-- side walls along the centreline
		local walls = K.folder("Walls", course)
		T.walls(centre, walls)
		return cur, centre
	end

	return O
end
