-- Wolf: grey, bigger + muscular, focused yellow eyes with brows, long muzzle with fangs, pointed ears, thick neck ruff, bushy tail.
local G, GD, GL, Y = rgb(130, 136, 150), rgb(84, 88, 102), rgb(218, 222, 230), rgb(250, 200, 40)
local k = quad{claws = rgb(60, 56, 60), col = G, belly = GL, pawCol = GL, W = 2.2, H = 2.1, L = 4.0, legH = 1.8, legW = 0.65, head = {2.0, 1.7, 1.8}, neckUp = 0.7, tailN = 4, tailW0 = 0.7, tailW1 = 0.55, tailLen = 0.85, tailCols = {G, GD}, tailCurl = -6}
local mc = face(k, {eyeS = 0.42, iris = Y, brow = GD, browAng = 18, muzzle = {1.0, 0.7, 0.75, GL}, nose = {0.42, 0.28}})
both(function(sx) add("Head", V(0.12, 0.25, 0.1), V(sx * 0.3, mc.Y - 0.42, mc.Z - 0.3), WHITE) end)   -- fangs
ears(k, "point", G, GD, 0.6, 0.75, 0.3)
add("Torso", V(2.5, 1.6, 1.0), V(0, k.by + 0.4, -1.85), GL, {studs = true})               -- neck ruff
add("Torso", V(2.24, 0.25, 3.6), V(0, k.by + 1.1, 0.1), GD)                                -- dark saddle
return {name = "Wolf", parts = P, joints = J, hrpSize = V(2.4, 4.6, 4.4), hrpPos = V(0, 2.3, 0)}
