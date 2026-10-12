-- Magma Slime (Volcano egg, Uncommon): wobbly orange cube slime with a glowing core, dark crust drips on top, cute face.
local O, CR, CO = rgb(240, 100, 30), rgb(70, 40, 36), rgb(255, 200, 60)
add("Torso", V(1.8, 1.5, 1.8), V(0, 0.75, 0), O, {transp = 0.2})
add("Torso", V(0.9, 0.8, 0.9), V(0, 0.7, 0.1), CO, {neon = true})
add("Torso", V(1.82, 0.25, 1.82), V(0, 1.42, 0), CR)
for _, p in ipairs({{0.5, -0.92, 0.4}, {-0.4, -0.92, 0.3}, {0.92, 0.3, 0.5}, {-0.92, -0.2, 0.35}}) do add("Torso", V(math.abs(p[2]) > 0.9 and 0.3 or 0.05, p[3], math.abs(p[2]) > 0.9 and 0.05 or 0.3), V(p[1] * (math.abs(p[2]) > 0.9 and 1 or 1), 1.3 - p[3] / 2, p[2]), CR) end
eye("Torso", 0.38, 0.85, -0.93, 0.4, "cute"); eye("Torso", -0.38, 0.85, -0.93, 0.4, "cute")
add("Torso", V(0.4, 0.08, 0.05), V(0, 0.45, -0.93), CR)
both(function(sx) add("Torso", V(0.3, 0.12, 0.05), V(sx * 0.62, 0.55, -0.93), rgb(255, 90, 110)) end)
joint("Torso", "Root", V(0, 0.75, 0))
lavaRock("Torso", V(0, 0.45, -0.95), 1)   -- food in the mouth
return {name = "MagmaSlime", parts = P, joints = J, hrpSize = V(1.8, 1.6, 1.8), hrpPos = V(0, 0.8, 0)}
