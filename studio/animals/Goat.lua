-- Goat: white, sturdy, curved-back horns, goatee beard, rectangular-pupil yellow eyes, short upright tail.
local W, WD, HN = rgb(240, 238, 230), rgb(196, 192, 182), rgb(130, 112, 92)
local k = quad{col = W, belly = WD, pawCol = rgb(70, 60, 54), W = 1.9, H = 1.8, L = 3.2, legH = 1.6, legW = 0.55, head = {1.5, 1.5, 1.7}, neckUp = 0.9, tailN = 1, tailW0 = 0.35, tailW1 = 0.35, tailLen = 0.45, tailCols = {W}, tailCurl = 50}
local mc = face(k, {eyeS = 0.4, iris = rgb(240, 200, 60), muzzle = {0.85, 0.65, 0.7, WD}, nose = {0.36, 0.2, rgb(220, 150, 160)}})
add("Head", V(0.35, 0.65, 0.3), V(0, mc.Y - 0.6, mc.Z), WD)                                -- beard
ears(k, "flop", W, nil, 0.6, 0.35)
both(function(sx)
	local b = V(sx * 0.35, k.head.Y + k.hh / 2, k.head.Z + 0.1)
	local h1, h2, h3 = b + V(sx * 0.1, 0.55, 0.3), b + V(sx * 0.2, 0.85, 0.85), b + V(sx * 0.25, 0.6, 1.3)
	rod("Head", b, h1, 0.3, HN); rod("Head", h1, h2, 0.26, HN); rod("Head", h2, h3, 0.2, HN)
end)
return {name = "Goat", parts = P, joints = J, hrpSize = V(2.2, 4.4, 3.8), hrpPos = V(0, 2.2, 0)}
