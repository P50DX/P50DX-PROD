-- Lion: golden body, huge layered dark mane framing the head, gold crown, proud brows, tufted tail.
local G, GD, MN, MND, CR, CRW = rgb(226, 164, 72), rgb(186, 124, 46), rgb(170, 88, 34), rgb(126, 60, 24), rgb(250, 226, 180), rgb(255, 204, 40)
local k = quad{col = G, belly = CR, pawCol = CR, W = 2.4, H = 2.2, L = 4.2, legH = 1.8, legW = 0.8, head = {1.9, 1.8, 1.7}, neckUp = 0.6, headFwd = 0.5, tailN = 5, tailW0 = 0.35, tailW1 = 0.3, tailLen = 0.8, tailCols = {G}, tailCurl = 8}
local mc = face(k, {eyeS = 0.4, iris = rgb(250, 190, 40), brow = GD, browAng = 12, muzzle = {1.0, 0.7, 0.6, CR}, nose = {0.42, 0.28, rgb(120, 70, 60)}})
local c = k.head
-- mane: big blocks around the head (behind the face plane) + chest
add("Head", V(3.0, 2.9, 1.2), V(0, c.Y - 0.1, c.Z + 0.5), MN, {studs = true})
add("Head", V(2.4, 0.6, 1.0), V(0, c.Y + 1.55, c.Z + 0.6), MND, {studs = true})
both(function(sx) add("Head", V(0.6, 2.2, 1.0), V(sx * 1.65, c.Y - 0.2, c.Z + 0.6), MND, {studs = true}) end)
add("Torso", V(2.3, 1.6, 0.8), V(0, k.by + 0.1, -2.15), MN, {studs = true})
-- crown sitting on the mane top
crown("Head", V(0, c.Y + 1.85, c.Z + 0.5), 1.5, CRW, rgb(220, 40, 60), {d = 1.0})
ears(k, "round", G, GD, 0.45, 0.4, 0.38)
local tt = tipOf("Tail5")
add("Tail5", V(0.6, 0.6, 0.6), tt, MND); add("Tail5", V(0.4, 0.4, 0.4), tt + V(0, 0.1, 0.25), MND)   -- tail tuft on the tip
return {name = "Lion", parts = P, joints = J, hrpSize = V(2.6, 5, 4.6), hrpPos = V(0, 2.5, 0)}
