-- Mammoth: giant shaggy brown, high domed head, long curling tusks, trunk, small ears, sloped back, hairy legs.
local B, BD, BL, TU = rgb(122, 78, 48), rgb(86, 52, 30), rgb(160, 110, 72), rgb(248, 238, 210)
local k = quad{col = B, belly = BD, pawCol = rgb(60, 50, 44), W = 3.6, H = 3.2, L = 5.0, legH = 2.4, legW = 1.2, head = {2.6, 2.6, 2.2}, neckUp = 0.2, headFwd = 0.3, tailN = 2, tailW0 = 0.35, tailW1 = 0.3, tailLen = 0.6, tailCols = {BD}, tailCurl = -30}
local f, c = k.face, k.head
add("Head", V(2.4, 1.0, 1.8), V(0, c.Y + 1.5, c.Z + 0.2), B, {studs = true})                  -- domed head
add("Torso", V(3.4, 1.4, 2.4), V(0, k.by + 1.9, -1.0), B, {studs = true})                     -- shoulder hump
eye("Head", 0.7, c.Y + 0.5, f, 0.36, "cute"); eye("Head", -0.7, c.Y + 0.5, f, 0.36, "cute")
-- trunk: rods hanging down and curling forward
local t0 = V(0, c.Y - 0.2, f - 0.2); local t1, t2, t3 = t0 + V(0, -1.3, -0.4), t0 + V(0, -2.5, -0.4), t0 + V(0, -3.2, -0.9)
rod("Head", t0, t1, 0.9, B); rod("Head", t1, t2, 0.75, B); rod("Head", t2, t3, 0.6, B)
-- tusks: long sweeping curves
both(function(sx)
	local a = V(sx * 0.7, c.Y - 0.6, f - 0.1)
	local b, cc, d = a + V(sx * 0.3, -0.75, -0.45), a + V(sx * 0.45, -0.7, -1.1), a + V(sx * 0.25, -0.1, -1.5)   -- shorter, curling up
	rod("Head", a, b, 0.42, TU); rod("Head", b, cc, 0.36, TU); rod("Head", cc, d, 0.28, TU)
	add("Head", V(0.3, 1.0, 0.8), V(sx * 1.4, c.Y + 0.3, c.Z + 0.3), BD)                       -- small ear
end)
-- shaggy fringe hanging off the belly + legs
for i = 0, 5 do both(function(sx) add("Torso", V(0.3, 0.8, 0.7), V(sx * 1.85, k.by - 1.2, -2.0 + i * 0.8), BD) end) end
return {name = "Mammoth", parts = P, joints = J, hrpSize = V(4, 8, 6.4), hrpPos = V(0, 4, 0)}
