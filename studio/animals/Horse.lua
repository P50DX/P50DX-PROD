-- Horse: chestnut, tall, long head + neck, flowing dark mane, long tail, white blaze, hooves.
local C, CD, MN, HF = rgb(160, 86, 40), rgb(120, 60, 26), rgb(50, 32, 24), rgb(60, 50, 44)
local k = quad{hoof = "solid", col = C, belly = CD, pawCol = HF, W = 2.0, H = 2.1, L = 4.2, legH = 2.6, legW = 0.6, head = {1.4, 1.5, 2.2}, neckUp = 1.6, headFwd = 0.5, tailN = 4, tailW0 = 0.55, tailW1 = 0.45, tailLen = 0.8, tailCols = {MN}, tailCurl = -22}
local mc = face(k, {eyeS = 0.38, eyeY = 0.25, eyeX = 0.32, muzzle = {1.1, 0.8, 0.9, CD}})
add("Head", V(0.3, 1.0, 0.06), V(0, k.head.Y + 0.05, k.face - 0.01), WHITE)            -- blaze
add("Head", V(0.15, 0.2, 0.06), V(0.25, mc.Y + 0.1, mc.Z - 0.48), MN); add("Head", V(0.15, 0.2, 0.06), V(-0.25, mc.Y + 0.1, mc.Z - 0.48), MN)
ears(k, "point", C, CD, 0.4, 0.5, 0.3)
-- mane: blocks along the neck top down to the withers
for i = 0, 4 do add("Head", V(0.35, 0.6, 0.55), V(0, k.head.Y + 0.6 - i * 0.55, k.head.Z + 0.9 + i * 0.4), MN) end
both(function(sx) add("Leg" .. (sx > 0 and "FL" or "FR"), V(0.68, 0.35, 0.72), V(sx * (1.0 - 0.3), 0.55, -(2.1 - 0.42)), WHITE) end)  -- socks
return {name = "Horse", parts = P, joints = J, hrpSize = V(2.2, 5.6, 4.6), hrpPos = V(0, 2.8, 0)}
