--@base Dragon
--@colors local R, RD, BEL, HN, MEM, EYE = rgb(44, 28, 70), rgb(22, 14, 38), rgb(130, 70, 220), rgb(210, 180, 255), rgb(80, 30, 140), rgb(230, 80, 255)
-- Void Dragon: black-violet dragon with glowing magenta eyes, starry wing membranes and a dark-energy chest.
local f = k.face
add("Torso", V(1.2, 1.2, 0.06), V(0, k.by + 0.2, -4.4 * 0.2 - 4.4 * 0.55 / 2 - 0.03), rgb(200, 60, 255), {neon = true, rot = {0, 0, 45}})
sprinkle("Torso", V(0, k.by, -0.9), V(2.6, 2.4, 2.4), 10, {rgb(255, 255, 255), rgb(220, 120, 255)}, 8)
return {name = "VoidDragon", parts = P, joints = J, hrpSize = V(3, 5.6, 5), hrpPos = V(0, 2.8, 0)}
