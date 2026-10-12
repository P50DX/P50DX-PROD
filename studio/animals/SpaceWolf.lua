--@base Wolf
--@colors local G, GD, GL, Y = rgb(44, 56, 120), rgb(24, 30, 72), rgb(150, 220, 255), rgb(80, 230, 255)
-- Space Wolf: navy wolf in a glass astronaut bubble helmet with a silver collar ring, glowing cyan eyes, star-dusted fur.
add("Head", V(3.3, 3.1, 3.3), k.head + V(0, 0.15, -0.35), rgb(190, 235, 255), {shape = "ball", mat = Enum.Material.Glass, transp = 0.7})
-- helmet seal ring round the neck (inner hole smaller than the neck so it sits on it), bolts, antenna with a light
local rc = k.head + V(0, -0.9, 0.5)
for _, z in ipairs({-0.65, 0.65}) do add("Head", V(1.7, 0.36, 0.36), rc + V(0, 0, z), rgb(210, 214, 226)) end
for _, x in ipairs({-0.65, 0.65}) do add("Head", V(0.36, 0.36, 1.7), rc + V(x, 0, 0), rgb(210, 214, 226)) end
for _, x in ipairs({-0.6, 0, 0.6}) do add("Head", V(0.14, 0.14, 0.06), rc + V(x * 0.8, 0, -0.85), rgb(120, 126, 140)) end
local top = k.head + V(0, 0.15 + 1.62, -0.35)
rod("Head", top + V(0.3, -0.1, 0), top + V(0.45, 0.7, 0.1), 0.1, rgb(210, 214, 226)); add("Head", V(0.25, 0.25, 0.25), top + V(0.45, 0.75, 0.1), rgb(80, 230, 255), {neon = true, shape = "ball"})
sprinkle("Torso", V(0, k.by, -0.8), V(2.2, 2.1, 2.2), 10, {rgb(255, 255, 255), rgb(120, 230, 255)}, 3)
return {name = "SpaceWolf", parts = P, joints = J, hrpSize = V(2.4, 4.8, 4.6), hrpPos = V(0, 2.4, 0)}
