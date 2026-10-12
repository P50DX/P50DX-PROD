-- Snow Bunny (Snow egg, Common): sitting white bunny, tall ears with pink inside, pink nose, cotton tail, big feet.
local W, WS = rgb(252, 252, 255), rgb(222, 230, 242)
add("Torso", V(1.3, 1.2, 1.3), V(0, 0.75, 0.15), W, {studs = true})
add("Torso", V(0.5, 0.5, 0.4), V(0, 0.6, 0.95), WS)
joint("Torso", "Root", V(0, 0.75, 0))
both(function(sx, s) add("Leg" .. s, V(0.45, 0.25, 0.8), V(sx * 0.4, 0.12, -0.25), WS); joint("Leg" .. s, "Torso", V(sx * 0.4, 0.3, 0)) end)
add("Head", V(1.4, 1.25, 1.2), V(0, 1.9, -0.15), W, {studs = true})
local k = {head = V(0, 1.9, -0.15), face = -0.78, hw = 1.4, hh = 1.25, hd = 1.2}
face(k, {eyeS = 0.38, eyeY = 0.1, eyeX = 0.27})
add("Head", V(0.25, 0.15, 0.06), V(0, 1.72, -0.8), PINK); add("Head", V(0.3, 0.06, 0.05), V(0, 1.58, -0.8), BLACK)
both(function(sx, s)
	add("Head", V(0.3, 0.12, 0.05), V(sx * 0.5, 1.68, -0.8), PINK)
	add("Ear" .. s, V(0.35, 1.2, 0.25), V(sx * 0.32, 3.05, -0.05), W, {rot = {0, 0, sx * -8}})
	add("Ear" .. s, V(0.18, 0.85, 0.06), V(sx * 0.32, 3.0, -0.19), PINK, {rot = {0, 0, sx * -8}})
	joint("Ear" .. s, "Head", V(sx * 0.32, 2.5, -0.05))
end)
joint("Head", "Torso", V(0, 1.3, -0.1))
return {name = "SnowBunny", parts = P, joints = J, hrpSize = V(1.6, 3.6, 1.8), hrpPos = V(0, 1.8, 0)}
