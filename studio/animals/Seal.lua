-- Seal: smooth grey torpedo body lying on the ground, front flippers, tail flippers, whiskered snout, big glossy eyes.
local G, GD, GL = rgb(150, 160, 176), rgb(110, 118, 134), rgb(206, 212, 222)
add("Torso", V(2.2, 1.6, 3.2), V(0, 0.9, 0.3), G, {studs = true})
add("Torso", V(1.7, 1.3, 1.4), V(0, 0.75, 2.4), G)
add("Torso", V(1.8, 0.3, 2.8), V(0, 0.15, 0.4), GL)
for _, p in ipairs({{0.6, 1.65, -0.5}, {-0.4, 1.6, 0.6}, {0.2, 1.6, 1.6}}) do add("Torso", V(0.35, 0.08, 0.35), V(p[1], p[2], p[3]), GD) end
joint("Torso", "Root", V(0, 0.9, 0.3))
add("Head", V(1.7, 1.5, 1.5), V(0, 1.9, -1.4), G, {studs = true})
add("Head", V(0.95, 0.65, 0.5), V(0, 1.6, -2.3), GL)
add("Head", V(0.36, 0.22, 0.12), V(0, 1.85, -2.6), rgb(40, 40, 48))
eye("Head", 0.42, 2.15, -2.17, 0.48, "cute"); eye("Head", -0.42, 2.15, -2.17, 0.48, "cute")
both(function(sx) for _, dy in ipairs({0.05, -0.12}) do add("Head", V(0.8, 0.04, 0.04), V(sx * 0.7, 1.6 + dy, -2.5), WHITE) end end)
joint("Head", "Torso", V(0, 1.4, -0.9))
both(function(sx, s)
	add("Flip" .. s, V(0.35, 0.25, 1.1), V(sx * 1.3, 0.2, -0.5), GD, {rot = {0, sx * -25, 0}}); joint("Flip" .. s, "Torso", V(sx * 1.05, 0.4, -0.5))
	add("Tail" .. s, V(0.7, 0.2, 1.0), V(sx * 0.45, 0.25, 3.4), GD, {rot = {0, sx * 20, 0}}); joint("Tail" .. s, "Torso", V(sx * 0.3, 0.4, 2.9))
end)
return {name = "Seal", parts = P, joints = J, hrpSize = V(2.4, 2.6, 4.6), hrpPos = V(0, 1.3, 0.4)}
