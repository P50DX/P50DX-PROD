-- Baby Bear (Forest egg, Epic): chubby brown cub, tan muzzle, round ears, honey pot hug.
local C, CL, CD = rgb(150, 98, 60), rgb(214, 170, 120), rgb(104, 66, 40)
local k = pup{col = C, belly = CL, pawCol = CD, W = 1.45, head = {1.7, 1.5, 1.4}, tailN = 1, tailW0 = 0.3, tailW1 = 0.3, tailLen = 0.25, tailCurl = 10}
cute(k, CL, BLACK)
ears(k, "round", C, CL, 0.42, 0.4, 0.38)
add("Torso", V(0.6, 0.55, 0.5), V(0, k.by - 0.1, -1.05), rgb(230, 160, 50)); add("Torso", V(0.62, 0.15, 0.52), V(0, k.by + 0.2, -1.05), rgb(255, 210, 80))
return {name = "BabyBear", parts = P, joints = J, hrpSize = V(1.8, 2.8, 2.4), hrpPos = V(0, 1.4, 0)}
