-- MenuStyle: gives every station that opens a menu (shops, eggs, Version Wheel, speed upgrades) and the treadmills
-- the big yellow outlined title + a glowing ring on the floor. apply(hub) is safe to run again (replaces old ones).
return function(K)
	local V = Vector3.new
	local M = {}

	local function anchor(parent, pos, name)
		local old = parent:FindFirstChild(name); if old then old:Destroy() end
		return K.part(V(1, 1, 1), CFrame.new(pos), Color3.new(1, 1, 1), { parent = parent, transp = 1, collide = false, name = name })
	end
	local function ring(parent, pos, r)
		local old = parent:FindFirstChild("GlowRing"); if old then old:Destroy() end
		return K.glowRing(CFrame.new(pos), r, parent)
	end
	local function killBillboards(inst) for _, d in inst:GetDescendants() do if d:IsA("BillboardGui") and d.Name ~= "MenuLabel" then d:Destroy() end end end

	local function clear(model)
		for _, nm in ipairs({ "GlowRing", "LabelAnchor" }) do local o = model:FindFirstChild(nm); if o then o:Destroy() end end
	end
	function M.apply(hub)
		local n = 0
		-- shops
		local shops = hub:FindFirstChild("Shops") or (hub.Name == "ShopLineup" and hub)
		if shops then
			for _, shop in shops:GetChildren() do
				if shop:IsA("Model") and shop.Name:match("^Shop_") then
					local pp = shop:FindFirstChildWhichIsA("ProximityPrompt", true)
					local title = pp and pp.ObjectText or "SHOP"
					clear(shop)
					local cf, size = shop:GetBoundingBox()
					local floorY = cf.Position.Y - size.Y / 2
					local icon = shop:FindFirstChild("Icon"); if icon then icon:Destroy() end
					local a = anchor(shop, V(cf.Position.X, cf.Position.Y + size.Y / 2 + 2, cf.Position.Z), "LabelAnchor")
					K.menuLabel(a, title, { offset = V(0, 4, 0), width = #title * 2.7, height = 6.5, dist = 320 })
					ring(shop, V(cf.Position.X, floorY, cf.Position.Z), math.max(size.X, size.Z) / 2 + 4)
					n += 1
				end
			end
		end
		-- egg station
		local eggs = hub:FindFirstChild("Eggs")
		local st = eggs and eggs:FindFirstChildWhichIsA("Model")
		if st then
			local sign = st:FindFirstChild("Sign")
			local pp = st:FindFirstChildWhichIsA("ProximityPrompt", true)
			local price = ""
			if sign then
				for _, d in sign:GetDescendants() do if d:IsA("TextLabel") and d.Name == "Price" then price = d.Text end end
				killBillboards(sign)
				K.menuLabel(sign, (pp and pp.ObjectText or "EGG"):upper(), { sub = price, offset = V(0, 1, 0), width = 22, height = 7.5, dist = 320 })
			end
			clear(st)
			local cf, size = st:GetBoundingBox()
			ring(st, V(cf.Position.X, cf.Position.Y - size.Y / 2, cf.Position.Z), 15.5)
			n += 1
		end
		-- version wheel
		local wheel = hub:FindFirstChild("Wheel")
		local vw = wheel and wheel:FindFirstChild("VersionWheel")
		if vw then
			killBillboards(vw)
			clear(vw)
			local cf, size = vw:GetBoundingBox()
			local a = anchor(vw, V(cf.Position.X, cf.Position.Y + size.Y / 2 + 1, cf.Position.Z), "LabelAnchor")
			K.menuLabel(a, "VERSION WHEEL", { sub = "Spin for a new version!", offset = V(0, 2, 0), width = 30, height = 8, dist = 360 })
			ring(vw, V(cf.Position.X, cf.Position.Y - size.Y / 2, cf.Position.Z), 19.5)
			n += 1
		end
		-- speed upgrades (one big title over the area)
		local su = hub:FindFirstChild("SpeedUpgrades")
		if su then
			local floor = su:FindFirstChild("Floor")
			if floor then
				local a = anchor(su, floor.Position + V(0, 40, 0), "LabelAnchor")
				K.menuLabel(a, "SPEED UPGRADES", { width = 34, height = 8, dist = 500, offset = V(0, 2, 0) })
				n += 1
			end
		end
		-- treadmills: big title over the training centre + a small label on each treadmill
		local tm = hub:FindFirstChild("Treadmills")
		if tm then
			local floor = tm:FindFirstChild("Floor")
			if floor then
				local a = anchor(tm, floor.Position + V(0, 42, 0), "LabelAnchor")
				K.menuLabel(a, "TREADMILLS", { width = 30, height = 8, dist = 500, offset = V(0, 2, 0) })
			end
			for _, t in tm:GetChildren() do
				if t:IsA("Model") and t.Name:match("^Treadmill") then
					local belt = t:FindFirstChild("Belt")
					if belt then
						local mult = belt:GetAttribute("Multiplier")
						K.menuLabel(belt, "x" .. tostring(mult) .. " SPEED", { width = 13, height = 3.8, dist = 160, offset = V(0, 14, 0), stroke = 4 })
						n += 1
					end
				end
			end
		end
		return n
	end
	return M
end
