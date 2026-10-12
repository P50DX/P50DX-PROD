-- Star Whale: huge friendly night-blue whale floating above the ground, glowing star spots, pale belly stripes,
-- side fins, big tail flukes, a fountain of stars from its blowhole.
local N, ND, BE, ST = rgb(40, 60, 140), rgb(24, 34, 90), rgb(170, 200, 255), rgb(255, 240, 160)
add("Torso", V(3.6, 3.0, 5.0), V(0, 3.0, 0), N, {studs = true})
add("Torso", V(3.0, 0.4, 4.6), V(0, 1.4, -0.1), BE)
for i = 0, 3 do add("Torso", V(2.8, 0.1, 0.25), V(0, 1.6 + (i % 2) * 0.05, -1.8 + i * 1.1), ND) end
sprinkle("Torso", V(0, 3.0, 0), V(3.6, 3.0, 5.0), 14, {ST, rgb(255, 255, 255), rgb(140, 220, 255)}, 21)
for i = 0, 4 do add("Torso", V(0.3, 1.0 + i * 0.25, 0.3), V((i - 2) * 0.35, 5.2 + i * 0.15, -0.8), i % 2 == 0 and ST or rgb(140, 220, 255), {neon = true, rot = {0, 0, (i - 2) * 18}}) end
joint("Torso", "Root", V(0, 3.0, 0))
add("Head", V(3.4, 2.7, 1.8), V(0, 3.05, -3.3), N, {studs = true})
add("Head", V(2.8, 0.5, 1.6), V(0, 1.75, -3.3), BE)
add("Head", V(2.2, 0.1, 0.06), V(0, 2.25, -4.23), BLACK)
both(function(sx)
	eye("Head", sx * 0.8, 3.3, -4.23, 0.5, "cute")
	add("Head", V(0.5, 0.2, 0.06), V(sx * 1.25, 2.65, -4.23), PINK)
end)
joint("Head", "Torso", V(0, 3.0, -2.5))
both(function(sx, s)
	add("Fin" .. s, V(1.8, 0.3, 1.0), V(sx * 2.4, 1.9, -1.2), ND, {rot = {0, sx * 25, sx * -25}})
	joint("Fin" .. s, "Torso", V(sx * 1.8, 2.2, -1.2))
end)
add("Tail1", V(2.2, 2.0, 2.0), V(0, 3.1, 3.3), N, {studs = true}); joint("Tail1", "Torso", V(0, 3.0, 2.5))
add("Tail2", V(1.2, 1.1, 1.6), V(0, 3.4, 4.9), N); joint("Tail2", "Tail1", V(0, 3.3, 4.2))
both(function(sx) add("Tail2", V(1.8, 0.3, 1.0), V(sx * 1.1, 3.7, 5.6), ND, {rot = {0, sx * -25, sx * 12}}) end)
return {name = "StarWhale", parts = P, joints = J, hrpSize = V(4, 6, 9), hrpPos = V(0, 3, 0.5)}
