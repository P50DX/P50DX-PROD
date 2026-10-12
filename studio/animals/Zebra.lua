-- Zebra: clean bold black stripes on white, black muzzle, upright striped mane, tufted tail, red bowtie on a collar band.
local W, BK, BTIE = rgb(246, 246, 246), rgb(30, 30, 34), rgb(220, 36, 44)
local k = quad{col = W, belly = W, legCol = W, pawCol = BK, W = 1.9, H = 2.0, L = 3.8, legH = 2.2, legW = 0.58, head = {1.3, 1.4, 2.0}, neckUp = 1.4, headFwd = 0.4, tailN = 3, tailW0 = 0.3, tailW1 = 0.25, tailLen = 0.7, tailCols = {W, W, BK}, tailCurl = -25}
local mc = face(k, {eyeS = 0.38, eyeY = 0.25, eyeX = 0.32, muzzle = {1.0, 0.75, 0.85, BK}})
ears(k, "point", W, BK, 0.4, 0.55, 0.3)
-- body stripes: vertical bands wrapping the torso, bands on legs, bands on the face
for _, z in ipairs({-1.5, -0.9, -0.3, 0.3, 0.9, 1.5}) do add("Torso", V(1.96, 2.06, 0.28), V(0, k.by, z), BK, {rot = {z * 4, 0, 0}}) end
for _, leg in ipairs({{1, -1}, {-1, -1}, {1, 1}, {-1, 1}}) do
	local x, z = leg[1] * (1.9 / 2 - 0.29), leg[2] * (3.8 / 2 - 0.4)
	for _, y in ipairs({0.75, 1.45}) do add("Leg" .. ((leg[2] < 0) and "F" or "B") .. ((leg[1] > 0) and "L" or "R"), V(0.64, 0.25, 0.68), V(x, y, z), BK) end
end
for _, dy in ipairs({0.45, 0.0}) do add("Head", V(1.36, 0.18, 1.6), V(0, k.head.Y + dy, k.head.Z + 0.2), BK) end
for i = 0, 4 do add("Head", V(0.3, 0.55, 0.5), V(0, k.head.Y + 0.75 - i * 0.5, k.head.Z + 0.9 + i * 0.38), (i % 2 == 0) and BK or W) end   -- mane
-- collar band + bowtie (sits on the band at the throat, no floating)
local nb = V(0, k.by + 0.95, -2.0)
add("Torso", V(1.3, 0.28, 1.05), nb, BTIE, {rot = {-35, 0, 0}})                               -- collar band
bowtie("Torso", nb + V(0, -0.2, -0.62), 1.1, BTIE)
return {name = "Zebra", parts = P, joints = J, hrpSize = V(2.2, 5, 4.4), hrpPos = V(0, 2.5, 0)}
