-- Lava Pup (Volcano egg, Epic): charcoal pup with glowing lava paws, ear tips, back cracks and tail flame.
local C, CL, LV = rgb(56, 48, 52), rgb(90, 78, 82), rgb(255, 120, 20)
local k = pup{col = C, belly = CL, pawCol = LV, tailN = 2, tailW0 = 0.32, tailW1 = 0.28, tailCols = {C, LV}}
cute(k, CL, BLACK, {iris = rgb(255, 150, 30)})
ears(k, "point", C, LV, 0.42, 0.55, 0.32)
for _, l in ipairs({{0.08, 0.5, 0.25, -0.3, 20}, {0.08, 0.45, -0.25, 0.3, -25}}) do add("Torso", V(l[1], 0.06, l[2]), V(l[3], k.by + 0.56, l[4]), LV, {neon = true, rot = {0, l[5], 0}}) end
bone("Head", MOUTH, 1, rgb(60, 50, 50), {knob = rgb(255, 120, 20)})   -- food in the mouth
return {name = "LavaPup", parts = P, joints = J, hrpSize = V(1.6, 2.8, 2.4), hrpPos = V(0, 1.4, 0)}
