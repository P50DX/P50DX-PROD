-- WORLD = "Desert" etc (prepended)
local B = game.ServerStorage.MapBuilder
local function R(n) local c = B[n]:Clone(); c.Parent = B; local ok, r = pcall(require, c); c:Destroy(); assert(ok, r); return r end
local K = R("MapKit"); local P = R("Props")(K); local S = R("Stations")(K, P); local Obby = R("Obby")(K, P, S)
S.eggBuilder = R("Eggs3")(K)
local Wd = R("Worlds")(K, P, S)
local cfg = (function() local c = game.ReplicatedStorage.ZooMapConfig:Clone(); c.Parent = B; local r = require(c); c:Destroy(); return r end)()
local T = Wd[WORLD]()
local O = cfg.Origins[T.id]
local old = workspace:FindFirstChild("World" .. T.id .. "_" .. T.key); if old then old:Destroy() end
local ok, err = pcall(R("WorldHub"), K, P, S, cfg, O, T)
if not ok then return "hub " .. tostring(err) end
local kinds = KINDS
local mult = {}
for i = 1, 10 do mult[i] = 1 end
local root = workspace["World" .. T.id .. "_" .. T.key]
local lens
for iter = 1, 14 do
	K.seed(500 + T.id)
	local plan = Wd.plan(T.id * 31, kinds, mult)
	local ok2, err2 = pcall(Obby.build, T, cfg.Worlds[T.id], CFrame.new(O + Vector3.new(0, 0, -170)), plan, root)
	if not ok2 then return "obby " .. tostring(err2) end
	lens = {}
	for i = 1, 10 do lens[i] = root.Obby["Stage" .. i]:GetAttribute("PathLength") end
	local okLen = true
	for i = 2, 10 do
		local want = lens[i - 1] + 70
		if lens[i] < want then okLen = false; mult[i] = mult[i] * math.min(1.6, (want + 40) / lens[i]) end
	end
	if lens[1] > 520 then okLen = false; mult[1] = mult[1] * 0.85 end
	if okLen then break end
end
-- menu titles + glow rings on every station
for _, w in workspace:GetChildren() do if w.Name:match("^World%d") and w:FindFirstChild("Hub") then R("MenuStyle")(K).apply(w.Hub) end end
local n = 0
for _, d in root:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
return "ok " .. WORLD .. " parts=" .. n .. " lens=" .. table.concat(lens, ",")
