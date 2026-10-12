-- Giraffe (stylized middle ground): chunky long neck, long legs, brown patch spots, ossicones with dark knobs,
-- cream muzzle, side ears, dark mane strip, tufted tail.
local GO, SP, CR, DK = rgb(240, 186, 78), rgb(176, 98, 40), rgb(250, 232, 196), rgb(92, 58, 36)
local k = quad{hoof = "split", col = GO, belly = CR, pawCol = DK, W = 1.8, H = 1.8, L = 3.2, legH = 3.2, legW = 0.6, head = {1.3, 1.2, 1.5}, neckUp = 4.0, headFwd = 0.6, tailN = 3, tailW0 = 0.22, tailW1 = 0.2, tailLen = 0.6, tailCols = {GO, GO, DK}, tailCurl = -30}
local f, c = k.face, k.head
face(k, {eyeS = 0.34, eyeY = 0.2, eyeX = 0.28, muzzle = {1.0, 0.55, 0.7, CR}, nose = {0.5, 0.12, DK}})
both(function(sx, s)
	rod("Head", V(sx * 0.32, c.Y + 0.5, c.Z + 0.35), V(sx * 0.4, c.Y + 1.15, c.Z + 0.5), 0.22, GO)     -- ossicones
	add("Head", V(0.32, 0.28, 0.32), V(sx * 0.4, c.Y + 1.22, c.Z + 0.5), DK)
	add("Ear" .. s, V(0.6, 0.22, 0.32), V(sx * 0.85, c.Y + 0.4, c.Z + 0.3), GO, {rot = {0, 0, sx * -20}})
	add("Ear" .. s, V(0.4, 0.06, 0.2), V(sx * 0.85, c.Y + 0.38, c.Z + 0.13), PINK, {rot = {0, 0, sx * -20}})
	joint("Ear" .. s, "Head", V(sx * 0.6, c.Y + 0.35, c.Z + 0.3))
	add("Head", V(0.3, 0.14, 0.06), V(sx * 0.48, c.Y - 0.1, f - 0.02), PINK)                         -- blush
end)
-- spots on the body sides and the neck
for _, p in ipairs({{3.9, -1.0}, {4.5, -0.2}, {3.7, 0.6}, {4.4, 1.2}, {3.95, -1.4}}) do
	both(function(sx) add("Torso", V(0.06, 0.45, 0.5), V(sx * 0.91, p[1], p[2]), SP) end)
end
local a, b = V(0, k.by + 0.36, -1.3), c + V(0, -0.24, 0.3)
for i = 1, 4 do
	local q = a + (b - a) * (i / 5)
	both(function(sx) add("Head", V(0.06, 0.4, 0.4), q + V(sx * 0.5, 0, (i % 2) * 0.15), SP) end)
end
rod("Head", a + V(0, 0.2, 0.45), b + V(0, 0.4, 0.5), 0.26, DK)                                     -- mane
return {name = "Giraffe", parts = P, joints = J, hrpSize = V(2, 10, 4), hrpPos = V(0, 5, -0.5)}
