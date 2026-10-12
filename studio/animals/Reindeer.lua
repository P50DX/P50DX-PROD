-- Reindeer: brown with cream neck mane + belly, big branching antlers, red nose, little bell collar.
local B, BD, CR, AN = rgb(140, 92, 58), rgb(98, 62, 38), rgb(240, 226, 200), rgb(214, 196, 162)
local k = quad{col = B, belly = CR, pawCol = rgb(40, 32, 28), W = 1.9, H = 1.9, L = 3.6, legH = 2.1, legW = 0.55, head = {1.5, 1.5, 1.7}, neckUp = 1.1, tailN = 1, tailW0 = 0.45, tailW1 = 0.45, tailLen = 0.4, tailCols = {CR}, tailCurl = 30}
local mc = face(k, {eyeS = 0.4, muzzle = {0.85, 0.65, 0.75, BD}})
add("Head", V(0.45, 0.4, 0.3), V(0, mc.Y + 0.1, mc.Z - 0.48), rgb(240, 40, 40), {neon = true})   -- red nose
ears(k, "round", B, CR, 0.5, 0.45, 0.5)
add("Torso", V(1.6, 1.4, 1.0), V(0, k.by + 0.5, -1.9), CR, {studs = true})                   -- neck mane
add("Torso", V(1.5, 0.22, 0.9), V(0, k.by + 0.8, -2.05), rgb(200, 30, 36), {rot = {-30, 0, 0}})
bell("Torso", V(0, k.by + 0.35, -2.45), 0.55)                                              -- bell on the collar
both(function(sx)
	local t = V(sx * 0.4, k.head.Y + k.hh / 2, k.head.Z + 0.2)
	local a1, a2, a3 = t + V(sx * 0.4, 0.8, 0.3), t + V(sx * 0.8, 1.7, 0.5), t + V(sx * 0.7, 2.5, 0.9)
	rod("Head", t, a1, 0.18, AN); rod("Head", a1, a2, 0.16, AN); rod("Head", a2, a3, 0.13, AN)
	rod("Head", a1, a1 + V(sx * 0.05, 0.6, -0.5), 0.12, AN); rod("Head", a2, a2 + V(sx * 0.5, 0.5, -0.3), 0.11, AN); rod("Head", a2, a2 + V(sx * -0.1, 0.6, -0.4), 0.1, AN)
end)
return {name = "Reindeer", parts = P, joints = J, hrpSize = V(2.2, 5, 4.2), hrpPos = V(0, 2.5, 0)}
