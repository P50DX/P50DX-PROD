-- Parrot (scarlet macaw): upright body with the head sitting ON TOP (not in front), white bare-skin face patches,
-- short hooked beak tucked under the face, folded wings red -> yellow -> blue, long pointed tail, grippy feet
-- (two toes forward, two back).
local RD, RDD, YE, BL, BEAK, GR = rgb(222, 40, 40), rgb(176, 26, 30), rgb(255, 206, 40), rgb(40, 110, 230), rgb(236, 230, 214), rgb(110, 110, 120)
add("Torso", V(1.5, 2.0, 1.4), V(0, 2.0, 0.25), RD, {studs = true, rot = {10, 0, 0}})
add("Torso", V(1.1, 1.3, 0.12), V(0, 2.0, -0.48), RDD, {rot = {10, 0, 0}})                 -- chest shading
joint("Torso", "Root", V(0, 2.0, 0.25))
add("Head", V(1.4, 1.35, 1.35), V(0, 3.55, 0.0), RD, {studs = true})
add("Head", V(1.12, 0.62, 0.06), V(0, 3.62, -0.7), WHITE)                                    -- face patch
for _, y in ipairs({3.5, 3.72}) do add("Head", V(0.9, 0.03, 0.03), V(0, y, -0.74), rgb(180, 180, 190)) end
eye("Head", 0.3, 3.68, -0.75, 0.28, "cute"); eye("Head", -0.3, 3.68, -0.75, 0.28, "cute")
add("Head", V(0.5, 0.36, 0.34), V(0, 3.42, -0.84), BEAK)                                     -- upper beak
add("Head", V(0.4, 0.3, 0.24), V(0, 3.22, -0.98), BEAK, {rot = {30, 0, 0}})                  -- hook
add("Head", V(0.22, 0.16, 0.16), V(0, 3.06, -0.98), rgb(60, 56, 60))                         -- hook tip
add("Head", V(0.36, 0.18, 0.26), V(0, 3.15, -0.8), rgb(40, 36, 40))                          -- lower beak
joint("Head", "Torso", V(0, 2.95, 0.05))
both(function(sx, s)
	foldedWing("Wing" .. s, V(sx * 0.75, 2.75, -0.3), sx, 1.9, 1.8, {RD, YE, BL})
	joint("Wing" .. s, "Torso", V(sx * 0.75, 2.75, -0.2))
	rod("Leg" .. s, V(sx * 0.35, 1.15, 0.3), V(sx * 0.35, 0.12, 0.25), 0.22, GR)
	for _, dx in ipairs({-0.09, 0.09}) do
		add("Leg" .. s, V(0.1, 0.14, 0.36), V(sx * 0.35 + dx, 0.08, 0.02), GR)                    -- toes forward
		add("Leg" .. s, V(0.1, 0.14, 0.3), V(sx * 0.35 + dx, 0.08, 0.45), GR)                     -- toes back
	end
	joint("Leg" .. s, "Torso", V(sx * 0.35, 1.15, 0.3))
end)
rod("Tail1", V(0, 1.3, 0.8), V(0, 0.35, 2.4), 0.5, RD, {h = 0.18})                          -- long pointed tail
for _, x in ipairs({-0.22, 0.22}) do rod("Tail1", V(x, 1.3, 0.85), V(x * 1.2, 0.45, 2.1), 0.32, BL, {h = 0.16}) end
joint("Tail1", "Torso", V(0, 1.3, 0.8))
return {name = "Parrot", parts = P, joints = J, hrpSize = V(2, 4.4, 2.4), hrpPos = V(0, 2.2, 0.4)}
