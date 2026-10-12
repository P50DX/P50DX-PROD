-- Cobra: coiled base, body rising up, wide flared hood with eye-pattern, forked tongue, fangs, menacing eyes.
local G, GD, BL, HP = rgb(150, 132, 60), rgb(100, 86, 36), rgb(232, 214, 150), rgb(50, 40, 22)
-- coil on the ground (ring of segments)
for i = 0, 9 do
	local a = i / 10 * math.pi * 2
	add("Torso", V(0.9, 0.8, 1.2), V(math.cos(a) * 1.3, 0.4, math.sin(a) * 1.3 + 0.6), (i % 2 == 0) and G or GD, {studs = true, rot = {0, -math.deg(a), 0}})
end
joint("Torso", "Root", V(0, 0.5, 0.6))
-- rising neck: rods up to the hood
local pts = {V(0, 0.6, -0.5), V(0, 1.8, -0.9), V(0, 3.0, -0.9), V(0, 3.9, -0.7)}
for i = 1, #pts - 1 do rod("Neck" .. i, pts[i], pts[i + 1], 0.8, G, {studs = true}); add("Neck" .. i, V(0.5, 0.2, 0.2), (pts[i] + pts[i + 1]) / 2 + V(0, 0, -0.42), BL); joint("Neck" .. i, i == 1 and "Torso" or "Neck" .. (i - 1), pts[i]) end
-- hood: wide flat plate behind the head with dark spectacle mark
add("Head", V(1.3, 1.1, 1.3), V(0, 4.35, -0.95), G, {studs = true})
add("Head", V(2.6, 2.0, 0.25), V(0, 3.9, -0.5), G, {studs = true})
add("Head", V(1.4, 1.4, 0.08), V(0, 3.75, -0.66), BL)
add("Head", V(0.5, 0.35, 0.1), V(0.35, 3.85, -0.32), HP); add("Head", V(0.5, 0.35, 0.1), V(-0.35, 3.85, -0.32), HP)  -- back eye-pattern
add("Head", V(0.9, 0.45, 0.6), V(0, 4.15, -1.8), G)                                        -- snout
eye("Head", 0.4, 4.55, -1.63, 0.35, "angry", rgb(250, 210, 40)); eye("Head", -0.4, 4.55, -1.63, 0.35, "angry", rgb(250, 210, 40))
brow("Head", 0.4, 4.8, -1.63, 0.5, GD, 22); brow("Head", -0.4, 4.8, -1.63, 0.5, GD, 22)
add("Head", V(0.1, 0.25, 0.08), V(0.2, 3.85, -2.08), WHITE); add("Head", V(0.1, 0.25, 0.08), V(-0.2, 3.85, -2.08), WHITE)  -- fangs
add("Head", V(0.12, 0.06, 0.6), V(0, 3.95, -2.35), rgb(220, 40, 60)); add("Head", V(0.06, 0.06, 0.25), V(0.07, 3.95, -2.7), rgb(220, 40, 60), {rot = {0, 25, 0}}); add("Head", V(0.06, 0.06, 0.25), V(-0.07, 3.95, -2.7), rgb(220, 40, 60), {rot = {0, -25, 0}})
joint("Head", "Neck3", pts[4])
tail(3, V(1.3, 0.35, 1.5), 0.5, 0.25, 0.8, {G, GD}, 0, "Tail")
return {name = "Cobra", parts = P, joints = J, hrpSize = V(3, 5, 3.4), hrpPos = V(0, 2.5, 0.3)}
