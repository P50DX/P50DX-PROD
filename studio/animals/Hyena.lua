-- Hyena: sloping back (high shoulders, low hips), spotted sandy coat, dark muzzle, round ears, bristly mane, mischievous grin.
local S, SD, SP, BK = rgb(204, 176, 120), rgb(160, 130, 84), rgb(92, 66, 44), rgb(40, 32, 30)
local k = quad{col = S, belly = rgb(230, 210, 170), pawCol = SD, W = 2.0, H = 1.9, L = 3.6, legH = 1.9, legW = 0.6, head = {1.8, 1.6, 1.6}, neckUp = 0.6, tailN = 3, tailW0 = 0.35, tailW1 = 0.4, tailLen = 0.6, tailCols = {S, SD, BK}, tailCurl = -20}
local mc = face(k, {eyeS = 0.38, iris = rgb(230, 190, 60), muzzle = {1.0, 0.75, 0.9, BK}, nose = {0.36, 0.22}})
add("Head", V(0.7, 0.12, 0.05), V(0, mc.Y - 0.18, mc.Z - 0.48), WHITE)                       -- toothy grin
ears(k, "round", S, BK, 0.6, 0.6, 0.38)
add("Torso", V(2.06, 0.7, 1.7), V(0, k.by + 1.0, -1.1), S, {studs = true})                   -- high shoulders (sloped back)
for i = 0, 3 do add("Torso", V(0.3, 0.45, 0.45), V(0, k.by + 1.5 - i * 0.18, -1.6 + i * 0.6), BK) end   -- mane
for _, p in ipairs({{1.02, 0.3, -1.2}, {1.02, -0.2, -0.4}, {1.02, 0.2, 0.4}, {0.92, -0.2, 1.2}, {0.92, 0.35, 1.5}}) do
	both(function(sx) add("Torso", V(0.08, 0.36, 0.36), V(sx * p[1], k.by + p[2], p[3]), SP) end)
end
return {name = "Hyena", parts = P, joints = J, hrpSize = V(2.2, 4.4, 4), hrpPos = V(0, 2.2, 0)}
