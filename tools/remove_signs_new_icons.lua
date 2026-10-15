-- Live patch: remove shop name boards (+ backing + lamps) and the SPEED UPGRADES / TRAINING CENTER boards,
-- swap every shop's rooftop icon for the new paw / potion / gem, then re-apply MenuStyle titles.
local B = game.ServerStorage.MapBuilder
local function R(n) local c = B[n]:Clone(); c.Parent = B; local ok, r = pcall(require, c); c:Destroy(); assert(ok, r); return r end
local K = R("MapKit"); local P = R("Props")(K); local S = R("Stations")(K, P); local MS = R("MenuStyle")(K)
local function textOf(part)
	for _, d in part:GetDescendants() do if d:IsA("TextLabel") then return d.Text end end
end
local KIND = { Animals = "paw", Boosts = "potion", Premium = "gem" }
local removed, icons = 0, 0
for _, w in workspace:GetChildren() do
	if w.Name:match("^World%d") and w:FindFirstChild("Hub") then
		local hub = w.Hub
		-- shops
		for _, shop in hub.Shops:GetChildren() do
			if shop:IsA("Model") and shop.Name:match("^Shop_") then
				local accent
				for _, part in shop:GetChildren() do
					if part:IsA("BasePart") and part:FindFirstChildOfClass("SurfaceGui") and (textOf(part) or ""):find("SHOP") then
						for _, q in shop:GetChildren() do -- backing plate right behind the board
							if q:IsA("BasePart") and q ~= part and (q.Position - part.Position).Magnitude < 1 and q.Size.Y > 6 then accent = q.Color; q:Destroy() end
						end
						part:Destroy(); removed += 1
					end
				end
				for _, q in shop:GetChildren() do -- the two little sign lamps
					if q:IsA("BasePart") and q.Material == Enum.Material.Neon and q.Size == Vector3.new(1.4, 1.4, 1.4) then q:Destroy() end
				end
				local old = shop:FindFirstChild("ShopIcon")
				local key = shop.Name:gsub("Shop_", "")
				local trig = shop:FindFirstChild("Interact")
				if old and trig then
					local pos = old:GetBoundingBox().Position
					local rot = trig.CFrame - trig.Position
					local c = accent
					if not c then for _, q in old:GetDescendants() do if q:IsA("BasePart") and q.Material == Enum.Material.Neon then c = q.Color break end end end
					old:Destroy()
					S.shopIcon(KIND[key] or "gem", CFrame.new(pos) * rot, c or Color3.fromRGB(255, 170, 60), shop)
					icons += 1
				end
			end
		end
		-- speed upgrades / training centre boards (+ their middle post), closed off with a beam
		for _, area in ipairs({ hub:FindFirstChild("SpeedUpgrades"), hub:FindFirstChild("Treadmills") }) do
			if area then
				for _, part in area:GetChildren() do
					local t = part:IsA("BasePart") and part:FindFirstChildOfClass("SurfaceGui") and textOf(part) or ""
					if t:find("SPEED UPGRADES") or t:find("TRAINING CENTER") then
						local postColor, len = nil, part.Size.Z * 2
						for _, q in area:GetChildren() do
							if q:IsA("BasePart") and q ~= part then
								local dxz = Vector3.new(q.Position.X - part.Position.X, 0, q.Position.Z - part.Position.Z).Magnitude
								if dxz < 1 and (q.Position - part.Position).Magnitude < 1 then q:Destroy() -- backing
								elseif dxz < 1 and q.Size.Y >= 30 and q.Size.X <= 5 then postColor = q.Color; q:Destroy() end -- middle post
							end
						end
						K.part(Vector3.new(3, 2.4, len), CFrame.new(part.Position.X, part.Position.Y + 5.5, part.Position.Z), postColor or Color3.fromRGB(52, 58, 82), { parent = area, studs = true, name = "Beam" })
						part:Destroy(); removed += 1
					end
				end
			end
		end
		MS.apply(hub)
	end
end
return "boards removed=" .. removed .. " icons=" .. icons
