-- Piglet (Zoo egg, Uncommon): pink round piglet, big snout with nostrils, folded ears, curly tail.
local C, CD = rgb(250, 176, 190), rgb(232, 136, 156)
local k = pup{col = C, belly = CD, pawCol = CD, tailW0 = 0.18, tailW1 = 0.16, tailLen = 0.3, tailN = 3, tailCurl = 70}
face(k, {eyeS = 0.4, eyeY = 0.18, eyeX = 0.28})
add("Head", V(0.7, 0.45, 0.25), V(0, k.head.Y - 0.25, k.face - 0.1), CD)
both(function(sx) add("Head", V(0.12, 0.2, 0.05), V(sx * 0.15, k.head.Y - 0.25, k.face - 0.24), rgb(160, 70, 90)); add("Head", V(0.3, 0.12, 0.05), V(sx * 0.56, k.head.Y - 0.2, k.face - 0.02), rgb(255, 120, 140)) end)
ears(k, "flop", CD, nil, 0.45, 0.45)
fruit("Head", V(0, k.head.Y - 0.38, k.face - 0.02), 1, rgb(220, 40, 40))   -- food in the mouth
return {name = "Piglet", parts = P, joints = J, hrpSize = V(1.6, 2.6, 2.4), hrpPos = V(0, 1.3, 0)}
