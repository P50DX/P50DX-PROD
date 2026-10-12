--@base Horse
--@colors local C, CD, MN, HF = rgb(236, 244, 255), rgb(190, 214, 240), rgb(110, 170, 250), rgb(255, 204, 70)
-- Pegasus: sky-white horse with a blue mane and big layered feathered wings with gold edges.
both(function(sx, s)
	local sh = V(sx * 0.9, k.by + 0.9, -0.9)
	for i = 0, 3 do
		local len = 4.2 - i * 0.65
		local a = sh + V(sx * 0.2, -i * 0.1, i * 0.35)
		rod("Wing" .. s, a, a + V(sx * len * 0.75, len * 0.55, len * 0.35), 1.1, i % 2 == 0 and WHITE or rgb(222, 236, 255), {h = 0.2})
	end
	rod("Wing" .. s, sh, sh + V(sx * 2.3, 1.7, 1.0), 0.18, HF, {h = 0.28})
	joint("Wing" .. s, "Torso", sh)
end)
return {name = "Pegasus", parts = P, joints = J, hrpSize = V(2.2, 6, 4.6), hrpPos = V(0, 3, 0)}
