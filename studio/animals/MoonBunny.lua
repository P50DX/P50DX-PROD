--@base SnowBunny
--@colors local W, WS = rgb(206, 190, 255), rgb(170, 150, 236)
-- Moon Bunny (Space egg, Uncommon): lavender bunny with a glowing crescent moon on its forehead.
add("Head", V(0.4, 0.4, 0.05), V(0, 2.35, -0.81), rgb(255, 236, 120), {neon = true})
add("Head", V(0.32, 0.36, 0.05), V(0.12, 2.39, -0.83), W)
sprinkle("Torso", V(0, 0.75, 0.15), V(1.3, 1.2, 1.3), 5, {rgb(255, 255, 255)}, 33)
return {name = "MoonBunny", parts = P, joints = J, hrpSize = V(1.6, 3.6, 1.8), hrpPos = V(0, 1.8, 0)}
