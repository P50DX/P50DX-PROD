-- Parrot: scarlet macaw - red body/head, yellow + blue wings, long blue tail, big hooked beak, white face patch.
local RD, RDD, YE, BL, BEAK = rgb(222, 40, 40), rgb(170, 24, 30), rgb(255, 210, 40), rgb(40, 110, 230), rgb(250, 240, 220)
add("Torso", V(1.6, 2.2, 1.6), V(0, 2.1, 0.3), RD, {studs = true, rot = {12, 0, 0}})
add("Head", V(1.5, 1.5, 1.5), V(0, 3.75, -0.3), RD, {studs = true})
add("Head", V(0.55, 0.9, 0.06), V(0.42, 3.75, -1.08), WHITE); add("Head", V(0.55, 0.9, 0.06), V(-0.42, 3.75, -1.08), WHITE)  -- face patch
add("Head", V(0.75, 0.7, 0.7), V(0, 3.55, -1.35), BEAK); add("Head", V(0.5, 0.5, 0.45), V(0, 3.0, -1.5), rgb(40, 36, 40))  -- hooked beak
eye("Head", 0.42, 3.95, -1.12, 0.3, "cute"); eye("Head", -0.42, 3.95, -1.12, 0.3, "cute")
joint("Torso", "Root", V(0, 2.0, 0.3)); joint("Head", "Torso", V(0, 3.1, -0.2))
both(function(sx, s)
	add("Wing" .. s, V(0.28, 1.9, 1.5), V(sx * 0.95, 2.3, 0.55), RD, {studs = true})
	add("Wing" .. s, V(0.3, 0.6, 1.5), V(sx * 0.97, 1.45, 0.75), YE)
	add("Wing" .. s, V(0.3, 0.7, 1.4), V(sx * 0.97, 0.95, 1.0), BL)
	joint("Wing" .. s, "Torso", V(sx * 0.85, 2.9, 0.2))
	rod("Leg" .. s, V(sx * 0.35, 1.1, 0.3), V(sx * 0.35, 0.2, 0.2), 0.22, rgb(90, 90, 100))
	add("Leg" .. s, V(0.5, 0.12, 0.6), V(sx * 0.35, 0.06, 0.1), rgb(90, 90, 100)); joint("Leg" .. s, "Torso", V(sx * 0.35, 1.1, 0.3))
end)
rod("Tail1", V(0, 1.2, 1.1), V(0, 0.4, 2.6), 0.75, BL); add("Tail1", V(0.55, 0.15, 0.9), V(0, 0.25, 2.9), RD); joint("Tail1", "Torso", V(0, 1.2, 1.0))
return {name = "Parrot", parts = P, joints = J, hrpSize = V(2, 4.6, 2.6), hrpPos = V(0, 2.3, 0.3)}
