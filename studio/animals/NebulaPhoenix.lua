--@base Phoenix
--@colors local RD, OR, YE, GD, FL = rgb(150, 60, 210), rgb(236, 90, 200), rgb(120, 230, 255), rgb(250, 220, 255), rgb(255, 110, 220)
-- Nebula Phoenix: violet phoenix with pink-cyan nebula flames and star sparks.
sprinkle("Torso", V(0, 3.0, 0), V(2.0, 2.2, 2.4), 8, {rgb(255, 255, 255), rgb(120, 230, 255)}, 6)
return {name = "NebulaPhoenix", parts = P, joints = J, hrpSize = V(2.6, 6.2, 3), hrpPos = V(0, 3.1, 0.3)}
