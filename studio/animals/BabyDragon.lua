-- Baby Dragon (Volcano egg, Legendary): chibi orange dragon, cream belly, little horns, back spikes, small wings,
-- golden eyes.
local C, CL, HN, WG, IR = rgb(236, 96, 48), rgb(255, 214, 130), rgb(255, 240, 210), rgb(200, 60, 40), rgb(255, 200, 40)
local k = pup{col = C, belly = CL, pawCol = CL, tailN = 3, tailW0 = 0.45, tailW1 = 0.25, tailLen = 0.5, tailCurl = -6}
cute(k, C, rgb(120, 40, 30), {iris = IR})
both(function(sx, s)
	rod("Head", V(sx * 0.45, k.head.Y + 0.6, k.head.Z + 0.2), V(sx * 0.55, k.head.Y + 1.1, k.head.Z + 0.5), 0.2, HN)
	local sh = V(sx * 0.55, k.by + 0.5, -0.3)
	rod("Wing" .. s, sh, sh + V(sx * 0.8, 0.6, 0.3), 0.14, WG)
	add("Wing" .. s, V(0.8, 0.7, 0.08), sh + V(sx * 0.5, 0.15, 0.35), WG, {rot = {-10, 0, sx * -20}})
	joint("Wing" .. s, "Torso", sh)
end)
for i = 0, 2 do add("Torso", V(0.18, 0.3, 0.3), V(0, k.by + 0.65, -0.4 + i * 0.4), HN, {shape = "wedge", rot = {0, 180, 0}}) end
if not SKIP_FOOD then drumstick("Head", MOUTH, 1) end   -- food in the mouth
return {name = "BabyDragon", parts = P, joints = J, hrpSize = V(1.6, 2.8, 2.6), hrpPos = V(0, 1.4, 0)}
