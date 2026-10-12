--@base Bear
--@colors local B, BD, BL = rgb(52, 40, 110), rgb(30, 22, 70), rgb(150, 120, 240)
-- Cosmic Bear: midnight-purple bear, glowing crescent moon on its chest, star-dusted fur, tiny planet ring halo.
local mz = -4.2 * 0.2 - 4.2 * 0.55 / 2 - 0.03
add("Torso", V(0.9, 0.9, 0.06), V(0.1, k.by + 0.3, mz), rgb(255, 230, 120), {neon = true})
add("Torso", V(0.7, 0.75, 0.06), V(0.35, k.by + 0.38, mz - 0.02), B)
sprinkle("Torso", V(0, k.by + 0.3, -0.9), V(2.8, 2.5, 2.3), 12, {rgb(255, 255, 255), rgb(170, 220, 255)}, 4)
for i = 0, 11 do
	local a = math.rad(i * 30)
	add("Head", V(0.45, 0.12, 0.2), k.head + V(math.cos(a) * 1.3, 1.6, math.sin(a) * 1.3), rgb(255, 210, 120), {neon = true, rot = {0, -i * 30 + 90, 0}})
end
return {name = "CosmicBear", parts = P, joints = J, hrpSize = V(3, 5.6, 5), hrpPos = V(0, 2.8, 0)}
