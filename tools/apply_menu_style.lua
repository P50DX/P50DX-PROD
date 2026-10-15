local B = game.ServerStorage.MapBuilder
local function R(n) local c = B[n]:Clone(); c.Parent = B; local ok, r = pcall(require, c); c:Destroy(); assert(ok, r); return r end
local K = R("MapKit"); local MS = R("MenuStyle")(K)
local out = {}
for _, w in workspace:GetChildren() do
	if w.Name:match("^World%d") and w:FindFirstChild("Hub") then table.insert(out, w.Name .. "=" .. MS.apply(w.Hub)) end
end
if workspace:FindFirstChild("ShopLineup") then table.insert(out, "lineup=" .. MS.apply(workspace.ShopLineup)) end
return table.concat(out, " ")
