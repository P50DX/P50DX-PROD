-- T-Rex (scary): massive head with open toothy jaws, glowing red eyes under a heavy brow, tiny arms,
-- huge legs with claws, thick tail, dark back ridge.
local G, GD, BE, MO, RED = rgb(92, 128, 58), rgb(58, 84, 36), rgb(214, 204, 150), rgb(120, 24, 24), rgb(255, 40, 30)
add("Torso", V(2.6, 2.8, 4.0), V(0, 4.6, 0), G, {studs = true})
add("Torso", V(2.2, 0.3, 3.4), V(0, 3.15, -0.1), BE)
for i = 0, 5 do add("Torso", V(0.6, 0.25, 0.45), V(0, 6.1, -1.5 + i * 0.6), GD) end
joint("Torso", "Root", V(0, 4.6, 0))
rod("Head", V(0, 5.4, -1.8), V(0, 6.4, -2.8), 1.6, G)
add("Head", V(2.4, 2.0, 3.0), V(0, 7.0, -3.6), G, {studs = true})
add("Head", V(2.0, 0.5, 2.4), V(0, 5.9, -3.8), MO)                                                   -- open mouth
add("Head", V(2.2, 0.7, 2.6), V(0, 5.4, -3.8), BE)                                                   -- lower jaw
for i = -3, 3 do
	local x = i * 0.3
	add("Head", V(0.16, 0.28, 0.1), V(x, 5.86, -5.08), WHITE, {shape = "wedge", rot = {0, 0, 180}})
	add("Head", V(0.14, 0.22, 0.1), V(x + 0.15, 5.86, -5.06), WHITE, {shape = "wedge"})
end
both(function(sx)
	for j = 0, 3 do add("Head", V(0.1, 0.25, 0.16), V(sx * 1.0, 5.86, -4.6 + j * 0.45), WHITE, {shape = "wedge", rot = {0, 0, 180}}) end
	local e = V(sx * 0.7, 7.45, -5.12)
	add("Head", V(0.55, 0.38, 0.06), e, BLACK); add("Head", V(0.42, 0.26, 0.06), e + V(0, 0, -0.02), RED, {neon = true}); add("Head", V(0.1, 0.26, 0.06), e + V(0, 0, -0.04), BLACK)
	add("Head", V(0.8, 0.28, 0.5), e + V(0, 0.32, 0.1), GD, {rot = {0, 0, sx * 22}})
	add("Head", V(0.18, 0.12, 0.06), V(sx * 0.35, 6.75, -5.12), BLACK)
	rod("Arm" .. (sx > 0 and "L" or "R"), V(sx * 1.3, 4.2, -1.6), V(sx * 1.5, 3.5, -2.2), 0.4, G)
	add("Arm" .. (sx > 0 and "L" or "R"), V(0.3, 0.18, 0.2), V(sx * 1.5, 3.35, -2.35), BE)
	joint("Arm" .. (sx > 0 and "L" or "R"), "Torso", V(sx * 1.3, 4.2, -1.6))
end)
joint("Head", "Torso", V(0, 5.6, -2.0))
both(function(sx, s)
	add("Leg" .. s, V(1.4, 2.4, 2.0), V(sx * 1.3, 3.6, 0.6), G, {studs = true})
	rod("Leg" .. s, V(sx * 1.3, 2.6, 0.8), V(sx * 1.3, 0.5, 0.4), 0.9, G)
	add("Leg" .. s, V(1.3, 0.4, 1.8), V(sx * 1.3, 0.2, 0.0), GD)
	for _, dx in ipairs({-0.4, 0, 0.4}) do add("Leg" .. s, V(0.18, 0.2, 0.35), V(sx * 1.3 + dx, 0.12, -1.0), BE) end
	joint("Leg" .. s, "Torso", V(sx * 1.3, 4.2, 0.6))
end)
tail(6, V(0, 4.8, 2.0), 2.0, 0.5, 1.2, {G, GD}, -3)
return {name = "TRex", parts = P, joints = J, hrpSize = V(3.6, 8, 6), hrpPos = V(0, 4, -1)}
