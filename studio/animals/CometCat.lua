-- Comet Cat (Space egg, Rare): bright blue cat with yellow eyes, whiskers and a glowing comet tail.
local C, CL, CO = rgb(70, 116, 230), rgb(200, 220, 255), rgb(120, 230, 255)
local k = pup{col = C, belly = CL, tailN = 4, tailW0 = 0.28, tailW1 = 0.24, tailLen = 0.45, tailCurl = 14}
cute(k, CL, PINK, {iris = rgb(255, 220, 60)})
ears(k, "point", C, PINK, 0.45, 0.5, 0.32)
both(function(sx) for _, dy in ipairs({0.04, -0.08}) do add("Head", V(0.5, 0.03, 0.03), V(sx * 0.6, k.head.Y - 0.25 + dy, k.face - 0.04), WHITE) end end)
local last, a = tipOf("Tail4")
local d = V(0, math.sin(a), math.cos(a))
for i, s in ipairs({0.5, 0.36, 0.24}) do add("Tail4", V(s, s, s), last + d * (0.1 + (i - 1) * 0.36), i == 1 and rgb(255, 255, 255) or CO, {neon = true}) end
fish("Head", MOUTH, 1, rgb(100, 230, 255), {neon = true})   -- food in the mouth
return {name = "CometCat", parts = P, joints = J, hrpSize = V(1.6, 3, 2.6), hrpPos = V(0, 1.5, 0)}
