-- Kangaroo: upright, huge back legs + feet, thick tail as a third leg, small arms with red boxing gloves, pouch.
local K, KD, CR, GL = rgb(196, 128, 76), rgb(156, 96, 54), rgb(240, 214, 176), rgb(220, 36, 40)
add("Torso", V(1.8, 2.4, 1.7), V(0, 3.0, 0.2), K, {studs = true, rot = {15, 0, 0}})
add("Torso", V(1.3, 1.5, 0.3), V(0, 2.7, -0.7), CR, {rot = {15, 0, 0}})                  -- pouch
add("Torso", V(1.1, 0.12, 0.32), V(0, 3.3, -0.85), KD, {rot = {15, 0, 0}})
joint("Torso", "Root", V(0, 2.5, 0.3))
add("Head", V(1.3, 1.3, 1.6), V(0, 4.75, -0.35), K, {studs = true})
add("Head", V(0.8, 0.7, 0.75), V(0, 4.5, -1.35), CR); add("Head", V(0.4, 0.26, 0.2), V(0, 4.75, -1.76), BLACK)
eye("Head", 0.35, 5.0, -1.18, 0.35, "cute"); eye("Head", -0.35, 5.0, -1.18, 0.35, "cute")
joint("Head", "Torso", V(0, 4.1, -0.2))
both(function(sx, s)
	add("Ear" .. s, V(0.4, 0.9, 0.2), V(sx * 0.45, 5.8, -0.1), K, {rot = {0, 0, sx * -12}}); add("Ear" .. s, V(0.22, 0.6, 0.06), V(sx * 0.45, 5.8, -0.22), CR, {rot = {0, 0, sx * -12}})
	joint("Ear" .. s, "Head", V(sx * 0.4, 5.35, -0.1))
	rod("Arm" .. s, V(sx * 0.75, 3.7, -0.6), V(sx * 0.7, 3.0, -1.3), 0.38, K)
	-- boxing glove: rounded fist, padded knuckles, thumb on the inside, white cuff with a lace
	add("Arm" .. s, V(0.72, 0.68, 0.78), V(sx * 0.7, 2.85, -1.55), GL); add("Arm" .. s, V(0.6, 0.5, 0.12), V(sx * 0.7, 2.88, -1.98), rgb(240, 70, 70))
	add("Arm" .. s, V(0.22, 0.38, 0.32), V(sx * 0.3, 2.95, -1.62), GL)
	add("Arm" .. s, V(0.64, 0.24, 0.64), V(sx * 0.7, 3.27, -1.45), WHITE); add("Arm" .. s, V(0.05, 0.22, 0.05), V(sx * 0.7, 3.27, -1.78), rgb(200, 200, 200))
	joint("Arm" .. s, "Torso", V(sx * 0.75, 3.7, -0.6))
	add("Leg" .. s, V(0.9, 1.6, 1.6), V(sx * 0.85, 1.6, 0.6), K, {studs = true, rot = {20, 0, 0}})   -- big thigh
	rod("Leg" .. s, V(sx * 0.85, 1.1, 1.1), V(sx * 0.85, 0.25, 0.7), 0.5, K)
	add("Leg" .. s, V(0.6, 0.35, 2.0), V(sx * 0.85, 0.18, -0.1), KD)                        -- long foot
	joint("Leg" .. s, "Torso", V(sx * 0.8, 2.2, 0.5))
end)
tail(4, V(0, 2.0, 1.0), 0.75, 0.4, 1.0, {K, K, KD, KD}, -14)
return {name = "Kangaroo", parts = P, joints = J, hrpSize = V(2.2, 6, 3.6), hrpPos = V(0, 3, 0.3)}
