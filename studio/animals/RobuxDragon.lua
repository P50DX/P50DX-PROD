--@base Dragon
--@colors local R, RD, BEL, HN, MEM, EYE = rgb(22, 170, 100), rgb(10, 108, 64), rgb(255, 206, 70), rgb(255, 214, 90), rgb(30, 196, 120), rgb(255, 220, 60)
-- Robux Dragon: emerald dragon with gold horns, belly and claws, a gold hexagon emblem on its chest, gold crown, gold sparkles.
local cz = -4.4 * 0.2 - 4.4 * 0.55 / 2 - 0.05
for _, a in ipairs({0, 60, 120}) do add("Torso", V(1.2, 0.69, 0.08), V(0, k.by + 0.3, cz), rgb(255, 210, 60), {rot = {0, 0, a}}) end
add("Torso", V(0.42, 0.42, 0.08), V(0, k.by + 0.3, cz - 0.03), rgb(10, 108, 64))
local c = k.head
add("Head", V(1.2, 0.3, 1.0), c + V(0, 0.98, 0.1), rgb(255, 210, 60))
for _, x in ipairs({-0.45, 0, 0.45}) do add("Head", V(0.25, 0.4, 0.25), c + V(x, 1.3, -0.25), rgb(255, 210, 60), {rot = {0, 45, 0}}) end
add("Head", V(0.2, 0.2, 0.08), c + V(0, 1.0, -0.42), rgb(60, 230, 255), {neon = true})
sprinkle("Torso", V(0, k.by, 0.8), V(2.4, 2.3, 2.0), 8, {rgb(255, 220, 80)}, 13)
return {name = "RobuxDragon", parts = P, joints = J, hrpSize = V(3, 5.6, 5), hrpPos = V(0, 2.8, 0)}
