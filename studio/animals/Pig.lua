-- Pig: round pink body, short legs, big flat snout with nostrils, flop-forward ears, curly tail.
local PK, PKD, PKL = rgb(250, 168, 184), rgb(222, 120, 146), rgb(255, 204, 214)
local k = quad{hoof = "split", col = PK, belly = PKL, pawCol = PKD, W = 2.4, H = 2.0, L = 3.2, legH = 0.8, legW = 0.6, head = {2.0, 1.8, 1.5}, neckUp = 0.1, headFwd = 0.1, tailN = 3, tailW0 = 0.22, tailW1 = 0.18, tailLen = 0.4, tailCols = {PKD}, tailCurl = 60}
local mc = face(k, {eyeS = 0.36, eyeY = 0.25, muzzle = {1.0, 0.75, 0.4, PKD}})
add("Head", V(0.16, 0.26, 0.06), V(0.22, mc.Y + 0.05, mc.Z - 0.23), rgb(140, 50, 80)); add("Head", V(0.16, 0.26, 0.06), V(-0.22, mc.Y + 0.05, mc.Z - 0.23), rgb(140, 50, 80))
ears(k, "point", PKD, nil, 0.6, 0.55, 0.32)
return {name = "Pig", parts = P, joints = J, hrpSize = V(2.6, 3.2, 3.6), hrpPos = V(0, 1.6, 0)}
