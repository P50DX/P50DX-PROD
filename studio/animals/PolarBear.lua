-- Polar Bear: massive cream-white, heavy shoulders, small round ears, long head with black nose, big paws.
local W, WD, BK = rgb(248, 246, 236), rgb(214, 210, 196), rgb(34, 32, 36)
local k = quad{claws = BLACK, col = W, belly = WD, pawCol = WD, W = 3.0, H = 2.6, L = 4.6, legH = 1.7, legW = 1.0, head = {2.0, 1.8, 2.0}, neckUp = 0.3, headFwd = 0.5, tailN = 1, tailW0 = 0.5, tailW1 = 0.5, tailLen = 0.4, tailCols = {W}, tailCurl = 10}
local mc = face(k, {eyeS = 0.34, eyeY = 0.3, muzzle = {1.1, 0.75, 0.9, W}, nose = {0.5, 0.35}})
ears(k, "round", W, WD, 0.5, 0.45, 0.4)
add("Torso", V(3.1, 1.0, 2.0), V(0, k.by + 1.2, -0.9), W, {studs = true})                   -- shoulder mass
return {name = "PolarBear", parts = P, joints = J, hrpSize = V(3.2, 5, 5.4), hrpPos = V(0, 2.5, 0)}
