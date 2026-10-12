-- Yeti: big shaggy white snow beast, ice-blue face, hands and feet, fluffy tufts, frowning brows, small fangs.
local W, WS, BL, BD = rgb(240, 244, 250), rgb(206, 216, 234), rgb(140, 186, 232), rgb(80, 110, 160)
add("Torso", V(3.0, 3.2, 2.2), V(0, 4.4, 0), W, {studs = true})
add("Torso", V(2.0, 2.0, 0.2), V(0, 4.2, -1.15), WS)
for _, p in ipairs({{1.55, 5.4}, {-1.55, 4.0}, {1.55, 3.2}, {-1.55, 5.6}}) do add("Torso", V(0.2, 0.6, 1.0), V(p[1], p[2], 0), WS) end   -- fur tufts
joint("Torso", "Root", V(0, 4.4, 0))
add("Head", V(2.4, 2.2, 2.2), V(0, 7.05, -0.1), W, {studs = true})
add("Head", V(1.6, 0.6, 1.4), V(0, 8.4, 0), W, {studs = true})                                       -- tuft on top
add("Head", V(1.8, 1.4, 0.1), V(0, 6.9, -1.25), BL)                                                  -- face
both(function(sx)
	eye("Head", sx * 0.42, 7.2, -1.32, 0.34, "angry"); brow("Head", sx * 0.45, 7.5, -1.33, 0.5, BD, 16)
	add("Head", V(0.12, 0.2, 0.06), V(sx * 0.3, 6.45, -1.35), WHITE, {shape = "wedge", rot = {0, 0, 180}})
	add("Head", V(0.5, 0.6, 0.6), V(sx * 1.3, 7.3, -0.1), WS)                                         -- side fluff
end)
add("Head", V(0.4, 0.22, 0.06), V(0, 6.85, -1.33), BD)                                               -- nose
add("Head", V(0.9, 0.12, 0.06), V(0, 6.55, -1.33), BLACK)                                            -- mouth
joint("Head", "Torso", V(0, 6.0, 0))
both(function(sx, s)
	add("Arm" .. s, V(1.2, 1.2, 1.2), V(sx * 1.9, 5.5, 0), W, {studs = true})
	rod("Arm" .. s, V(sx * 1.9, 5.4, 0), V(sx * 2.2, 3.0, -0.3), 1.0, W)
	hand("Arm" .. s, V(sx * 2.2, 3.0, -0.32), sx, 1.55, BL)
	joint("Arm" .. s, "Torso", V(sx * 1.9, 5.6, 0))
	add("Leg" .. s, V(1.1, 2.8, 1.2), V(sx * 0.8, 1.6, 0.1), W, {studs = true})
	add("Leg" .. s, V(1.3, 0.4, 1.7), V(sx * 0.8, 0.2, -0.15), BL)
	joint("Leg" .. s, "Torso", V(sx * 0.8, 2.9, 0.1))
end)
return {name = "Yeti", parts = P, joints = J, hrpSize = V(4.6, 8.6, 2.6), hrpPos = V(0, 4.3, 0)}
