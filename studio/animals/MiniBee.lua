-- Mini Bee (Zoo egg, Rare): hovering fuzzy bee - yellow with black stripes, see-through wings, antennae, stinger.
local Y, BK = rgb(255, 210, 50), rgb(40, 34, 30)
add("Torso", V(1.2, 1.1, 1.4), V(0, 1.5, 0.1), Y, {studs = true})
for _, z in ipairs({0.05, 0.5}) do add("Torso", V(1.22, 1.12, 0.2), V(0, 1.5, z), BK) end
add("Torso", V(0.2, 0.2, 0.4), V(0, 1.45, 0.95), BK, {rot = {-10, 0, 0}})
joint("Torso", "Root", V(0, 1.5, 0))
add("Head", V(1.2, 1.1, 0.9), V(0, 1.6, -0.95), Y, {studs = true})
eye("Head", 0.3, 1.7, -1.42, 0.36, "cute"); eye("Head", -0.3, 1.7, -1.42, 0.36, "cute")
add("Head", V(0.3, 0.06, 0.05), V(0, 1.35, -1.42), BK)
both(function(sx)
	add("Head", V(0.25, 0.1, 0.05), V(sx * 0.42, 1.4, -1.42), PINK)
	rod("Head", V(sx * 0.25, 2.1, -1.1), V(sx * 0.45, 2.6, -1.35), 0.08, BK); add("Head", V(0.16, 0.16, 0.16), V(sx * 0.45, 2.65, -1.35), BK)
end)
joint("Head", "Torso", V(0, 1.5, -0.6))
both(function(sx, s)
	add("Wing" .. s, V(0.9, 0.06, 0.7), V(sx * 0.6, 2.1, 0.2), rgb(220, 240, 255), {transp = 0.35, rot = {0, 0, sx * 25}})
	joint("Wing" .. s, "Torso", V(sx * 0.3, 2.05, 0.2))
end)
sprig("Head", V(0, 1.33, -1.44), 0.8, rgb(80, 170, 60), rgb(255, 250, 250), "flower")   -- food in the mouth
return {name = "MiniBee", parts = P, joints = J, hrpSize = V(1.4, 2.6, 2), hrpPos = V(0, 1.3, 0)}
