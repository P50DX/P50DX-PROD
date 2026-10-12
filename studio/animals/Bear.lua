-- Bear (brown): big hump, round ears, broad head with tan muzzle, heavy paws with claws, stubby tail.
local B, BD, BL = rgb(128, 82, 50), rgb(92, 56, 34), rgb(198, 150, 104)
local k = quad{col = B, belly = BD, pawCol = BD, W = 2.8, H = 2.5, L = 4.2, legH = 1.6, legW = 0.95, head = {2.1, 1.9, 1.9}, neckUp = 0.3, headFwd = 0.4, tailN = 1, tailW0 = 0.45, tailW1 = 0.45, tailLen = 0.35, tailCols = {B}, tailCurl = 10}
face(k, {eyeS = 0.36, eyeY = 0.28, muzzle = {1.1, 0.75, 0.8, BL}, nose = {0.5, 0.32}})
ears(k, "round", B, BL, 0.55, 0.5, 0.38)
add("Torso", V(2.4, 0.9, 1.8), V(0, k.by + 1.4, -1.0), B, {studs = true})                    -- shoulder hump
for _, leg in ipairs({{"FL", 1, -1}, {"FR", -1, -1}, {"BL", 1, 1}, {"BR", -1, 1}}) do
	local x, z = leg[2] * (2.8 / 2 - 0.475), leg[3] * (4.2 / 2 - 0.665)
	for _, dx in ipairs({-0.3, 0, 0.3}) do add("Leg" .. leg[1], V(0.15, 0.18, 0.2), V(x + dx, 0.1, z - 0.8), rgb(236, 226, 206)) end
end
return {name = "Bear", parts = P, joints = J, hrpSize = V(3, 4.8, 5), hrpPos = V(0, 2.4, 0)}
