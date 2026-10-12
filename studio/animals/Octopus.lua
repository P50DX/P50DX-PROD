-- Octopus: big round purple head, cute eyes + blush, eight curling tentacles with pale suckers.
local PU, PD, SU = rgb(170, 84, 196), rgb(124, 56, 152), rgb(246, 196, 236)
add("Torso", V(2.6, 2.4, 2.6), V(0, 2.6, 0), PU, {studs = true})
add("Torso", V(2.2, 0.8, 2.2), V(0, 4.1, 0.1), PU, {studs = true})
add("Torso", V(2.4, 0.6, 2.4), V(0, 1.2, 0), PD)
for _, p in ipairs({{0.6, 4.55, -0.3}, {-0.5, 4.55, 0.5}, {1.3, 3.2, 0.4}, {-1.31, 2.8, -0.2}}) do add("Torso", V(0.3, 0.08, 0.3), V(p[1], p[2], p[3]), PD) end
joint("Torso", "Root", V(0, 2.4, 0))
both(function(sx)
	eye("Torso", sx * 0.6, 2.8, -1.33, 0.55, "cute")
	add("Torso", V(0.4, 0.2, 0.06), V(sx * 0.95, 2.25, -1.33), PINK)
end)
add("Torso", V(0.4, 0.1, 0.06), V(0, 2.15, -1.33), BLACK)
for i = 0, 7 do
	local a = math.rad(i * 45 + 22.5); local d = V(math.sin(a), 0, -math.cos(a))
	local p0 = V(0, 1.1, 0) + d * 0.9
	local p1, p2 = p0 + d * 1.0 + V(0, -0.6, 0), p0 + d * 1.9 + V(0, -0.7, 0)
	local p3 = p2 + d * 0.5 + V(0, 0.5, 0)
	local g = "Arm" .. (i + 1)
	rod(g, p0, p1, 0.6, PU); rod(g, p1, p2, 0.48, PU); rod(g, p2, p3, 0.36, PD)
	add(g, V(0.18, 0.06, 0.18), p1 + d * 0.3 + V(0, -0.28, 0), SU); add(g, V(0.16, 0.06, 0.16), p2 - d * 0.3 + V(0, -0.2, 0), SU)
	joint(g, "Torso", p0)
end
return {name = "Octopus", parts = P, joints = J, hrpSize = V(4, 4.8, 4), hrpPos = V(0, 2.4, 0)}
