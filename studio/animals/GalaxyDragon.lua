--@base BabyDragon
--@colors local C, CL, HN, WG, IR = rgb(100, 56, 200), rgb(255, 150, 230), rgb(200, 240, 255), rgb(60, 30, 140), rgb(255, 80, 220)
-- Galaxy Dragon (Space egg, Legendary premium): violet chibi dragon, glowing magenta eyes, crystal wing shards,
-- star-filled body and a tiny orbiting planet.
both(function(sx, s)
	local sh = V(sx * 0.55, k.by + 0.5, -0.3)
	for i, o in ipairs({{0.9, 0.9, 0.3}, {1.2, 0.5, 0.5}, {0.6, 1.2, 0.5}}) do add("Wing" .. s, V(0.18, 0.45, 0.18), sh + V(sx * o[1], o[2], o[3]), i == 2 and rgb(120, 230, 255) or rgb(255, 120, 240), {neon = true, rot = {0, 45, sx * -30}}) end
end)
sprinkle("Torso", V(0, k.by, 0), V(1.3, 1.1, 1.7), 8, {rgb(255, 255, 255), rgb(150, 220, 255), rgb(255, 160, 240)}, 37)
sprinkle("Head", k.head, V(1.6, 1.45, 1.35), 4, {rgb(255, 255, 255)}, 38)
add("Head", V(0.35, 0.35, 0.35), k.head + V(1.1, 0.9, 0), rgb(120, 230, 255), {neon = true})
add("Head", V(0.7, 0.05, 0.7), k.head + V(1.1, 0.9, 0), rgb(255, 210, 120), {neon = true, rot = {0, 45, 20}})
return {name = "GalaxyDragon", parts = P, joints = J, hrpSize = V(1.6, 2.8, 2.6), hrpPos = V(0, 1.4, 0)}
