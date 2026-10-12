-- Polar Bear: massive cream-white, heavy shoulders, small round ears, long head with black nose, big paws.
local W, WD, BK = rgb(248, 246, 236), rgb(214, 210, 196), rgb(34, 32, 36)
local k = quad{col = W, belly = WD, pawCol = WD, W = 3.0, H = 2.6, L = 4.6, legH = 1.7, legW = 1.0, head = {2.0, 1.8, 2.0}, neckUp = 0.3, headFwd = 0.5, tailN = 1, tailW0 = 0.5, tailW1 = 0.5, tailLen = 0.4, tailCols = {W}, tailCurl = 10}
local mc = face(k, {eyeS = 0.34, eyeY = 0.3, muzzle = {1.1, 0.75, 0.9, W}, nose = {0.5, 0.35}})
ears(k, "round", W, WD, 0.5, 0.45, 0.4)
add("Torso", V(3.1, 1.0, 2.0), V(0, k.by + 1.2, -0.9), W, {studs = true})                   -- shoulder mass
for _, leg in ipairs({{"FL", 1, -1}, {"FR", -1, -1}, {"BL", 1, 1}, {"BR", -1, 1}}) do
	local x, z = leg[2] * (3.0 / 2 - 0.5), leg[3] * (4.6 / 2 - 0.7)
	for _, dx in ipairs({-0.3, 0, 0.3}) do add("Leg" .. leg[1], V(0.16, 0.18, 0.2), V(x + dx, 0.1, z - 0.85), BK) end
end
return {name = "PolarBear", parts = P, joints = J, hrpSize = V(3.2, 5, 5.4), hrpPos = V(0, 2.5, 0)}
