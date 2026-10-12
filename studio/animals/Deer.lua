-- Deer: slim, long legs, white spotted back (fawn spots), cream chest, branching antlers, little white tail.
local B, BD, CR, AN = rgb(186, 120, 66), rgb(140, 84, 44), rgb(246, 228, 200), rgb(236, 220, 186)
local k = quad{col = B, belly = CR, pawCol = rgb(50, 40, 34), W = 1.7, H = 1.7, L = 3.4, legH = 2.2, legW = 0.48, head = {1.5, 1.5, 1.6}, neckUp = 1.2, tailN = 1, tailW0 = 0.45, tailW1 = 0.45, tailLen = 0.4, tailCols = {WHITE}, tailCurl = 30}
face(k, {eyeS = 0.42, muzzle = {0.8, 0.6, 0.7, CR}, nose = {0.36, 0.24}})
ears(k, "round", B, CR, 0.55, 0.5, 0.48)
for _, p in ipairs({{0.4, -1.0}, {-0.4, -0.5}, {0.3, 0.2}, {-0.3, 0.8}, {0.45, 1.2}}) do add("Torso", V(0.3, 0.08, 0.3), V(p[1], k.by + 0.9, p[2]), WHITE) end
-- antlers: main beam + tines on each side (rods so every piece meets)
both(function(sx, s)
	local top = V(sx * 0.4, k.head.Y + k.hh / 2, k.head.Z + 0.2)
	local a1, a2, a3 = top + V(sx * 0.3, 0.7, 0.15), top + V(sx * 0.55, 1.4, 0.4), top + V(sx * 0.4, 1.9, 0.6)
	rod("Head", top, a1, 0.16, AN); rod("Head", a1, a2, 0.14, AN); rod("Head", a2, a3, 0.12, AN)
	rod("Head", a1, a1 + V(sx * 0.1, 0.45, -0.3), 0.11, AN); rod("Head", a2, a2 + V(sx * 0.35, 0.4, -0.1), 0.1, AN)
end)
return {name = "Deer", parts = P, joints = J, hrpSize = V(2, 5, 4), hrpPos = V(0, 2.5, 0)}
