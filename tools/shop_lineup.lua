-- Review lineup: every theme, version 1 (left) and version 2 (right), on floating ground plates
local B = game.ServerStorage.MapBuilder
local function R(n) local c = B[n]:Clone(); c.Parent = B; local ok, r = pcall(require, c); c:Destroy(); assert(ok, r); return r end
local K = R("MapKit"); local P = R("Props")(K); local S = R("Stations")(K, P); local build = R("Shops2")(K, P, S)
local f = workspace:FindFirstChild("ShopLineup"); if f then f:Destroy() end
f = Instance.new("Folder"); f.Name = "ShopLineup"; f.Parent = workspace
local cols = { Zoo = Color3.fromRGB(255, 130, 40), Desert = Color3.fromRGB(46, 176, 176), Snow = Color3.fromRGB(230, 80, 80), Forest = Color3.fromRGB(220, 110, 50), Volcano = Color3.fromRGB(230, 90, 40), Space = Color3.fromRGB(255, 110, 200) }
local errs = {}
for i, th in ipairs({ "Zoo", "Desert", "Snow", "Forest", "Volcano", "Space" }) do
	for v = 1, 2 do
		local x = 3000 + (i - 1) * 110 + (v - 1) * 46
		local ok, e = pcall(build, th, v, CFrame.new(x, 400, 1200), { id = th .. v, title = "ANIMAL SHOP", color = cols[th], iconKind = "paw" }, f)
		if not ok then table.insert(errs, th .. v .. ": " .. tostring(e)) end
	end
end
return #errs == 0 and "ok" or table.concat(errs, "\n")
