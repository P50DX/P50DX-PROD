--@base IceOwl
--@colors local W, B, BD, Y, TIP, IR, TIPN = rgb(240, 214, 255), rgb(130, 80, 210), rgb(84, 46, 150), rgb(255, 200, 60), rgb(255, 120, 230), rgb(255, 120, 230), true; local SKIP_FOOD = true
-- Nebula Owl (Space egg, Epic): violet owl with glowing pink eyes and wing tips, scattered stars.
sprinkle("Torso", V(0, 1.15, 0), V(1.5, 1.8, 1.3), 8, {rgb(255, 255, 255), rgb(150, 220, 255)}, 35)
star("Head", V(0, 2.12, -0.9), 0.8, rgb(255, 120, 230), {neon = true})   -- food in the mouth
return {name = "NebulaOwl", parts = P, joints = J, hrpSize = V(1.8, 3.6, 1.6), hrpPos = V(0, 1.8, 0)}
