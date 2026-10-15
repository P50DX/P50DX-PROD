local B = game.ServerStorage.MapBuilder
local function R(n) local c = B[n]:Clone(); c.Parent = B; local ok, r = pcall(require, c); c:Destroy(); assert(ok, r); return r end
local K = R("MapKit"); local P = R("Props")(K); local S = R("Stations")(K, P); local Obby = R("Obby")(K, P, S)
S.eggBuilder = R("Eggs3")(K)
S.shopBuilder = R("Shops2")(K, P, S) -- the toy-brick stall (version 2) is the chosen shop
-- the 6 world eggs as clean models for later worlds / UI
local zm = game.ServerStorage:FindFirstChild("ZooModels")
if zm then
	local f = zm:FindFirstChild("Eggs") or Instance.new("Folder"); f.Name = "Eggs"; f.Parent = zm; f:ClearAllChildren()
	for i, w in ipairs({ "Zoo", "Desert", "Snow", "Forest", "Volcano", "Space" }) do S.eggBuilder(w, CFrame.new(0, 10, 0), f) end
end
local cfg = (function() local c = game.ReplicatedStorage.ZooMapConfig:Clone(); c.Parent = B; local r = require(c); c:Destroy(); return r end)()
local O = Vector3.new(3000, 100, 0)
local old = workspace:FindFirstChild("World1_Zoo"); if old then old:Destroy() end
local ok, T = pcall(R("ZooHub"), K, P, S, cfg, O)
if not ok then return "hub " .. tostring(T) end
local ok2, err = pcall(R("ZooObby"), K, P, S, Obby, cfg, O, T)
if not ok2 then return "obby " .. tostring(err) end
-- menu titles + glow rings on every station
for _, w in workspace:GetChildren() do if w.Name:match("^World%d") and w:FindFirstChild("Hub") then R("MenuStyle")(K).apply(w.Hub) end end
local n = 0
for _, d in workspace.World1_Zoo:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
local info = ""
for i = 1, 10 do info = info .. " S" .. i .. "=" .. tostring(workspace.World1_Zoo.Obby["Stage" .. i]:GetAttribute("PathLength")) end
return "ok parts=" .. n .. info
