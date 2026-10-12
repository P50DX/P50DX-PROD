-- Snake: long S-curving green body along the ground, lighter belly, diamond back pattern, friendly-sly face, flicking tongue.
local G, GD, Y = rgb(80, 170, 70), rgb(46, 116, 44), rgb(222, 230, 120)
local pts = {}
for i = 0, 9 do table.insert(pts, V(math.sin(i * 0.8) * 1.3, 0.45, -1.8 + i * 0.75)) end
for i = 1, #pts - 1 do
	local g = (i == 1) and "Torso" or ("Tail" .. (i - 1))
	local w = 0.95 - i * 0.07
	rod(g, pts[i], pts[i + 1], w, (i % 2 == 0) and G or GD, {studs = true, h = w * 0.85, extra = 0.25})
	add(g, V(0.3, 0.1, 0.3), (pts[i] + pts[i + 1]) / 2 + V(0, w * 0.43, 0), Y, {rot = {0, 45, 0}})
	joint(g, (i == 1) and "Root" or ((i == 2) and "Torso" or ("Tail" .. (i - 2))), pts[i])
end
add("Head", V(1.3, 0.85, 1.4), V(0, 0.6, -2.5), G, {studs = true})
add("Head", V(1.0, 0.25, 1.2), V(0, 0.28, -2.55), Y)
eye("Head", 0.38, 0.85, -3.23, 0.36, "sharp", rgb(250, 210, 40)); eye("Head", -0.38, 0.85, -3.23, 0.36, "sharp", rgb(250, 210, 40))
add("Head", V(0.08, 0.06, 0.55), V(0, 0.45, -3.5), rgb(220, 40, 60))
add("Head", V(0.06, 0.06, 0.25), V(0.07, 0.45, -3.85), rgb(220, 40, 60), {rot = {0, 25, 0}}); add("Head", V(0.06, 0.06, 0.25), V(-0.07, 0.45, -3.85), rgb(220, 40, 60), {rot = {0, -25, 0}})
add("Head", V(0.6, 0.06, 0.06), V(0.15, 0.45, -3.21), BLACK, {rot = {0, 0, -8}})               -- sly smirk
joint("Head", "Torso", V(0, 0.5, -1.9))
return {name = "Snake", parts = P, joints = J, hrpSize = V(2.6, 1.6, 6), hrpPos = V(0, 0.8, 1)}
