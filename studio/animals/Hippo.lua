-- Hippo: chunky purple-grey barrel, huge wide head with pink mouth, little tusks, nostrils on top, tiny ears.
local G, GD, PK = rgb(150, 126, 160), rgb(112, 90, 124), rgb(236, 150, 168)
local k = quad{col = G, belly = PK, pawCol = GD, W = 3.2, H = 2.4, L = 4.2, legH = 1.1, legW = 1.0, head = {2.4, 1.6, 2.0}, neckUp = 0.1, headFwd = 0.5, tailN = 1, tailW0 = 0.3, tailW1 = 0.3, tailLen = 0.4, tailCols = {GD}, tailCurl = -30}
local f, c = k.face, k.head
add("Head", V(2.7, 1.0, 1.5), V(0, c.Y - 0.6, f - 0.65), G)                -- upper muzzle
add("Head", V(2.5, 0.55, 1.4), V(0, c.Y - 1.25, f - 0.6), PK)                              -- open pink mouth
add("Head", V(2.5, 0.35, 1.4), V(0, c.Y - 1.55, f - 0.6), G)                               -- lower jaw
both(function(sx)
	add("Head", V(0.25, 0.4, 0.25), V(sx * 0.9, c.Y - 1.2, f - 1.2), WHITE)                     -- tusks
	add("Head", V(0.3, 0.15, 0.3), V(sx * 0.5, c.Y - 0.05, f - 1.0), GD)                         -- nostrils
	add("Head", V(0.6, 0.5, 0.5), V(sx * 0.6, c.Y + 1.0, f + 0.25), G)                          -- eye bumps
	eye("Head", sx * 0.6, c.Y + 1.0, f - 0.04, 0.38, "cute")
	add("Head", V(0.4, 0.15, 0.06), V(sx * 1.05, c.Y - 0.3, f - 1.42), PINK)
end)
ears(k, "round", G, PK, 0.35, 0.3, 0.4)
return {name = "Hippo", parts = P, joints = J, hrpSize = V(3.4, 4.2, 6), hrpPos = V(0, 2.1, 0)}
