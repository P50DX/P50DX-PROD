--@base TRex
--@colors local G, GD, BE, MO, RED = rgb(150, 156, 170), rgb(78, 84, 98), rgb(206, 212, 222), rgb(30, 30, 38), rgb(255, 40, 30)
-- Mecha T-Rex: steel robot T-Rex - armour panels, glowing cyan power lines, bolts, back exhaust pipes, laser red eyes.
local CY = rgb(60, 230, 255)
both(function(sx)
	add("Torso", V(0.06, 0.18, 3.4), V(sx * 1.32, 4.2, 0), CY, {neon = true})
	add("Torso", V(0.06, 1.6, 0.18), V(sx * 1.32, 4.8, -1.2), CY, {neon = true})
	for _, z in ipairs({-1.6, 0, 1.6}) do add("Torso", V(0.1, 0.22, 0.22), V(sx * 1.33, 5.6, z), GD) end
	rod("Torso", V(sx * 0.6, 6.0, 1.2), V(sx * 0.7, 7.0, 1.6), 0.45, GD)                          -- exhaust pipes
	add("Torso", V(0.35, 0.12, 0.35), V(sx * 0.72, 7.15, 1.65), rgb(255, 140, 40), {neon = true})
	add("Head", V(0.06, 0.2, 2.2), V(sx * 1.22, 7.4, -3.6), CY, {neon = true})
end)
add("Torso", V(0.8, 0.8, 0.08), V(0, 4.6, -2.04), CY, {neon = true})                               -- power core
rod("Head", V(0.5, 8.0, -3.0), V(0.7, 8.9, -2.6), 0.12, GD); add("Head", V(0.25, 0.25, 0.25), V(0.7, 8.95, -2.6), RED, {neon = true})
return {name = "MechaTRex", parts = P, joints = J, hrpSize = V(3.6, 8, 6), hrpPos = V(0, 4, -1)}
