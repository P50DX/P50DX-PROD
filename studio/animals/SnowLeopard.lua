-- Snow Leopard: pale grey-cream, dark rosette spots, very long thick fluffy tail, icy pale eyes, compact powerful body.
local W, WD, SP, IC = rgb(232, 232, 226), rgb(196, 196, 190), rgb(70, 70, 76), rgb(170, 220, 240)
local k = quad{claws = rgb(240, 236, 226), col = W, belly = rgb(252, 252, 250), pawCol = W, W = 2.0, H = 1.8, L = 3.8, legH = 1.5, legW = 0.65, head = {1.9, 1.6, 1.6}, neckUp = 0.5, tailN = 5, tailW0 = 0.72, tailW1 = 0.62, tailLen = 0.72, tailCols = {W, WD}, tailCurl = -2}
face(k, {eyeS = 0.42, iris = IC, brow = WD, browAng = 14, muzzle = {0.95, 0.55, 0.5, rgb(252, 252, 250)}, nose = {0.32, 0.22, rgb(200, 140, 140)}})
ears(k, "round", W, SP, 0.45, 0.45, 0.35)
for _, p in ipairs({{1.02, 0.4, -1.4}, {1.02, -0.2, -0.8}, {1.02, 0.3, -0.1}, {0.92, -0.2, 0.6}, {0.92, 0.35, 1.2}, {0.92, -0.1, 1.6}}) do
	both(function(sx) add("Torso", V(0.08, 0.42, 0.42), V(sx * p[1], k.by + p[2], p[3]), SP); add("Torso", V(0.09, 0.2, 0.2), V(sx * p[1], k.by + p[2], p[3]), WD) end)
end
for _, z in ipairs({-1.2, 0.2, 1.4}) do add("Torso", V(0.4, 0.08, 0.4), V(0.3, k.by + 0.95, z), SP) end
return {name = "SnowLeopard", parts = P, joints = J, hrpSize = V(2.2, 3.8, 4.4), hrpPos = V(0, 1.9, 0)}
