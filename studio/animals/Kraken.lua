--@base Octopus
--@colors local PU, PD, SU = rgb(30, 110, 124), rgb(16, 70, 84), rgb(255, 140, 120)
-- Kraken: deep-sea teal giant with burning eyes, heavy brows, fanged grin and a sunken gold crown.
both(function(sx)
	add("Torso", V(0.7, 0.66, 0.06), V(sx * 0.6, 2.8, -1.37), BLACK)
	add("Torso", V(0.55, 0.36, 0.06), V(sx * 0.6, 2.78, -1.39), rgb(255, 120, 30), {neon = true})
	add("Torso", V(0.1, 0.36, 0.06), V(sx * 0.6, 2.78, -1.41), BLACK)
	add("Torso", V(0.8, 0.2, 0.2), V(sx * 0.6, 3.25, -1.38), PD, {rot = {0, 0, sx * -20}})
	add("Torso", V(0.45, 0.25, 0.06), V(sx * 0.95, 2.25, -1.36), PU)                                  -- hide blush
	add("Torso", V(0.12, 0.25, 0.06), V(sx * 0.3, 2.0, -1.38), WHITE, {shape = "wedge", rot = {0, 0, 180}})
end)
add("Torso", V(1.0, 0.15, 0.06), V(0, 2.15, -1.37), BLACK)
add("Torso", V(1.6, 0.4, 1.6), V(0, 4.7, 0.1), rgb(255, 200, 50))
for _, p in ipairs({{-0.6, -0.6}, {0.6, -0.6}, {-0.6, 0.6}, {0.6, 0.6}, {0, -0.7}}) do add("Torso", V(0.3, 0.45, 0.3), V(p[1], 5.1, 0.1 + p[2]), rgb(255, 200, 50)) end
add("Torso", V(0.3, 0.3, 0.1), V(0, 4.7, -0.72), rgb(255, 60, 90), {neon = true})
return {name = "Kraken", parts = P, joints = J, hrpSize = V(4, 5.4, 4), hrpPos = V(0, 2.7, 0)}
