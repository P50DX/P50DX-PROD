-- Boar: heavy front, bristly dark mane ridge, long snout with big curved tusks, small angry eyes, short legs.
local B, BD, BR, TU = rgb(110, 74, 52), rgb(74, 48, 34), rgb(46, 32, 26), rgb(246, 238, 210)
local k = quad{col = B, belly = BD, pawCol = BR, W = 2.4, H = 2.2, L = 3.6, legH = 1.0, legW = 0.65, head = {2.0, 1.8, 1.7}, neckUp = 0.1, headFwd = 0.2, tailN = 2, tailW0 = 0.2, tailW1 = 0.2, tailLen = 0.5, tailCols = {BR}, tailCurl = -40}
local mc = face(k, {eyeS = 0.34, eyeY = 0.3, iris = rgb(220, 60, 40), brow = BR, browAng = 24, muzzle = {1.1, 0.85, 0.9, BD}})
add("Head", V(1.0, 0.75, 0.15), V(0, mc.Y, mc.Z - 0.52), rgb(200, 130, 120))              -- snout disc
add("Head", V(0.15, 0.3, 0.06), V(0.25, mc.Y, mc.Z - 0.61), BR); add("Head", V(0.15, 0.3, 0.06), V(-0.25, mc.Y, mc.Z - 0.61), BR)
both(function(sx) rod("Head", V(sx * 0.55, mc.Y - 0.3, mc.Z - 0.1), V(sx * 0.75, mc.Y + 0.35, mc.Z - 0.55), 0.18, TU); rod("Head", V(sx * 0.75, mc.Y + 0.35, mc.Z - 0.55), V(sx * 0.7, mc.Y + 0.65, mc.Z - 0.3), 0.14, TU) end)
ears(k, "point", B, BD, 0.5, 0.55, 0.35)
for i = 0, 5 do add("Torso", V(0.45, 0.5, 0.55), V(0, k.by + 1.25 - i * 0.07, -1.6 + i * 0.6), BR) end   -- bristle ridge
add("Torso", V(2.5, 2.3, 1.2), V(0, k.by + 0.1, -1.4), B, {studs = true})                    -- heavy shoulders
return {name = "Boar", parts = P, joints = J, hrpSize = V(2.6, 3.8, 4), hrpPos = V(0, 1.9, 0)}
