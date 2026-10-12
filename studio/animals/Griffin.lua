-- Griffin: lion body in gold, white eagle head with hooked gold beak and fierce eyes, feather tufts, white chest
-- feathers, big brown-gold wings, tufted lion tail.
local G, GD, WH, BK, BR = rgb(222, 166, 72), rgb(176, 120, 44), rgb(250, 250, 246), rgb(255, 196, 40), rgb(140, 92, 50)
local k = quad{col = G, belly = WH, pawCol = BK, W = 2.4, H = 2.2, L = 4.2, legH = 1.8, legW = 0.75, head = {1.7, 1.6, 1.6}, neckUp = 0.8, headFwd = 0.4, tailN = 4, tailW0 = 0.35, tailW1 = 0.3, tailLen = 0.8, tailCols = {G}, tailCurl = 8}
local f, c = k.face, k.head
add("Head", V(1.7, 1.6, 1.6), c, WH, {studs = true})
add("Head", V(0.7, 0.55, 0.7), V(0, c.Y - 0.1, f - 0.3), BK); add("Head", V(0.45, 0.4, 0.3), V(0, c.Y - 0.45, f - 0.6), rgb(210, 150, 30))
both(function(sx, s)
	eye("Head", sx * 0.48, c.Y + 0.3, f - 0.02, 0.36, "sharp", rgb(255, 170, 30)); brow("Head", sx * 0.5, c.Y + 0.6, f - 0.04, 0.5, BR, 20)
	add("Ear" .. s, V(0.25, 0.7, 0.4), V(sx * 0.55, c.Y + 1.05, c.Z + 0.4), WH, {rot = {-25, 0, sx * -15}})
	joint("Ear" .. s, "Head", V(sx * 0.55, c.Y + 0.8, c.Z + 0.4))
	local sh = V(sx * 1.0, k.by + 0.9, -1.0)
	for i = 0, 3 do
		local len = 4.2 - i * 0.65
		local a = sh + V(sx * 0.2, -i * 0.1, i * 0.35)
		rod("Wing" .. s, a, a + V(sx * len * 0.75, len * 0.55, len * 0.35), 1.1, i % 2 == 0 and BR or G, {h = 0.2})
	end
	rod("Wing" .. s, sh, sh + V(sx * 2.3, 1.7, 1.0), 0.2, WH, {h = 0.28})
	joint("Wing" .. s, "Torso", sh)
end)
add("Torso", V(1.8, 1.6, 0.3), V(0, k.by + 0.2, -4.2 * 0.2 - 4.2 * 0.55 / 2 - 0.1), WH)             -- chest feathers
add("Tail4", V(0.55, 0.55, 0.55), tipOf("Tail4"), BR)
return {name = "Griffin", parts = P, joints = J, hrpSize = V(2.6, 5.4, 4.6), hrpPos = V(0, 2.7, 0)}
