-- Mouse: grey pear body, huge round pink-lined ears, pink nose + whiskers, long pink tail.
local G, GD, GL = rgb(176, 178, 190), rgb(132, 134, 148), rgb(226, 226, 234)
add("Torso", V(2.0, 1.8, 2.6), V(0, 1.55, 0.3), G, {studs = true})
add("Torso", V(1.5, 0.3, 2.0), V(0, 0.65, 0.2), GL)                                       -- belly
add("Torso", V(1.6, 1.4, 1.0), V(0, 1.55, 1.75), G, {studs = true})                        -- rump
add("Head", V(1.7, 1.5, 1.6), V(0, 2.3, -1.45), G, {studs = true})
add("Head", V(0.9, 0.75, 0.75), V(0, 2.05, -2.5), GL)                                     -- snout
add("Head", V(0.3, 0.25, 0.2), V(0, 2.25, -2.92), PINK)                                   -- nose
eye("Head", 0.42, 2.55, -2.27, 0.42, "cute"); eye("Head", -0.42, 2.55, -2.27, 0.42, "cute")
add("Head", V(0.25, 0.3, 0.08), V(0, 1.72, -2.85), WHITE)                                 -- teeth
both(function(sx, s)
	add("Ear" .. s, V(1.0, 1.0, 0.18), V(sx * 0.85, 3.35, -1.2), G, {rot = {0, 0, sx * -15}})
	add("Ear" .. s, V(0.68, 0.68, 0.06), V(sx * 0.85, 3.35, -1.32), PINK, {rot = {0, 0, sx * -15}})
	joint("Ear" .. s, "Head", V(sx * 0.6, 2.9, -1.2))
	for _, dy in ipairs({0.08, -0.12}) do add("Head", V(0.9, 0.04, 0.04), V(sx * 0.75, 2.1 + dy, -2.75), BLACK, {rot = {0, 0, sx * dy * 60}}) end  -- whiskers
	add("Leg" .. "F" .. s, V(0.45, 0.6, 0.5), V(sx * 0.65, 0.3, -0.7), G); add("LegF" .. s, V(0.5, 0.15, 0.55), V(sx * 0.65, 0.07, -0.85), PINK)
	joint("LegF" .. s, "Torso", V(sx * 0.65, 0.6, -0.7))
	add("LegB" .. s, V(0.6, 0.8, 0.8), V(sx * 0.75, 0.45, 1.4), G); add("LegB" .. s, V(0.55, 0.15, 0.8), V(sx * 0.75, 0.07, 1.25), PINK)
	joint("LegB" .. s, "Torso", V(sx * 0.75, 0.85, 1.4))
end)
joint("Torso", "Root", V(0, 1.4, 0.3)); joint("Head", "Torso", V(0, 2.0, -0.8))
tail(6, V(0, 1.3, 2.25), 0.22, 0.1, 0.7, {PINK}, 3)
return {name = "Mouse", parts = P, joints = J, hrpSize = V(2.2, 2.8, 4), hrpPos = V(0, 1.4, 0.2)}
