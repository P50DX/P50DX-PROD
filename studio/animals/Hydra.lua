-- Hydra (scary): teal-green four-legged serpent with three necks, each head with glowing red eyes, fangs and
-- horns; spiked back and tail.
local G, GD, BE, HN, RED = rgb(40, 140, 110), rgb(24, 90, 74), rgb(206, 222, 150), rgb(236, 226, 196), rgb(255, 40, 40)
local k = quad{col = G, belly = BE, pawCol = GD, W = 3.0, H = 2.4, L = 4.2, legH = 1.4, legW = 0.95, head = {1.4, 1.2, 1.6}, neckUp = 2.6, headFwd = 0.4, tailN = 5, tailW0 = 0.9, tailW1 = 0.35, tailLen = 0.9, tailCols = {G, GD}, tailCurl = -3}
local function head(g, c, block)
	if block then add(g, V(1.4, 1.2, 1.6), c, G, {studs = true}) end
	local f = c.Z - 0.8
	add(g, V(1.0, 0.6, 1.0), c + V(0, -0.3, -1.2), G)
	add(g, V(0.9, 0.08, 0.06), V(c.X, c.Y - 0.45, f - 0.93), BLACK)
	for _, x in ipairs({-0.3, 0.3}) do add(g, V(0.12, 0.22, 0.06), V(c.X + x, c.Y - 0.55, f - 0.95), WHITE, {shape = "wedge", rot = {0, 0, 180}}) end
	both(function(sx)
		local e = V(c.X + sx * 0.4, c.Y + 0.22, f - 0.03)
		add(g, V(0.42, 0.3, 0.06), e, BLACK); add(g, V(0.32, 0.2, 0.06), e + V(0, 0, -0.02), RED, {neon = true}); add(g, V(0.08, 0.2, 0.06), e + V(0, 0, -0.04), BLACK)
		add(g, V(0.55, 0.16, 0.2), e + V(0, 0.22, 0.02), GD, {rot = {0, 0, sx * 22}})
		rod(g, V(c.X + sx * 0.45, c.Y + 0.55, c.Z + 0.3), V(c.X + sx * 0.6, c.Y + 1.1, c.Z + 0.9), 0.24, HN)
	end)
end
head("Head", k.head, false)
both(function(sx, s)
	local c2 = V(sx * 2.1, 5.3, -2.5)
	rod("Head" .. s, V(sx * 0.9, k.by + 0.6, -1.6), c2 + V(0, -0.2, 0.3), 0.9, G)
	head("Head" .. s, c2, true)
	joint("Head" .. s, "Torso", V(sx * 0.9, k.by + 0.6, -1.6))
end)
for i = 0, 5 do add("Torso", V(0.3, 0.55, 0.5), V(0, k.by + 1.45, -1.6 + i * 0.6), HN, {shape = "wedge", rot = {0, 180, 0}}) end
return {name = "Hydra", parts = P, joints = J, hrpSize = V(5, 7, 5), hrpPos = V(0, 3.5, 0)}
