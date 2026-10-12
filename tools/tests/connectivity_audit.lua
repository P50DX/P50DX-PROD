local TOL = 0.06
local function axes(cf) return {cf.RightVector, cf.UpVector, cf.LookVector} end
local function proj(cf, half, ax)
	local r = cf.RightVector:Dot(ax) * half.X; local u = cf.UpVector:Dot(ax) * half.Y; local l = cf.LookVector:Dot(ax) * half.Z
	return math.abs(r) + math.abs(u) + math.abs(l)
end
local function touch(a, b)
	local ca, cb = a.CFrame, b.CFrame
	local ha, hb = a.Size / 2 + Vector3.one * TOL, b.Size / 2 + Vector3.one * TOL
	local d = cb.Position - ca.Position
	if d.Magnitude > ha.Magnitude + hb.Magnitude then return false end
	local A, B = axes(ca), axes(cb)
	local list = {A[1], A[2], A[3], B[1], B[2], B[3]}
	for i = 1, 3 do for j = 1, 3 do local c = A[i]:Cross(B[j]); if c.Magnitude > 1e-4 then table.insert(list, c.Unit) end end end
	for _, ax in ipairs(list) do
		if math.abs(d:Dot(ax)) > proj(ca, ha, ax) + proj(cb, hb, ax) then return false end
	end
	return true
end
local out = {}
for _, m in ipairs(workspace:GetChildren()) do
	if m:IsA("Model") and m:GetAttribute("PartCount") and not m.Name:find("_") then
		local ps = {}
		for _, d in ipairs(m:GetDescendants()) do if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and d.Transparency < 0.9 then table.insert(ps, d) end end
		local par = {}
		for i = 1, #ps do par[i] = i end
		local function f(i) while par[i] ~= i do par[i] = par[par[i]]; i = par[i] end return i end
		for i = 1, #ps do for j = i + 1, #ps do if f(i) ~= f(j) and touch(ps[i], ps[j]) then par[f(i)] = f(j) end end end
		local comps = {}
		for i = 1, #ps do local r = f(i); comps[r] = comps[r] or {}; table.insert(comps[r], ps[i]) end
		local main, best = nil, 0
		for r, c in pairs(comps) do if #c > best then best = #c; main = r end end
		local bad = {}
		local piv = m:GetPivot().Position
		for r, c in pairs(comps) do if r ~= main then
			local p = c[1]; local g = p.Parent:IsA("Model") and p.Name or p.Parent.Name
			local lp = p.Position - Vector3.new(piv.X, 0, piv.Z)
			table.insert(bad, ("%s[%d]@%.1f,%.1f,%.1f"):format(g, #c, lp.X, lp.Y, lp.Z))
		end end
		if #bad > 0 then table.insert(out, m.Name .. ": " .. table.concat(bad, " ")) end
	end
end
return #out .. " models with loose pieces\n" .. table.concat(out, "\n")
