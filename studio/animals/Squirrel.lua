-- Squirrel: upright sitting body, huge S-curved bushy tail with cream underside, tufted ears, big front teeth.
local R, RD, CR = rgb(196, 106, 52), rgb(150, 74, 34), rgb(250, 228, 196)
add("Torso", V(1.7, 2.1, 1.7), V(0, 1.75, 0.2), R, {studs = true, rot = {8, 0, 0}})
add("Torso", V(1.2, 1.6, 0.25), V(0, 1.65, -0.7), CR, {rot = {8, 0, 0}})
add("Head", V(1.6, 1.4, 1.5), V(0, 3.35, -0.35), R, {studs = true})
add("Head", V(0.85, 0.6, 0.55), V(0, 3.05, -1.3), CR)
add("Head", V(0.26, 0.2, 0.12), V(0, 3.25, -1.58), BLACK)
add("Head", V(0.3, 0.28, 0.07), V(0, 2.7, -1.57), WHITE)
eye("Head", 0.42, 3.55, -1.13, 0.38, "cute"); eye("Head", -0.42, 3.55, -1.13, 0.38, "cute")
both(function(sx, s)
	add("Ear" .. s, V(0.45, 0.6, 0.2), V(sx * 0.55, 4.3, -0.25), R, {rot = {0, 0, sx * -10}}); add("Ear" .. s, V(0.18, 0.3, 0.18), V(sx * 0.6, 4.72, -0.25), RD)  -- tufts
	joint("Ear" .. s, "Head", V(sx * 0.5, 4.0, -0.25))
	add("ArmF" .. s, V(0.38, 0.8, 0.4), V(sx * 0.5, 2.0, -0.95), R, {rot = {-35, 0, 0}}); add("ArmF" .. s, V(0.35, 0.25, 0.3), V(sx * 0.4, 1.75, -1.25), CR)
	joint("ArmF" .. s, "Torso", V(sx * 0.6, 2.3, -0.7))
	add("LegB" .. s, V(0.7, 0.9, 1.1), V(sx * 0.75, 0.6, 0.35), R, {studs = true}); add("LegB" .. s, V(0.5, 0.15, 0.9), V(sx * 0.75, 0.07, -0.3), RD)
	joint("LegB" .. s, "Torso", V(sx * 0.7, 1.0, 0.4))
end)
joint("Torso", "Root", V(0, 1.5, 0.2)); joint("Head", "Torso", V(0, 2.8, -0.2))
-- bushy tail: up the back, curling forward over the top
local pts = {V(0, 1.0, 1.2), V(0, 2.0, 1.85), V(0, 3.2, 2.0), V(0, 4.2, 1.7), V(0, 4.8, 1.05)}
local wid = {0.8, 1.15, 1.3, 1.2, 0.95}
for i = 1, #pts - 1 do
	rod("Tail" .. i, pts[i], pts[i + 1], wid[i], (i % 2 == 0) and RD or R, {studs = true, extra = 0.3})
	add("Tail" .. i, V(wid[i] * 0.6, 0.3, 0.3), pts[i + 1] + V(0, 0, -0.05), CR)
	joint("Tail" .. i, i == 1 and "Torso" or "Tail" .. (i - 1), pts[i])
end
return {name = "Squirrel", parts = P, joints = J, hrpSize = V(2, 4.4, 3), hrpPos = V(0, 2.2, 0.4)}
