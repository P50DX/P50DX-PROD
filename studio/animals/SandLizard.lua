-- Sand Lizard (Desert egg, Uncommon): low sandy lizard, brown back spots, long tapered tail, happy smile.
local C, CL, SP = rgb(214, 178, 108), rgb(242, 222, 172), rgb(150, 104, 56)
local k = pup{col = C, belly = CL, W = 1.3, H = 0.7, L = 2.0, legH = 0.3, legW = 0.35, head = {1.3, 0.9, 1.2}, neckUp = 0.0, headFwd = 0.1, tailN = 4, tailW0 = 0.45, tailW1 = 0.2, tailLen = 0.5, tailCurl = 3}
face(k, {eyeS = 0.36, eyeY = 0.25, eyeX = 0.28})
add("Head", V(0.6, 0.06, 0.05), V(0, k.head.Y - 0.2, k.face - 0.02), BLACK)
both(function(sx) add("Head", V(0.25, 0.1, 0.05), V(sx * 0.48, k.head.Y - 0.12, k.face - 0.02), PINK) end)
for _, p in ipairs({{0.3, -0.5}, {-0.3, -0.1}, {0.25, 0.4}, {-0.2, 0.75}}) do add("Torso", V(0.28, 0.06, 0.28), V(p[1], k.by + 0.37, p[2]), SP) end
if not SKIP_FOOD then fruit("Head", V(0, k.head.Y - 0.22, k.face), 0.9, rgb(236, 80, 140), {spots = rgb(40, 30, 30)}) end   -- food in the mouth
return {name = "SandLizard", parts = P, joints = J, hrpSize = V(1.6, 1.6, 3), hrpPos = V(0, 0.8, 0)}
