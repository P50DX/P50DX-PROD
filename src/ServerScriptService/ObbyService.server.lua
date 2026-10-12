-- ObbyService (Script -> ServerScriptService)
-- Server side of the worlds: stage gates, checkpoints, the three reward choices (yellow / purple x2 / green skip),
-- Zookeeper chases, return pads and station prompts. Your existing systems plug in through
-- ServerStorage.ZooMapHooks (BindableEvents) - this script never touches your data or balancing.
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local cfg = require(ReplicatedStorage:WaitForChild("ZooMapConfig"))
local AnimalRig = require(ReplicatedStorage:WaitForChild("AnimalRig"))

----------------------------------------------------------------------------------------------------------------
-- remotes + hooks
----------------------------------------------------------------------------------------------------------------
local remotes = ReplicatedStorage:FindFirstChild("ZooMapRemotes") or Instance.new("Folder")
remotes.Name = "ZooMapRemotes"; remotes.Parent = ReplicatedStorage
local function remote(name)
	local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name = name; r.Parent = remotes
	return r
end
local GateRemote, PadRemote, Notify, ResetRemote = remote("StageGate"), remote("RewardPad"), remote("Notify"), remote("Reset")

local hooks = ServerStorage:FindFirstChild("ZooMapHooks") or Instance.new("Folder")
hooks.Name = "ZooMapHooks"; hooks.Parent = ServerStorage
local function hook(name)
	local b = hooks:FindFirstChild(name) or Instance.new("BindableEvent")
	b.Name = name; b.Parent = hooks
	return b
end
local GrantReward = hook("GrantReward")       -- (player, worldId, stage, wins, kind)  -> give Wins in your data
local StageReached = hook("StageReached")     -- (player, worldId, stage)               -> save progress
local Interact = hook("Interact")             -- (player, kind, attributes)             -> open shop / hatch / spin / buy
local ProductPurchased = hook("ProductPurchased") -- YOU fire this from your ProcessReceipt: (player, productId)

----------------------------------------------------------------------------------------------------------------
-- map index
----------------------------------------------------------------------------------------------------------------
local function key(w, s) return w .. ":" .. s end
local function index(tag)
	local t = {}
	for _, p in CollectionService:GetTagged(tag) do t[key(p:GetAttribute("World"), p:GetAttribute("Stage"))] = p end
	return t
end
local gates, checkpoints, stageEnds, stages, routes
local function reindex()
	gates, checkpoints, stageEnds, stages, routes = index("StageGate"), index("Checkpoint"), index("StageEnd"), index("ObbyStage"), index("ChaseRoute")
end
reindex()

local function worldSpawn(w)
	for _, p in CollectionService:GetTagged("WorldSpawn") do
		if p:GetAttribute("World") == w then return p.CFrame end
	end
	local s = workspace:FindFirstChildOfClass("SpawnLocation")
	return s and s.CFrame or CFrame.new(0, 10, 0)
end

local function root(player)
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

-- put a character on a spot (feet on the floor), facing the spot's -Z
local function sendTo(player, cf)
	local c = player.Character
	local r = root(player)
	if not (c and r) then return end
	pcall(player.RequestStreamAroundAsync, player, cf.Position, 3) -- load the destination first (StreamingEnabled)
	local _, size = c:GetBoundingBox()
	c:PivotTo(CFrame.new(cf.Position + Vector3.new(0, size.Y / 2 + 1.5, 0)) * (cf - cf.Position))
	r.AssemblyLinearVelocity = Vector3.zero
end

local function checkpointCf(w, s)
	local cp = checkpoints[key(w, s)]
	return cp and cp.CFrame
end

----------------------------------------------------------------------------------------------------------------
-- player state: CurrentWorld / CurrentStage (0 = in the hub) / Stage_<w> (best stage reached, save it!)
----------------------------------------------------------------------------------------------------------------
local chases = {}
local stopChase, startChase

local function setStage(player, w, s)
	player:SetAttribute("CurrentWorld", w)
	player:SetAttribute("CurrentStage", s)
	if s > (player:GetAttribute("Stage_" .. w) or 0) then
		player:SetAttribute("Stage_" .. w, s)
		StageReached:Fire(player, w, s)
	end
end

