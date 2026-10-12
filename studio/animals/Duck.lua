-- Duck: mallard-ish - white/cream body, green head, yellow-orange bill, orange webbed feet, little tail flick.
local W, WD, GH, BILL, FT = rgb(246, 244, 236), rgb(206, 204, 196), rgb(40, 140, 80), rgb(250, 176, 40), rgb(250, 130, 40)
add("Torso", V(2.0, 1.6, 2.8), V(0, 1.7, 0.2), W, {studs = true})
add("Torso", V(1.7, 0.3, 2.2), V(0, 0.85, 0.2), WD)
add("Torso", V(1.2, 0.7, 0.9), V(0, 2.1, 1.8), W, {rot = {-30, 0, 0}})                  -- tail flick
add("Head", V(1.3, 1.3, 1.3), V(0, 3.25, -1.0), GH, {studs = true})
add("Head", V(1.2, 0.18, 1.2), V(0, 2.55, -1.0), W)                                     -- white collar
add("Head", V(0.85, 0.32, 0.8), V(0, 3.0, -1.95), BILL)                                 -- bill
add("Head", V(0.75, 0.06, 0.06), V(0, 2.95, -2.36), rgb(200, 120, 20))
eye("Head", 0.4, 3.45, -1.67, 0.3, "cute"); eye("Head", -0.4, 3.45, -1.67, 0.3, "cute")
joint("Torso", "Root", V(0, 1.6, 0.2)); joint("Head", "Torso", V(0, 2.5, -0.9))
both(function(sx, s)
	foldedWing("Wing" .. s, V(sx * 1.0, 2.3, -0.5), sx, 2.4, 1.1, {WD, W, rgb(80, 110, 200)}); joint("Wing" .. s, "Torso", V(sx * 1.0, 2.3, 0))
	rod("Leg" .. s, V(sx * 0.5, 0.95, 0.3), V(sx * 0.5, 0.15, 0.2), 0.2, FT)
	add("Leg" .. s, V(0.7, 0.1, 0.75), V(sx * 0.5, 0.05, -0.05), FT); joint("Leg" .. s, "Torso", V(sx * 0.5, 0.95, 0.3))
end)
return {name = "Duck", parts = P, joints = J, hrpSize = V(2.2, 3.8, 3.2), hrpPos = V(0, 1.9, 0.2)}
