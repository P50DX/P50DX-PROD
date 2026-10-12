--@base TRex
--@colors local G, GD, BE, MO, RED = rgb(150, 156, 170), rgb(78, 84, 98), rgb(206, 212, 222), rgb(30, 30, 38), rgb(255, 40, 30)
-- Mecha T-Rex: steel robot T-Rex - glowing cyan power lines on body and skull, bolts, back exhaust pipes, a chest
-- power core, laser-red eyes and an antenna.
local CY = rgb(60, 230, 255)
both(function(sx)
	add("Torso", V(0.06, 0.2, 2.9), V(sx * 1.42, 5.2, -1.7), CY, {neon = true, rot = {-6, 0, 0}})
	add("Torso", V(0.06, 1.8, 0.2), V(sx * 1.37, 6.1, 0.9), CY, {neon = true})
	for _, z in ipairs({-2.6, -1.4, -0.2}) do add("Torso", V(0.1, 0.24, 0.24), V(sx * 1.43, 6.5, z), GD) end
	rod("Torso", V(sx * 0.6, 7.3, 0.6), V(sx * 0.7, 8.3, 1.0), 0.45, GD)                                -- exhaust pipes
	add("Torso", V(0.35, 0.12, 0.35), V(sx * 0.71, 8.4, 1.04), rgb(255, 140, 40), {neon = true})
	add("Head", V(0.06, 0.2, 2.4), V(sx * 0.97, 7.95, -7.8), CY, {neon = true})
end)
add("Torso", V(0.9, 0.9, 0.08), V(0, 5.2, -3.38), CY, {neon = true, rot = {-6, 0, 0}})                  -- power core
rod("Head", V(0.5, 9.0, -5.0), V(0.6, 10.0, -4.6), 0.12, GD); add("Head", V(0.25, 0.25, 0.25), V(0.6, 10.05, -4.6), RED, {neon = true})
return {name = "MechaTRex", parts = P, joints = J, hrpSize = V(3.6, 9.5, 8), hrpPos = V(0, 4.75, -1.5)}
