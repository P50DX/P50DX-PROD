-- Rhino: heavy grey armour plates, big front horn + small horn, little ears, folds on legs, grumpy brow.
local G, GD, HN = rgb(140, 140, 150), rgb(100, 100, 112), rgb(232, 222, 196)
local k = quad{col = G, belly = GD, pawCol = GD, W = 3.0, H = 2.6, L = 4.6, legH = 1.5, legW = 1.0, head = {1.9, 1.7, 2.2}, neckUp = 0.0, headFwd = 0.6, tailN = 2, tailW0 = 0.25, tailW1 = 0.2, tailLen = 0.5, tailCols = {GD}, tailCurl = -40}
local f, c = k.face, k.head
add("Head", V(1.5, 1.0, 0.6), V(0, c.Y - 0.3, f - 0.27), G, {studs = true})                 -- snout
add("Head", V(0.62, 0.45, 0.62), V(0, c.Y + 0.38, f - 0.38), HN)                              -- big horn, tapering
add("Head", V(0.46, 0.45, 0.46), V(0, c.Y + 0.78, f - 0.32), HN, {rot = {12, 0, 0}})
add("Head", V(0.28, 0.42, 0.28), V(0, c.Y + 1.14, f - 0.2), HN, {rot = {24, 0, 0}})
add("Head", V(0.38, 0.4, 0.38), V(0, c.Y + 1.0, f + 0.35), HN); add("Head", V(0.22, 0.25, 0.22), V(0, c.Y + 1.3, f + 0.38), HN)   -- small horn
both(function(sx)
	eye("Head", sx * 0.62, c.Y + 0.25, f, 0.3, "angry"); brow("Head", sx * 0.62, c.Y + 0.5, f - 0.02, 0.45, GD, 18)
	add("Head", V(0.15, 0.12, 0.06), V(sx * 0.35, c.Y - 0.2, f - 0.6), BLACK)
end)
add("Head", V(0.9, 0.08, 0.06), V(0, c.Y - 0.6, f - 0.6), BLACK)
ears(k, "point", G, PINK, 0.4, 0.55, 0.38)
for i = 0, 2 do add("Torso", V(3.1, 0.25, 0.3), V(0, k.by + 0.4 - i * 0.05, -1.3 + i * 1.6), GD) end   -- plate folds
return {name = "Rhino", parts = P, joints = J, hrpSize = V(3.2, 5, 6), hrpPos = V(0, 2.5, 0)}
