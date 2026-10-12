-- Frost Wolf Pup (Snow egg, Legendary): pale ice-blue wolf pup with pointed ears, glowing ice eyes, crystal
-- spikes along its back and a frosty scarf.
local C, CL, CD = rgb(190, 218, 246), rgb(244, 250, 255), rgb(110, 150, 210)
local k = pup{col = C, belly = CL, tailN = 3, tailW0 = 0.42, tailW1 = 0.36, tailLen = 0.45, tailCols = {C, CL}, tailCurl = -12}
cute(k, CL, rgb(60, 70, 110), {iris = rgb(90, 230, 255)})
ears(k, "point", C, rgb(150, 200, 255), 0.45, 0.7, 0.3)
for i, z in ipairs({-0.55, -0.15, 0.25, 0.6}) do add("Torso", V(0.22, 0.6 - i * 0.07, 0.22), V(0, k.by + 0.8, z), rgb(110, 230, 255), {neon = true, rot = {0, 45, 0}}) end
scarf("Torso", V(0, 0.85, -0.5), 1.3, 0.75, rgb(70, 130, 230), rgb(236, 248, 255), 0.42)
bone("Head", MOUTH, 1, rgb(170, 235, 255), {neon = true})   -- food in the mouth
return {name = "FrostWolfPup", parts = P, joints = J, hrpSize = V(1.6, 3, 2.4), hrpPos = V(0, 1.5, 0)}
