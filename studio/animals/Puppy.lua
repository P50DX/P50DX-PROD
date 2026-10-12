-- Puppy (Zoo egg, Epic): golden puppy, floppy brown ears, tongue out, red collar with a gold tag.
local C, CD, BL = rgb(232, 190, 120), rgb(150, 96, 52), rgb(250, 236, 210)
local k = pup{col = C, belly = BL, tailCurl = -40}
cute(k, BL, BLACK, {tongue = true})
ears(k, "flop", CD, nil, 0.4, 0.8)
collar("Torso", V(0, 0.85, -0.5), 1.3, 0.75, rgb(220, 50, 50), rgb(255, 210, 60), {h = 0.22})
if not SKIP_FOOD then bone("Head", MOUTH, 1, rgb(250, 244, 230)) end   -- food in the mouth
return {name = "Puppy", parts = P, joints = J, hrpSize = V(1.6, 2.8, 2.4), hrpPos = V(0, 1.4, 0)}
