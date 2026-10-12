-- Dragon: powerful red quadruped dragon - horned head with jaw + fangs, glowing slit eyes under heavy brows,
-- spiked back ridge, big bat wings (arm bones + membrane panels), clawed feet, spiked tail.
local R, RD, BEL, HN, MEM, EYE = rgb(196, 44, 36), rgb(128, 24, 24), rgb(244, 196, 110), rgb(240, 228, 196), rgb(150, 30, 34), rgb(255, 210, 40)
local k = quad{col = R, belly = BEL, pawCol = RD, W = 2.6, H = 2.4, L = 4.4, legH = 1.8, legW = 0.85, head = {2.1, 1.7, 2.0}, neckUp = 1.4, headFwd = 0.8, tailN = 6, tailW0 = 1.0, tailW1 = 0.4, tailLen = 1.0, tailCols = {R, RD}, tailCurl = -4}
local f, c = k.face, k.head
-- jaw: snout + lower jaw with fangs
add("Head", V(1.5, 0.75, 1.3), V(0, c.Y - 0.15, f - 0.6), R, {studs = true})
add("Head", V(1.4, 0.4, 1.2), V(0, c.Y - 0.75, f - 0.5), BEL)
add("Head", V(1.3, 0.12, 0.06), V(0, c.Y - 0.55, f - 1.25), BLACK)
for _, x in ipairs({-0.5, -0.2, 0.2, 0.5}) do add("Head", V(0.14, 0.28, 0.1), V(x, c.Y - 0.67, f - 1.24), WHITE) end
both(function(sx) add("Head", V(0.2, 0.15, 0.06), V(sx * 0.35, c.Y + 0.15, f - 1.27), BLACK) end)   -- nostrils
-- eyes: glowing slit eyes with heavy angry brows
both(function(sx)
	local e = V(sx * 0.6, c.Y + 0.35, f)
	add("Head", V(0.55, 0.4, 0.06), e, BLACK); add("Head", V(0.45, 0.3, 0.06), e + V(0, 0, -0.02), EYE, {neon = true}); add("Head", V(0.1, 0.3, 0.06), e + V(0, 0, -0.04), BLACK)
	add("Head", V(0.8, 0.25, 0.3), e + V(0, 0.32, 0.05), RD, {rot = {0, 0, sx * 22}})
	-- horns: two-stage swept back
	local b = V(sx * 0.6, c.Y + 0.85, c.Z + 0.3)
	rod("Head", b, b + V(sx * 0.3, 0.8, 0.7), 0.4, HN); rod("Head", b + V(sx * 0.3, 0.8, 0.7), b + V(sx * 0.4, 1.1, 1.6), 0.25, HN)
	add("Head", V(0.35, 0.2, 0.5), V(sx * 1.1, c.Y + 0.2, c.Z + 0.5), RD, {rot = {0, sx * 30, 0}})   -- cheek frill
end)
-- back spikes
for i = 0, 6 do add("Torso", V(0.3, 0.55 - math.abs(i - 3) * 0.05, 0.5), V(0, k.by + 1.45, -1.8 + i * 0.6), HN, {shape = "wedge", rot = {0, 180, 0}}) end

-- wings: arm bone (rods) + two membrane panels, attached at the shoulders
both(function(sx, s)
	local sh = V(sx * 1.1, k.by + 1.1, -1.0)
	local el, tip = sh + V(sx * 1.8, 1.4, 0.6), sh + V(sx * 3.8, 1.9, 1.4)
	rod("Wing" .. s, sh, el, 0.35, RD); rod("Wing" .. s, el, tip, 0.25, RD)
	add("Wing" .. s, V(1.9, 2.0, 0.12), (sh + el) / 2 + V(0, -0.7, 0.9), MEM, {rot = {-15, 0, sx * -20}})
	add("Wing" .. s, V(2.0, 2.2, 0.12), (el + tip) / 2 + V(0, -0.9, 0.9), MEM, {rot = {-15, 0, sx * -10}})
	add("Wing" .. s, V(0.3, 0.3, 0.3), tip, HN)
	joint("Wing" .. s, "Torso", sh)
end)
-- claws on every foot
for _, leg in ipairs({{"FL", 1, -1}, {"FR", -1, -1}, {"BL", 1, 1}, {"BR", -1, 1}}) do
	local x, z = leg[2] * (2.6 / 2 - 0.425), leg[3] * (4.4 / 2 - 0.6)
	for _, dx in ipairs({-0.25, 0, 0.25}) do add("Leg" .. leg[1], V(0.14, 0.18, 0.25), V(x + dx, 0.1, z - 0.7), HN) end
end
local tt = tipOf("Tail6")                                                                       -- tail spade on the tip
add("Tail6", V(1.0, 0.18, 0.7), tt + V(0, 0, 0.25), HN, {rot = {0, 45, 0}}); add("Tail6", V(0.5, 0.2, 0.5), tt, HN)
return {name = "Dragon", parts = P, joints = J, hrpSize = V(3, 5.6, 5), hrpPos = V(0, 2.8, 0)}
