-- Ice Owl (Snow egg, Epic): white-blue owl, big icy eyes in a pale face disk, ear tufts, frosty wing tips.
local W, B, BD, Y = rgb(236, 244, 255), rgb(160, 200, 240), rgb(100, 150, 210), rgb(255, 200, 60)
add("Torso", V(1.5, 1.8, 1.3), V(0, 1.15, 0), B, {studs = true})
add("Torso", V(1.1, 1.0, 0.06), V(0, 0.9, -0.67), W)
for i = 0, 2 do add("Torso", V(0.6, 0.06, 0.05), V(0, 0.6 + i * 0.3, -0.71), BD) end
joint("Torso", "Root", V(0, 1.15, 0))
add("Head", V(1.6, 1.3, 1.3), V(0, 2.65, -0.05), B, {studs = true})
add("Head", V(1.3, 0.95, 0.06), V(0, 2.6, -0.73), W)
eye("Head", 0.32, 2.7, -0.78, 0.42, "sharp", rgb(110, 210, 255)); eye("Head", -0.32, 2.7, -0.78, 0.42, "sharp", rgb(110, 210, 255))
add("Head", V(0.22, 0.25, 0.2), V(0, 2.35, -0.85), Y)
both(function(sx) add("Head", V(0.3, 0.45, 0.3), V(sx * 0.6, 3.4, 0), B, {rot = {0, 0, sx * -20}}) end)
joint("Head", "Torso", V(0, 2.0, 0))
both(function(sx, s)
	add("Wing" .. s, V(0.25, 1.4, 1.0), V(sx * 0.85, 1.2, 0.1), BD, {rot = {0, 0, sx * -8}})
	add("Wing" .. s, V(0.26, 0.35, 0.9), V(sx * 0.9, 0.55, 0.15), rgb(130, 230, 255), {neon = true})
	joint("Wing" .. s, "Torso", V(sx * 0.75, 1.8, 0))
	add("Leg" .. s, V(0.35, 0.2, 0.45), V(sx * 0.3, 0.1, -0.2), Y); joint("Leg" .. s, "Torso", V(sx * 0.3, 0.3, 0))
end)
return {name = "IceOwl", parts = P, joints = J, hrpSize = V(1.8, 3.6, 1.6), hrpPos = V(0, 1.8, 0)}
