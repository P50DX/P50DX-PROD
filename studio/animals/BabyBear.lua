-- Baby Bear (Forest egg, Epic): chubby brown cub, tan muzzle, round ears, honey pot hug.
local C, CL, CD = rgb(150, 98, 60), rgb(214, 170, 120), rgb(104, 66, 40)
local k = pup{col = C, belly = CL, pawCol = CD, W = 1.45, head = {1.7, 1.5, 1.4}, tailN = 1, tailW0 = 0.3, tailW1 = 0.3, tailLen = 0.25, tailCurl = 10}
cute(k, CL, BLACK)
ears(k, "round", C, CL, 0.42, 0.4, 0.38)
-- honey pot hugged between the front paws: pot, darker rim, lid, label, drip
add("Torso", V(0.75, 0.65, 0.65), V(0, 0.33, -1.12), rgb(220, 140, 50)); add("Torso", V(0.82, 0.12, 0.72), V(0, 0.68, -1.12), rgb(170, 100, 36))
add("Torso", V(0.6, 0.1, 0.5), V(0, 0.79, -1.12), rgb(255, 205, 70)); add("Torso", V(0.5, 0.26, 0.05), V(0, 0.33, -1.47), rgb(250, 236, 200))
add("Torso", V(0.12, 0.26, 0.06), V(0.22, 0.6, -1.47), rgb(255, 205, 70)); add("Torso", V(0.16, 0.16, 0.06), V(0.22, 0.45, -1.47), rgb(255, 205, 70), {shape = "ball"})
return {name = "BabyBear", parts = P, joints = J, hrpSize = V(1.8, 2.8, 2.4), hrpPos = V(0, 1.4, 0)}
