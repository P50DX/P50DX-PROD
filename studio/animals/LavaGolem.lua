-- Lava Golem: hulking basalt rock body with glowing lava cracks, molten core, burning eyes, boulder fists.
local R, RD, LV, LY = rgb(58, 52, 56), rgb(36, 32, 36), rgb(255, 110, 20), rgb(255, 200, 60)
add("Torso", V(3.4, 3.0, 2.4), V(0, 5.0, 0), R, {studs = true})
add("Torso", V(0.9, 0.9, 0.1), V(0, 5.3, -1.22), LY, {neon = true})                                  -- core
for _, s in ipairs({{0.12, 1.4, 0.8, 5.0, 20}, {0.12, 1.2, -0.9, 4.6, -25}, {1.0, 0.12, 0.2, 4.0, 10}}) do
	add("Torso", V(s[1], s[2], 0.08), V(s[3], s[4], -1.22), LV, {neon = true, rot = {0, 0, s[5]}})
end
for i = 0, 3 do add("Torso", V(0.7, 0.6, 0.7), V((i % 2) * 0.8 - 0.4, 6.6, 0.2 + i * 0.2), RD) end   -- back rocks
joint("Torso", "Root", V(0, 5.0, 0))
add("Head", V(1.6, 1.4, 1.5), V(0, 7.1, -0.4), R, {studs = true})
both(function(sx)
	add("Head", V(0.45, 0.22, 0.06), V(sx * 0.38, 7.2, -1.17), LV, {neon = true})
	add("Head", V(0.6, 0.2, 0.2), V(sx * 0.4, 7.45, -1.15), RD, {rot = {0, 0, sx * -18}})
end)
add("Head", V(0.8, 0.1, 0.06), V(0, 6.7, -1.17), LV, {neon = true})
joint("Head", "Torso", V(0, 6.4, -0.3))
both(function(sx, s)
	add("Arm" .. s, V(1.6, 1.6, 1.6), V(sx * 2.3, 6.1, 0), RD, {studs = true})
	rod("Arm" .. s, V(sx * 2.4, 5.6, 0), V(sx * 2.6, 2.7, -0.2), 1.2, R)
	add("Arm" .. s, V(0.08, 1.0, 0.1), V(sx * 2.5, 4.2, -0.75), LV, {neon = true})
	add("Arm" .. s, V(1.6, 1.4, 1.6), V(sx * 2.6, 2.0, -0.2), RD, {studs = true})
	add("Arm" .. s, V(1.2, 0.12, 0.08), V(sx * 2.6, 2.2, -1.02), LV, {neon = true})
	joint("Arm" .. s, "Torso", V(sx * 2.3, 6.1, 0))
	add("Leg" .. s, V(1.3, 3.3, 1.4), V(sx * 0.9, 1.85, 0.1), R, {studs = true})
	add("Leg" .. s, V(0.08, 0.9, 0.08), V(sx * 0.9, 1.8, -0.62), LV, {neon = true})
	add("Leg" .. s, V(1.5, 0.4, 1.8), V(sx * 0.9, 0.2, -0.1), RD)
	joint("Leg" .. s, "Torso", V(sx * 0.9, 3.5, 0.1))
end)
return {name = "LavaGolem", parts = P, joints = J, hrpSize = V(5.4, 8, 2.8), hrpPos = V(0, 4, 0)}
