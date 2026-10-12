-- Fire Bat (Volcano egg, Rare): hovering round red bat, big ears, tiny fangs, wings with flame tips.
local R, RD, FL = rgb(200, 52, 40), rgb(120, 26, 24), rgb(255, 150, 30)
add("Torso", V(1.3, 1.2, 1.1), V(0, 1.7, 0), R, {studs = true})
eye("Torso", 0.3, 1.85, -0.58, 0.36, "cute"); eye("Torso", -0.3, 1.85, -0.58, 0.36, "cute")
both(function(sx) add("Torso", V(0.1, 0.16, 0.05), V(sx * 0.12, 1.42, -0.58), WHITE, {shape = "wedge", rot = {0, 0, 180}}); add("Torso", V(0.25, 0.1, 0.05), V(sx * 0.45, 1.55, -0.58), PINK) end)
add("Torso", V(0.4, 0.06, 0.05), V(0, 1.5, -0.57), BLACK)
joint("Torso", "Root", V(0, 1.7, 0))
both(function(sx, s)
	add("Ear" .. s, V(0.4, 0.6, 0.2), V(sx * 0.4, 2.55, 0), R, {rot = {0, 0, sx * -15}}); add("Ear" .. s, V(0.2, 0.4, 0.06), V(sx * 0.4, 2.52, -0.11), PINK, {rot = {0, 0, sx * -15}})
	joint("Ear" .. s, "Torso", V(sx * 0.4, 2.3, 0))
	membraneWing("Wing" .. s, V(sx * 0.6, 1.9, 0.1), sx, 1.5, RD:Lerp(BLACK, 0.3), RD, {tipCol = FL})
	joint("Wing" .. s, "Torso", V(sx * 0.6, 1.9, 0.1))
end)
dragonFruit("Torso", V(0, 1.42, -0.5), 0.8)   -- food in the mouth
return {name = "FireBat", parts = P, joints = J, hrpSize = V(1.6, 2.6, 1.4), hrpPos = V(0, 1.3, 0)}
