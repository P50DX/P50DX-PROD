-- Puppy (Zoo egg, Epic): golden puppy, floppy brown ears, tongue out, red collar with a gold tag.
local C, CD, BL = rgb(232, 190, 120), rgb(150, 96, 52), rgb(250, 236, 210)
local k = pup{col = C, belly = BL, tailCurl = -40}
cute(k, BL, BLACK, {tongue = true})
ears(k, "flop", CD, nil, 0.4, 0.8)
add("Torso", V(1.4, 0.2, 0.7), V(0, k.by + 0.35, -0.75), rgb(220, 50, 50)); add("Torso", V(0.22, 0.22, 0.06), V(0, k.by + 0.15, -1.12), rgb(255, 210, 60))
return {name = "Puppy", parts = P, joints = J, hrpSize = V(1.6, 2.8, 2.4), hrpPos = V(0, 1.4, 0)}
