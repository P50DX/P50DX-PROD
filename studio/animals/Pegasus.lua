--@base Horse
--@colors local C, CD, MN, HF = rgb(236, 244, 255), rgb(190, 214, 240), rgb(110, 170, 250), rgb(255, 204, 70)
-- Pegasus: sky-white horse with a blue mane and big layered feathered wings with gold edges.
both(function(sx, s)
	local sh = V(sx * 0.9, k.by + 0.9, -0.9)
	featherWing("Wing" .. s, sh, sx, 3.6, HF, {WHITE, rgb(222, 236, 255), rgb(200, 222, 250)})
	joint("Wing" .. s, "Torso", sh)
end)
return {name = "Pegasus", parts = P, joints = J, hrpSize = V(2.2, 6, 4.6), hrpPos = V(0, 3, 0)}
