-- Falcon: sleek raptor - slate back, barred cream chest, dark "moustache" mark, hooked yellow beak, piercing eyes, folded pointed wings.
local SL, SLD, CR, Y, BK = rgb(90, 104, 130), rgb(56, 64, 84), rgb(244, 232, 212), rgb(250, 196, 40), rgb(30, 30, 36)
add("Torso", V(1.6, 2.2, 1.8), V(0, 2.6, 0.2), SL, {studs = true, rot = {15, 0, 0}})
add("Torso", V(1.2, 1.7, 0.3), V(0, 2.45, -0.72), CR, {rot = {15, 0, 0}})
for i = 0, 3 do add("Torso", V(1.1, 0.08, 0.32), V(0, 2.0 + i * 0.38, -0.85 + i * 0.1), SLD, {rot = {15, 0, 0}}) end   -- chest bars
joint("Torso", "Root", V(0, 2.4, 0.2))
add("Head", V(1.4, 1.3, 1.4), V(0, 4.1, -0.3), SLD, {studs = true})
add("Head", V(1.1, 0.75, 0.3), V(0, 3.75, -0.95), CR)
add("Head", V(0.55, 0.5, 0.55), V(0, 3.85, -1.25), Y); add("Head", V(0.35, 0.35, 0.3), V(0, 3.55, -1.45), BK)  -- hooked beak
both(function(sx) add("Head", V(0.2, 0.55, 0.06), V(sx * 0.45, 3.65, -1.12), BK) end)          -- moustache marks
eye("Head", 0.38, 4.25, -1.03, 0.38, "sharp", Y); eye("Head", -0.38, 4.25, -1.03, 0.38, "sharp", Y)
brow("Head", 0.4, 4.55, -1.03, 0.5, BK, 20); brow("Head", -0.4, 4.55, -1.03, 0.5, BK, 20)
joint("Head", "Torso", V(0, 3.5, -0.2))
both(function(sx, s)
	foldedWing("Wing" .. s, V(sx * 0.8, 3.35, -0.25), sx, 2.0, 1.7, {SL, SLD, SLD:Lerp(BK, 0.3)})
	joint("Wing" .. s, "Torso", V(sx * 0.85, 3.3, 0.2))
	rod("Leg" .. s, V(sx * 0.4, 1.4, 0.2), V(sx * 0.4, 0.2, 0.1), 0.3, Y)
	add("Leg" .. s, V(0.6, 0.15, 0.7), V(sx * 0.4, 0.08, -0.1), Y); add("Leg" .. s, V(0.1, 0.15, 0.15), V(sx * 0.4, 0.08, -0.5), BK)
	joint("Leg" .. s, "Torso", V(sx * 0.4, 1.5, 0.2))
end)
rod("Tail1", V(0, 1.7, 1.0), V(0, 0.9, 2.2), 0.9, SLD, {h = 0.25}); joint("Tail1", "Torso", V(0, 1.7, 1.0))
return {name = "Falcon", parts = P, joints = J, hrpSize = V(2, 5, 3), hrpPos = V(0, 2.5, 0.3)}
