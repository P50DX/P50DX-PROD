-- Moose: huge dark brown, tall shoulder hump, long droopy muzzle, dewlap, wide flat palmate antlers.
local B, BD, BL, AN = rgb(96, 64, 44), rgb(64, 42, 30), rgb(150, 112, 80), rgb(206, 182, 140)
local k = quad{col = B, belly = BD, legCol = BL, pawCol = BD, W = 2.4, H = 2.4, L = 4.2, legH = 2.6, legW = 0.65, head = {1.5, 1.5, 2.2}, neckUp = 0.7, headFwd = 0.6, tailN = 1, tailW0 = 0.3, tailW1 = 0.3, tailLen = 0.4, tailCols = {BD}, tailCurl = -30}
local mc = face(k, {eyeS = 0.36, eyeY = 0.3, eyeX = 0.33, muzzle = {1.2, 1.0, 1.0, BD}})
add("Head", V(0.25, 0.8, 0.4), V(0, k.head.Y - 1.1, k.head.Z + 0.2), BD)                   -- dewlap
add("Torso", V(2.4, 1.0, 2.0), V(0, k.by + 1.5, -1.0), B, {studs = true})                   -- shoulder hump
ears(k, "point", B, BD, 0.45, 0.5, 0.48)
both(function(sx)
	local b = V(sx * 0.55, k.head.Y + k.hh / 2, k.head.Z + 0.3)
	rod("Head", b, b + V(sx * 0.6, 0.4, 0), 0.25, AN)
	add("Head", V(1.6, 0.25, 1.3), b + V(sx * 1.3, 0.75, 0.1), AN, {studs = true, rot = {0, 0, sx * 25}})   -- palm
	for i = 0, 3 do add("Head", V(0.2, 0.45, 0.2), b + V(sx * (0.9 + i * 0.32), 1.25 + i * 0.12, -0.3 + i * 0.25), AN) end   -- points
end)
return {name = "Moose", parts = P, joints = J, hrpSize = V(2.6, 6.4, 4.8), hrpPos = V(0, 3.2, 0)}
