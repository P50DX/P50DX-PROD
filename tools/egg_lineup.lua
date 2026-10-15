-- Builds both versions of every world egg side by side (top row = v1 mine, bottom row = v2 reference) for review.
local B = game.ServerStorage.MapBuilder
local function R(n) local c = B[n]:Clone(); c.Parent = B; local ok, r = pcall(require, c); c:Destroy(); assert(ok, r); return r end
local K = R("MapKit"); local build = R("Eggs2")(K)
local f = workspace:FindFirstChild("EggLineup"); if f then f:Destroy() end
f = Instance.new("Folder"); f.Name = "EggLineup"; f.Parent = workspace
local errs = {}
for i, w in ipairs({ "Zoo", "Desert", "Snow", "Forest", "Volcano", "Space" }) do
	for v = 1, 2 do
		local ok, e = pcall(build, w, v, CFrame.new(3000 + (i - 3.5) * 26, 420 + (v == 1 and 9 or -9), 600) * CFrame.Angles(0, math.rad(180), 0), f)
		if not ok then table.insert(errs, w .. v .. ": " .. tostring(e)) end
	end
end
return #errs == 0 and "ok" or table.concat(errs, "\n")
