-- Falcon: upright sleek raptor - slate back, barred cream chest, dark "moustache" marks, head sitting on top of the
-- body, short hooked yellow-and-dark beak, piercing eyes, folded pointed wings, fanned tail, yellow talons.
local SL, SLD, CR, Y, BK = rgb(90, 104, 130), rgb(56, 64, 84), rgb(244, 232, 212), rgb(250, 196, 40), rgb(30, 30, 36)
add("Torso", V(1.6, 2.1, 1.5), V(0, 2.45, 0.15), SL, {studs = true})
add("Torso", V(1.2, 1.6, 0.1), V(0, 2.35, -0.62), CR)                                          -- cream chest
for i = 0, 3 do add("Torso", V(1.0, 0.07, 0.06), V(0, 1.85 + i * 0.36, -0.68), SLD) end         -- chest bars
joint("Torso", "Root", V(0, 2.4, 0.15))
add("Head", V(1.4, 1.25, 1.35), V(0, 4.08, 0.0), SLD, {studs = true})
add("Head", V(1.1, 0.7, 0.08), V(0, 3.8, -0.71), CR)                                           -- pale cheeks
both(function(sx) add("Head", V(0.2, 0.5, 0.06), V(sx * 0.45, 3.68, -0.76), BK) end)            -- moustache marks
eye("Head", 0.36, 4.18, -0.72, 0.36, "sharp", Y); eye("Head", -0.36, 4.18, -0.72, 0.36, "sharp", Y)
brow("Head", 0.38, 4.47, -0.72, 0.48, BK, 20); brow("Head", -0.38, 4.47, -0.72, 0.48, BK, 20)
add("Head", V(0.44, 0.32, 0.3), V(0, 3.78, -0.82), Y)                                          -- cere + upper beak
add("Head", V(0.34, 0.28, 0.22), V(0, 3.6, -0.94), BK, {rot = {30, 0, 0}})                     -- hooked tip
joint("Head", "Torso", V(0, 3.45, 0.05))
both(function(sx, s)
	foldedWing("Wing" .. s, V(sx * 0.8, 3.3, -0.35), sx, 2.0, 1.9, {SL, SLD, SLD:Lerp(BK, 0.3)})
	joint("Wing" .. s, "Torso", V(sx * 0.8, 3.3, -0.2))
	rod("Leg" .. s, V(sx * 0.4, 1.45, 0.15), V(sx * 0.4, 0.15, 0.1), 0.3, Y)
	add("Leg" .. s, V(0.6, 0.15, 0.7), V(sx * 0.4, 0.08, -0.1), Y)
	for _, dx in ipairs({-0.18, 0, 0.18}) do add("Leg" .. s, V(0.08, 0.12, 0.14), V(sx * 0.4 + dx, 0.07, -0.5), BK, {shape = "wedge", rot = {0, 180, 0}}) end
	joint("Leg" .. s, "Torso", V(sx * 0.4, 1.5, 0.15))
end)
featherFan("Tail1", V(0, 1.6, 0.85), 5, 1.4, 0.42, {SLD, SL}, -55, 50)                          -- fanned tail pointing down-back
joint("Tail1", "Torso", V(0, 1.6, 0.85))
return {name = "Falcon", parts = P, joints = J, hrpSize = V(2, 4.8, 2.4), hrpPos = V(0, 2.4, 0.2)}
