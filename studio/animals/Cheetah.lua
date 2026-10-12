-- Cheetah (face of the game): small aerodynamic head, deep chest, narrow waist, long legs, long ringed tail.
local C = {
	gold = Color3.fromRGB(226, 150, 52), goldD = Color3.fromRGB(190, 112, 34), cream = Color3.fromRGB(252, 232, 190),
	spot = Color3.fromRGB(58, 38, 24), black = Color3.fromRGB(28, 24, 22), white = Color3.fromRGB(255, 255, 255),
	amber = Color3.fromRGB(255, 196, 40), pink = Color3.fromRGB(235, 140, 140),
}
local V = Vector3.new
local P = {}
local LIFT = 1.3
local function add(g, size, pos, col, o)
	if not (g:find("Front") or g:find("Back")) then pos = pos + Vector3.new(0, LIFT, 0) end
	table.insert(P, {g, size, pos, col, o})
end
local function both(fn) fn(1); fn(-1) end

-- body: deep chest -> narrow waist -> hips
add("Torso", V(2.5, 2.5, 2.3), V(0, 3.75, -1.2), C.gold, {studs = true})
add("Torso", V(1.9, 1.8, 2.4), V(0, 3.9, 0.95), C.gold, {studs = true})
add("Torso", V(2.2, 2.1, 1.7), V(0, 3.85, 2.75), C.gold, {studs = true})
add("Torso", V(2.1, 0.5, 2.0), V(0, 2.42, -1.2), C.cream)                                  -- chest underside
add("Torso", V(1.5, 0.4, 2.2), V(0, 2.95, 0.95), C.cream)                                  -- tucked belly
add("Torso", V(2.3, 0.25, 4.2), V(0, 5.05, 0.6), C.goldD)                                  -- darker back ridge
-- spots (flat dark tiles on the sides and back)
local spots = { {1.26, 4.3, -1.8}, {1.26, 3.5, -0.9}, {1.26, 4.5, -0.4}, {0.96, 3.6, 0.6}, {0.96, 4.4, 1.3},
	{1.11, 3.6, 2.3}, {1.11, 4.4, 3.1}, {1.26, 3.1, -1.9} }
for _, s in ipairs(spots) do both(function(sx) add("Torso", V(0.08, 0.38, 0.38), V(sx * s[1], s[2], s[3]), C.spot) end) end
for _, z in ipairs({-1.6, -0.3, 0.9, 2.1, 3.2}) do add("Torso", V(0.38, 0.08, 0.38), V((z % 2 > 1) and 0.45 or -0.45, 5.2, z), C.spot) end

-- neck (rises forward from the chest)
add("Neck", V(1.4, 1.5, 1.4), V(0, 4.75, -2.55), C.gold, {studs = true, rot = {-25, 0, 0}})

-- head: small, sleek; cream muzzle, black nose, tear marks, sharp amber eyes
add("Head", V(2.0, 1.7, 1.9), V(0, 5.65, -3.5), C.gold, {studs = true})
add("Head", V(1.15, 0.5, 0.8), V(0, 5.38, -4.75), C.gold)                                  -- muzzle top
add("Head", V(1.05, 0.42, 0.75), V(0, 4.98, -4.72), C.cream)                               -- jaw
add("Head", V(0.5, 0.3, 0.2), V(0, 5.5, -5.16), C.black)                                -- nose
add("Head", V(0.6, 0.07, 0.06), V(0, 5.1, -5.11), C.black)                                 -- mouth line
both(function(sx)
	add("Head", V(0.55, 0.5, 0.06), V(sx * 0.52, 5.95, -4.47), C.black)                     -- eye socket
	add("Head", V(0.42, 0.38, 0.06), V(sx * 0.52, 5.93, -4.5), C.amber, {neon = false})     -- iris
	add("Head", V(0.11, 0.38, 0.06), V(sx * 0.52, 5.93, -4.53), C.black)                    -- slit pupil
	add("Head", V(0.12, 0.12, 0.06), V(sx * 0.62, 6.04, -4.56), C.white)                    -- shine
	add("Head", V(0.62, 0.13, 0.08), V(sx * 0.55, 6.3, -4.48), C.goldD, {rot = {0, 0, sx * 16}})  -- confident brow (outer end up)
	add("Head", V(0.15, 0.62, 0.06), V(sx * 0.66, 5.45, -4.48), C.black, {rot = {0, 0, sx * -8}})  -- tear mark (eye corner down the cheek)
	add("Head", V(0.08, 0.07, 0.06), V(sx * 0.3, 5.15, -5.11), C.black)                      -- smirk corner
	add("Head", V(0.08, 0.35, 0.35), V(sx * 1.04, 5.7, -3.3), C.cream)                      -- cheek fluff
	-- ears: small rounded, set back on the skull, dark backs
	add("Ear" .. (sx > 0 and "L" or "R"), V(0.55, 0.55, 0.22), V(sx * 0.7, 6.72, -3.1), C.gold, {rot = {0, 0, sx * -12}})
	add("Ear" .. (sx > 0 and "L" or "R"), V(0.32, 0.32, 0.05), V(sx * 0.7, 6.7, -3.23), C.pink, {rot = {0, 0, sx * -12}})
	add("Ear" .. (sx > 0 and "L" or "R"), V(0.5, 0.5, 0.05), V(sx * 0.7, 6.74, -2.97), C.black, {rot = {0, 0, sx * -12}})
end)

