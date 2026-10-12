-- Tiger: bright orange with bold black stripes, white cheeks + muzzle + belly, fierce amber eyes, striped tail.
local O, OD, W, BK = rgb(240, 130, 40), rgb(200, 96, 26), rgb(250, 246, 240), rgb(32, 26, 26)
local k = quad{col = O, belly = W, pawCol = W, W = 2.3, H = 2.1, L = 4.4, legH = 1.8, legW = 0.75, head = {1.9, 1.7, 1.7}, neckUp = 0.5, headFwd = 0.4, tailN = 6, tailW0 = 0.45, tailW1 = 0.35, tailLen = 0.8, tailCols = {O, BK}, tailCurl = 5}
local mc = face(k, {eyeS = 0.42, iris = rgb(250, 190, 40), brow = BK, browAng = 20, muzzle = {1.05, 0.65, 0.5, W}, nose = {0.4, 0.26, rgb(220, 120, 120)}})
local c, f = k.head, k.face
both(function(sx)
	add("Head", V(0.55, 0.65, 0.45), V(sx * 0.8, c.Y - 0.35, f + 0.2), W)                     -- white cheek fluff
	add("Head", V(0.12, 0.45, 0.06), V(sx * 0.85, c.Y + 0.1, f - 0.01), BK, {rot = {0, 0, sx * 30}})   -- face stripes
	add("Head", V(0.12, 0.35, 0.06), V(sx * 0.2, c.Y + 0.7, f - 0.01), BK)
end)
add("Head", V(0.12, 0.4, 0.06), V(0, c.Y + 0.7, f - 0.01), BK)
ears(k, "round", O, BK, 0.45, 0.45, 0.38)
for _, z in ipairs({-1.8, -1.1, -0.4, 0.3, 1.0, 1.7}) do
	both(function(sx) add("Torso", V(0.08, 1.4, 0.28), V(sx * 1.16, k.by + 0.25, z), BK, {rot = {z * 6, 0, 0}}) end)
	add("Torso", V(1.6, 0.08, 0.3), V(0, k.by + 1.06, z), BK)
end
return {name = "Tiger", parts = P, joints = J, hrpSize = V(2.6, 4.6, 5), hrpPos = V(0, 2.3, 0)}
