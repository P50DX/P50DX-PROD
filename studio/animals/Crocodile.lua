-- Crocodile: long low armoured body, scute ridges, long snout with interlocking teeth, eyes on top, sprawled legs, thick tail.
local G, GD, BEL, Y = rgb(74, 120, 60), rgb(46, 80, 40), rgb(206, 196, 130), rgb(250, 210, 40)
add("Torso", V(2.4, 1.1, 4.0), V(0, 1.0, 0.3), G, {studs = true})
add("Torso", V(2.0, 0.3, 3.6), V(0, 0.4, 0.3), BEL)
for i = 0, 6 do add("Torso", V(0.3, 0.35, 0.4), V(0.45, 1.65, -1.4 + i * 0.6), GD); add("Torso", V(0.3, 0.35, 0.4), V(-0.45, 1.65, -1.4 + i * 0.6), GD) end
joint("Torso", "Root", V(0, 1.0, 0.3))
add("Head", V(1.9, 1.0, 1.6), V(0, 1.15, -2.4), G, {studs = true})
add("Head", V(1.4, 0.55, 2.4), V(0, 1.05, -4.3), G)                                          -- upper snout
add("Head", V(1.3, 0.35, 2.3), V(0, 0.6, -4.25), BEL)                                        -- lower jaw
for i = 0, 6 do
	local z = -3.3 - i * 0.33
	add("Head", V(0.1, 0.25, 0.1), V(0.68, 0.78, z), WHITE); add("Head", V(0.1, 0.25, 0.1), V(-0.68, 0.78, z), WHITE)
end
add("Head", V(0.2, 0.15, 0.15), V(0.25, 1.35, -5.4), GD); add("Head", V(0.2, 0.15, 0.15), V(-0.25, 1.35, -5.4), GD)   -- nostrils
both(function(sx)
	add("Head", V(0.6, 0.55, 0.6), V(sx * 0.55, 1.8, -2.6), G)                               -- eye bumps on top
	add("Head", V(0.45, 0.35, 0.06), V(sx * 0.55, 1.85, -2.93), BLACK); add("Head", V(0.36, 0.26, 0.06), V(sx * 0.55, 1.85, -2.95), Y); add("Head", V(0.08, 0.26, 0.06), V(sx * 0.55, 1.85, -2.97), BLACK)
	add("Head", V(0.55, 0.15, 0.1), V(sx * 0.55, 2.12, -2.92), GD, {rot = {0, 0, sx * 18}})
end)
joint("Head", "Torso", V(0, 1.0, -1.7))
both(function(sx, s)
	for _, z in ipairs({-1.2, 1.6}) do
		local g = "Leg" .. (z < 0 and "F" or "B") .. s
		rod(g, V(sx * 1.1, 0.9, z), V(sx * 1.7, 0.7, z), 0.5, G); rod(g, V(sx * 1.7, 0.7, z), V(sx * 1.75, 0.1, z - 0.2), 0.45, G)
		add(g, V(0.7, 0.18, 0.8), V(sx * 1.8, 0.09, z - 0.45), GD); joint(g, "Torso", V(sx * 1.1, 0.9, z))
	end
end)
tail(5, V(0, 1.0, 2.3), 1.3, 0.45, 1.0, {G, GD}, 0)
return {name = "Crocodile", parts = P, joints = J, hrpSize = V(2.8, 2.2, 6), hrpPos = V(0, 1.1, 0)}
