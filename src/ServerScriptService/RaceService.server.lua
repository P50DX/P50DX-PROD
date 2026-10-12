-- RaceService (Script -> ServerScriptService)
-- Timed "Speed Race" events. Every Interval seconds: the lobby opens (players get a JOIN button), joiners wait in
-- the lobby, then everyone in the lobby is placed on the start grid, 3-2-1-GO, first across the finish wins.
-- Rewards go through ServerStorage.ZooMapHooks.GrantReward(player, 0, 0, wins, "Race<place>").
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local cfg = require(ReplicatedStorage:WaitForChild("ZooMapConfig"))
local RACE = cfg.Race or { Interval = 300, LobbyTime = 25, MaxTime = 90, Rewards = { 3, 2, 1 } } -- TEST values
local remotes = ReplicatedStorage:WaitForChild("ZooMapRemotes")
local Notify = remotes:WaitForChild("Notify")
local RaceRemote = remotes:FindFirstChild("Race") or Instance.new("RemoteEvent")
RaceRemote.Name = "Race"; RaceRemote.Parent = remotes
local hooks = ServerStorage:WaitForChild("ZooMapHooks")
local GrantReward = hooks:WaitForChild("GrantReward")

local function tagged(t) return CollectionService:GetTagged(t)[1] end
local function root(p) local c = p.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function place(p, cf)
	local c = p.Character
	if not c then return end
	pcall(p.RequestStreamAroundAsync, p, cf.Position, 3)
	local _, size = c:GetBoundingBox()
	c:PivotTo(CFrame.new(cf.Position + Vector3.new(0, size.Y / 2 + 1.5, 0)) * (cf - cf.Position))
end
local function boardSet(name, text)
	local b = tagged("RaceBoard")
	local l = b and b:FindFirstChild(name, true)
	if l then l.Text = text end
end

local state = "idle" -- idle | lobby | countdown | racing
local inLobby = {}   -- player -> { world, returnCf }
local finished = {}
local function backHome(p)
	local info = inLobby[p]
	inLobby[p] = nil
	local r = root(p)
	if r then r.Anchored = false end
	local w = (info and info.world) or 1
	p:SetAttribute("CurrentWorld", w); p:SetAttribute("CurrentStage", 0); p:SetAttribute("InRace", false)
	for _, s in CollectionService:GetTagged("WorldSpawn") do
		if s:GetAttribute("World") == w then place(p, s.CFrame) end
	end
end

RaceRemote.OnServerEvent:Connect(function(p, action)
	if action == "Join" and state == "lobby" and not inLobby[p] then
		inLobby[p] = { world = p:GetAttribute("CurrentWorld") or 1 }
		p:SetAttribute("CurrentStage", 0); p:SetAttribute("InRace", true)
		local sp = tagged("RaceLobbySpawn")
		if sp then place(p, sp.CFrame * CFrame.new(math.random(-20, 20), 0, math.random(-12, 12))) end
		Notify:FireClient(p, "RaceJoined")
	elseif action == "Leave" and inLobby[p] and state == "lobby" then
		backHome(p)
	end
end)
Players.PlayerRemoving:Connect(function(p) inLobby[p] = nil end)

local function runRace()
	local racers = {}
	for p in pairs(inLobby) do if p.Parent and root(p) then table.insert(racers, p) end end
	if #racers == 0 then return end
	state = "countdown"
	local grid = tagged("RaceGrid")
	local barrier = tagged("RaceStartBarrier")
	if barrier then barrier.CanCollide = true end
	for i, p in ipairs(racers) do
		local row, col = math.floor((i - 1) / 8), (i - 1) % 8
		place(p, grid.CFrame * CFrame.new(-28 + col * 8, 0, 10 - row * 9))
	end
	task.wait(1)
	local lights = CollectionService:GetTagged("RaceLight")
	table.sort(lights, function(a, b) return a:GetAttribute("Index") < b:GetAttribute("Index") end)
	for _, l in ipairs(lights) do l.Color = Color3.fromRGB(80, 0, 0) end
	for n = 3, 1, -1 do
		for _, p in ipairs(racers) do Notify:FireClient(p, "RaceCount", n) end
		if lights[4 - n] then lights[4 - n].Color = Color3.fromRGB(255, 40, 40) end
		task.wait(1)
	end
	for _, l in ipairs(lights) do l.Color = Color3.fromRGB(60, 255, 90) end
	if barrier then barrier.CanCollide = false end
	state = "racing"
	finished = {}
	local t0 = os.clock()
	for _, p in ipairs(racers) do Notify:FireClient(p, "RaceCount", 0) end
	local finish = tagged("RaceFinish")
	local placeN = 0
	while os.clock() - t0 < RACE.MaxTime and placeN < #racers do
		task.wait(0.05)
		for _, p in ipairs(racers) do
			local r = root(p)
			if r and not finished[p] and finish.CFrame:PointToObjectSpace(r.Position).Z < 0 then
				placeN += 1
				finished[p] = placeN
				local wins = RACE.Rewards[placeN] or 0
				GrantReward:Fire(p, 0, 0, wins, "Race" .. placeN)
				if cfg.TestMode and wins > 0 then
					local ls = p:FindFirstChild("leaderstats"); local v = ls and ls:FindFirstChild("Wins"); if v then v.Value += wins end
				end
				for _, q in ipairs(racers) do Notify:FireClient(q, "RaceFinish", p.DisplayName, placeN, string.format("%.2f", os.clock() - t0), q == p, wins) end
				local pod = nil
				for _, pd in CollectionService:GetTagged("RacePodium") do if pd:GetAttribute("Place") == placeN then pod = pd end end
				if pod then
					local lbl = pod.Parent:FindFirstChild("PodiumName" .. placeN)
					local t = lbl and lbl:FindFirstChild("Name", true)
					if t then t.Text = placeN .. ". " .. p.DisplayName end
					if placeN <= 3 then task.delay(1.5, function() place(p, pod.CFrame * CFrame.new(0, pod.Size.Y / 2, 0)) end) end
				end
			end
		end
	end
	task.wait(6)
	for _, p in ipairs(racers) do backHome(p) end
	for _, l in ipairs(lights) do l.Color = Color3.fromRGB(80, 0, 0) end
end

task.spawn(function()
	while true do
		local interval = workspace:GetAttribute("RaceIntervalOverride") or RACE.Interval
		local nextRace = workspace:GetServerTimeNow() + interval
		workspace:SetAttribute("NextRace", nextRace)
		state = "idle"
		while workspace:GetServerTimeNow() < nextRace - RACE.LobbyTime do
			task.wait(0.5)
			boardSet("Time", "Next race in " .. math.floor(nextRace - workspace:GetServerTimeNow()) .. "s")
		end
		state = "lobby"
		Notify:FireAllClients("RaceOpen", RACE.LobbyTime)
		while workspace:GetServerTimeNow() < nextRace do
			local left = math.ceil(nextRace - workspace:GetServerTimeNow())
			boardSet("Time", "STARTS IN " .. left)
			local n = 0; for _ in pairs(inLobby) do n += 1 end
			boardSet("Count", n .. " racer" .. (n == 1 and "" or "s") .. " waiting")
			task.wait(0.25)
		end
		Notify:FireAllClients("RaceClosed")
		boardSet("Time", "RACE IN PROGRESS")
		local ok, err = pcall(runRace)
		if not ok then warn("RaceService: " .. tostring(err)) end
		for p in pairs(inLobby) do backHome(p) end
		boardSet("Count", "")
	end
end)
