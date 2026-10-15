-- Replace every hub shop with the Shops2 toy-brick stall (user's reference version) in that world's theme.
local B = game.ServerStorage.MapBuilder
local function R(n) local c = B[n]:Clone(); c.Parent = B; local ok, r = pcall(require, c); c:Destroy(); assert(ok, r); return r end
local K = R("MapKit"); local P = R("Props")(K); local S = R("Stations")(K, P); local build = R("Shops2")(K, P, S); local MS = R("MenuStyle")(K)
local KIND = { Animals = "paw", Boosts = "potion", Premium = "gem" }
local TITLE = { Animals = "ANIMAL SHOP", Boosts = "BOOST SHOP", Premium = "PREMIUM SHOP" }
local out = {}
for _, w in workspace:GetChildren() do
	local theme = w.Name:match("^World%d_(%a+)$")
	if theme and w:FindFirstChild("Hub") then
		local n = 0
		for _, shop in w.Hub.Shops:GetChildren() do
			local id = shop.Name:match("^Shop_(%a+)$")
			local trig = shop:FindFirstChild("Interact")
			if id and trig then
				local cf = trig.CFrame * CFrame.new(0, -4, 9)
				local c = Color3.fromRGB(255, 170, 60)
				local icon = shop:FindFirstChild("ShopIcon")
				if icon then for _, q in icon:GetDescendants() do if q:IsA("ParticleEmitter") and q.Name == "Sparkle" then c = q.Color.Keypoints[1].Value end end end
				shop:Destroy()
				build(theme, 2, cf, { id = id, title = TITLE[id] or id, color = c, iconKind = KIND[id] or "gem" }, w.Hub.Shops)
				n += 1
			end
		end
		-- tidy loose shop props left at the old spots (Zoo crates/barrels in front of the old kiosks)
		MS.apply(w.Hub)
		table.insert(out, theme .. "=" .. n)
	end
end
local lu = workspace:FindFirstChild("ShopLineup"); if lu then lu:Destroy() end
return table.concat(out, " ")
