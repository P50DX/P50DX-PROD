-- Race map: a waiting lobby (square arena with a big countdown board and a portal ring, like your screenshot)
-- and a long straight race track (start gate with lights, checkered start/finish, grandstands, distance markers,
-- podium). RaceService moves players between them.
return function(K, P, S, R)
	local V = Vector3.new
	local rad = math.rad
	local rgb = K.rgb
	local root = workspace:FindFirstChild("RaceMap"); if root then root:Destroy() end
	root = K.folder("RaceMap", workspace)
	K.seed(77)
	local function at(x, y, z) return R + V(x, y, z) end
	local pal = { treePal = { trunk = rgb(132, 86, 52), leaf = rgb(72, 172, 66), leaf2 = rgb(116, 206, 84) } }
	local gold = rgb(255, 200, 50)

	------------------------------------------------------------------------------------------------------------
	-- LOBBY (centre R): 150 x 150 arena
	------------------------------------------------------------------------------------------------------------
	local lobby = K.folder("Lobby", root)
	K.parent = lobby
	local L = 150
	K.part(V(L + 40, 20, L + 40), CFrame.new(at(0, -10, 0)), rgb(90, 180, 80), { studs = true, name = "Ground" })
	for i = 0, 9 do for j = 0, 9 do
		K.part(V(L / 10, 0.6, L / 10), CFrame.new(at(-L / 2 + (i + 0.5) * L / 10, 0.3, -L / 2 + (j + 0.5) * L / 10)), ((i + j) % 2 == 0) and rgb(245, 245, 250) or rgb(120, 110, 150), { studs = true, name = "Tile" })
	end end
	K.part(V(L + 2, 0.4, L + 2), CFrame.new(at(0, 0.1, 0)), rgb(255, 120, 200), { neon = true, collide = false })
	-- walls: stepped cliffs on three sides, the track gate on the fourth (+Z)
	local cl = { height = 26, depth = 22, rock = { rgb(158, 112, 82), rgb(186, 138, 100) }, top = rgb(96, 192, 76), trees = 0.35, bushes = 0.4, treeKind = { "oak", "pine" }, treePal = pal.treePal }
	cl.inward = V(1, 0, 0); P.cliff(at(-L / 2, 0, -L / 2), at(-L / 2, 0, L / 2), cl, lobby)
	cl.inward = V(-1, 0, 0); P.cliff(at(L / 2, 0, L / 2), at(L / 2, 0, -L / 2), cl, lobby)
	cl.inward = V(0, 0, 1); P.cliff(at(-L / 2, 0, -L / 2), at(L / 2, 0, -L / 2), cl, lobby)
	cl.inward = V(0, 0, -1); P.cliff(at(-L / 2, 0, L / 2), at(-24, 0, L / 2), cl, lobby); P.cliff(at(24, 0, L / 2), at(L / 2, 0, L / 2), cl, lobby)
	-- countdown board on the north wall + the portal ring (closed until the race starts)
	local board = K.part(V(60, 22, 2), CFrame.new(at(0, 30, -L / 2 + 6)), rgb(30, 28, 50), { name = "Countdown" })
	K.part(V(64, 26, 1.6), CFrame.new(at(0, 30, -L / 2 + 5.4)), gold, { collide = false })
	K.textPanel(board, Enum.NormalId.Back, { { name = "Title", text = "SPEED RACE", h = 0.35, grad = { rgb(255, 250, 150), rgb(255, 150, 40) }, font = K.FONT_BOLD }, { name = "Time", text = "--", h = 0.45 }, { name = "Count", text = "", h = 0.2 } }, { pps = 10, stroke = 5 })
	for _, sx in ipairs({ -1, 1 }) do K.part(V(4, 30, 4), CFrame.new(at(sx * 33, 15, -L / 2 + 6)), rgb(60, 64, 90), { studs = true }) end
	local ringCf = CFrame.new(at(0, 18, L / 2 - 2))
	S.ring(ringCf, 20, 3, 5, rgb(240, 240, 250), 24, { studs = true, collide = true }, lobby)
	S.ring(ringCf * CFrame.new(0, 0, -2.6), 18.4, 0.8, 0.6, rgb(80, 220, 255), 24, { neon = true }, lobby)
	local gateField = K.part(V(36, 36, 1), ringCf, rgb(80, 220, 255), { transp = 0.4, mat = Enum.Material.ForceField, name = "LobbyGate", collide = true })
	gateField.Shape = Enum.PartType.Cylinder; gateField.Size = V(1, 36, 36); gateField.CFrame = ringCf * CFrame.Angles(0, rad(90), 0)
	-- benches + lamps
	for k = 0, 3 do
		P.bench(CFrame.new(at(-50 + k * 33, 0, -40)) * CFrame.Angles(0, math.pi, 0), { wood = rgb(186, 124, 70), metal = rgb(52, 58, 82) }, lobby)
		P.lamp(at(-60 + k * 40, 0, 60), { metal = rgb(52, 58, 82) }, k % 2 == 0, lobby)
	end
	local spawnPad = K.part(V(60, 1, 40), CFrame.new(at(0, 0.7, 10)), Color3.new(1, 1, 1), { transp = 1, collide = false, name = "LobbySpawn" })
	K.tag(spawnPad, "RaceLobbySpawn")
	K.tag(board, "RaceBoard")

	------------------------------------------------------------------------------------------------------------
	-- TRACK: starts just past the lobby gate, runs +Z
	------------------------------------------------------------------------------------------------------------
	local track = K.folder("Track", root)
	K.parent = track
	local TW, TL = 80, 2600
	local z0 = L / 2 + 40
	local function tz(z) return z0 + z end
	-- start grid apron
	K.part(V(TW + 40, 20, 80), CFrame.new(at(0, -10, tz(-30))), rgb(90, 180, 80), { studs = true })
	local seg = 40
	for i = 0, TL / seg - 1 do
		local c = (i % 2 == 0) and rgb(74, 196, 170) or rgb(60, 176, 152)
		K.part(V(TW, 4, seg), CFrame.new(at(0, -2, tz(i * seg + seg / 2))), c, { studs = true, name = "TrackFloor" })
		K.part(V(TW + 4, 1.5, seg), CFrame.new(at(0, -4.6, tz(i * seg + seg / 2))), rgb(40, 50, 70), { collide = false })
		if i % 2 == 0 then K.part(V(2, 0.2, seg * 0.6), CFrame.new(at(0, 0.1, tz(i * seg + seg / 2))), rgb(255, 255, 255), { collide = false }) end
	end
	-- side barriers (blue, like the screenshot) + grandstands + flags
	for _, sx in ipairs({ -1, 1 }) do
		K.part(V(3, 8, TL), CFrame.new(at(sx * (TW / 2 + 1.5), 4, tz(TL / 2))), rgb(60, 90, 200), { studs = true, name = "Barrier" })
		K.part(V(3.4, 0.8, TL), CFrame.new(at(sx * (TW / 2 + 1.5), 8.2, tz(TL / 2))), rgb(255, 255, 255), { collide = false })
		K.part(V(4, 300, TL + 200), CFrame.new(at(sx * (TW / 2 + 3), 150, tz(TL / 2))), Color3.new(1, 1, 1), { transp = 1, name = "Boundary" })
		for k = 0, math.floor(TL / 200) - 1 do
			local zc = tz(100 + k * 200)
			if k % 2 == 0 then -- grandstand
				for r = 0, 3 do K.part(V(8, 3 + r * 3, 60), CFrame.new(at(sx * (TW / 2 + 10 + r * 8), (3 + r * 3) / 2, zc)), (r % 2 == 0) and rgb(240, 240, 250) or rgb(255, 120, 60), { studs = true }) end
				K.part(V(36, 1.2, 64), CFrame.new(at(sx * (TW / 2 + 22), 18, zc)), rgb(60, 90, 200), { collide = false })
			else
				P.tree(at(sx * (TW / 2 + 24), 0, zc), K.pick({ "oak", "pine", "round" }), 1.2, pal.treePal, track)
				P.banner(at(sx * (TW / 2 + 8), 0, zc + 30), sx > 0 and 180 or 0, (k % 4 == 1) and rgb(255, 120, 60) or rgb(60, 180, 255), "⚡", { metal = rgb(52, 58, 82) }, track)
			end
		end
		K.part(V(120, 16, TL + 200), CFrame.new(at(sx * (TW / 2 + 70), -8, tz(TL / 2))), rgb(90, 180, 80), { studs = true, collide = false })
	end
	-- distance markers every 500
	for d = 500, TL - 100, 500 do
		local sgn = K.part(V(TW + 10, 6, 1), CFrame.new(at(0, 30, tz(d))), rgb(30, 30, 50), { collide = false })
		K.textPanel(sgn, Enum.NormalId.Front, { { text = d .. " STUDS", h = 0.8, color = rgb(255, 230, 120), font = K.FONT_BOLD } }, { pps = 8, stroke = 3 })
		for _, sx in ipairs({ -1, 1 }) do K.part(V(2, 33, 2), CFrame.new(at(sx * (TW / 2 + 4), 16.5, tz(d))), rgb(52, 58, 82), {}) end
	end
	-- start gate: arch with three red lights + checkered start line
	local startArch, sTop = P.arch(CFrame.new(at(0, 0, tz(30))), TW + 4, 26, { pillar = rgb(240, 240, 250), trim = rgb(255, 80, 80), pillarW = 6 }, track)
	K.textPanel(sTop, Enum.NormalId.Front, { { text = "START", h = 0.9, color = Color3.new(1, 1, 1), font = K.FONT_BOLD } }, { pps = 6, stroke = 4 })
	for k = -1, 1 do
		local l = K.part(V(4, 4, 4), CFrame.new(at(k * 7, 38, tz(30) - 3)), rgb(80, 0, 0), { neon = true, collide = false, shape = "ball", name = "StartLight" })
		K.tag(l, "RaceLight", { Index = k + 2 })
	end
	for i = 0, 15 do for j = 0, 1 do
		K.part(V(TW / 16, 0.2, 2.5), CFrame.new(at(-TW / 2 + (i + 0.5) * TW / 16, 0.1, tz(34 + j * 2.5))), ((i + j) % 2 == 0) and rgb(255, 255, 255) or rgb(20, 20, 30), { collide = false })
	end end
	-- invisible start barrier (players wait behind it during 3-2-1)
	local barrier = K.part(V(TW, 30, 2), CFrame.new(at(0, 15, tz(37))), Color3.new(1, 1, 1), { transp = 1, name = "StartBarrier" })
	K.tag(barrier, "RaceStartBarrier")
	local grid = K.part(V(TW - 10, 1, 30), CFrame.new(at(0, 0.6, tz(16))), Color3.new(1, 1, 1), { transp = 1, collide = false, name = "Grid" })
	K.tag(grid, "RaceGrid")
	-- finish line + arch + podium
	local fz = tz(TL - 120)
	for i = 0, 15 do for j = 0, 3 do
		K.part(V(TW / 16, 0.2, 2.5), CFrame.new(at(-TW / 2 + (i + 0.5) * TW / 16, 0.1, fz + j * 2.5)), ((i + j) % 2 == 0) and rgb(255, 255, 255) or rgb(20, 20, 30), { collide = false })
	end end
	local _, fTop = P.arch(CFrame.new(at(0, 0, fz + 4)), TW + 4, 30, { pillar = rgb(255, 210, 60), trim = rgb(255, 255, 255), pillarW = 7 }, track)
	K.textPanel(fTop, Enum.NormalId.Back, { { text = "🏁 FINISH 🏁", h = 0.9, grad = { rgb(255, 255, 170), rgb(255, 170, 40) }, font = K.FONT_BOLD } }, { pps = 6, stroke = 5 })
	local finish = K.part(V(TW, 40, 2), CFrame.new(at(0, 20, fz + 5)), Color3.new(1, 1, 1), { transp = 1, collide = false, name = "FinishLine" })
	K.tag(finish, "RaceFinish")
	-- end wall + podium
	K.part(V(TW + 10, 40, 6), CFrame.new(at(0, 20, tz(TL) + 3)), rgb(60, 90, 200), { studs = true })
	local pc = CFrame.new(at(0, 0, tz(TL - 50)))
	for k, h in ipairs({ 9, 6, 4 }) do
		local x = ({ 0, -14, 14 })[k]
		local p = K.part(V(12, h, 12), pc * CFrame.new(x, h / 2, 0), ({ gold, rgb(210, 220, 235), rgb(220, 140, 80) })[k], { studs = true, name = "Podium" .. k })
		local lbl = K.part(V(10, 3, 0.4), pc * CFrame.new(x, h / 2, -6.2), rgb(30, 30, 50), { collide = false, name = "PodiumName" .. k })
		K.textPanel(lbl, Enum.NormalId.Front, { { name = "Name", text = tostring(k), h = 0.9, color = Color3.new(1, 1, 1) } }, { pps = 20, stroke = 2 })
		K.tag(p, "RacePodium", { Place = k })
	end
	P.backdrop({ at(0, 0, -L / 2), at(0, 0, tz(TL)) }, { base = rgb(150, 112, 84), grass = rgb(98, 182, 82), grass2 = rgb(120, 196, 96), floor = rgb(84, 158, 92), floorY = -120 }, root)
	K.parent = workspace
	return root
end
