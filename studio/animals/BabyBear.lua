-- Baby Bear (Forest egg, Epic): chubby brown cub, tan muzzle, round ears, carrying a honey pot in its mouth.
local C, CL, CD = rgb(150, 98, 60), rgb(214, 170, 120), rgb(104, 66, 40)
local k = pup{col = C, belly = CL, pawCol = CD, W = 1.45, head = {1.7, 1.5, 1.4}, tailN = 1, tailW0 = 0.3, tailW1 = 0.3, tailLen = 0.25, tailCurl = 10}
cute(k, CL, BLACK)
ears(k, "round", C, CL, 0.42, 0.4, 0.38)
-- honey pot carried by its wire handle in the mouth: handle bar between the teeth, two wires down to the rim,
-- pot with a darker rim, lid, label and a honey drip
local mz = k.face - 0.32
add("Head", V(0.9, 0.1, 0.1), V(0, 1.2, mz), rgb(200, 200, 210))
both(function(sx) rod("Head", V(sx * 0.42, 1.2, mz), V(sx * 0.32, 0.92, mz - 0.05), 0.06, rgb(200, 200, 210)) end)
add("Head", V(0.66, 0.55, 0.56), V(0, 0.62, mz - 0.05), rgb(220, 140, 50)); add("Head", V(0.72, 0.1, 0.62), V(0, 0.92, mz - 0.05), rgb(170, 100, 36))
add("Head", V(0.5, 0.08, 0.42), V(0, 1.0, mz - 0.05), rgb(255, 205, 70)); add("Head", V(0.44, 0.22, 0.05), V(0, 0.62, mz - 0.35), rgb(250, 236, 200))
add("Head", V(0.1, 0.22, 0.06), V(0.2, 0.84, mz - 0.35), rgb(255, 205, 70)); add("Head", V(0.14, 0.14, 0.06), V(0.2, 0.7, mz - 0.35), rgb(255, 205, 70), {shape = "ball"})
return {name = "BabyBear", parts = P, joints = J, hrpSize = V(1.8, 2.8, 2.4), hrpPos = V(0, 1.4, 0)}
