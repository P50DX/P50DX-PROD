-- Arctic Fox: fluffy white, short rounded ears, short muzzle, huge fluffy tail, icy-blue eyes, chunky fur ruff.
local W, WD, BL, BK = rgb(248, 250, 255), rgb(210, 220, 236), rgb(120, 200, 255), rgb(40, 40, 50)
local k = quad{col = W, belly = WD, pawCol = WD, W = 1.9, H = 1.7, L = 3.2, legH = 1.3, legW = 0.55, head = {1.8, 1.6, 1.5}, neckUp = 0.5, tailN = 4, tailW0 = 0.95, tailW1 = 1.1, tailLen = 0.85, tailCols = {W, WD}, tailCurl = 12}
face(k, {eyeS = 0.44, iris = BL, muzzle = {0.8, 0.55, 0.7, W}, nose = {0.32, 0.22}})
ears(k, "round", W, rgb(200, 216, 236), 0.55, 0.55, 0.32)
add("Torso", V(2.3, 1.5, 1.0), V(0, k.by + 0.3, -1.45), W, {studs = true})               -- fluffy ruff
return {name = "ArcticFox", parts = P, joints = J, hrpSize = V(2.2, 3.6, 3.8), hrpPos = V(0, 1.8, 0)}
