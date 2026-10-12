-- Hamster: chubby round body, puffy cream cheeks, tiny round ears, buck teeth, stubby legs.
local O, OD, CR = rgb(232, 150, 70), rgb(196, 112, 46), rgb(252, 238, 214)
add("Torso", V(2.6, 2.3, 2.8), V(0, 1.55, 0.3), O, {studs = true})
add("Torso", V(2.0, 1.6, 0.3), V(0, 1.35, -1.12), CR)                                    -- cream chest
add("Torso", V(2.2, 0.35, 2.2), V(0, 0.5, 0.3), CR)
add("Head", V(2.3, 1.9, 1.8), V(0, 2.9, -0.9), O, {studs = true})
add("Head", V(2.4, 0.8, 0.5), V(0, 2.35, -1.62), CR)                                     -- puffy cheeks
add("Head", V(1.0, 0.6, 0.35), V(0, 2.75, -1.92), CR)                                    -- muzzle
add("Head", V(0.28, 0.2, 0.15), V(0, 2.95, -2.14), PINK)                                  -- nose
add("Head", V(0.3, 0.3, 0.08), V(0, 2.32, -2.12), WHITE); add("Head", V(0.04, 0.3, 0.09), V(0, 2.32, -2.13), BLACK)  -- buck teeth
eye("Head", 0.55, 3.3, -1.83, 0.42, "cute"); eye("Head", -0.55, 3.3, -1.83, 0.42, "cute")
both(function(sx, s)
	add("Ear" .. s, V(0.55, 0.55, 0.2), V(sx * 0.85, 4.0, -0.7), O); add("Ear" .. s, V(0.32, 0.32, 0.06), V(sx * 0.85, 4.0, -0.82), PINK)
	joint("Ear" .. s, "Head", V(sx * 0.8, 3.75, -0.7))
	add("Head", V(0.3, 0.15, 0.06), V(sx * 0.95, 2.6, -1.88), PINK, {transp = 0.2})          -- blush
	add("ArmF" .. s, V(0.4, 0.4, 0.4), V(sx * 0.6, 1.3, -1.35), O); hand("ArmF" .. s, V(sx * 0.6, 1.12, -1.4), sx, 0.55, PINK)
	joint("ArmF" .. s, "Torso", V(sx * 0.6, 1.5, -1.3))
	add("LegB" .. s, V(0.6, 0.5, 0.75), V(sx * 0.8, 0.25, 0.6), O); add("LegB" .. s, V(0.55, 0.12, 0.75), V(sx * 0.8, 0.06, 0.45), PINK)
	joint("LegB" .. s, "Torso", V(sx * 0.8, 0.5, 0.6))
end)
add("Tail1", V(0.35, 0.35, 0.3), V(0, 1.2, 1.8), CR); joint("Tail1", "Torso", V(0, 1.2, 1.65))
joint("Torso", "Root", V(0, 1.5, 0.3)); joint("Head", "Torso", V(0, 2.3, -0.8))
return {name = "Hamster", parts = P, joints = J, hrpSize = V(2.8, 3.2, 3.4), hrpPos = V(0, 1.6, 0)}
