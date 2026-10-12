-- Coyote: lean tan-grey canine, long narrow muzzle, big pointed ears, cunning half-lidded amber eyes, bushy black-tipped tail.
local T, TD, CR, BK = rgb(196, 160, 116), rgb(140, 108, 76), rgb(240, 226, 200), rgb(46, 38, 34)
local k = quad{claws = rgb(60, 50, 40), col = T, belly = CR, pawCol = CR, W = 1.7, H = 1.7, L = 3.6, legH = 1.9, legW = 0.5, head = {1.6, 1.4, 1.6}, neckUp = 0.6, tailN = 4, tailW0 = 0.65, tailW1 = 0.55, tailLen = 0.8, tailCols = {T, T, TD, BK}, tailCurl = -10}
face(k, {eyeS = 0.4, iris = rgb(240, 180, 50), brow = TD, browAng = 20, muzzle = {0.75, 0.55, 0.7, CR}, nose = {0.32, 0.22}})
ears(k, "point", T, BK, 0.6, 0.85, 0.3)
add("Torso", V(1.76, 0.25, 3.2), V(0, k.by + 0.95, 0.1), TD)
return {name = "Coyote", parts = P, joints = J, hrpSize = V(2, 4.2, 4), hrpPos = V(0, 2.1, 0)}
