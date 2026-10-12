local B = game.ServerStorage.MapBuilder
local function R(n) local c = B[n]:Clone(); c.Parent = B; local ok, r = pcall(require, c); c:Destroy(); assert(ok, r); return r end
local K = R("MapKit"); local P = R("Props")(K); local S = R("Stations")(K, P)
local ok, err = pcall(R("Race"), K, P, S, Vector3.new(3000, 100, 2600))
local n = 0; for _, d in workspace.RaceMap:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
return tostring(ok) .. " " .. tostring(err) .. " parts=" .. n
