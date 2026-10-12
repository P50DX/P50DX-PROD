-- Elephant: big grey body, huge flapping ears with pink inside, long curled trunk, short tusks, cute eyes, toenails.
local G, GD, GL, TU = rgb(150, 160, 176), rgb(110, 118, 134), rgb(184, 192, 206), rgb(250, 244, 226)
local k = quad{nails = TU, col = G, belly = GD, pawCol = GL, W = 3.4, H = 3.0, L = 4.8, legH = 2.0, legW = 1.2, head = {2.4, 2.3, 2.0}, neckUp = 0.2, headFwd = 0.4, tailN = 2, tailW0 = 0.3, tailW1 = 0.25, tailLen = 0.6, tailCols = {GD}, tailCurl = -40}
local f, c = k.face, k.head
add("Head", V(2.2, 0.6, 1.8), V(0, c.Y + 1.3, c.Z + 0.1), G, {studs = true})               -- forehead dome
-- trunk: hangs down from the face, tapering, curling forward at the tip, with crease rings
local tp = {V(0, c.Y - 0.2, f - 0.25), V(0, c.Y - 0.9, f - 0.5), V(0, c.Y - 1.6, f - 0.6), V(0, c.Y - 2.2, f - 0.55), V(0, c.Y - 2.6, f - 0.8), V(0, c.Y - 2.65, f - 1.15)}
for i = 1, #tp - 1 do
	local w = 0.85 - i * 0.1
	rod("Head", tp[i], tp[i + 1], w, G)
	add("Head", V(w + 0.04, 0.06, w + 0.04), tp[i + 1], GD)
end
both(function(sx, s)
	eye("Head", sx * 0.62, c.Y + 0.35, f, 0.4, "cute")
	add("Head", V(0.4, 0.15, 0.06), V(sx * 0.9, c.Y - 0.1, f - 0.02), PINK)
	rod("Head", V(sx * 0.6, c.Y - 0.6, f - 0.1), V(sx * 0.7, c.Y - 1.0, f - 0.9), 0.3, TU)       -- tusks
	add("Ear" .. s, V(0.25, 2.4, 2.0), V(sx * 1.6, c.Y + 0.1, c.Z + 0.4), G, {studs = true, rot = {0, sx * -25, 0}})
	add("Ear" .. s, V(0.08, 1.8, 1.4), V(sx * 1.5, c.Y + 0.1, c.Z + 0.1), PINK, {rot = {0, sx * -25, 0}})
	joint("Ear" .. s, "Head", V(sx * 1.2, c.Y + 0.1, c.Z))
end)
return {name = "Elephant", parts = P, joints = J, hrpSize = V(3.6, 7, 6), hrpPos = V(0, 3.5, 0)}
