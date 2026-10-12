-- Baby Camel (Desert egg, Rare): tan calf, one fluffy hump, longer legs, eyelashes, little round ears.
local C, CL, CD = rgb(214, 170, 110), rgb(240, 214, 170), rgb(150, 110, 70)
local k = pup{hoof = "split", col = C, belly = CL, pawCol = CD, legH = 0.9, legW = 0.36, neckUp = 0.6, head = {1.35, 1.25, 1.3}, tailN = 1, tailW0 = 0.2, tailW1 = 0.2, tailLen = 0.4, tailCurl = -40}
cute(k, CL, CD)
both(function(sx) add("Head", V(0.08, 0.16, 0.05), V(sx * 0.5, k.head.Y + 0.42, k.face - 0.03), BLACK, {rot = {0, 0, sx * 30}}) end)
ears(k, "round", C, CL, 0.3, 0.28, 0.42)
add("Torso", V(0.9, 0.6, 0.8), V(0, k.by + 0.75, 0.05), C, {studs = true})
add("Torso", V(0.6, 0.2, 0.5), V(0, k.by + 1.12, 0.05), CL)
hay("Head", MOUTH, 1)   -- food in the mouth
return {name = "BabyCamel", parts = P, joints = J, hrpSize = V(1.6, 3.4, 2.4), hrpPos = V(0, 1.7, 0)}
