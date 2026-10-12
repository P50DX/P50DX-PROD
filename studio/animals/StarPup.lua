--@base Puppy
--@colors local C, CD, BL = rgb(56, 70, 150), rgb(30, 36, 96), rgb(176, 196, 255); local SKIP_FOOD = true
-- Star Pup (Space egg, Common): navy puppy with a glowing star on its forehead and star-dusted fur.
local s = V(0, k.head.Y + 0.45, k.face)
add("Head", V(0.3, 0.3, 0.05), s, rgb(255, 230, 90), {neon = true, rot = {0, 0, 45}}); add("Head", V(0.3, 0.3, 0.05), s, rgb(255, 230, 90), {neon = true})
sprinkle("Torso", V(0, k.by, 0), V(1.3, 1.1, 1.6), 6, {rgb(255, 255, 255), rgb(150, 220, 255)}, 31)
star("Head", MOUTH, 1, rgb(240, 196, 110), {icing = rgb(255, 240, 120)})   -- food in the mouth
return {name = "StarPup", parts = P, joints = J, hrpSize = V(1.6, 2.8, 2.4), hrpPos = V(0, 1.4, 0)}
