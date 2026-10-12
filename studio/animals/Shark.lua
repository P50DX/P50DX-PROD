-- Shark: grey torpedo "swimming" just above the ground, white belly, dorsal + pectoral fins, tall tail fin,
-- wide toothy grin and mean little eyes under a brow.
local G, GD, WB = rgb(96, 118, 142), rgb(64, 82, 104), rgb(238, 242, 246)
add("Torso", V(2.2, 2.0, 3.0), V(0, 1.9, 0), G, {studs = true})
add("Torso", V(2.0, 0.5, 3.0), V(0, 0.9, 0), WB)
add("Torso", V(1.2, 0.3, 1.0), V(0, 3.05, 0.2), GD, {rot = {-20, 0, 0}})                   -- dorsal fin base
add("Torso", V(0.3, 1.3, 1.0), V(0, 3.4, 0.4), GD, {shape = "wedge", rot = {0, 180, 0}})   -- dorsal fin
joint("Torso", "Root", V(0, 1.8, 0))
add("Head", V(2.0, 1.8, 1.8), V(0, 1.85, -2.3), G, {studs = true})
add("Head", V(1.4, 1.1, 0.9), V(0, 2.1, -3.5), G)                                          -- snout
add("Head", V(1.9, 0.5, 1.7), V(0, 1.15, -2.4), WB)                                        -- jaw
add("Head", V(1.5, 0.22, 0.06), V(0, 1.45, -3.21), BLACK)                                  -- mouth
for _, x in ipairs({-0.6, -0.36, -0.12, 0.12, 0.36, 0.6}) do add("Head", V(0.15, 0.2, 0.06), V(x, 1.5, -3.24), WHITE, {shape = "wedge", rot = {0, 0, 180}}) end
both(function(sx)
	eye("Head", sx * 0.62, 2.35, -3.22, 0.3, "angry")
	add("Head", V(0.5, 0.12, 0.08), V(sx * 0.6, 2.62, -3.22), GD, {rot = {0, 0, sx * 18}})
	for i = 0, 2 do add("Head", V(0.06, 0.6, 0.3), V(sx * 1.02, 1.9, -1.9 + i * 0.3), GD) end   -- gills
end)
joint("Head", "Torso", V(0, 1.9, -1.4))
both(function(sx, s)
	add("Fin" .. s, V(1.3, 0.2, 0.9), V(sx * 1.6, 1.1, -0.8), GD, {rot = {0, sx * 20, sx * -25}})
	joint("Fin" .. s, "Torso", V(sx * 1.1, 1.3, -0.8))
end)
add("Tail1", V(1.5, 1.4, 1.6), V(0, 1.9, 2.3), G, {studs = true}); joint("Tail1", "Torso", V(0, 1.9, 1.5))
add("Tail2", V(0.9, 0.9, 1.4), V(0, 1.95, 3.7), G); joint("Tail2", "Tail1", V(0, 1.95, 3.1))
add("Tail2", V(0.25, 1.8, 0.8), V(0, 3.0, 4.6), GD, {rot = {-25, 0, 0}})                    -- upper lobe
add("Tail2", V(0.25, 1.1, 0.7), V(0, 1.2, 4.45), GD, {rot = {30, 0, 0}})                    -- lower lobe
return {name = "Shark", parts = P, joints = J, hrpSize = V(2.6, 3.8, 7), hrpPos = V(0, 1.9, 0)}
