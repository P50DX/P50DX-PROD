-- samples how much every NPC's joints move in each test phase (sum of joint angles, max over the phase)
local RS = game:GetService("RunService")
local res = {}
local t0 = os.clock()
while workspace:GetAttribute("TestPhase") == nil and os.clock() - t0 < 30 do task.wait(0.1) end
local folder = workspace:WaitForChild("MotionTest", 20)
local conn = RS.Heartbeat:Connect(function()
	local ph = workspace:GetAttribute("TestPhase")
	if not ph or ph == "done" then return end
	for _, m in ipairs(folder:GetChildren()) do
		local sum = 0
		for _, j in ipairs(m:GetDescendants()) do
			if j:IsA("Motor6D") and j.Name ~= "Torso" then
				local _, ang = j.Transform:ToAxisAngle(); sum += math.abs(ang)
			end
		end
		local r = res[m.Name] or {}; res[m.Name] = r
		r[ph] = math.max(r[ph] or 0, sum)
	end
end)
while workspace:GetAttribute("TestPhase") ~= "done" and os.clock() - t0 < 90 do task.wait(0.2) end
conn:Disconnect()
local lines, low = {}, {}
for name, r in pairs(res) do
	local i, w, rn, j, f = r.idle or 0, r.walk or 0, r.run or 0, r.jump or 0, r.fall or 0
	table.insert(lines, ("%s i%.2f w%.2f r%.2f j%.2f f%.2f"):format(name, i, w, rn, j, f))
	if w < 0.3 or rn < 0.3 or j < 0.2 or f < 0.2 or i < 0.05 then table.insert(low, name) end
end
table.sort(lines)
return #lines .. " models sampled\nLOW: " .. table.concat(low, ", ") .. "\n" .. table.concat(lines, "\n")
