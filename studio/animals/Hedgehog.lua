-- Hedgehog: dome of brown spines (wedge spikes), cream face/belly, pointy snout, tiny legs.
local SP, SPD, SPT, CR = rgb(120, 82, 54), rgb(84, 56, 36), rgb(232, 214, 184), rgb(244, 220, 186)
add("Torso", V(2.4, 1.6, 2.6), V(0, 1.3, 0.4), SP, {studs = true})
add("Torso", V(2.0, 0.4, 2.2), V(0, 0.5, 0.3), CR)
-- spikes: wedges pointing back/up in rows, light tips
for row = 0, 3 do
	for col = -2, 2 do
		local x, z = col * 0.48, -0.5 + row * 0.75
		local y = 2.15 - math.abs(col) * 0.22 - (row == 3 and 0.25 or 0)
		add("Torso", V(0.42, 0.6, 0.7), V(x, y, z), (row + col) % 2 == 0 and SPD or SP, {shape = "wedge", rot = {0, 180, 0}})
		add("Torso", V(0.2, 0.2, 0.25), V(x, y + 0.2, z + 0.35), SPT)
	end
end
add("Head", V(1.6, 1.3, 1.2), V(0, 1.35, -1.25), CR)
add("Head", V(0.7, 0.55, 0.8), V(0, 1.15, -2.1), CR)                                     -- snout
add("Head", V(0.32, 0.28, 0.2), V(0, 1.25, -2.55), BLACK)
add("Head", V(0.3, 0.12, 0.06), V(0.55, 1.05, -1.87), PINK); add("Head", V(0.3, 0.12, 0.06), V(-0.55, 1.05, -1.87), PINK)
eye("Head", 0.4, 1.6, -1.87, 0.32, "cute"); eye("Head", -0.4, 1.6, -1.87, 0.32, "cute")
joint("Torso", "Root", V(0, 1.2, 0.4)); joint("Head", "Torso", V(0, 1.3, -0.7))
both(function(sx, s)
	add("Ear" .. s, V(0.35, 0.35, 0.15), V(sx * 0.6, 2.05, -1.0), CR); joint("Ear" .. s, "Head", V(sx * 0.6, 1.85, -1.0))
	add("LegF" .. s, V(0.4, 0.4, 0.45), V(sx * 0.7, 0.2, -0.5), CR); joint("LegF" .. s, "Torso", V(sx * 0.7, 0.45, -0.5))
	add("LegB" .. s, V(0.45, 0.4, 0.5), V(sx * 0.75, 0.2, 1.1), CR); joint("LegB" .. s, "Torso", V(sx * 0.75, 0.45, 1.1))
end)
return {name = "Hedgehog", parts = P, joints = J, hrpSize = V(2.6, 2.6, 3.4), hrpPos = V(0, 1.3, 0.3)}
