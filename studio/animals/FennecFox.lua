-- Fennec Fox (Desert egg, Common): cream fox with giant ears, fluffy tail with a dark tip.
local C, CL, CD = rgb(240, 204, 146), rgb(252, 240, 220), rgb(120, 80, 50)
local k = pup{col = C, belly = CL, tailN = 3, tailW0 = 0.45, tailW1 = 0.4, tailLen = 0.45, tailCols = {C, C, CD}, tailCurl = -15}
cute(k, CL, BLACK)
ears(k, "point", C, PINK, 0.55, 1.1, 0.33)
if not SKIP_FOOD then sprig("Head", MOUTH, 1, rgb(110, 80, 50), rgb(230, 80, 60), "berries") end   -- food in the mouth
return {name = "FennecFox", parts = P, joints = J, hrpSize = V(1.6, 3.4, 2.4), hrpPos = V(0, 1.7, 0)}