-- legs: long and lean; front under the chest, back under the hips
both(function(sx)
	local s = sx > 0 and "L" or "R"
	add("FrontUpper" .. s, V(0.78, 2.0, 0.9), V(sx * 0.82, 3.0, -1.45), C.gold, {studs = true})
	add("FrontUpper" .. s, V(0.08, 0.38, 0.38), V(sx * 1.22, 3.2, -1.45), C.spot)
	add("FrontLower" .. s, V(0.56, 1.85, 0.6), V(sx * 0.82, 1.1, -1.55), C.gold)
	add("FrontLower" .. s, V(0.8, 0.36, 0.95), V(sx * 0.82, 0.18, -1.75), C.cream)          -- paw
	add("FrontLower" .. s, V(0.08, 0.12, 0.1), V(sx * 0.62, 0.2, -2.24), C.black)            -- claws
	add("FrontLower" .. s, V(0.08, 0.12, 0.1), V(sx * 1.02, 0.2, -2.24), C.black)
	add("FrontLower" .. s, V(0.08, 0.32, 0.32), V(sx * 1.11, 1.3, -1.55), C.spot)
	add("BackUpper" .. s, V(0.95, 2.2, 1.3), V(sx * 0.86, 3.4, 2.85), C.gold, {studs = true, rot = {12, 0, 0}})
	add("BackUpper" .. s, V(0.08, 0.4, 0.4), V(sx * 1.35, 3.6, 2.7), C.spot)
	add("BackLower" .. s, V(0.56, 1.95, 0.6), V(sx * 0.86, 1.2, 3.2), C.gold, {rot = {-8, 0, 0}})
	add("BackLower" .. s, V(0.8, 0.36, 0.95), V(sx * 0.86, 0.18, 2.95), C.cream)
	add("BackLower" .. s, V(0.08, 0.12, 0.1), V(sx * 0.66, 0.2, 2.46), C.black)
	add("BackLower" .. s, V(0.08, 0.12, 0.1), V(sx * 1.06, 0.2, 2.46), C.black)
end)

-- tail: long, tapering, curling up at the end; black rings and a white tip
local tz, ty = 3.7, 4.3
for i = 1, 6 do
	local w = 0.72 - i * 0.06
	local len = 0.95
	local col = (i >= 4) and ((i % 2 == 0) and C.black or C.gold) or C.gold
	local up = (i >= 4) and (i - 3) * 0.28 or -0.1
	ty += up; tz += len * 0.92
	add("Tail" .. i, V(w, w, len), V(0, ty, tz), col, {rot = {-(i >= 4 and (i - 3) * 16 or -4), 0, 0}})
	if i <= 3 then add("Tail" .. i, V(0.08, 0.2, 0.25), V(w / 2 + 0.01, ty, tz), C.spot) end
end
add("Tail6", V(0.36, 0.36, 0.3), V(0, ty + 0.12, tz + 0.55), C.white)

local J = { Torso = {"Root", V(0, 5.1, 0.5)}, Neck = {"Torso", V(0, 5.7, -2.1)}, Head = {"Neck", V(0, 6.5, -2.9)},
	EarL = {"Head", V(0.7, 7.75, -3.1)}, EarR = {"Head", V(-0.7, 7.75, -3.1)},
	FrontUpperL = {"Torso", V(0.82, 3.9, -1.45)}, FrontUpperR = {"Torso", V(-0.82, 3.9, -1.45)},
	FrontLowerL = {"FrontUpperL", V(0.82, 2.0, -1.5)}, FrontLowerR = {"FrontUpperR", V(-0.82, 2.0, -1.5)},
	BackUpperL = {"Torso", V(0.86, 4.4, 2.7)}, BackUpperR = {"Torso", V(-0.86, 4.4, 2.7)},
	BackLowerL = {"BackUpperL", V(0.86, 2.2, 3.1)}, BackLowerR = {"BackUpperR", V(-0.86, 2.2, 3.1)},
	Tail1 = {"Torso", V(0, 5.6, 3.6)} }
for i = 2, 6 do J["Tail" .. i] = {"Tail" .. (i - 1), V(0, 0, 0)} end
return { name = "Cheetah", parts = P, joints = J, hrpSize = V(2.4, 5.8, 5), hrpPos = V(0, 2.9, 0.3) }
