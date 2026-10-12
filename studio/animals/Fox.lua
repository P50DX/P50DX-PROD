-- Fox: orange, light frame, long pointed muzzle with white cheeks, big pointed black-tipped ears, huge bushy white-tipped tail, black socks.
local O, OD, W, BK = rgb(240, 120, 40), rgb(200, 86, 26), rgb(252, 246, 240), rgb(48, 34, 30)
local k = quad{col = O, belly = W, legCol = BK, pawCol = BK, W = 1.7, H = 1.6, L = 3.4, legH = 1.5, legW = 0.5, head = {1.7, 1.5, 1.5}, neckUp = 0.55, tailN = 4, tailW0 = 0.8, tailW1 = 0.95, tailLen = 0.9, tailCols = {O, O, O, W}, tailCurl = 8}
face(k, {eyeS = 0.42, iris = rgb(250, 190, 40), brow = OD, browAng = 12, muzzle = {0.8, 0.6, 1.0, W}, nose = {0.32, 0.22}})
ears(k, "point", O, BK, 0.6, 0.75, 0.28)
both(function(sx) add("Head", V(0.5, 0.6, 0.6), V(sx * 0.62, k.head.Y - 0.45, k.face + 0.25), W) end)   -- white cheeks
return {name = "Fox", parts = P, joints = J, hrpSize = V(2, 3.8, 4), hrpPos = V(0, 1.9, 0)}
