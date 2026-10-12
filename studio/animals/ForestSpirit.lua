-- Forest Spirit (Forest egg, Legendary): floating see-through green spirit, glowing white eyes, wooden antlers
-- with leaves, a leaf skirt and little light orbs circling it.
local G, GL, WD, LF, LT = rgb(110, 230, 150), rgb(190, 255, 210), rgb(130, 90, 56), rgb(70, 190, 80), rgb(230, 255, 140)
add("Torso", V(1.2, 1.3, 1.1), V(0, 1.75, 0), G, {transp = 0.25})
for i = 0, 5 do add("Torso", V(0.5, 0.15, 0.6), V(math.cos(math.rad(i * 60)) * 0.5, 1.05, math.sin(math.rad(i * 60)) * 0.5), LF, {rot = {0, -i * 60, -20}}) end

joint("Torso", "Root", V(0, 1.75, 0))
add("Head", V(1.5, 1.3, 1.3), V(0, 3.0, -0.1), G, {transp = 0.15})
both(function(sx)
	add("Head", V(0.3, 0.38, 0.06), V(sx * 0.33, 3.05, -0.78), WHITE, {neon = true})
	add("Head", V(0.28, 0.1, 0.05), V(sx * 0.55, 2.75, -0.78), rgb(255, 160, 200))
	local b = V(sx * 0.4, 3.6, -0.05)
	rod("Head", b, b + V(sx * 0.3, 0.7, 0), 0.14, WD); rod("Head", b + V(sx * 0.3, 0.7, 0), b + V(sx * 0.7, 1.1, 0), 0.12, WD)
	rod("Head", b + V(sx * 0.2, 0.5, 0), b + V(sx * 0.0, 0.9, 0), 0.1, WD)
	add("Head", V(0.3, 0.12, 0.2), b + V(sx * 0.75, 1.15, 0), LF, {rot = {0, 0, sx * 30}}); add("Head", V(0.25, 0.12, 0.18), b + V(0, 0.95, 0), LF)
end)
add("Head", V(0.3, 0.06, 0.05), V(0, 2.7, -0.78), rgb(40, 90, 60))
joint("Head", "Torso", V(0, 2.35, 0))
both(function(sx, s) rod("Arm" .. s, V(sx * 0.6, 2.1, 0), V(sx * 0.9, 1.5, -0.2), 0.25, G, {transp = 0.25}); joint("Arm" .. s, "Torso", V(sx * 0.6, 2.1, 0)) end)
return {name = "ForestSpirit", parts = P, joints = J, hrpSize = V(1.8, 4.4, 1.8), hrpPos = V(0, 2.2, 0)}
