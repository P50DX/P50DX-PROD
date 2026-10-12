-- Elephant: big grey body, huge flapping ears with pink inside, long curled trunk, short tusks, cute eyes, toenails.
local G, GD, GL, TU = rgb(150, 160, 176), rgb(110, 118, 134), rgb(184, 192, 206), rgb(250, 244, 226)
local k = quad{col = G, belly = GD, pawCol = GL, W = 3.4, H = 3.0, L = 4.8, legH = 2.0, legW = 1.2, head = {2.4, 2.3, 2.0}, neckUp = 0.2, headFwd = 0.4, tailN = 2, tailW0 = 0.3, tailW1 = 0.25, tailLen = 0.6, tailCols = {GD}, tailCurl = -40}
local f, c = k.face, k.head
add("Head", V(2.2, 0.6, 1.8), V(0, c.Y + 1.3, c.Z + 0.1), G, {studs = true})               -- forehead dome
local t0 = V(0, c.Y - 0.3, f - 0.3); local t1, t2, t3 = t0 + V(0, -1.0, -0.4), t0 + V(0, -1.9, -0.6), t0 + V(0, -2.2, -1.2)
rod("Head", t0, t1, 0.85, G); rod("Head", t1, t2, 0.7, G); rod("Head", t2, t3, 0.55, GD)
both(function(sx, s)
	eye("Head", sx * 0.62, c.Y + 0.35, f, 0.4, "cute")
	add("Head", V(0.4, 0.15, 0.06), V(sx * 0.9, c.Y - 0.1, f - 0.02), PINK)
	rod("Head", V(sx * 0.6, c.Y - 0.6, f - 0.1), V(sx * 0.7, c.Y - 1.0, f - 0.9), 0.3, TU)       -- tusks
	add("Ear" .. s, V(0.25, 2.4, 2.0), V(sx * 1.6, c.Y + 0.1, c.Z + 0.4), G, {studs = true, rot = {0, sx * -25, 0}})
	add("Ear" .. s, V(0.08, 1.8, 1.4), V(sx * 1.5, c.Y + 0.1, c.Z + 0.1), PINK, {rot = {0, sx * -25, 0}})
	joint("Ear" .. s, "Head", V(sx * 1.2, c.Y + 0.1, c.Z))
end)
for _, leg in ipairs({{"FL", 1, -1}, {"FR", -1, -1}, {"BL", 1, 1}, {"BR", -1, 1}}) do
	local x, z = leg[2] * (3.4 / 2 - 0.6), leg[3] * (4.8 / 2 - 0.84)
	for _, dx in ipairs({-0.35, 0, 0.35}) do add("Leg" .. leg[1], V(0.25, 0.22, 0.1), V(x + dx, 0.2, z - 0.85), TU) end
end
return {name = "Elephant", parts = P, joints = J, hrpSize = V(3.6, 7, 6), hrpPos = V(0, 3.5, 0)}
