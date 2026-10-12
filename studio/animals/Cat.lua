-- Cat: orange tabby, sleek body, pointed ears, green slit eyes, long upright tail, white muzzle + paws.
local O, OD, CR = rgb(240, 150, 60), rgb(196, 100, 36), rgb(252, 240, 224)
local k = quad{col = O, belly = CR, pawCol = CR, W = 1.8, H = 1.6, L = 3.2, legH = 1.3, legW = 0.55, head = {1.8, 1.6, 1.5}, neckUp = 0.5, tailN = 5, tailW0 = 0.42, tailW1 = 0.3, tailLen = 0.75, tailCols = {O, OD}, tailCurl = 14}
face(k, {eyeS = 0.45, iris = rgb(110, 210, 80), muzzle = {0.95, 0.55, 0.45, CR}, nose = {0.28, 0.18, PINK}})
ears(k, "point", O, PINK, 0.5, 0.5, 0.28)
for i, z in ipairs({-1.2, -0.3, 0.6, 1.3}) do add("Torso", V(1.86, 0.25, 0.3), V(0, 3.0 - (i == 1 and 0 or 0.05), z), OD) end  -- tabby stripes
both(function(sx) for _, dy in ipairs({0.05, -0.12}) do add("Head", V(0.8, 0.04, 0.04), V(sx * 0.7, k.head.Y - 0.35 + dy, k.face - 0.3), WHITE) end end)
return {name = "Cat", parts = P, joints = J, hrpSize = V(2, 3.6, 3.6), hrpPos = V(0, 1.8, 0)}
