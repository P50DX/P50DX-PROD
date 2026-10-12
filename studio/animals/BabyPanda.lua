-- Baby Panda (Zoo egg, Legendary): white chibi panda, black ears, eye patches, legs and shoulder band, carrying bamboo in its mouth.
local W, B, BB = rgb(250, 250, 248), rgb(40, 38, 44), rgb(110, 190, 80)
local k = pup{col = W, belly = W, pawCol = B, tailN = 1, tailW0 = 0.3, tailW1 = 0.3, tailLen = 0.25, tailCurl = 10, head = {1.75, 1.55, 1.45}}
both(function(sx) add("Head", V(0.55, 0.6, 0.05), V(sx * 0.42, k.head.Y + 0.12, k.face + 0.01), B, {rot = {0, 0, sx * -15}}) end)
face(k, {eyeS = 0.34, eyeY = 0.12, eyeX = 0.24, muzzle = {0.7, 0.4, 0.3, W}, nose = {0.26, 0.15}})
both(function(sx) add("Head", V(0.3, 0.12, 0.05), V(sx * 0.6, k.head.Y - 0.25, k.face - 0.02), PINK) end)
ears(k, "round", B, nil, 0.45, 0.4, 0.38)
add("Torso", V(1.32, 0.5, 0.7), V(0, k.by + 0.1, -0.5), B)
for _, l in ipairs({"FL", "FR", "BL", "BR"}) do end
for _, leg in ipairs({{"FL", 1, -1}, {"FR", -1, -1}, {"BL", 1, 1}, {"BR", -1, 1}}) do
	local x, z = leg[2] * (1.3 / 2 - 0.21), leg[3] * (1.7 / 2 - 0.29)
	add("Leg" .. leg[1], V(0.44, 0.82, 0.48), V(x, 0.4, z), B)
end
-- bamboo carried crosswise in the mouth (resting on the muzzle front): node rings, leaves at one end
local mz = k.face - 0.32                                                   -- just in front of the muzzle
add("Head", V(2.4, 0.18, 0.18), V(0.15, 1.18, mz), BB)
for _, x in ipairs({-0.65, 0.15, 0.9}) do add("Head", V(0.06, 0.24, 0.24), V(x, 1.18, mz), rgb(80, 150, 56)) end
add("Head", V(0.55, 0.06, 0.22), V(1.55, 1.33, mz), rgb(80, 170, 60), {rot = {0, 0, 30}})
add("Head", V(0.5, 0.06, 0.2), V(1.5, 1.04, mz), rgb(80, 170, 60), {rot = {0, 0, -25}})
return {name = "BabyPanda", parts = P, joints = J, hrpSize = V(1.8, 2.8, 2.4), hrpPos = V(0, 1.4, 0)}
