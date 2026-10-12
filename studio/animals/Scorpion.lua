-- Scorpion: dark armoured segmented body, big pincers, 8 legs, tall segmented tail arching over with a glowing stinger.
local A, AD, AL, ST = rgb(52, 46, 60), rgb(30, 26, 36), rgb(96, 86, 110), rgb(255, 170, 40)
add("Torso", V(2.2, 0.9, 1.6), V(0, 1.2, -0.7), A, {studs = true})
for i = 1, 3 do add("Torso", V(2.1 - i * 0.15, 0.8, 0.75), V(0, 1.15, 0.35 + (i - 1) * 0.7), (i % 2 == 0) and AD or A, {studs = true}) end
joint("Torso", "Root", V(0, 1.2, 0))
add("Head", V(1.6, 0.8, 0.9), V(0, 1.25, -1.85), A, {studs = true})
eye("Head", 0.35, 1.45, -2.32, 0.34, "angry", rgb(255, 60, 40)); eye("Head", -0.35, 1.45, -2.32, 0.34, "angry", rgb(255, 60, 40))
brow("Head", 0.37, 1.72, -2.32, 0.45, AL, 20); brow("Head", -0.37, 1.72, -2.32, 0.45, AL, 20)
joint("Head", "Torso", V(0, 1.2, -1.4))
both(function(sx, s)
	local sh, el, cl = V(sx * 0.7, 1.15, -2.2), V(sx * 1.6, 1.15, -2.6), V(sx * 1.4, 1.15, -3.6)
	rod("Claw" .. s, sh, el, 0.4, A); rod("Claw" .. s, el, cl, 0.45, A)
	add("Claw" .. s, V(0.8, 0.55, 0.9), cl + V(0, 0, -0.35), A, {studs = true})
	add("Claw" .. s, V(0.28, 0.3, 0.8), cl + V(sx * 0.3, 0, -1.1), AL); add("Claw" .. s, V(0.28, 0.3, 0.7), cl + V(sx * -0.25, 0, -1.05), AL)
	joint("Claw" .. s, "Torso", sh)
	for i = 1, 4 do
		local z = -0.9 + (i - 1) * 0.55
		local hip, knee, foot = V(sx * 1.0, 1.1, z), V(sx * 1.7, 1.4, z + 0.1), V(sx * 2.05, 0.08, z + 0.2)
		rod("Leg" .. i .. s, hip, knee, 0.18, AD); rod("Leg" .. i .. s, knee, foot, 0.16, AD)
		joint("Leg" .. i .. s, "Torso", hip)
	end
end)
-- tail arching up and over the back
local pts = {V(0, 1.2, 2.2), V(0, 2.0, 2.9), V(0, 3.0, 3.1), V(0, 3.9, 2.7), V(0, 4.3, 1.9)}
for i = 1, #pts - 1 do
	rod("Tail" .. i, pts[i], pts[i + 1], 0.65 - i * 0.07, (i % 2 == 0) and AD or A, {studs = true, extra = 0.2})
	joint("Tail" .. i, i == 1 and "Torso" or "Tail" .. (i - 1), pts[i])
end
rod("Tail4", pts[5], pts[5] + V(0, -0.6, -0.5), 0.3, ST, {neon = true})
return {name = "Scorpion", parts = P, joints = J, hrpSize = V(3, 2, 4.4), hrpPos = V(0, 1, 0)}
