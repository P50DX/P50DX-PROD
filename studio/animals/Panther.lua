-- Panther: sleek glossy black big cat, glowing green eyes, faint rosettes, long low tail, lean muscular shoulders.
local B, BD, BL, GR = rgb(36, 34, 42), rgb(22, 20, 28), rgb(58, 56, 68), rgb(120, 255, 120)
local k = quad{claws = rgb(230, 230, 230), col = B, belly = BD, pawCol = BD, W = 2.0, H = 1.8, L = 4.2, legH = 1.7, legW = 0.65, head = {1.8, 1.5, 1.6}, neckUp = 0.4, tailN = 6, tailW0 = 0.5, tailW1 = 0.35, tailLen = 0.85, tailCols = {B, BD}, tailCurl = 4}
local f, c = k.face, k.head
both(function(sx)
	local e = V(sx * 0.45, c.Y + 0.2, f)
	add("Head", V(0.5, 0.35, 0.06), e, BD); add("Head", V(0.42, 0.28, 0.06), e + V(0, 0, -0.02), GR, {neon = true}); add("Head", V(0.1, 0.28, 0.06), e + V(0, 0, -0.04), BLACK)
	brow("Head", sx * 0.47, c.Y + 0.48, f, 0.6, BL, 18)
end)
add("Head", V(0.9, 0.5, 0.5), V(0, c.Y - 0.35, f - 0.22), BL); add("Head", V(0.32, 0.2, 0.15), V(0, c.Y - 0.18, f - 0.5), BD)
add("Head", V(0.1, 0.18, 0.06), V(0.2, c.Y - 0.62, f - 0.48), WHITE); add("Head", V(0.1, 0.18, 0.06), V(-0.2, c.Y - 0.62, f - 0.48), WHITE)
ears(k, "round", B, BL, 0.45, 0.45, 0.33)
for _, p in ipairs({{1.02, 0.3, -1.4}, {1.02, -0.2, -0.5}, {0.92, 0.25, 0.5}, {0.92, -0.15, 1.4}}) do both(function(sx) add("Torso", V(0.08, 0.4, 0.4), V(sx * p[1], k.by + p[2], p[3]), BL) end) end
return {name = "Panther", parts = P, joints = J, hrpSize = V(2.2, 4, 4.6), hrpPos = V(0, 2, 0)}
