-- Phoenix: blazing red-orange bird, flame crest, gold beak and legs, wings with glowing tips, long fire tail.
local RD, OR, YE, GD, FL = rgb(224, 56, 36), rgb(250, 120, 30), rgb(255, 196, 60), rgb(255, 204, 70), rgb(255, 150, 40)
add("Torso", V(2.0, 2.2, 2.4), V(0, 3.0, 0), RD, {studs = true})
add("Torso", V(1.5, 1.6, 0.3), V(0, 2.8, -1.25), YE)
joint("Torso", "Root", V(0, 3.0, 0))
add("Head", V(1.6, 1.5, 1.5), V(0, 4.75, -0.6), RD, {studs = true})
add("Head", V(0.6, 0.45, 0.7), V(0, 4.5, -1.6), GD); add("Head", V(0.45, 0.22, 0.45), V(0, 4.2, -1.5), rgb(210, 150, 30))
both(function(sx)
	eye("Head", sx * 0.45, 4.95, -1.37, 0.36, "sharp", rgb(255, 170, 30)); brow("Head", sx * 0.45, 5.25, -1.38, 0.45, rgb(150, 30, 24), 14)
end)
for i, p in ipairs({{0, 5.8, -0.6, 0.9, -10}, {0, 5.75, -0.1, 1.1, 20}, {0, 5.6, 0.35, 0.9, 40}}) do
	add("Head", V(0.3, p[4], 0.35), V(p[1], p[2], p[3]), i == 2 and YE or FL, {neon = true, rot = {p[5], 0, 0}})
end
joint("Head", "Torso", V(0, 4.0, -0.4))
both(function(sx, s)
	add("Wing" .. s, V(0.3, 1.9, 2.2), V(sx * 1.15, 3.1, 0.3), OR, {studs = true, rot = {10, 0, sx * -8}})
	add("Wing" .. s, V(0.25, 0.7, 1.8), V(sx * 1.2, 1.9, 0.9), YE, {neon = true, rot = {25, 0, sx * -8}})
	joint("Wing" .. s, "Torso", V(sx * 1.0, 3.8, 0))
	rod("Leg" .. s, V(sx * 0.5, 2.0, 0.2), V(sx * 0.5, 0.25, 0.1), 0.3, GD)
	add("Leg" .. s, V(0.7, 0.18, 0.8), V(sx * 0.5, 0.09, -0.1), GD)
	joint("Leg" .. s, "Torso", V(sx * 0.5, 2.0, 0.2))
end)
for i, x in ipairs({-0.6, 0, 0.6}) do
	rod("Tail1", V(x * 0.4, 2.6, 1.1), V(x, 1.3, 3.4), 0.5, i == 2 and YE or FL, {h = 0.2, neon = true})
end
add("Tail1", V(1.0, 0.5, 0.6), V(0, 2.5, 1.3), RD)
joint("Tail1", "Torso", V(0, 2.6, 1.1))
return {name = "Phoenix", parts = P, joints = J, hrpSize = V(2.6, 6.2, 3), hrpPos = V(0, 3.1, 0.3)}
