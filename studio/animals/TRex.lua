-- T-Rex (scary): proper theropod - body held horizontal and balanced over big hips, huge deep skull with a long
-- snout, bony brow bosses over side-set glowing eyes, jaws lined with teeth, thick S-curved neck, tiny two-fingered
-- arms, bird-like legs (thigh, backward shin, long foot) with three clawed toes, long thick tapering tail.
local G, GD, BE, MO, RED = rgb(92, 128, 58), rgb(58, 84, 36), rgb(214, 204, 150), rgb(120, 24, 24), rgb(255, 40, 30)
-- body: hips (highest point) -> chest sloping slightly forward-down, pale belly, dark back stripes
add("Torso", V(2.7, 2.7, 2.6), V(0, 6.1, 0.9), G, {studs = true})
add("Torso", V(2.8, 2.8, 3.2), V(0, 5.75, -1.7), G, {studs = true, rot = {-6, 0, 0}})
add("Torso", V(2.3, 0.45, 4.6), V(0, 4.45, -0.6), BE, {rot = {-4, 0, 0}})
for i, z in ipairs({-2.6, -1.6, -0.6, 0.4, 1.4}) do add("Torso", V(2.0 - (i % 2) * 0.4, 0.12, 0.4), V(0, 7.2 - (z < -1 and (z + 1) * -0.1 or 0), z), GD) end
joint("Torso", "Root", V(0, 6.0, 0))
-- neck: two blocks making an S up to the head
add("Neck", V(2.1, 2.0, 1.7), V(0, 6.6, -3.5), G, {studs = true, rot = {30, 0, 0}})
add("Neck", V(1.9, 1.8, 1.4), V(0, 7.35, -4.2), G, {rot = {10, 0, 0}})
add("Neck", V(1.6, 0.4, 2.2), V(0, 5.9, -3.7), BE, {rot = {30, 0, 0}})
joint("Neck", "Torso", V(0, 6.4, -2.9))
-- head: deep skull, long snout, brow bosses, side eyes, nostrils
add("Head", V(2.4, 2.2, 2.4), V(0, 8.0, -5.4), G, {studs = true})
add("Head", V(1.9, 1.5, 2.6), V(0, 7.7, -7.8), G, {studs = true})
add("Head", V(1.2, 0.3, 1.8), V(0, 8.55, -7.6), GD)                                              -- snout ridge
both(function(sx)
	add("Head", V(0.55, 0.45, 1.1), V(sx * 0.95, 9.15, -6.0), GD)                                  -- brow boss
	add("Head", V(0.08, 0.5, 0.75), V(sx * 1.23, 8.5, -6.1), BLACK)                               -- side eye
	add("Head", V(0.08, 0.3, 0.55), V(sx * 1.25, 8.5, -6.15), RED, {neon = true})
	add("Head", V(0.08, 0.3, 0.12), V(sx * 1.27, 8.5, -6.15), BLACK)
	add("Head", V(0.3, 0.2, 0.8), V(sx * 1.1, 8.85, -6.15), GD, {rot = {0, 0, sx * -25}})          -- angry lid
	add("Head", V(0.3, 0.18, 0.08), V(sx * 0.45, 8.15, -9.12), BLACK)                            -- nostril
	add("Head", V(0.12, 0.6, 2.2), V(sx * 1.0, 7.4, -6.6), GD)                                     -- lip line
	for i = 0, 6 do                                                                               -- upper teeth
		add("Head", V(0.14, 0.3, 0.18), V(sx * 0.82, 6.82, -8.8 + i * 0.5), WHITE, {shape = "wedge", rot = {0, 0, 180}})
	end
end)
for i = -2, 2 do add("Head", V(0.16, 0.32, 0.14), V(i * 0.32, 6.82, -9.0), WHITE, {shape = "wedge", rot = {0, 0, 180}}) end
joint("Head", "Neck", V(0, 7.9, -4.6))
-- lower jaw, a little open, with dark mouth and lower teeth
add("Head", V(1.6, 0.6, 3.2), V(0, 6.75, -7.4), MO)                                             -- mouth inside
add("Jaw", V(1.75, 0.65, 4.0), V(0, 6.2, -7.0), G, {rot = {-7, 0, 0}})
add("Jaw", V(1.5, 0.12, 3.7), V(0, 6.55, -7.0), MO, {rot = {-7, 0, 0}})
add("Jaw", V(1.5, 0.2, 3.6), V(0, 5.88, -6.9), BE, {rot = {-7, 0, 0}})
local function jawTop(z) return 6.55 + (z + 7.0) * math.tan(math.rad(7)) end
both(function(sx)
	for i = 0, 5 do local z = -8.7 + i * 0.5; add("Jaw", V(0.13, 0.26, 0.16), V(sx * 0.68, jawTop(z) + 0.1, z), WHITE, {shape = "wedge"}) end
end)
for i = -1, 1 do add("Jaw", V(0.14, 0.26, 0.14), V(i * 0.32, jawTop(-8.85) + 0.1, -8.85), WHITE, {shape = "wedge"}) end
joint("Jaw", "Head", V(0, 6.8, -5.0))
-- tiny arms with two clawed fingers
both(function(sx, s)
	local sh, el, wr = V(sx * 1.3, 5.0, -2.9), V(sx * 1.45, 4.35, -3.25), V(sx * 1.4, 4.4, -3.9)
	rod("Arm" .. s, sh, el, 0.38, G); rod("Arm" .. s, el, wr, 0.32, G)
	add("Arm" .. s, V(0.34, 0.26, 0.3), wr, G)                                                        -- little hand
	for _, dx in ipairs({-0.08, 0.08}) do                                                             -- two clawed fingers
		add("Arm" .. s, V(0.11, 0.22, 0.13), wr + V(dx, -0.2, -0.08), G, {rot = {-20, 0, 0}})
		add("Arm" .. s, V(0.09, 0.14, 0.11), wr + V(dx, -0.36, -0.16), BE, {shape = "wedge", rot = {180, 0, 0}})
	end
	joint("Arm" .. s, "Torso", sh)
end)
-- legs: thigh -> shin angled back -> long foot bone forward -> toes
both(function(sx, s)
	local hip, knee, ankle, ball = V(sx * 1.45, 6.0, 0.9), V(sx * 1.5, 4.0, 0.0), V(sx * 1.5, 1.9, 1.3), V(sx * 1.5, 0.35, 0.4)
	add("Leg" .. s, V(1.4, 2.9, 2.3), (hip + knee) / 2 + V(0, 0.2, 0.2), G, {studs = true, rot = {-20, 0, 0}})
	rod("Leg" .. s, knee, ankle, 1.0, G)
	rod("Leg" .. s, ankle, ball, 0.75, G)
	add("Leg" .. s, V(1.3, 0.45, 1.3), ball + V(0, -0.12, -0.25), GD)
	for _, dx in ipairs({-0.42, 0, 0.42}) do
		rod("Leg" .. s, ball + V(dx * 0.6, -0.15, -0.5), ball + V(dx, -0.2, -1.4), 0.28, GD, {h = 0.26})
		add("Leg" .. s, V(0.18, 0.22, 0.32), ball + V(dx * 1.05, -0.24, -1.6), BE, {shape = "wedge", rot = {0, 180, 0}})
	end
	joint("Leg" .. s, "Torso", hip)
end)
-- long heavy tail carried straight back, slightly up, striped
tail(7, V(0, 6.2, 2.0), 2.3, 0.45, 1.45, {G, G, GD}, 0.6)
return {name = "TRex", parts = P, joints = J, hrpSize = V(3.6, 9.5, 8), hrpPos = V(0, 4.75, -1.5)}
