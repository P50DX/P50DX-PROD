-- Baby Deer (Forest egg, Common): fawn with white back spots, big ears, white tail, long little legs.
local C, CL, CD = rgb(196, 124, 70), rgb(250, 232, 206), rgb(120, 76, 44)
local k = pup{hoof = "split", col = C, belly = CL, pawCol = CD, legH = 0.85, legW = 0.32, tailN = 1, tailW0 = 0.25, tailW1 = 0.25, tailLen = 0.3, tailCols = {CL}, tailCurl = 30}
cute(k, CL, BLACK)
ears(k, "round", C, PINK, 0.4, 0.6, 0.45)
for _, p in ipairs({{0.3, -0.4}, {-0.25, -0.1}, {0.35, 0.3}, {-0.3, 0.5}, {0.05, 0.1}}) do add("Torso", V(0.2, 0.06, 0.2), V(p[1], k.by + 0.53, p[2]), CL) end
sprig("Head", MOUTH, 1, rgb(90, 150, 60), rgb(90, 190, 70), "clover")   -- food in the mouth
return {name = "BabyDeer", parts = P, joints = J, hrpSize = V(1.6, 3.2, 2.4), hrpPos = V(0, 1.6, 0)}
