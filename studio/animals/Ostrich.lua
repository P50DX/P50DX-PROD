-- Ostrich: fluffy black body, white wing + tail plumes, very long pink neck, small head, big eyes, long pink legs.
local BK, BKL, W, PK, PKD = rgb(40, 38, 44), rgb(70, 66, 76), rgb(246, 244, 238), rgb(240, 170, 160), rgb(206, 130, 120)
add("Torso", V(2.4, 1.9, 3.0), V(0, 4.3, 0.2), BK, {studs = true})
add("Torso", V(2.0, 0.8, 1.2), V(0, 4.6, 1.9), W, {studs = true, rot = {-25, 0, 0}})     -- tail plume
joint("Torso", "Root", V(0, 4.2, 0.2))
both(function(sx, s) foldedWing("Wing" .. s, V(sx * 1.2, 4.9, -0.6), sx, 2.6, 1.3, {BK, BKL, W}); joint("Wing" .. s, "Torso", V(sx * 1.2, 4.8, 0)) end)
-- neck: rods up and forward to the head
local n0, n1, n2 = V(0, 4.9, -1.2), V(0, 6.3, -1.5), V(0, 7.6, -1.6)
rod("Neck", n0, n1, 0.55, PK); rod("Neck", n1, n2, 0.48, PK)
joint("Neck", "Torso", n0)
add("Head", V(1.0, 0.9, 1.1), V(0, 8.05, -1.75), PK)
add("Head", V(0.6, 0.3, 0.7), V(0, 7.85, -2.55), rgb(240, 200, 150))                       -- flat beak
add("Head", V(1.06, 0.3, 0.6), V(0, 8.4, -1.6), BKL)                                       -- tuft
eye("Head", 0.3, 8.15, -2.32, 0.38, "cute"); eye("Head", -0.3, 8.15, -2.32, 0.38, "cute")
add("Head", V(0.75, 0.1, 0.07), V(0, 8.5, -2.32), BK)                                      -- lash line
joint("Head", "Neck", V(0, 7.6, -1.6))
both(function(sx, s)
	add("Leg" .. s, V(0.9, 1.1, 1.0), V(sx * 0.6, 3.2, 0.3), BK, {studs = true})             -- feathered thigh
	rod("Leg" .. s, V(sx * 0.6, 2.8, 0.35), V(sx * 0.6, 1.4, 0.55), 0.4, PK)
	rod("Leg" .. s, V(sx * 0.6, 1.4, 0.55), V(sx * 0.6, 0.2, 0.2), 0.34, PK)
	add("Leg" .. s, V(0.6, 0.25, 0.95), V(sx * 0.6, 0.13, -0.15), PKD)
	joint("Leg" .. s, "Torso", V(sx * 0.6, 3.6, 0.3))
end)
return {name = "Ostrich", parts = P, joints = J, hrpSize = V(2.6, 8.4, 3.6), hrpPos = V(0, 4.2, 0)}
