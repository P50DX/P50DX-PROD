-- Sphinx Cat (Desert egg, Legendary): sitting sand-coloured cat wearing a blue + gold striped royal headdress,
-- gold collar with a gem, glowing blue eyes, curled tail.
local C, CL, G, BL = rgb(222, 186, 126), rgb(246, 226, 186), rgb(255, 200, 50), rgb(40, 80, 180)
add("Torso", V(1.2, 1.4, 1.3), V(0, 0.9, 0.15), C, {studs = true})
add("Torso", V(0.9, 0.9, 0.1), V(0, 0.9, -0.52), CL)
add("Torso", V(1.25, 0.18, 0.9), V(0, 1.55, -0.1), G); add("Torso", V(0.2, 0.2, 0.06), V(0, 1.45, -0.58), rgb(60, 220, 255), {neon = true})
joint("Torso", "Root", V(0, 0.9, 0))
both(function(sx, s)
	add("Leg" .. s, V(0.36, 1.0, 0.38), V(sx * 0.35, 0.5, -0.45), C); add("Leg" .. s, V(0.4, 0.2, 0.5), V(sx * 0.35, 0.1, -0.55), CL)
	joint("Leg" .. s, "Torso", V(sx * 0.35, 1.0, -0.45))
end)
add("Head", V(1.5, 1.35, 1.3), V(0, 2.25, -0.25), C, {studs = true})
add("Head", V(1.8, 1.0, 1.0), V(0, 2.55, 0.3), G)
for _, y in ipairs({2.25, 2.55, 2.85}) do add("Head", V(1.82, 0.12, 1.02), V(0, y, 0.3), BL) end
both(function(sx)
	add("Head", V(0.3, 1.3, 0.6), V(sx * 0.88, 1.95, -0.2), G)
	for _, y in ipairs({1.55, 1.85, 2.15}) do add("Head", V(0.32, 0.1, 0.62), V(sx * 0.88, y, -0.2), BL) end
	add("Head", V(0.35, 0.45, 0.25), V(sx * 0.45, 3.1, -0.15), C, {rot = {0, 0, sx * -10}})
end)
cute({head = V(0, 2.25, -0.25), face = -0.93, hw = 1.5, hh = 1.35, hd = 1.3}, CL, PINK, {iris = rgb(70, 160, 255)})
joint("Head", "Torso", V(0, 1.6, -0.2))
tail(3, V(0, 0.4, 0.8), 0.25, 0.22, 0.45, {C}, 25)
return {name = "SphinxCat", parts = P, joints = J, hrpSize = V(1.8, 3.4, 2), hrpPos = V(0, 1.7, 0)}
