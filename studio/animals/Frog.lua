-- Frog: wide flat head with big bulging eyes on top, wide smile, cream belly, folded powerful back legs.
local GR, GRD, BEL = rgb(96, 192, 70), rgb(58, 140, 44), rgb(236, 236, 160)
add("Torso", V(2.6, 1.4, 2.4), V(0, 1.2, 0.5), GR, {studs = true, rot = {-12, 0, 0}})
add("Torso", V(2.0, 0.3, 2.0), V(0, 0.5, 0.2), BEL)
for _, p in ipairs({{0.6, 1.95, 0.9}, {-0.5, 1.9, 0.2}, {0.2, 1.85, 1.4}}) do add("Torso", V(0.45, 0.08, 0.45), V(p[1], p[2], p[3]), GRD) end  -- dark spots
add("Head", V(2.8, 1.2, 1.9), V(0, 1.45, -1.3), GR, {studs = true})
add("Head", V(2.3, 0.35, 1.4), V(0, 0.95, -1.45), BEL)                                    -- throat
add("Head", V(1.9, 0.09, 0.06), V(0, 1.18, -2.27), BLACK)                                 -- wide smile
add("Head", V(0.09, 0.2, 0.06), V(0.95, 1.25, -2.27), BLACK); add("Head", V(0.09, 0.2, 0.06), V(-0.95, 1.25, -2.27), BLACK)
add("Head", V(0.12, 0.1, 0.06), V(0.25, 1.65, -2.27), GRD); add("Head", V(0.12, 0.1, 0.06), V(-0.25, 1.65, -2.27), GRD)  -- nostrils
both(function(sx, s)
	add("Head", V(0.85, 0.75, 0.8), V(sx * 0.85, 2.3, -1.45), GR)                          -- eye bump
	add("Head", V(0.7, 0.6, 0.06), V(sx * 0.85, 2.32, -1.88), WHITE)
	eye("Head", sx * 0.85, 2.3, -1.92, 0.38, "cute")
	add("ArmF" .. s, V(0.45, 0.9, 0.45), V(sx * 1.05, 0.5, -0.7), GR, {rot = {0, 0, sx * 10}})
	add("ArmF" .. s, V(0.75, 0.12, 0.6), V(sx * 1.15, 0.06, -0.9), GRD)
	joint("ArmF" .. s, "Torso", V(sx * 1.0, 0.95, -0.7))
	add("LegB" .. s, V(0.9, 0.85, 1.6), V(sx * 1.35, 0.7, 1.2), GR, {studs = true})          -- folded thigh
	add("LegB" .. s, V(0.55, 0.45, 1.3), V(sx * 1.45, 0.25, 0.4), GR)
	add("LegB" .. s, V(1.0, 0.12, 0.9), V(sx * 1.5, 0.06, -0.15), GRD)                       -- webbed foot
	joint("LegB" .. s, "Torso", V(sx * 1.1, 1.0, 1.5))
end)
joint("Torso", "Root", V(0, 1.1, 0.5)); joint("Head", "Torso", V(0, 1.4, -0.5))
return {name = "Frog", parts = P, joints = J, hrpSize = V(3, 2.6, 4), hrpPos = V(0, 1.3, 0)}
