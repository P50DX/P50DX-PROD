-- Gorilla (scary): knuckle-walker - huge shoulders and arms, silver back, heavy brow ridge, glowing red eyes,
-- bared fangs, short legs.
local B, BD, SK, SV, RED = rgb(48, 46, 52), rgb(30, 28, 34), rgb(92, 86, 94), rgb(170, 172, 180), rgb(255, 40, 40)
add("Torso", V(3.6, 2.6, 2.4), V(0, 4.0, -0.6), B, {studs = true})                          -- chest + shoulders
add("Torso", V(2.8, 2.0, 2.0), V(0, 3.2, 1.2), SV, {studs = true})                           -- silver back / hips
add("Torso", V(2.2, 1.6, 0.3), V(0, 3.8, -1.85), SK)                                         -- chest plate
add("Torso", V(1.0, 0.7, 0.1), V(-0.55, 4.3, -2.02), BD); add("Torso", V(1.0, 0.7, 0.1), V(0.55, 4.3, -2.02), BD)   -- pecs
joint("Torso", "Root", V(0, 3.6, 0))
add("Head", V(1.9, 1.8, 1.7), V(0, 5.5, -1.5), B, {studs = true})
add("Head", V(1.3, 0.8, 0.4), V(0, 6.5, -1.6), B, {studs = true})                           -- crest
add("Head", V(1.5, 1.2, 0.4), V(0, 5.15, -2.45), SK)                                         -- face
add("Head", V(1.9, 0.35, 0.6), V(0, 5.95, -2.4), BD)                                         -- brow ridge
both(function(sx)
	add("Head", V(0.42, 0.26, 0.06), V(sx * 0.42, 5.62, -2.67), BLACK)
	add("Head", V(0.32, 0.18, 0.06), V(sx * 0.42, 5.62, -2.69), RED, {neon = true})
	add("Head", V(0.5, 0.18, 0.2), V(sx * 0.45, 5.83, -2.62), BD, {rot = {0, 0, sx * -20}})       -- angry brows
	add("Head", V(0.2, 0.14, 0.06), V(sx * 0.18, 5.15, -2.67), BLACK)                            -- nostrils
	add("Head", V(0.14, 0.3, 0.08), V(sx * 0.35, 4.6, -2.72), WHITE, {shape = "wedge", rot = {0, 0, 180}})   -- fangs
end)
add("Head", V(1.0, 0.35, 0.06), V(0, 4.72, -2.67), BLACK)                                    -- snarl
add("Head", V(0.7, 0.1, 0.07), V(0, 4.85, -2.7), WHITE)                                      -- teeth row
joint("Head", "Torso", V(0, 5.0, -1.2))
both(function(sx, s)
	local sh = V(sx * 2.0, 4.6, -1.0)
	add("Arm" .. s, V(1.3, 1.4, 1.3), sh, B, {studs = true})
	rod("Arm" .. s, sh, V(sx * 2.2, 2.1, -1.5), 1.2, B)
	rod("Arm" .. s, V(sx * 2.2, 2.1, -1.5), V(sx * 2.2, 0.5, -1.7), 1.0, B)
	add("Arm" .. s, V(1.2, 0.6, 1.2), V(sx * 2.2, 0.3, -1.8), SK)                               -- knuckles
	joint("Arm" .. s, "Torso", sh)
	add("Leg" .. s, V(1.0, 2.2, 1.1), V(sx * 1.0, 1.4, 1.6), B, {studs = true})
	add("Leg" .. s, V(1.1, 0.4, 1.5), V(sx * 1.0, 0.2, 1.4), SK)
	joint("Leg" .. s, "Torso", V(sx * 1.0, 2.5, 1.6))
end)
return {name = "Gorilla", parts = P, joints = J, hrpSize = V(5, 7, 4.5), hrpPos = V(0, 3.5, 0)}
