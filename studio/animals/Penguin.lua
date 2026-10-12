-- Penguin: upright navy body with white belly, orange beak + feet, flipper wings, little tuft, red beanie.
local N, ND, W, OR, HAT = rgb(40, 50, 80), rgb(26, 32, 54), rgb(250, 250, 252), rgb(250, 150, 40), rgb(220, 40, 44)
add("Torso", V(2.1, 2.6, 1.9), V(0, 1.75, 0.1), N, {studs = true})
add("Torso", V(1.6, 2.1, 0.3), V(0, 1.6, -0.83), W)
joint("Torso", "Root", V(0, 1.7, 0.1))
add("Head", V(1.8, 1.5, 1.7), V(0, 3.75, 0), N, {studs = true})
add("Head", V(1.4, 1.0, 0.3), V(0, 3.6, -0.75), W)
add("Head", V(0.55, 0.35, 0.6), V(0, 3.45, -1.15), OR)
eye("Head", 0.38, 3.85, -0.92, 0.38, "cute"); eye("Head", -0.38, 3.85, -0.92, 0.38, "cute")
-- knitted beanie: ribbed white cuff, red crown in two steps, fluffy pompom
add("Head", V(1.9, 0.7, 1.8), V(0, 4.85, 0), HAT, {studs = true}); add("Head", V(1.5, 0.35, 1.4), V(0, 5.35, 0), HAT)
add("Head", V(2.0, 0.38, 1.9), V(0, 4.5, 0), W)
for i = -3, 3 do add("Head", V(0.06, 0.34, 0.05), V(i * 0.26, 4.5, -0.97), rgb(220, 222, 230)) end
add("Head", V(0.7, 0.7, 0.7), V(0, 5.75, 0), W, {shape = "ball"})
joint("Head", "Torso", V(0, 3.05, 0))
both(function(sx, s)
	add("Wing" .. s, V(0.3, 1.8, 1.0), V(sx * 1.2, 1.95, 0.1), ND, {studs = true, rot = {0, 0, sx * -12}}); joint("Wing" .. s, "Torso", V(sx * 1.05, 2.8, 0.1))
	add("Leg" .. s, V(0.6, 0.25, 0.9), V(sx * 0.5, 0.13, -0.35), OR); add("Leg" .. s, V(0.4, 0.35, 0.4), V(sx * 0.5, 0.4, -0.05), OR); joint("Leg" .. s, "Torso", V(sx * 0.5, 0.4, 0))
end)
return {name = "Penguin", parts = P, joints = J, hrpSize = V(2.2, 5.6, 2.2), hrpPos = V(0, 2.8, 0)}
