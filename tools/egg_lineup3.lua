local B = game.ServerStorage.MapBuilder
local function R(n) local c = B[n]:Clone(); c.Parent = B; local ok, r = pcall(require, c); c:Destroy(); assert(ok, r); return r end
local K = R("MapKit"); local build = R("Eggs3")(K)
local f = workspace:FindFirstChild("EggLineup"); if f then f:Destroy() end
f = Instance.new("Folder"); f.Name = "EggLineup"; f.Parent = workspace
local errs = {}
for i, w in ipairs({ "Zoo", "Desert", "Snow", "Forest", "Volcano", "Space" }) do
	local ok, e = pcall(build, w, CFrame.new(3000 + (i - 3.5) * 30, 420, 600) * CFrame.Angles(0, math.rad(180), 0), f)
	if not ok then table.insert(errs, w .. ": " .. tostring(e)) end
end
return #errs == 0 and "ok" or table.concat(errs, "\n")
