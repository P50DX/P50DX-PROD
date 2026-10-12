-- FastestStatue (Script -> ServerScriptService)
-- Puts the fastest player in the server on the "Fastest Runner" plinth: a frozen copy of THEIR animal
-- (same animal + version they are playing), with their name and Speed on the plaque. Updates every 10 s.
-- "Fastest" = leaderstats.Speed, else the player attribute "Speed", else leaderstats.Wins (test place).
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local function speedOf(p)
	local ls = p:FindFirstChild("leaderstats")
	local v = ls and ls:FindFirstChild("Speed")
	if v then return v.Value end
	if p:GetAttribute("Speed") then return p:GetAttribute("Speed") end
	local w = ls and ls:FindFirstChild("Wins")
	return w and w.Value or 0
end
local function fmt(n)
	if type(n) ~= "number" then return tostring(n) end
	for _, s in ipairs({ { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }) do
		if n >= s[1] then return string.format("%.2f%s", n / s[1], s[2]) end
	end
	return tostring(math.floor(n))
end

local shown = {} -- spot -> { userId, animal }
local function freeze(char)
	local was = char.Archivable
	char.Archivable = true
	local m = char:Clone()
	char.Archivable = was
	for _, d in m:GetDescendants() do
		if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Humanoid") or d:IsA("Sound") or d:IsA("BillboardGui") then d:Destroy()
		elseif d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false; d.CanTouch = false; d.CanQuery = false end
	end
	for _, t in CollectionService:GetTags(m) do CollectionService:RemoveTag(m, t) end -- not animated, not a rig
	return m
end

local function update()
	local best, bestV
	for _, p in Players:GetPlayers() do
		local v = speedOf(p)
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and (not bestV or v > bestV) then best, bestV = p, v end
	end
	for _, spot in CollectionService:GetTagged("FastestStatue") do
		local model = spot.Parent
		local plaque = model and model:FindFirstChild("Plaque")
		local who = plaque and plaque:FindFirstChild("Text", true) and plaque:FindFirstChild("Who", true)
		if best then
			local key = best.UserId .. ":" .. tostring(best.Character:GetAttribute("Animal")) .. ":" .. tostring(best.Character:GetAttribute("Variant"))
			if not shown[spot] or shown[spot].key ~= key then
				local old = model:FindFirstChild("Statue"); if old then old:Destroy() end
				local m = freeze(best.Character)
				m.Name = "Statue"
				local _, size = m:GetBoundingBox()
				local s = math.clamp(12 / math.max(size.X, size.Z, size.Y * 0.8), 0.6, 2.2)
				m:ScaleTo(m:GetScale() * s)
				local cf, sz = m:GetBoundingBox()
				m:PivotTo(CFrame.new(spot.Position) * (spot.CFrame - spot.Position) * CFrame.new(0, 0, 0))
				local cf2, sz2 = m:GetBoundingBox()
				m:PivotTo(m:GetPivot() + Vector3.new(0, (spot.Position.Y - spot.Size.Y / 2) - (cf2.Position.Y - sz2.Y / 2), 0) + (spot.Position - cf2.Position) * Vector3.new(1, 0, 1))
				m.Parent = model
				shown[spot] = { key = key }
			end
			if who then who.Text = best.DisplayName .. "  •  ⚡ " .. fmt(bestV) end
		elseif who then
			who.Text = "..."
		end
	end
end

task.spawn(function()
	while true do
		pcall(update)
		task.wait(10)
	end
end)
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(2); pcall(update) end) end)
