-- Turn every hub shop 180 degrees around its own centre
local n = 0
for _, w in workspace:GetChildren() do
	if w.Name:match("^World%d") and w:FindFirstChild("Hub") then
		for _, shop in w.Hub.Shops:GetChildren() do
			if shop:IsA("Model") and shop.Name:match("^Shop_") then
				local trig = shop:FindFirstChild("Interact")
				local base = trig.CFrame * CFrame.new(0, -4, 9) -- the stall's own origin (centre, floor)
				local turn = CFrame.new(base.Position) * CFrame.Angles(0, math.pi, 0) * CFrame.new(-base.Position)
				for _, d in shop:GetDescendants() do
					if d:IsA("BasePart") then d.CFrame = turn * d.CFrame end
				end
				n += 1
			end
		end
	end
end
return n
