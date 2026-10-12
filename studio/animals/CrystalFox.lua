--@base FennecFox
--@colors local C, CL, CD = rgb(170, 220, 255), rgb(236, 248, 255), rgb(90, 200, 255)
-- Crystal Fox (Snow egg, Rare): icy blue fox with glowing crystal shards on its back and tail tip.
for i, z in ipairs({-0.3, 0.2, 0.6}) do add("Torso", V(0.2, 0.5 - i * 0.08, 0.2), V((i % 2 - 0.5) * 0.3, k.by + 0.75, z), rgb(120, 230, 255), {neon = true, rot = {0, 45, (i % 2 - 0.5) * 30}}) end
return {name = "CrystalFox", parts = P, joints = J, hrpSize = V(1.6, 3.4, 2.4), hrpPos = V(0, 1.7, 0)}
