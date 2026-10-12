-- Kit: shared helpers prepended to every animal spec.
local V = Vector3.new
local P, J = {}, {}
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local BLACK, WHITE, PINK = rgb(28, 24, 26), rgb(255, 255, 255), rgb(238, 140, 150)
local function add(g, size, pos, col, o) table.insert(P, {g, size, pos, col, o}) end
local function both(fn) fn(1, "L"); fn(-1, "R") end
local function joint(g, parent, pivot) J[g] = {parent, pivot} end
-- pixel eye on a face plane at z (front = -Z). style: "cute" big square + shine, "sharp" iris+slit, "angry" + brow
local function eye(g, x, y, z, s, style, iris)
	local E = {name = "Eye"}                             -- named so variants leave eyes alone
	add(g, V(s, s * 1.1, 0.06), V(x, y, z), BLACK, E)
	if iris then
		add(g, V(s * 0.78, s * 0.85, 0.06), V(x, y, z - 0.02), iris, E)
		add(g, V(s * 0.22, s * 0.85, 0.06), V(x, y, z - 0.04), BLACK, E)
	end
	add(g, V(s * 0.3, s * 0.3, 0.06), V(x + (x > 0 and 0.18 or -0.18) * s * 2 * 0.5, y + s * 0.25, z - 0.06), WHITE, E)