local function toHub(player, w)
	stopChase(player)
	player:SetAttribute("CurrentStage", 0)
	sendTo(player, worldSpawn(w or player:GetAttribute("CurrentWorld") or 1))
end

local function testWins(player, n)
	-- TEST PLACE ONLY: show the reward on a leaderstats board when your data system is not connected
	if not cfg.TestMode then return end
	local ls = player:FindFirstChild("leaderstats")
	if not ls then ls = Instance.new("Folder"); ls.Name = "leaderstats"; ls.Parent = player end
	local v = ls:FindFirstChild("Wins") or Instance.new("IntValue")
	v.Name = "Wins"; v.Parent = ls
	v.Value += n
end

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("CurrentWorld", player:GetAttribute("CurrentWorld") or 1)
	player:SetAttribute("CurrentStage", 0)
	player.CharacterAdded:Connect(function(char)
		task.wait(0.15) -- let AnimalSwitchService swap the animal in first
		if player.Character ~= char then return end
		local w, s = player:GetAttribute("CurrentWorld") or 1, player:GetAttribute("CurrentStage") or 0
		if s > 0 and checkpointCf(w, s) then
			sendTo(player, checkpointCf(w, s)) -- respawn at the stage you were on, never back at Stage 1
			if stages[key(w, s)] and stages[key(w, s)]:GetAttribute("Kind") == "Chase" then task.delay(1, function() if player:GetAttribute("CurrentStage") == s then startChase(player, w, s) end end) end
		end
	end)
	testWins(player, 0)
end)
Players.PlayerRemoving:Connect(function(p) stopChase(p); busy[p] = nil end)

----------------------------------------------------------------------------------------------------------------
-- Zookeeper chase
----------------------------------------------------------------------------------------------------------------
local npcFolder = workspace:FindFirstChild("ZooMapNPC") or Instance.new("Folder")
npcFolder.Name = "ZooMapNPC"; npcFolder.Parent = workspace

local function routePoints(w, s)
	local r = routes[key(w, s)]
	if not r then return nil end
	local pts = {}
	for _, p in r:GetChildren() do pts[p:GetAttribute("Index")] = p.Position end
	return pts
end

-- index of the route segment closest to pos (and the projected point)
local function progress(pts, pos)
	local best, bi = math.huge, 1
	for i = 1, #pts - 1 do
		local a, b = pts[i], pts[i + 1]
		local ab = b - a
		local t = math.clamp((pos - a):Dot(ab) / ab:Dot(ab), 0, 1)
		local d = (a + ab * t - pos).Magnitude
		if d < best then best, bi = d, i + t end
	end
	return bi, best
end

function stopChase(player)
	local st = chases[player]
	if st then
		chases[player] = nil
		st.alive = false
		if st.keeper then st.keeper:Destroy() end
	end
end

local function spawnKeeper(cf)
	local src = ServerStorage:FindFirstChild("ZooModels") and ServerStorage.ZooModels.Zookeepers:FindFirstChild("Zookeeper")
	local m = src:Clone()
	m.Name = "ChasingZookeeper"
	m:ScaleTo(1.7)
	AnimalRig.prepare(m, "npc")
	local _, size = m:GetBoundingBox()
	m:PivotTo(CFrame.new(cf.Position + Vector3.new(0, size.Y / 2 + 1, 0)) * (cf - cf.Position))
	m.Parent = npcFolder
	local r = m:FindFirstChild("HumanoidRootPart")
	pcall(function() r:SetNetworkOwner(nil) end)
	return m
end

