-- Baby Chick (Zoo egg, Common): round yellow fluff ball, tiny orange beak, wing nubs, hair tuft, little feet.
local Y, YD, O = rgb(255, 222, 80), rgb(240, 190, 50), rgb(255, 140, 40)
add("Torso", V(1.5, 1.4, 1.4), V(0, 1.0, 0), Y, {studs = true})
add("Torso", V(0.3, 0.4, 0.3), V(0, 1.85, -0.1), YD, {rot = {0, 0, 20}}); add("Torso", V(0.25, 0.3, 0.25), V(0.15, 1.85, 0.1), YD, {rot = {0, 0, -25}})
eye("Torso", 0.35, 1.2, -0.72, 0.36, "cute"); eye("Torso", -0.35, 1.2, -0.72, 0.36, "cute")
add("Torso", V(0.35, 0.22, 0.3), V(0, 0.95, -0.8), O)
both(function(sx) add("Torso", V(0.28, 0.12, 0.05), V(sx * 0.55, 0.92, -0.72), PINK) end)
joint("Torso", "Root", V(0, 1.0, 0))
both(function(sx, s)
	add("Wing" .. s, V(0.2, 0.6, 0.7), V(sx * 0.82, 1.0, 0.05), YD, {rot = {0, 0, sx * -15}}); joint("Wing" .. s, "Torso", V(sx * 0.75, 1.25, 0))
	add("Leg" .. s, V(0.14, 0.35, 0.14), V(sx * 0.3, 0.2, 0), O); add("Leg" .. s, V(0.35, 0.08, 0.4), V(sx * 0.3, 0.04, -0.1), O)
	joint("Leg" .. s, "Torso", V(sx * 0.3, 0.35, 0))
end)
return {name = "BabyChick", parts = P, joints = J, hrpSize = V(1.6, 2, 1.6), hrpPos = V(0, 1, 0)}