end
local function brow(g, x, y, z, w, col, ang) add(g, V(w, w * 0.22, 0.08), V(x, y, z), col, {rot = {0, 0, (x > 0 and 1 or -1) * ang}}) end
-- tapering tail chain going back (+Z) from p, curling by `curl` degrees per segment
local function tail(n, p, w0, w1, len, cols, curl, group)
	local pos, ang = p, 0
	for i = 1, n do
		local w = w0 + (w1 - w0) * (i - 1) / math.max(1, n - 1)
		ang += curl
		local dir = V(0, math.sin(math.rad(ang)), math.cos(math.rad(ang)))
		pos = pos + dir * len * 0.5
		add((group or "Tail") .. i, V(w, w, len), pos, cols[(i - 1) % #cols + 1], {rot = {-ang, 0, 0}})
		joint((group or "Tail") .. i, i == 1 and "Torso" or ((group or "Tail") .. (i - 1)), pos - dir * len * 0.5)
		pos = pos + dir * len * 0.5
	end
end
-- rod: a block spanning a -> b (limbs, antennae, whiskers) so connected pieces always meet
local function rod(g, a, b, w, col, o)
	o = o or {}; o.look = b
	add(g, V(w, o.h or w, (b - a).Magnitude + (o.extra or w * 0.6)), (a + b) / 2, col, o)
end
-- quad: four-legged base. o = {col, belly, legCol, pawCol, W, H, L (body), legH, legW, head = {w,h,d}, neckUp, headFwd,
--   tailN, tailW0, tailW1, tailLen, tailCols, tailCurl}. Returns key points for faces.
local function quad(o)
	local by = o.legH + o.H / 2                          -- body centre height
	add("Torso", V(o.W, o.H, o.L * 0.55), V(0, by + o.H * 0.03, -o.L * 0.2), o.col, {studs = true})     -- chest
	add("Torso", V(o.W * 0.9, o.H * 0.92, o.L * 0.5), V(0, by, o.L * 0.25), o.col, {studs = true})       -- hips
	if o.belly then add("Torso", V(o.W * 0.75, 0.3, o.L * 0.8), V(0, by - o.H / 2 - 0.05, 0), o.belly) end
	joint("Torso", "Root", V(0, by, 0))
	local hw, hh, hd = o.head[1], o.head[2], o.head[3]
	local hc = V(0, by + o.H / 2 + (o.neckUp or 0.4), -o.L / 2 - (o.headFwd or 0.3))
	add("Head", V(hw, hh, hd), hc, o.col, {studs = true})
	joint("Head", "Torso", V(0, by + o.H * 0.3, -o.L / 2 + 0.3))
	if (o.neckUp or 0.4) > 0.6 then
		rod("Head", V(0, by + o.H * 0.2, -o.L / 2 + 0.3), hc + V(0, -hh * 0.2, hd * 0.2), math.min(o.W, hw) * 0.75, o.col)
	end
	for _, leg in ipairs({{"FL", 1, -1}, {"FR", -1, -1}, {"BL", 1, 1}, {"BR", -1, 1}}) do
		local g, sx, sz = "Leg" .. leg[1], leg[2], leg[3]
		local x, z = sx * (o.W / 2 - o.legW / 2), sz * (o.L / 2 - o.legW * 0.7)
		add(g, V(o.legW, o.legH + 0.3, o.legW * 1.1), V(x, (o.legH + 0.3) / 2 + 0.15, z), o.legCol or o.col, {studs = o.legH > 1.4})
		add(g, V(o.legW * 1.08, 0.32, o.legW * 1.35), V(x, 0.16, z - o.legW * 0.15), o.pawCol or o.belly or o.col)
		joint(g, "Torso", V(x, o.legH + 0.2, z))
	end
	if o.tailN then tail(o.tailN, V(0, by + o.H * 0.25, o.L / 2), o.tailW0, o.tailW1, o.tailLen, o.tailCols or {o.col}, o.tailCurl or 0) end
	return {head = hc, face = hc.Z - hd / 2 - 0.03, hw = hw, hh = hh, hd = hd, by = by}
end
local MOUTH                                           -- front-centre of the last muzzle made by face() (food goes here)
-- standard face: eyes (+ optional iris/brows), muzzle block, nose, mouth
local function face(k, o)
	local f, c = k.face, k.head
	local ey = c.Y + k.hh * (o.eyeY or 0.15)
	eye("Head", k.hw * (o.eyeX or 0.25), ey, f, o.eyeS or 0.4, o.style, o.iris)
	eye("Head", -k.hw * (o.eyeX or 0.25), ey, f, o.eyeS or 0.4, o.style, o.iris)
	if o.brow then brow("Head", k.hw * 0.27, ey + (o.eyeS or 0.4) * 0.8, f, (o.eyeS or 0.4) * 1.3, o.brow, o.browAng or 14); brow("Head", -k.hw * 0.27, ey + (o.eyeS or 0.4) * 0.8, f, (o.eyeS or 0.4) * 1.3, o.brow, o.browAng or 14) end
	if o.muzzle then
		local m = o.muzzle
		local mc = V(0, c.Y - k.hh * 0.22, f - m[3] / 2 + 0.05)
		add("Head", V(m[1], m[2], m[3]), mc, m[4])
		if o.nose then add("Head", V(o.nose[1], o.nose[2], 0.2), V(0, mc.Y + m[2] / 2 - o.nose[2] / 2, mc.Z - m[3] / 2 - 0.05), o.nose[3] or BLACK) end
		add("Head", V(m[1] * 0.45, 0.07, 0.05), V(0, mc.Y - m[2] * 0.2, mc.Z - m[3] / 2 - 0.03), BLACK)
		if o.tongue then add("Head", V(0.28, 0.32, 0.06), V(0.1, mc.Y - m[2] * 0.45, mc.Z - m[3] / 2 - 0.03), PINK) end
		MOUTH = V(0, mc.Y - m[2] * 0.2, mc.Z - m[3] / 2)
		return mc
	end
end
-- ears: style "point" (triangle-ish tall), "round", "flop" (hanging), placed on head top
local function ears(k, style, col, inner, w, h, spread)
	both(function(sx, s)
		local c = k.head; local top = c.Y + k.hh / 2
		local g = "Ear" .. s
		if style == "flop" then
			add(g, V(w, h, 0.25), V(sx * (k.hw / 2 + w * 0.3), c.Y + k.hh * 0.1, c.Z), col, {rot = {0, 0, sx * 12}})
			joint(g, "Head", V(sx * k.hw / 2, top - 0.1, c.Z))
		else
			local x = sx * k.hw * (spread or 0.3)
			add(g, V(w, h, 0.25), V(x, top + h / 2 - 0.05, c.Z + 0.1), col, {rot = {0, 0, sx * -8}})
			if style == "point" then add(g, V(w * 0.6, h * 0.35, 0.25), V(x - sx * w * 0.1, top + h + h * 0.1, c.Z + 0.1), col, {rot = {0, 0, sx * -8}}) end
			if inner then add(g, V(w * 0.55, h * 0.6, 0.06), V(x, top + h / 2 - 0.05, c.Z - 0.06), inner, {rot = {0, 0, sx * -8}}) end
			joint(g, "Head", V(x, top, c.Z + 0.1))
		end
	end)
end
-- sprinkle: n small neon "stars" on the top and side faces of a box (centre c, size s); same seed = same layout
local function sprinkle(g, c, s, n, cols, seed)
	local r = Random.new(seed or 7)
	for i = 1, n do
		local x, y, z = (r:NextNumber() - 0.5) * s.X * 0.85, (r:NextNumber() - 0.5) * s.Y * 0.85, (r:NextNumber() - 0.5) * s.Z * 0.85
		local side = i % 3
		if side == 0 then y = s.Y / 2 + 0.02 elseif side == 1 then x = s.X / 2 + 0.02 else x = -s.X / 2 - 0.02 end
		local w = (i % 4 == 0) and 0.24 or 0.14
		add(g, V(w, w, w), c + V(x, y, z), cols[(i - 1) % #cols + 1], {neon = true, rot = {0, 45, 0}})
	end
end
-- pup: chibi four-legged pet base (big head, tiny body). Any quad field can be overridden in o.
local function pup(o)
	local d = {W = 1.3, H = 1.1, L = 1.7, legH = 0.5, legW = 0.42, head = {1.6, 1.45, 1.35}, neckUp = 0.05, headFwd = -0.1, tailN = 2, tailW0 = 0.3, tailW1 = 0.25, tailLen = 0.4, tailCurl = -25}
	for key, v in pairs(o) do d[key] = v end
	d.pawCol = d.pawCol or d.belly; d.tailCols = d.tailCols or {d.col}
	return quad(d)
end
-- cute: pet face - big shiny eyes, small muzzle + nose, blush
local function cute(k, mcol, ncol, o)
	o = o or {}
	local mc = face(k, {eyeS = o.eyeS or 0.42, eyeY = 0.12, eyeX = 0.27, iris = o.iris, style = o.iris and "sharp" or "cute", muzzle = {0.7, 0.4, 0.3, mcol}, nose = {0.26, 0.15, ncol}, tongue = o.tongue})
	both(function(sx) add("Head", V(0.3, 0.12, 0.05), V(sx * 0.56, k.head.Y - 0.22, k.face - 0.02), PINK) end)
	return mc
end
-------------------------------------------------------------------------------- accessories (fitted, nothing floats)
local GOLD, GOLDD = rgb(255, 200, 40), rgb(206, 140, 20)
-- tipOf: the far end of a tail segment group built by tail() (so tufts / spades / flames sit exactly on the tip)
local function tipOf(g)
	for i = #P, 1, -1 do
		local p = P[i]
		if p[1] == g and p[5] and p[5].rot then
			local a = -math.rad(p[5].rot[1])
			return p[3] + V(0, math.sin(a), math.cos(a)) * (p[2].Z / 2), a
		end
	end
	error("no tail group " .. g)
end
-- crown: base = centre of its bottom (put it on the top surface). w = width. Band with rims, 8 diamond points with
-- pearl tips, a big front gem and side gems.
local function crown(g, base, w, col, gem, o)
	o = o or {}
	col = col or GOLD; gem = gem or rgb(230, 40, 70)
	local dark = o.dark or col:Lerp(BLACK, 0.3)
	local d = o.d or w * 0.85
	local h = w * 0.3
	add(g, V(w, h, d), base + V(0, h / 2 - 0.03, 0), col, {mat = Enum.Material.Metal})
	add(g, V(w + 0.08, h * 0.22, d + 0.08), base + V(0, h * 0.11, 0), dark, {mat = Enum.Material.Metal})
	add(g, V(w + 0.06, h * 0.16, d + 0.06), base + V(0, h - 0.06, 0), dark, {mat = Enum.Material.Metal})
	local pts = {{1, 1}, {-1, 1}, {1, -1}, {-1, -1}, {0, -1}, {0, 1}, {1, 0}, {-1, 0}}
	for i, q in ipairs(pts) do
		local tall = (q[1] == 0 and q[2] == -1) and 1.5 or ((q[1] == 0 or q[2] == 0) and 1.15 or 0.9)
		local ps = w * 0.2
		local p = base + V(q[1] * (w / 2 - ps * 0.45), h + ps * tall * 0.5 - 0.06, q[2] * (d / 2 - ps * 0.45))
		add(g, V(ps, ps * tall, ps), p, col, {mat = Enum.Material.Metal, rot = {0, 45, 0}})
		add(g, V(ps * 0.55, ps * 0.55, ps * 0.55), p + V(0, ps * tall * 0.5 + ps * 0.15, 0), o.tip or WHITE, {shape = "ball", neon = o.neonTips})
	end
	add(g, V(w * 0.22, w * 0.22, 0.08), base + V(0, h * 0.55, -d / 2 - 0.03), gem, {rot = {0, 0, 45}, neon = o.neonGem})
	both(function(sx)
		add(g, V(w * 0.12, w * 0.12, 0.07), base + V(sx * w * 0.3, h * 0.55, -d / 2 - 0.03), o.gem2 or rgb(60, 140, 255), {rot = {0, 0, 45}})
		add(g, V(0.07, w * 0.14, w * 0.14), base + V(sx * (w / 2 + 0.03), h * 0.55, 0), gem, {rot = {45, 0, 0}})
	end)
end
-- collar: a band wrapped round a body block (centre c, block width w / depth d), buckle and a hanging round tag
local function collar(g, c, w, d, col, tagCol, o)
	o = o or {}
	local hb = o.h or 0.3
	add(g, V(w + 0.12, hb, d + 0.12), c, col)
	add(g, V(w + 0.14, hb * 0.25, d + 0.14), c + V(0, hb * 0.32, 0), col:Lerp(WHITE, 0.25))
	add(g, V(0.08, hb * 1.1, 0.3), c + V(w / 2 + 0.09, 0, 0), rgb(220, 220, 228))             -- buckle
	if tagCol then
		local f = c + V(0, 0, -d / 2 - 0.08)
		add(g, V(0.14, 0.2, 0.14), f + V(0, -hb / 2 - 0.05, 0), rgb(220, 220, 228))           -- ring
		add(g, V(0.08, 0.42, 0.42), f + V(0, -hb / 2 - 0.32, -0.02), tagCol, {shape = "cyl", rot = {0, 90, 0}, mat = Enum.Material.Metal})
		add(g, V(0.06, 0.18, 0.18), f + V(0, -hb / 2 - 0.32, -0.07), tagCol:Lerp(WHITE, 0.4), {shape = "cyl", rot = {0, 90, 0}})
	end
end
-- bowtie at p (its back touches whatever is behind it), s = overall width
local function bowtie(g, p, s, col)
	local dark = col:Lerp(BLACK, 0.35)
	add(g, V(s * 0.24, s * 0.28, s * 0.22), p + V(0, 0, -s * 0.05), col)                     -- knot
	add(g, V(s * 0.25, s * 0.06, s * 0.05), p + V(0, 0, -s * 0.17), dark)
	both(function(sx)
		add(g, V(s * 0.3, s * 0.32, s * 0.16), p + V(sx * s * 0.25, 0, 0), col)               -- inner wing
		add(g, V(s * 0.16, s * 0.5, s * 0.18), p + V(sx * s * 0.42, 0, 0), col)               -- flared end
		add(g, V(s * 0.04, s * 0.36, s * 0.05), p + V(sx * s * 0.3, 0, -s * 0.09), dark)      -- fold line
		add(g, V(s * 0.04, s * 0.26, s * 0.05), p + V(sx * s * 0.42, 0, -s * 0.1), dark)
	end)
end
-- scarf: wrapped band (block w x d at c) + knot on one side + two striped tails hanging down the chest
local function scarf(g, c, w, d, col, stripe, len)
	len = len or 0.9
	add(g, V(w + 0.16, 0.38, d + 0.16), c, col)
	add(g, V(w + 0.18, 0.08, d + 0.18), c, stripe)
	local k = c + V(w * 0.28, -0.12, -d / 2 - 0.12)
	add(g, V(0.36, 0.32, 0.26), k, col)
	for i, dx in ipairs({-0.1, 0.14}) do
		local top = k + V(dx, -0.12, -0.02 - i * 0.03)
		add(g, V(0.26, len, 0.1), top + V(0, -len / 2, 0), col, {rot = {0, 0, (i == 1) and 6 or -8}})
		add(g, V(0.27, 0.08, 0.11), top + V(0, -len * 0.35, 0), stripe, {rot = {0, 0, (i == 1) and 6 or -8}})
		add(g, V(0.27, 0.08, 0.11), top + V(0, -len * 0.7, 0), stripe, {rot = {0, 0, (i == 1) and 6 or -8}})
		for f = -1, 1 do add(g, V(0.05, 0.12, 0.05), top + V(f * 0.08, -len - 0.04, 0), stripe) end
	end
end
-- bell hanging under p (p = point on the strap): loop, dome, flared rim, slot, clapper
local function bell(g, p, s, col)
	col = col or GOLD
	add(g, V(s * 0.2, s * 0.25, s * 0.2), p + V(0, -s * 0.1, 0), col:Lerp(BLACK, 0.3))
	add(g, V(s * 0.55, s * 0.55, s * 0.55), p + V(0, -s * 0.4, 0), col, {shape = "ball", mat = Enum.Material.Metal})
	add(g, V(s * 0.7, s * 0.4, s * 0.7), p + V(0, -s * 0.68, 0), col, {mat = Enum.Material.Metal})
	add(g, V(s * 0.86, s * 0.12, s * 0.86), p + V(0, -s * 0.9, 0), col:Lerp(BLACK, 0.2), {mat = Enum.Material.Metal})
	add(g, V(s * 0.5, s * 0.06, 0.04), p + V(0, -s * 0.72, -s * 0.36), col:Lerp(BLACK, 0.5))
	add(g, V(s * 0.2, s * 0.2, s * 0.2), p + V(0, -s * 1.0, 0), col:Lerp(BLACK, 0.4), {shape = "ball"})
end
-------------------------------------------------------------------------------- food carried in the mouth
-- p = front-centre of the mouth, s = scale (1 for a chibi pet). Crosswise items are held in the middle and touch the
-- muzzle; round items sit just in front of it.
local function bone(g, p, s, col, o)
	o = o or {}
	local c = p + V(0, 0, -0.06 * s)
	add(g, V(1.1 * s, 0.18 * s, 0.18 * s), c, col, {neon = o.neon})
	for _, x in ipairs({-0.55, 0.55}) do for _, y in ipairs({-0.1, 0.1}) do
		add(g, V(0.24 * s, 0.24 * s, 0.24 * s), c + V(x * s, y * s, 0), o.knob or col, {shape = "ball", neon = o.neon})
	end end
end
local function fish(g, p, s, col, o)
	o = o or {}
	local c = p + V(0.1 * s, 0, -0.07 * s)
	add(g, V(0.9 * s, 0.34 * s, 0.18 * s), c, col, {neon = o.neon})
	add(g, V(0.5 * s, 0.1 * s, 0.19 * s), c + V(0, -0.1 * s, 0), o.belly or col:Lerp(WHITE, 0.5))
	add(g, V(0.18 * s, 0.42 * s, 0.08 * s), c + V(0.52 * s, 0, 0), o.tail or col:Lerp(BLACK, 0.2), {rot = {0, 0, 0}})
	add(g, V(0.08 * s, 0.08 * s, 0.2 * s), c + V(-0.32 * s, 0.06 * s, 0), BLACK)
	add(g, V(0.3 * s, 0.12 * s, 0.08 * s), c + V(0.05 * s, 0.22 * s, 0), o.tail or col:Lerp(BLACK, 0.2))
end
local function carrot(g, p, s, col, o)
	o = o or {}
	local c = p + V(0, 0, -0.06 * s)
	for i, w in ipairs({0.26, 0.21, 0.15}) do add(g, V(0.36 * s, w * s, w * s), c + V((-0.45 + i * 0.3) * s, 0, 0), col or rgb(255, 140, 30), {neon = o.neon}) end
	for _, a in ipairs({-25, 0, 25}) do add(g, V(0.36 * s, 0.07 * s, 0.1 * s), c + V(-0.42 * s, 0.05 * s, 0), o.leaf or rgb(80, 180, 60), {rot = {0, 0, 180 + a}}) end
end
local function fruit(g, p, s, col, o)
	o = o or {}
	local c = p + V(0, -0.04 * s, -0.24 * s)
	add(g, V(0.48 * s, 0.46 * s, 0.46 * s), c, col, {shape = o.box and nil or "ball", neon = o.neon})
	add(g, V(0.06 * s, 0.16 * s, 0.06 * s), c + V(0, 0.28 * s, 0), rgb(110, 70, 40))
	add(g, V(0.2 * s, 0.05 * s, 0.12 * s), c + V(0.1 * s, 0.32 * s, 0), o.leaf or rgb(80, 180, 60), {rot = {0, 0, 20}})
	if o.spots then for _, q in ipairs({{-0.12, 0.08}, {0.1, -0.1}, {0.14, 0.12}}) do add(g, V(0.06 * s, 0.06 * s, 0.04 * s), c + V(q[1] * s, q[2] * s, -0.23 * s), o.spots) end end
end
local function worm(g, p, s, col)
	local c = p + V(0, 0, -0.05 * s)
	local pts = {{-0.12, -0.05}, {0.08, -0.22}, {0.24, -0.4}, {0.1, -0.58}}
	for i, q in ipairs(pts) do add(g, V(0.2 * s, 0.2 * s, 0.2 * s), c + V(q[1] * s, q[2] * s, 0), col or rgb(240, 130, 150), {shape = "ball"}) end
	add(g, V(0.18 * s, 0.18 * s, 0.18 * s), c + V(-0.28 * s, 0.02 * s, 0), col or rgb(240, 130, 150), {shape = "ball"})
end
-- sprig: a stem held crosswise, with leaves (or berries / a flower) at the far end
local function sprig(g, p, s, stem, top, kind, o)
	o = o or {}
	local c = p + V(0, 0, -0.06 * s)
	add(g, V(0.9 * s, 0.07 * s, 0.07 * s), c + V(0.15 * s, 0, 0), stem)
	local e = c + V(0.6 * s, 0, 0)
	if kind == "berries" then
		for _, q in ipairs({{0.05, 0.1}, {0.18, -0.06}, {-0.05, -0.12}}) do add(g, V(0.18 * s, 0.18 * s, 0.18 * s), e + V(q[1] * s, q[2] * s, 0), top, {shape = "ball", neon = o.neon}) end
		add(g, V(0.25 * s, 0.05 * s, 0.12 * s), e + V(-0.15 * s, 0.1 * s, 0), rgb(80, 170, 60), {rot = {0, 0, 30}})
	elseif kind == "flower" then
		for i = 0, 4 do local a = math.rad(i * 72); add(g, V(0.16 * s, 0.16 * s, 0.06 * s), e + V(math.cos(a) * 0.14 * s, math.sin(a) * 0.14 * s, 0), top) end
		add(g, V(0.14 * s, 0.14 * s, 0.08 * s), e, rgb(255, 210, 60))
	else
		for i, a in ipairs({35, -30, 10}) do add(g, V(0.34 * s, 0.05 * s, 0.16 * s), e + V((i - 2) * 0.12 * s, (i == 2 and -0.08 or 0.08) * s, 0), top, {rot = {0, 0, a}}) end
	end
end
local function chili(g, p, s)
	local c = p + V(0, 0, -0.06 * s)
	add(g, V(0.4 * s, 0.2 * s, 0.2 * s), c + V(0.1 * s, 0, 0), rgb(230, 40, 30))
	add(g, V(0.3 * s, 0.15 * s, 0.15 * s), c + V(0.38 * s, -0.08 * s, 0), rgb(230, 40, 30), {rot = {0, 0, -25}})
	add(g, V(0.12 * s, 0.14 * s, 0.14 * s), c + V(0.55 * s, -0.18 * s, 0), rgb(255, 120, 30), {neon = true, rot = {0, 0, -45}})
	add(g, V(0.14 * s, 0.24 * s, 0.24 * s), c + V(-0.15 * s, 0, 0), rgb(70, 160, 50)); add(g, V(0.15 * s, 0.06 * s, 0.06 * s), c + V(-0.28 * s, 0.03 * s, 0), rgb(70, 160, 50))
end
local function drumstick(g, p, s)
	local c = p + V(0, 0, -0.06 * s)
	add(g, V(0.5 * s, 0.4 * s, 0.4 * s), c + V(0.15 * s, 0, 0), rgb(176, 96, 44)); add(g, V(0.3 * s, 0.3 * s, 0.41 * s), c + V(0.3 * s, 0.03 * s, 0), rgb(200, 120, 60))
	add(g, V(0.4 * s, 0.12 * s, 0.12 * s), c + V(-0.25 * s, 0, 0), rgb(250, 244, 230))
	for _, y in ipairs({-0.07, 0.07}) do add(g, V(0.14 * s, 0.14 * s, 0.14 * s), c + V(-0.47 * s, y * s, 0), rgb(250, 244, 230), {shape = "ball"}) end
end
-- star cookie / crystal / lava rock: a chunky shape held just in front of the mouth
local function star(g, p, s, col, o)
	o = o or {}
	local c = p + V(0, -0.02 * s, -0.12 * s)
	add(g, V(0.5 * s, 0.5 * s, 0.14 * s), c, col, {neon = o.neon}); add(g, V(0.5 * s, 0.5 * s, 0.14 * s), c, col, {neon = o.neon, rot = {0, 0, 45}})
	if o.icing then add(g, V(0.2 * s, 0.2 * s, 0.05 * s), c + V(0, 0, -0.08 * s), o.icing, {rot = {0, 0, 45}}) end
end
local function crystal(g, p, s, col, o)
	o = o or {}
	local c = p + V(0, -0.05 * s, -0.2 * s)
	add(g, V(0.36 * s, 0.36 * s, 0.36 * s), c, col, {neon = o.neon, rot = {45, 45, 0}})
	if o.cracks then for _, r in ipairs({{0, 0, 30}, {0, 0, -40}}) do add(g, V(0.4 * s, 0.05 * s, 0.38 * s), c, o.cracks, {neon = true, rot = r}) end end
end
