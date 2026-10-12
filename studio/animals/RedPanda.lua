-- Red Panda (Forest egg, Rare): russet fur, white face marks and ear rims, dark legs, long ringed tail.
local C, CD, DK, W = rgb(206, 92, 40), rgb(140, 60, 28), rgb(60, 36, 30), rgb(252, 246, 236)
local k = pup{col = C, belly = DK, pawCol = DK, tailN = 4, tailW0 = 0.45, tailW1 = 0.4, tailLen = 0.45, tailCols = {C, CD}, tailCurl = -8}
cute(k, W, BLACK)
both(function(sx) add("Head", V(0.35, 0.18, 0.05), V(sx * 0.32, k.head.Y + 0.48, k.face - 0.02), W) end)
ears(k, "point", C, W, 0.45, 0.45, 0.36)
for _, l in ipairs({"FL", "FR", "BL", "BR"}) do end
sprig("Head", MOUTH, 1, rgb(126, 204, 92), rgb(80, 170, 60), "bamboo")   -- food in the mouth
return {name = "RedPanda", parts = P, joints = J, hrpSize = V(1.6, 2.8, 2.6), hrpPos = V(0, 1.4, 0)}
