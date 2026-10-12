-- Chicken: tall white block body + head in one, red comb + wattle, orange beak, studded wings, stick legs.
local W, WD, RED, BEAK, LEG = rgb(248, 246, 252), rgb(214, 210, 226), rgb(220, 32, 38), rgb(246, 178, 96), rgb(240, 170, 90)
add("Torso", V(2.0, 1.7, 2.4), V(0, 1.9, 0.3), W, {studs = true})
featherFan("Torso", V(0, 2.4, 1.3), 5, 1.2, 0.36, {W, WD}, 55, 70)                          -- fanned tail feathers
add("Head", V(1.6, 1.9, 1.5), V(0, 3.55, -0.65), W, {studs = true})
add("Head", V(0.25, 0.5, 0.9), V(0, 4.75, -0.6), RED); add("Head", V(0.25, 0.35, 0.4), V(0, 4.65, -1.15), RED)  -- comb
add("Head", V(0.85, 0.45, 0.6), V(0, 3.4, -1.65), BEAK)
add("Head", V(0.3, 0.45, 0.2), V(0, 2.95, -1.5), RED)                                     -- wattle
eye("Head", 0.45, 3.95, -1.43, 0.42, "cute"); eye("Head", -0.45, 3.95, -1.43, 0.42, "cute")
joint("Torso", "Root", V(0, 1.8, 0.3)); joint("Head", "Torso", V(0, 2.7, -0.6))
both(function(sx, s)
	foldedWing("Wing" .. s, V(sx * 1.0, 2.55, -0.4), sx, 2.0, 1.3, {W, WD, rgb(190, 186, 200)}); joint("Wing" .. s, "Torso", V(sx * 1.0, 2.5, 0))
	rod("Leg" .. s, V(sx * 0.45, 1.1, 0.3), V(sx * 0.45, 0.15, 0.25), 0.22, LEG)
	add("Leg" .. s, V(0.55, 0.1, 0.65), V(sx * 0.45, 0.05, 0.05), LEG); joint("Leg" .. s, "Torso", V(sx * 0.45, 1.1, 0.3))
end)
return {name = "Chicken", parts = P, joints = J, hrpSize = V(2.2, 4.4, 3), hrpPos = V(0, 2.2, 0.2)}
