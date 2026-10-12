-- Cockroach: glossy brown shell wings, long antennae, 6 spindly legs, cheeky face.
local SH, SHD, BEL, LEG = rgb(122, 66, 30), rgb(84, 42, 18), rgb(196, 140, 84), rgb(60, 34, 18)
add("Torso", V(1.9, 0.8, 2.9), V(0, 1.15, 0.4), BEL)                                     -- body/underside
add("Torso", V(1.0, 0.35, 2.9), V(0.48, 1.68, 0.5), SH, {studs = true, rot = {0, 0, -6}})  -- wing cases
add("Torso", V(1.0, 0.35, 2.9), V(-0.48, 1.68, 0.5), SH, {studs = true, rot = {0, 0, 6}})
add("Torso", V(0.08, 0.2, 2.8), V(0, 1.8, 0.5), SHD)                                     -- centre seam
add("Torso", V(1.7, 0.55, 0.9), V(0, 1.45, -1.3), SHD, {studs = true})                   -- pronotum shield
add("Head", V(1.25, 0.95, 0.85), V(0, 1.25, -2.15), SHD)
eye("Head", 0.32, 1.38, -2.6, 0.32, "cute"); eye("Head", -0.32, 1.38, -2.6, 0.32, "cute")
add("Head", V(0.5, 0.08, 0.06), V(0, 1.0, -2.6), BLACK)                                    -- grin
add("Head", V(0.2, 0.18, 0.12), V(0.17, 0.85, -2.6), BEL); add("Head", V(0.2, 0.18, 0.12), V(-0.17, 0.85, -2.6), BEL)  -- mandibles
joint("Torso", "Root", V(0, 1.2, 0.3)); joint("Head", "Torso", V(0, 1.25, -1.75))
both(function(sx, s)
	-- antennae: two thin segments sweeping up and back
	add("Ant" .. s, V(0.1, 0.1, 1.4), V(sx * 0.35, 1.95, -2.75), LEG, {rot = {35, sx * 15, 0}})
	add("Ant" .. s, V(0.08, 0.08, 1.4), V(sx * 0.6, 2.75, -2.6), LEG, {rot = {-30, sx * 30, 0}})
	joint("Ant" .. s, "Head", V(sx * 0.3, 1.6, -2.4))
	for i, z in ipairs({-0.9, 0.2, 1.3}) do
		local g = "Leg" .. i .. s
		add(g, V(0.95, 0.18, 0.2), V(sx * 1.25, 1.0, z), LEG, {rot = {0, 0, sx * -30}})       -- femur up-out
		add(g, V(0.16, 0.95, 0.16), V(sx * 1.72, 0.47, z + (i - 2) * 0.15), LEG)                -- tibia down
		add(g, V(0.3, 0.1, 0.35), V(sx * 1.75, 0.05, z + (i - 2) * 0.3), LEG)                   -- foot
		joint(g, "Torso", V(sx * 0.85, 1.0, z))
	end
end)
add("Torso", V(0.12, 0.12, 0.7), V(0.3, 1.2, 2.15), LEG, {rot = {-20, 10, 0}}); add("Torso", V(0.12, 0.12, 0.7), V(-0.3, 1.2, 2.15), LEG, {rot = {-20, -10, 0}})  -- cerci
return {name = "Cockroach", parts = P, joints = J, hrpSize = V(2.4, 1.8, 4.5), hrpPos = V(0, 0.9, 0)}
