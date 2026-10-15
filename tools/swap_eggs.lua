-- Replace the egg on every world's egg pedestal with the final Eggs3 design (keeps position/orientation)
local B = game.ServerStorage.MapBuilder
local CS = game:GetService("CollectionService")
local function R(n) local c = B[n]:Clone(); c.Parent = B; local ok, r = pcall(require, c); c:Destroy(); assert(ok, r); return r end
local K = R("MapKit"); local build = R("Eggs3")(K)
local names = { "Zoo", "Desert", "Snow", "Forest", "Volcano", "Space" }
local out = {}
for i, w in ipairs(names) do
	local world = workspace:FindFirstChild("World" .. i .. "_" .. w)
	local station = world and world.Hub:FindFirstChild("Eggs") and world.Hub.Eggs:FindFirstChildWhichIsA("Model")
	local old = station and station:FindFirstChild(w .. "Egg")
	if old then
		local cf = old:GetPivot()
		old:Destroy()
		local m = build(w, cf, station)
		CS:AddTag(m, "SpinEgg")
		m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		table.insert(out, w .. " ok")
	else
		table.insert(out, w .. " missing")
	end
end
-- clean copies for later / UI
local zm = game.ServerStorage:FindFirstChild("ZooModels")
if zm then
	local f = zm:FindFirstChild("Eggs") or Instance.new("Folder"); f.Name = "Eggs"; f.Parent = zm; f:ClearAllChildren()
	for _, w in ipairs(names) do build(w, CFrame.new(0, 10, 0), f) end
end
local lu = workspace:FindFirstChild("EggLineup"); if lu then lu:Destroy() end
return table.concat(out, ", ")
