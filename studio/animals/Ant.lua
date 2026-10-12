-- Ant: red, three-part body (head / thorax / big gaster), elbowed antennae, mandibles, 6 legs.
local R, RD, RL = rgb(204, 52, 40), rgb(150, 30, 26), rgb(240, 110, 90)
add("Torso", V(0.9, 0.8, 1.3), V(0, 1.55, 0), R, {studs = true})                          -- thorax
add("Torso", V(0.45, 0.45, 0.5), V(0, 1.5, 0.85), RD)                                    -- waist node
add("Gaster", V(1.7, 1.5, 2.0), V(0, 1.75, 2.0), R, {studs = true})                       -- big rear
add("Gaster", V(1.3, 0.2, 1.6), V(0, 2.55, 2.0), RD)
add("Gaster", V(1.75, 0.15, 0.25), V(0, 1.95, 1.4), RD); add("Gaster", V(1.75, 0.15, 0.25), V(0, 1.95, 2.3), RD)  -- bands
add("Head", V(1.45, 1.3, 1.2), V(0, 1.95, -1.25), R, {studs = true})
eye("Head", 0.36, 2.15, -1.88, 0.42, "cute"); eye("Head", -0.36, 2.15, -1.88, 0.42, "cute")
brow("Head", 0.37, 2.5, -1.88, 0.42, RD, 12); brow("Head", -0.37, 2.5, -1.88, 0.42, RD, 12)
add("Head", V(0.35, 0.15, 0.55), V(0.25, 1.4, -2.05), RD, {rot = {0, -25, 0}}); add("Head", V(0.35, 0.15, 0.55), V(-0.25, 1.4, -2.05), RD, {rot = {0, 25, 0}})  -- mandibles
add("Head", V(0.4, 0.08, 0.06), V(0, 1.62, -1.88), BLACK)
joint("Torso", "Root", V(0, 1.5, 0)); joint("Gaster", "Torso", V(0, 1.6, 1.0)); joint("Head", "Torso", V(0, 1.8, -0.65))
both(function(sx, s)
	local base, elbow, tip = V(sx * 0.32, 2.55, -1.45), V(sx * 0.55, 3.4, -1.6), V(sx * 0.85, 3.55, -2.45)
	rod("Ant" .. s, base, elbow, 0.11, RD); rod("Ant" .. s, elbow, tip, 0.09, RD)
	add("Ant" .. s, V(0.18, 0.18, 0.18), tip, RD)
	joint("Ant" .. s, "Head", V(sx * 0.3, 2.55, -1.4))
	for i, z in ipairs({-0.45, 0.05, 0.55}) do
		local g = "Leg" .. i .. s
		add(g, V(1.0, 0.16, 0.16), V(sx * 0.9, 1.75, z), RD, {rot = {0, (i - 2) * sx * -25, sx * 35}})
		add(g, V(0.14, 1.35, 0.14), V(sx * 1.38, 0.72, z + (i - 2) * 0.35), RD, {rot = {(i - 2) * -12, 0, sx * -8}})
		add(g, V(0.25, 0.1, 0.3), V(sx * 1.45, 0.05, z + (i - 2) * 0.5), RD)
		joint(g, "Torso", V(sx * 0.45, 1.6, z))
	end
end)
return {name = "Ant", parts = P, joints = J, hrpSize = V(2.6, 2.4, 4), hrpPos = V(0, 1.2, 0.4)}
