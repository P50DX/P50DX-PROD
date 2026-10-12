--@base TRex
--@colors local G, GD, BE, MO, RED = rgb(40, 44, 120), rgb(22, 22, 70), rgb(140, 100, 230), rgb(70, 10, 90), rgb(80, 240, 255)
-- Cosmic T-Rex: deep-space blue T-Rex covered in stars, glowing nebula back spikes and cyan eyes.
for i = 0, 5 do add("Torso", V(0.3, 0.7 - math.abs(i - 2.5) * 0.1, 0.45), V(0, 6.55, -1.5 + i * 0.6), rgb(220, 100, 255), {neon = true, shape = "wedge", rot = {0, 180, 0}}) end
sprinkle("Torso", V(0, 4.6, 0), V(2.6, 2.8, 4.0), 16, {rgb(255, 255, 255), rgb(150, 220, 255), rgb(255, 160, 240)}, 11)
sprinkle("Head", V(0, 7.0, -3.6), V(2.4, 2.0, 3.0), 8, {rgb(255, 255, 255), rgb(150, 220, 255)}, 12)
return {name = "CosmicTRex", parts = P, joints = J, hrpSize = V(3.6, 8, 6), hrpPos = V(0, 4, -1)}
