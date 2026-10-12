-- Frost Wolf Pup (Snow egg, Legendary): pale ice-blue wolf pup with pointed ears, glowing ice eyes, crystal
-- spikes along its back and a frosty scarf.
local C, CL, CD = rgb(190, 218, 246), rgb(244, 250, 255), rgb(110, 150, 210)
local k = pup{col = C, belly = CL, tailN = 3, tailW0 = 0.42, tailW1 = 0.36, tailLen = 0.45, tailCols = {C, CL}, tailCurl = -12}
cute(k, CL, rgb(60, 70, 110), {iris = rgb(90, 230, 255)})
ears(k, "point", C, rgb(150, 200, 255), 0.45, 0.7, 0.3)
for i, z in ipairs({-0.55, -0.15, 0.25, 0.6}) do add("Torso", V(0.22, 0.6 - i * 0.07, 0.22), V(0, k.by + 0.8, z), rgb(110, 230, 255), {neon = true, rot = {0, 45, 0}}) end
add("Torso", V(1.45, 0.25, 0.75), V(0, k.by + 0.35, -0.75), rgb(70, 130, 230)); add("Torso", V(0.3, 0.6, 0.2), V(0.45, k.by, -1.15), rgb(70, 130, 230))
return {name = "FrostWolfPup", parts = P, joints = J, hrpSize = V(1.6, 3, 2.4), hrpPos = V(0, 1.5, 0)}
