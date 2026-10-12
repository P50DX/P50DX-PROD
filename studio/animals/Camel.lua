-- Camel: tall, long curved neck, single big studded hump, droopy-lidded eyes, split lip, knobbly knees, tuft tail.
local S, SD, SL = rgb(214, 170, 116), rgb(170, 124, 78), rgb(236, 206, 160)
local k = quad{hoof = "split", col = S, belly = SL, pawCol = SD, W = 2.0, H = 2.0, L = 3.8, legH = 2.8, legW = 0.55, head = {1.2, 1.2, 2.0}, neckUp = 2.0, headFwd = 1.0, tailN = 2, tailW0 = 0.25, tailW1 = 0.25, tailLen = 0.7, tailCols = {S, SD}, tailCurl = -30}
local mc = face(k, {eyeS = 0.36, eyeY = 0.3, eyeX = 0.33, muzzle = {0.95, 0.7, 0.8, SL}})
both(function(sx) add("Head", V(0.42, 0.14, 0.08), V(sx * 0.4, k.head.Y + 0.42, k.face - 0.03), SD) end)  -- heavy lids
both(function(sx) add("Head", V(0.15, 0.12, 0.06), V(sx * 0.25, mc.Y + 0.2, mc.Z - 0.43), SD) end)
ears(k, "round", S, nil, 0.3, 0.3, 0.4)
add("Torso", V(1.6, 1.4, 1.8), V(0, k.by + 1.5, 0.1), S, {studs = true}); add("Torso", V(1.1, 0.5, 1.2), V(0, k.by + 2.35, 0.1), S, {studs = true})  -- hump
for _, z in ipairs({-1, 1}) do for _, sx in ipairs({1, -1}) do add("Leg" .. (z < 0 and "F" or "B") .. (sx > 0 and "L" or "R"), V(0.7, 0.45, 0.7), V(sx * 0.72, 1.6, z * 1.5), SD) end end   -- knees
return {name = "Camel", parts = P, joints = J, hrpSize = V(2.2, 6.4, 4.4), hrpPos = V(0, 3.2, 0)}
