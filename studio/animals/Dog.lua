-- Dog: golden retriever-ish - floppy ears, happy tongue-out smile, wagging tail, sturdy legs.
local G, GD, CR = rgb(226, 170, 84), rgb(186, 128, 54), rgb(250, 230, 190)
local k = quad{col = G, belly = CR, W = 2.0, H = 1.8, L = 3.4, legH = 1.4, legW = 0.65, head = {1.9, 1.7, 1.7}, neckUp = 0.6, tailN = 4, tailW0 = 0.45, tailW1 = 0.35, tailLen = 0.7, tailCols = {G}, tailCurl = 18}
face(k, {eyeS = 0.42, muzzle = {1.1, 0.75, 0.8, CR}, nose = {0.45, 0.3}, tongue = true})
ears(k, "flop", GD, nil, 0.55, 1.2)
add("Torso", V(1.4, 0.25, 0.6), V(0, 3.1, -1.75), rgb(220, 40, 40))                     -- red collar
add("Torso", V(0.3, 0.3, 0.1), V(0, 2.85, -2.08), rgb(250, 200, 40))                     -- tag
return {name = "Dog", parts = P, joints = J, hrpSize = V(2.2, 3.8, 3.8), hrpPos = V(0, 1.9, 0)}
