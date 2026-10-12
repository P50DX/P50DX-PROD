-- Walrus: huge blubbery brown body, whiskery moustache pad, two long ivory tusks, small eyes, flippers.
local B, BD, BL, TU = rgb(170, 116, 92), rgb(128, 82, 64), rgb(212, 160, 136), rgb(248, 240, 214)
add("Torso", V(3.2, 2.5, 3.8), V(0, 1.35, 0.6), B, {studs = true})
add("Torso", V(2.4, 1.6, 1.4), V(0, 0.9, 3.0), B)
add("Torso", V(2.6, 0.3, 3.4), V(0, 0.15, 0.6), BD)
joint("Torso", "Root", V(0, 1.3, 0.6))
add("Head", V(2.2, 1.8, 1.7), V(0, 2.8, -1.4), B, {studs = true})
add("Head", V(1.8, 0.9, 0.8), V(0, 2.25, -2.45), BL)                                         -- moustache pad
for _, x in ipairs({-0.6, -0.3, 0, 0.3, 0.6}) do add("Head", V(0.08, 0.08, 0.08), V(x, 2.3, -2.87), BD) end
add("Head", V(0.4, 0.25, 0.15), V(0, 2.7, -2.87), rgb(60, 40, 34))
both(function(sx) rod("Head", V(sx * 0.4, 1.95, -2.6), V(sx * 0.45, 0.6, -2.9), 0.28, TU) end)   -- tusks
eye("Head", 0.55, 3.2, -2.27, 0.3, "cute"); eye("Head", -0.55, 3.2, -2.27, 0.3, "cute")
joint("Head", "Torso", V(0, 2.2, -0.8))
both(function(sx, s)
	add("Flip" .. s, V(0.5, 0.25, 1.3), V(sx * 1.75, 0.2, -0.7), BD, {rot = {0, sx * -25, 0}}); joint("Flip" .. s, "Torso", V(sx * 1.5, 0.5, -0.6))
	add("Tail" .. s, V(0.9, 0.25, 1.1), V(sx * 0.6, 0.15, 4.1), BD, {rot = {0, sx * 20, 0}}); joint("Tail" .. s, "Torso", V(sx * 0.4, 0.4, 3.6))
end)
return {name = "Walrus", parts = P, joints = J, hrpSize = V(3.4, 3.6, 5.6), hrpPos = V(0, 1.8, 0.6)}
