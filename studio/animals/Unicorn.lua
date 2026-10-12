--@base Horse
--@colors local C, CD, MN, HF = rgb(252, 250, 255), rgb(240, 214, 242), rgb(255, 140, 205), rgb(255, 204, 70)
-- Unicorn: pearl-white horse, rainbow mane, gold spiral horn, gold hooves.
local RB = {rgb(255, 90, 110), rgb(255, 170, 60), rgb(255, 230, 80), rgb(90, 220, 130), rgb(90, 170, 255), rgb(170, 110, 240)}
for i = 0, 5 do add("Head", V(0.42, 0.55, 0.45), V((i % 2 == 0) and 0.04 or -0.04, k.head.Y + 0.75 - i * 0.5, k.head.Z + 0.85 + i * 0.37), RB[i + 1]) end
local b = V(0, k.head.Y + 0.7, k.head.Z - 0.35)
-- spiral horn: stacked tapering segments, each twisted 30 degrees, gold and cream alternating
for i = 0, 5 do
	local s = 0.44 - i * 0.065
	add("Head", V(s, 0.32, s), b + V(0, 0.12 + i * 0.27, -0.05 - i * 0.105), (i % 2 == 0) and rgb(255, 210, 80) or rgb(255, 242, 190), {rot = {-21, i * 30, 0}})
end
add("Head", V(0.08, 0.22, 0.08), b + V(0, 1.75, -0.7), rgb(255, 242, 190), {rot = {-21, 0, 0}})
both(function(sx) add("Head", V(0.08, 0.18, 0.06), V(sx * 0.62, k.head.Y + 0.6, k.face - 0.04), BLACK, {rot = {0, 0, sx * 30}}) end)   -- lashes
return {name = "Unicorn", parts = P, joints = J, hrpSize = V(2.2, 6.4, 4.6), hrpPos = V(0, 3.2, 0)}