function startChase(player, w, s)
	stopChase(player)
	local pts = routePoints(w, s)
	local gate = gates[key(w, s)]
	if not (pts and gate) then return end
	local st = { alive = true, w = w, s = s }
	chases[player] = st
	Notify:FireClient(player, "ChaseWarning", s)
	task.delay(2.6, function()
		if not st.alive then return end
		local keeper = spawnKeeper(gate.CFrame * CFrame.new(0, -gate.Size.Y / 2, 10) * CFrame.Angles(0, 0, 0))
		st.keeper = keeper
		Notify:FireClient(player, "ChaseStart", s)
		local hum = keeper:FindFirstChildOfClass("Humanoid")
		local kr = keeper:FindFirstChild("HumanoidRootPart")
		local lastPos, stuckT = kr.Position, 0
		local killY = (stages[key(w, s)] and stages[key(w, s)]:GetAttribute("KillY")) or -1e9
		while st.alive and keeper.Parent do
			local dt = task.wait(0.1)
			local pr, ph = root(player)
			if not (pr and ph) or player:GetAttribute("CurrentStage") ~= s or player:GetAttribute("CurrentWorld") ~= w then break end
			-- the player reached the reward area -> safe
			local endp = stageEnds[key(w, s)]
			if endp and (pr.Position - endp.Position).Magnitude < 60 then
				Notify:FireClient(player, "ChaseSafe", s)
				break
			end
			local pIdx = progress(pts, pr.Position)
			local kIdx = progress(pts, kr.Position)
			local dist = (pr.Position - kr.Position).Magnitude
			-- fair pressure: a bit slower than the player, catches up only when far behind
			local base = math.max(16, ph.WalkSpeed)
			hum.WalkSpeed = base * ((dist > 140) and 1.12 or 0.93)
			if math.floor(kIdx) < math.floor(pIdx) then
				hum:MoveTo(pts[math.min(#pts, math.floor(kIdx) + 1)])
			else
				hum:MoveTo(pr.Position)
			end
			-- caught?
			local _, ksize = keeper:GetBoundingBox()
			if dist < ksize.Z * 0.5 + 5 then
				Notify:FireClient(player, "Caught", s)
				sendTo(player, checkpointCf(w, s))
				st.alive = false
				keeper:Destroy()
				task.delay(1.2, function() if player:GetAttribute("CurrentStage") == s then startChase(player, w, s) end end)
				return
			end
			-- unstick / recover from a fall (only if it really cannot move)
			if (kr.Position - lastPos).Magnitude < 1 then stuckT += dt else stuckT = 0; lastPos = kr.Position end
			if stuckT > 2.5 or kr.Position.Y < killY then
				local nxt = pts[math.min(#pts, math.floor(kIdx) + 1)]
				keeper:PivotTo(CFrame.new(nxt + Vector3.new(0, 6, 0)))
				stuckT = 0
			end
		end
		if chases[player] == st then stopChase(player) elseif keeper.Parent then keeper:Destroy() end
	end)
end

----------------------------------------------------------------------------------------------------------------
-- stage gates (the client reports crossing the gate plane; server checks it is plausible)
----------------------------------------------------------------------------------------------------------------
GateRemote.OnServerEvent:Connect(function(player, w, s)
	if typeof(w) ~= "number" or typeof(s) ~= "number" then return end
	local g = gates[key(w, s)]
	local r = root(player)
	if not (g and r) or (r.Position - g.Position).Magnitude > 120 then return end
	local cur = player:GetAttribute("CurrentStage") or 0
	if s > (player:GetAttribute("Stage_" .. w) or 0) + 1 and s > cur + 1 then return end -- no jumping ahead
	local again = (cur == s)
	setStage(player, w, s)
	if not again then
		Notify:FireClient(player, "StageStart", s)
		local st = stages[key(w, s)]
		if st and st:GetAttribute("Kind") == "Chase" then startChase(player, w, s) else stopChase(player) end
	end
end)

----------------------------------------------------------------------------------------------------------------
-- reward pads
----------------------------------------------------------------------------------------------------------------
local busy = {}
local pendingProduct = {} -- player -> { kind, w, s }

local function grant(player, w, s, mult, kind)
	local st = cfg.Worlds[w] and cfg.Worlds[w].stages[s]
	local wins = (st and st.wins or 1) * mult
	GrantReward:Fire(player, w, s, wins, kind)
	testWins(player, wins)
	Notify:FireClient(player, "Reward", s, wins, kind)
	stopChase(player)
	if cfg.ReturnToHubAfterReward then
		task.delay(1.4, function() toHub(player, w) end)
	end
end

local function skip(player, w, s)
	local e = stageEnds[key(w, s)]
	if not e then return end
	stopChase(player)
	setStage(player, w, s)
	Notify:FireClient(player, "Skipped", s)
	sendTo(player, e.CFrame * CFrame.new(0, 0, 4))
end

local function finishProduct(player, kind, w, s)
	if kind == "Double" then grant(player, w, s, 2, "Double") elseif kind == "Skip" then skip(player, w, s) end
end

PadRemote.OnServerEvent:Connect(function(player, pad)
	if typeof(pad) ~= "Instance" or not CollectionService:HasTag(pad, "RewardPad") then return end
	local r = root(player)
	if not r or (r.Position - pad.Position).Magnitude > 45 then return end
	busy[player] = busy[player] or {}
	if busy[player][pad] and os.clock() - busy[player][pad] < 2.5 then return end
	busy[player][pad] = os.clock()
	local w, s, kind = pad:GetAttribute("World"), pad:GetAttribute("Stage"), pad:GetAttribute("Kind")
	if kind == "Normal" then
		grant(player, w, s, 1, "Normal")
	else
		local id = kind == "Double" and cfg.Products.DoubleWins or cfg.Products.SkipStage
		if id then
			pendingProduct[player] = { id = id, kind = kind, w = w, s = s }
			MarketplaceService:PromptProductPurchase(player, id)
		elseif cfg.TestMode then
			Notify:FireClient(player, "TestPurchase", kind)
			finishProduct(player, kind, w, s)
		end
	end
end)

-- call from YOUR ProcessReceipt when the product was bought (keeps a single receipt handler in the game)
ProductPurchased.Event:Connect(function(player, productId)
	local p = pendingProduct[player]
	if p and p.id == productId then
		pendingProduct[player] = nil
		finishProduct(player, p.kind, p.w, p.s)
	end
end)

----------------------------------------------------------------------------------------------------------------
-- return pads, station prompts, fall safety net
----------------------------------------------------------------------------------------------------------------
for _, pad in CollectionService:GetTagged("ReturnPad") do
	pad.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and player:GetAttribute("CurrentStage") ~= 0 then toHub(player, pad:GetAttribute("World")) end
	end)
end
ResetRemote.OnServerEvent:Connect(function(player) -- client asks to go back to its checkpoint (after a fall)
	local w, s = player:GetAttribute("CurrentWorld") or 1, player:GetAttribute("CurrentStage") or 0
	if s > 0 then sendTo(player, checkpointCf(w, s)) else sendTo(player, worldSpawn(w)) end
end)

local KINDS = { ShopStation = "Shop", EggStation = "Egg", WheelStation = "Wheel", WorldPortal = "Portal", SpeedUpgrade = "SpeedUpgrade", PremiumAnimal = "PremiumAnimal" }
local function wirePrompt(pp, kind)
	pp.Triggered:Connect(function(player)
		Interact:Fire(player, kind, pp:GetAttributes())
		if cfg.TestMode then
			if kind == "Egg" then
				local ok, PetService = pcall(require, game:GetService("ServerScriptService"):FindFirstChild("PetService"))
				local egg = cfg.Worlds[pp:GetAttribute("World")] and cfg.Worlds[pp:GetAttribute("World")].egg
				if ok and PetService and egg then
					local pet = egg.pets[math.random(1, #egg.pets)]
					pcall(PetService.equip, player, pet)
					Notify:FireClient(player, "Toast", "🥚 Test hatch: " .. pet)
					return
				end
			end
			Notify:FireClient(player, "Toast", (pp.ObjectText ~= "" and pp.ObjectText or kind) .. " - connect your " .. kind .. " system (ZooMapHooks.Interact)")
		end
	end)
end
for tag, kind in pairs(KINDS) do
	for _, pp in CollectionService:GetTagged(tag) do wirePrompt(pp, kind) end
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(pp) wirePrompt(pp, kind) end)
end

-- server safety net: anyone far below their stage gets put back (the client normally does this instantly)
task.spawn(function()
	while true do
		task.wait(0.5)
		for _, player in Players:GetPlayers() do
			local r = root(player)
			local w, s = player:GetAttribute("CurrentWorld") or 1, player:GetAttribute("CurrentStage") or 0
			local st = stages[key(w, math.max(1, s))]
			if r and st and r.Position.Y < (st:GetAttribute("KillY") or -1e9) - 60 then
				if s > 0 then sendTo(player, checkpointCf(w, s)) else sendTo(player, worldSpawn(w)) end
			end
		end
	end
end)
