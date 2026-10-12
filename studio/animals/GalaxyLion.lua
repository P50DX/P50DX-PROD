--@base Lion
--@colors local G, GD, MN, MND, CR, CRW = rgb(120, 76, 200), rgb(80, 46, 150), rgb(40, 36, 120), rgb(24, 18, 80), rgb(220, 200, 255), rgb(255, 120, 220)
-- Galaxy Lion: violet lion with a deep-space mane full of stars and a glowing pink crown.
sprinkle("Head", k.head + V(0, 0, 0.4), V(3.2, 3.0, 1.2), 14, {rgb(255, 255, 255), rgb(255, 150, 240), rgb(120, 220, 255)}, 5)
sprinkle("Torso", V(0, k.by, -0.8), V(2.4, 2.2, 2.3), 8, {rgb(255, 255, 255), rgb(255, 150, 240)}, 9)
return {name = "GalaxyLion", parts = P, joints = J, hrpSize = V(2.6, 5, 4.6), hrpPos = V(0, 2.5, 0)}
