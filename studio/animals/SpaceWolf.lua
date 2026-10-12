--@base Wolf
--@colors local G, GD, GL, Y = rgb(44, 56, 120), rgb(24, 30, 72), rgb(150, 220, 255), rgb(80, 230, 255)
-- Space Wolf: navy wolf in a glass astronaut bubble helmet with a silver collar ring, glowing cyan eyes, star-dusted fur.
add("Head", V(3.3, 3.1, 3.3), k.head + V(0, 0.15, -0.35), rgb(190, 235, 255), {shape = "ball", mat = Enum.Material.Glass, transp = 0.7})
add("Head", V(2.6, 0.35, 2.4), k.head + V(0, -1.3, 0.1), rgb(210, 214, 226))
sprinkle("Torso", V(0, k.by, -0.8), V(2.2, 2.1, 2.2), 10, {rgb(255, 255, 255), rgb(120, 230, 255)}, 3)
return {name = "SpaceWolf", parts = P, joints = J, hrpSize = V(2.4, 4.8, 4.6), hrpPos = V(0, 2.4, 0)}
