-- Sun Scarab (Desert egg, Epic): shiny teal beetle shell with a glowing gold sun on its back, horn, six legs.
local T, TD, G, BK = rgb(40, 156, 146), rgb(20, 100, 96), rgb(255, 200, 60), rgb(36, 32, 40)
add("Torso", V(1.6, 0.9, 1.8), V(0, 0.8, 0.1), T, {studs = true})
add("Torso", V(0.06, 0.92, 1.8), V(0, 0.81, 0.1), TD)
add("Torso", V(0.6, 0.06, 0.6), V(0, 1.27, 0.2), G, {neon = true})
for i = 0, 3 do add("Torso", V(0.12, 0.06, 0.45), V(0, 1.27, 0.2), G, {neon = true, rot = {0, i * 45, 0}}) end
joint("Torso", "Root", V(0, 0.8, 0))
add("Head", V(1.1, 0.75, 0.6), V(0, 0.7, -1.05), BK)
eye("Head", 0.28, 0.8, -1.37, 0.32, "cute"); eye("Head", -0.28, 0.8, -1.37, 0.32, "cute")
both(function(sx) add("Head", V(0.2, 0.08, 0.05), V(sx * 0.42, 0.55, -1.37), PINK) end)
rod("Head", V(0, 1.0, -1.2), V(0, 1.45, -1.5), 0.18, G)
joint("Head", "Torso", V(0, 0.8, -0.8))
for i, z in ipairs({-0.5, 0.1, 0.7}) do both(function(sx, s) rod("Leg" .. s .. i, V(sx * 0.7, 0.5, z), V(sx * 1.05, 0.05, z - 0.1), 0.14, BK); joint("Leg" .. s .. i, "Torso", V(sx * 0.7, 0.5, z)) end) end
sunBerry("Head", V(0, 0.62, -1.38), 0.8)   -- food in the mouth
return {name = "SunScarab", parts = P, joints = J, hrpSize = V(2, 1.8, 2.6), hrpPos = V(0, 0.9, 0)}
