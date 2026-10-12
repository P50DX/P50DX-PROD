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
	add("Torso", V(o.W, o.H, o.L * 0.5), V(0, by + o.H * 0.03, o.L * 0.25), o.col, {studs = true})       -- hips (same size as the chest so markings sit on it)
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
		-- foot: toe-line paw (leg colour, a touch darker, 3 toes), hoof (solid or split), optional claws / nails
		local lc = o.legCol or o.col
		local fw, fd = o.legW * 1.06, o.legW * 1.2
		local fz = z - o.legW * 0.08
		local front = fz - fd / 2
		if o.hoof then
			local hc = o.pawCol or rgb(60, 50, 44)
			add(g, V(fw, 0.34, fd), V(x, 0.17, fz), hc)
			add(g, V(fw + 0.02, 0.07, fd + 0.02), V(x, 0.36, fz), hc:Lerp(WHITE, 0.15))
			if o.hoof == "split" then add(g, V(0.05, 0.26, 0.06), V(x, 0.15, front - 0.02), hc:Lerp(BLACK, 0.5)) end
		else
			local pc = lc:Lerp(BLACK, 0.12)
			add(g, V(fw, 0.3, fd), V(x, 0.15, fz), pc)
			for _, dx in ipairs({-0.17, 0.17}) do add(g, V(0.045, 0.2, 0.05), V(x + dx * o.legW, 0.13, front - 0.02), lc:Lerp(BLACK, 0.5)) end
			if o.claws then for _, dx in ipairs({-0.33, 0, 0.33}) do add(g, V(0.1, 0.1, 0.16), V(x + dx * o.legW, 0.06, front - 0.07), o.claws, {shape = "wedge", rot = {0, 180, 0}}) end end
			if o.nails then for _, dx in ipairs({-0.33, 0, 0.33}) do add(g, V(0.2 * o.legW, 0.16, 0.08), V(x + dx * o.legW, 0.12, front - 0.03), o.nails) end end
		end
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
-- p = front-centre of the mouth, s = scale (1 for a chibi pet). Crosswise items are gripped in the middle and touch
-- the muzzle; round items sit just in front of it. Everything faces the front so it reads at a glance.
local FS = 1.2                                          -- all food a bit bigger than life so it reads in game
local function shade(c, k) return c:Lerp(k > 0 and WHITE or BLACK, math.abs(k)) end
-- leaf: pointed blade in the front plane, from base point b, direction angle a (deg), length l, width w
local function leaf(g, b, a, l, w, col)
	local d = V(math.cos(math.rad(a)), math.sin(math.rad(a)), 0)
	add(g, V(l * 0.62, w, 0.05), b + d * l * 0.33, col, {rot = {0, 0, a}})
	add(g, V(l * 0.42, w * 0.55, 0.05), b + d * l * 0.78, col, {rot = {0, 0, a}})
	add(g, V(l * 0.85, w * 0.12, 0.06), b + d * l * 0.45, shade(col, -0.25), {rot = {0, 0, a}})
end
local function bone(g, p, s, col, o)
	o = o or {}; s = s * FS
	local c = p + V(0, 0, -0.09 * s)
	add(g, V(0.95 * s, 0.22 * s, 0.2 * s), c, col, {neon = o.neon})
	add(g, V(0.7 * s, 0.05 * s, 0.21 * s), c + V(0, 0.06 * s, 0), shade(col, 0.4), {neon = o.neon})
	for _, x in ipairs({-0.5, 0.5}) do for _, y in ipairs({-0.12, 0.12}) do
		add(g, V(0.3 * s, 0.3 * s, 0.26 * s), c + V(x * s, y * s, 0), o.knob or col, {shape = "ball", neon = o.neon})
	end end
end
local function fish(g, p, s, col, o)
	o = o or {}; s = s * FS
	local c = p + V(0.05 * s, 0, -0.1 * s)
	local fin, belly = o.tail or shade(col, -0.25), o.belly or shade(col, 0.55)
	add(g, V(0.36 * s, 0.4 * s, 0.22 * s), c + V(-0.2 * s, 0, 0), col, {neon = o.neon})          -- head + body
	add(g, V(0.34 * s, 0.34 * s, 0.2 * s), c + V(0.13 * s, 0, 0), col, {neon = o.neon})
	add(g, V(0.24 * s, 0.22 * s, 0.15 * s), c + V(0.4 * s, 0, 0), col, {neon = o.neon})
	add(g, V(0.12 * s, 0.24 * s, 0.16 * s), c + V(-0.42 * s, -0.02 * s, 0), col, {neon = o.neon})  -- snout
	add(g, V(0.6 * s, 0.1 * s, 0.23 * s), c + V(-0.05 * s, -0.13 * s, 0), belly)                 -- pale belly
	for _, y in ipairs({1, -1}) do add(g, V(0.34 * s, 0.1 * s, 0.07 * s), c + V(0.62 * s, y * 0.11 * s, 0), fin, {rot = {0, 0, y * 38}}) end   -- forked tail
	add(g, V(0.28 * s, 0.14 * s, 0.07 * s), c + V(-0.02 * s, 0.24 * s, 0), fin, {rot = {0, 0, -12}})  -- dorsal fin
	add(g, V(0.18 * s, 0.08 * s, 0.24 * s), c + V(-0.04 * s, -0.1 * s, 0), fin, {rot = {0, 0, -30}})  -- side fin
	for _, side in ipairs({-1, 1}) do
		local z = side * 0.115 * s
		add(g, V(0.13 * s, 0.13 * s, 0.03 * s), c + V(-0.26 * s, 0.06 * s, z), WHITE)                -- eye
		add(g, V(0.07 * s, 0.07 * s, 0.035 * s), c + V(-0.27 * s, 0.06 * s, z), BLACK)
		add(g, V(0.03 * s, 0.3 * s, 0.03 * s), c + V(-0.08 * s, 0, z), shade(col, -0.3))             -- gill
		for i = 0, 1 do add(g, V(0.03 * s, 0.22 * s, 0.03 * s), c + V((0.12 + i * 0.14) * s, 0.02 * s, z * 0.92), shade(col, -0.15)) end   -- scale lines
	end
end
local function carrot(g, p, s, col, o)
	o = o or {}; s = s * FS
	col = col or rgb(255, 136, 24)
	local c = p + V(0, 0, -0.1 * s)
	for i, w in ipairs({0.3, 0.25, 0.19, 0.12, 0.07}) do
		add(g, V(0.2 * s, w * s, w * s), c + V((-0.2 + (i - 1) * 0.18) * s, -(i - 1) * 0.02 * s, 0), col, {neon = o.neon})
		if i < 5 then add(g, V(0.03 * s, w * 0.7 * s, w * s + 0.02), c + V((-0.13 + (i - 1) * 0.18) * s, -(i - 1) * 0.02 * s, 0), shade(col, -0.25)) end   -- ridges
	end
	local top = c + V(-0.32 * s, 0.02 * s, 0)
	add(g, V(0.08 * s, 0.24 * s, 0.24 * s), top, shade(o.leaf or rgb(80, 180, 60), -0.2))
	for _, a in ipairs({125, 160, 195, 230}) do leaf(g, top, a, 0.42 * s, 0.11 * s, o.leaf or rgb(80, 180, 60)) end
end
local function fruit(g, p, s, col, o)                                -- apple-style fruit
	o = o or {}; s = s * FS
	local c = p + V(0, -0.04 * s, -0.27 * s)
	add(g, V(0.5 * s, 0.5 * s, 0.5 * s), c, col, {shape = "ball", neon = o.neon})
	add(g, V(0.42 * s, 0.42 * s, 0.46 * s), c + V(0, -0.05 * s, 0), col, {neon = o.neon})        -- fuller bottom
	add(g, V(0.14 * s, 0.05 * s, 0.14 * s), c + V(0, 0.25 * s, 0), shade(col, -0.4))             -- top dent
	add(g, V(0.05 * s, 0.18 * s, 0.05 * s), c + V(0.02 * s, 0.33 * s, 0), rgb(110, 70, 40), {rot = {0, 0, -12}})
	leaf(g, c + V(0.04 * s, 0.36 * s, 0), 25, 0.3 * s, 0.12 * s, o.leaf or rgb(80, 180, 60))
	add(g, V(0.1 * s, 0.07 * s, 0.03 * s), c + V(-0.12 * s, 0.14 * s, -0.24 * s), WHITE, {transp = 0.2})   -- shine
	if o.spots then for _, q in ipairs({{-0.12, 0.0}, {0.1, -0.12}, {0.14, 0.1}, {-0.04, -0.16}}) do add(g, V(0.05 * s, 0.05 * s, 0.03 * s), c + V(q[1] * s, q[2] * s, -0.25 * s), o.spots) end end
end
local function worm(g, p, s, col)
	s = s * FS; col = col or rgb(240, 130, 150)
	local c = p + V(0, 0, -0.08 * s)
	local pts = {{-0.22, 0.02}, {-0.06, -0.06}, {0.08, -0.18}, {0.14, -0.34}, {0.06, -0.5}, {-0.08, -0.6}}
	for i, q in ipairs(pts) do
		add(g, V(0.2 * s, 0.2 * s, 0.2 * s), c + V(q[1] * s, q[2] * s, 0), (i % 2 == 0) and shade(col, -0.12) or col, {shape = "ball"})
	end
	local h = c + V(-0.18 * s, -0.66 * s, 0)
	add(g, V(0.22 * s, 0.22 * s, 0.22 * s), h, col, {shape = "ball"})                            -- head at the dangling end
	for _, x in ipairs({-0.05, 0.05}) do add(g, V(0.04 * s, 0.05 * s, 0.03 * s), h + V(x * s, 0.03 * s, -0.11 * s), BLACK) end
	add(g, V(0.06 * s, 0.03 * s, 0.03 * s), h + V(0, -0.04 * s, -0.11 * s), shade(col, -0.4))
end
-- sprig: stem held crosswise, with berries / a daisy / clover / bamboo leaves / leaves at the far end
local function sprig(g, p, s, stem, top, kind, o)
	o = o or {}; s = s * FS
	local c = p + V(0, 0, -0.08 * s)
	add(g, V(0.85 * s, 0.07 * s, 0.07 * s), c + V(0.15 * s, 0, 0), stem)
	add(g, V(0.14 * s, 0.14 * s, 0.16 * s), c, stem)                                              -- grip point
	local e = c + V(0.6 * s, 0.02 * s, 0)
	if kind == "berries" then
		for _, q in ipairs({{0.0, 0.12}, {0.17, 0.0}, {0.0, -0.14}, {-0.14, 0.0}, {0.12, 0.17}}) do
			local b = e + V(q[1] * s, q[2] * s, 0)
			add(g, V(0.19 * s, 0.19 * s, 0.19 * s), b, top, {shape = "ball", neon = o.neon})
			add(g, V(0.05 * s, 0.05 * s, 0.03 * s), b + V(0, 0, -0.095 * s), shade(top, -0.5))
			add(g, V(0.05 * s, 0.04 * s, 0.02 * s), b + V(-0.04 * s, 0.05 * s, -0.09 * s), WHITE)
		end
		leaf(g, e + V(-0.2 * s, 0.02 * s, 0), 110, 0.3 * s, 0.12 * s, rgb(80, 170, 60))
	elseif kind == "flower" then                                        -- daisy
		for i = 0, 7 do
			local a = i * 45
			local d = V(math.cos(math.rad(a)), math.sin(math.rad(a)), 0)
			add(g, V(0.22 * s, 0.09 * s, 0.05 * s), e + d * 0.15 * s, top, {rot = {0, 0, a}})
		end
		add(g, V(0.06 * s, 0.15 * s, 0.15 * s), e + V(0, 0, -0.02 * s), rgb(255, 200, 40), {shape = "cyl", rot = {0, 90, 0}})
		leaf(g, c + V(0.3 * s, 0, 0), -50, 0.28 * s, 0.1 * s, rgb(80, 170, 60))
	elseif kind == "clover" then
		for _, a in ipairs({90, 210, 330}) do
			local d = V(math.cos(math.rad(a)), math.sin(math.rad(a)), 0)
			add(g, V(0.04 * s, 0.2 * s, 0.2 * s), e + d * 0.11 * s, top, {shape = "cyl", rot = {0, 90, 0}})
			add(g, V(0.045 * s, 0.08 * s, 0.08 * s), e + d * 0.11 * s, shade(top, 0.35), {shape = "cyl", rot = {0, 90, 0}})
		end
	elseif kind == "bamboo" then
		add(g, V(0.4 * s, 0.13 * s, 0.13 * s), e + V(-0.15 * s, 0, 0), rgb(126, 204, 92)); add(g, V(0.05 * s, 0.17 * s, 0.17 * s), e + V(-0.1 * s, 0, 0), rgb(80, 150, 56))
		for _, a in ipairs({60, 15, -35}) do leaf(g, e + V(0.05 * s, 0, 0), a, 0.5 * s, 0.11 * s, top) end
	else
		for _, a in ipairs({55, 10, -40}) do leaf(g, e, a, 0.38 * s, 0.14 * s, top) end
	end
end
local function hay(g, p, s)                                              -- tied bundle of straw, fanned at both ends
	s = s * FS
	local c = p + V(0, 0, -0.12 * s)
	local cols = {rgb(236, 206, 110), rgb(214, 178, 76), rgb(248, 226, 150)}
	add(g, V(0.62 * s, 0.24 * s, 0.24 * s), c, cols[1])                                           -- packed core
	for i = 0, 5 do
		local y, z = ((i % 3) - 1) * 0.08 * s, ((i < 3) and -0.06 or 0.06) * s
		add(g, V(0.66 * s, 0.07 * s, 0.07 * s), c + V(0, y, z - 0.04 * s), cols[i % 3 + 1])        -- straws on the surface
	end
	for _, side in ipairs({-1, 1}) do
		for j, a in ipairs({-35, -15, 5, 25, 45}) do
			local ang = (side < 0) and (180 - a) or a
			local d = V(math.cos(math.rad(ang)), math.sin(math.rad(ang)), 0)
			add(g, V(0.3 * s, 0.06 * s, 0.06 * s), c + V(side * 0.3 * s, 0, -0.04 * s) + d * 0.13 * s, cols[j % 3 + 1], {rot = {0, 0, ang}})
		end
	end
	add(g, V(0.09 * s, 0.28 * s, 0.28 * s), c + V(-0.12 * s, 0, 0), rgb(200, 60, 50)); add(g, V(0.09 * s, 0.28 * s, 0.28 * s), c + V(0.14 * s, 0, 0), rgb(200, 60, 50))   -- twine
end
local function cactusFruit(g, p, s)                                      -- prickly pear
	s = s * FS
	local c = p + V(0, -0.04 * s, -0.27 * s)
	add(g, V(0.44 * s, 0.56 * s, 0.44 * s), c, rgb(222, 50, 120), {shape = "ball"}); add(g, V(0.38 * s, 0.48 * s, 0.42 * s), c, rgb(222, 50, 120))
	for _, q in ipairs({{-0.1, 0.12}, {0.1, 0.05}, {-0.05, -0.12}, {0.12, -0.15}, {0.0, 0.0}}) do add(g, V(0.05 * s, 0.05 * s, 0.03 * s), c + V(q[1] * s, q[2] * s, -0.22 * s), rgb(255, 230, 120)) end
	for _, a in ipairs({70, 90, 110}) do leaf(g, c + V(0, 0.27 * s, 0), a, 0.18 * s, 0.07 * s, rgb(100, 170, 70)) end
end
local function dragonFruit(g, p, s)
	s = s * FS
	local c = p + V(0, -0.04 * s, -0.28 * s)
	add(g, V(0.46 * s, 0.58 * s, 0.46 * s), c, rgb(236, 60, 140), {shape = "ball"}); add(g, V(0.4 * s, 0.5 * s, 0.44 * s), c, rgb(236, 60, 140))
	for i, q in ipairs({{-0.2, 0.1, 150}, {0.2, 0.0, 20}, {-0.18, -0.15, 200}, {0.18, -0.18, -20}, {0.0, 0.3, 90}, {0.08, 0.12, 60}, {-0.05, -0.05, 230}}) do
		add(g, V(0.16 * s, 0.07 * s, 0.05 * s), c + V(q[1] * s, q[2] * s, -0.22 * s), rgb(120, 210, 80), {rot = {0, 0, q[3]}})
	end
end
local function sunBerry(g, p, s)
	s = s * FS
	local c = p + V(0, -0.02 * s, -0.25 * s)
	add(g, V(0.4 * s, 0.4 * s, 0.4 * s), c, rgb(255, 196, 40), {shape = "ball", neon = true})
	for i = 0, 7 do
		local a = i * 45
		local d = V(math.cos(math.rad(a)), math.sin(math.rad(a)), 0)
		add(g, V(0.14 * s, 0.07 * s, 0.05 * s), c + d * 0.27 * s, rgb(255, 150, 30), {neon = true, rot = {0, 0, a}})
	end
end
local function chili(g, p, s)
	s = s * FS
	local c = p + V(0, 0, -0.09 * s)
	local R = rgb(226, 34, 28)
	add(g, V(0.3 * s, 0.22 * s, 0.22 * s), c + V(0.05 * s, 0, 0), R)
	add(g, V(0.26 * s, 0.18 * s, 0.18 * s), c + V(0.28 * s, -0.04 * s, 0), R, {rot = {0, 0, -18}})
	add(g, V(0.22 * s, 0.13 * s, 0.13 * s), c + V(0.46 * s, -0.13 * s, 0), R, {rot = {0, 0, -38}})
	add(g, V(0.16 * s, 0.08 * s, 0.08 * s), c + V(0.56 * s, -0.25 * s, 0), R, {rot = {0, 0, -60}})
	add(g, V(0.18 * s, 0.05 * s, 0.03 * s), c + V(0.1 * s, 0.06 * s, -0.11 * s), rgb(255, 160, 150))   -- shine
	add(g, V(0.1 * s, 0.26 * s, 0.26 * s), c + V(-0.14 * s, 0, 0), rgb(70, 150, 50))                   -- green cap
	add(g, V(0.16 * s, 0.06 * s, 0.06 * s), c + V(-0.24 * s, 0.05 * s, 0), rgb(70, 150, 50), {rot = {0, 0, 25}})
end
local function drumstick(g, p, s)
	s = s * FS
	local c = p + V(0, 0, -0.1 * s)
	local M, ML = rgb(170, 92, 40), rgb(206, 128, 62)
	add(g, V(0.5 * s, 0.44 * s, 0.4 * s), c + V(0.22 * s, 0, 0), M, {shape = "ball"})
	add(g, V(0.4 * s, 0.36 * s, 0.38 * s), c + V(0.18 * s, 0, 0), M)
	add(g, V(0.2 * s, 0.14 * s, 0.05 * s), c + V(0.26 * s, 0.08 * s, -0.19 * s), ML)                   -- crispy highlight
	add(g, V(0.36 * s, 0.13 * s, 0.13 * s), c + V(-0.15 * s, 0, 0), rgb(250, 244, 230))
	for _, y in ipairs({-0.08, 0.08}) do add(g, V(0.16 * s, 0.16 * s, 0.16 * s), c + V(-0.35 * s, y * s, 0), rgb(250, 244, 230), {shape = "ball"}) end
end
-- 5-point star (cookie or glowing star), facing the front
local function star(g, p, s, col, o)
	o = o or {}; s = s * FS
	local c = p + V(0, -0.02 * s, -0.12 * s)
	add(g, V(0.12 * s, 0.3 * s, 0.3 * s), c, col, {shape = "cyl", rot = {0, 90, 0}, neon = o.neon})
	for i = 0, 4 do
		local a = 90 + i * 72
		local d = V(math.cos(math.rad(a)), math.sin(math.rad(a)), 0)
		add(g, V(0.22 * s, 0.2 * s, 0.12 * s), c + d * 0.17 * s, col, {rot = {0, 0, a}, neon = o.neon})
		add(g, V(0.14 * s, 0.11 * s, 0.12 * s), c + d * 0.33 * s, col, {rot = {0, 0, a}, neon = o.neon})
		if o.icing then add(g, V(0.16 * s, 0.04 * s, 0.03 * s), c + d * 0.22 * s + V(0, 0, -0.07 * s), o.icing, {rot = {0, 0, a}}) end
	end
	if o.icing then for _, x in ipairs({-0.06, 0.06}) do add(g, V(0.04 * s, 0.04 * s, 0.03 * s), c + V(x * s, 0.02 * s, -0.07 * s), rgb(255, 100, 140)) end end
end
local function crystal(g, p, s, col, o)                                  -- pointed gem
	o = o or {}; s = s * FS
	local c = p + V(0, -0.02 * s, -0.2 * s)
	add(g, V(0.26 * s, 0.4 * s, 0.26 * s), c, col, {neon = o.neon, rot = {0, 45, 0}})
	add(g, V(0.18 * s, 0.16 * s, 0.18 * s), c + V(0, 0.27 * s, 0), col, {neon = o.neon, rot = {0, 45, 0}})
	add(g, V(0.09 * s, 0.12 * s, 0.09 * s), c + V(0, 0.4 * s, 0), col, {neon = o.neon, rot = {0, 45, 0}})
	add(g, V(0.16 * s, 0.14 * s, 0.16 * s), c + V(0, -0.26 * s, 0), col, {neon = o.neon, rot = {0, 45, 0}})
	add(g, V(0.06 * s, 0.32 * s, 0.03 * s), c + V(-0.05 * s, 0.02 * s, -0.17 * s), WHITE, {transp = 0.3})   -- facet shine
end
local function lavaRock(g, p, s)
	s = s * FS
	local c = p + V(0, -0.02 * s, -0.22 * s)
	local D = rgb(52, 40, 40)
	add(g, V(0.36 * s, 0.32 * s, 0.34 * s), c, D, {rot = {12, 20, 8}})
	add(g, V(0.24 * s, 0.22 * s, 0.24 * s), c + V(0.15 * s, 0.1 * s, 0), D, {rot = {-15, 35, 20}})
	add(g, V(0.2 * s, 0.2 * s, 0.22 * s), c + V(-0.14 * s, -0.08 * s, 0), D, {rot = {25, -10, -15}})
	for _, r in ipairs({{0.3, 25}, {0.24, -40}, {0.18, 70}}) do add(g, V(r[1] * s, 0.035 * s, 0.4 * s), c, rgb(255, 120, 20), {neon = true, rot = {0, 0, r[2]}}) end
end
-------------------------------------------------------------------------------- wings
-- foldedWing: a bird wing lying flat on the body side. top = shoulder point ON the body side surface, side = +1/-1,
-- len = how far back it reaches, h = how tall it is, cols = {shoulder coverts, middle feathers, long flight feathers}
local function foldedWing(g, top, side, len, h, cols, o)
	o = o or {}
	add(g, V(0.22, h * 0.5, len * 0.5), top + V(side * 0.1, -h * 0.22, len * 0.22), cols[1], {rot = {-6, 0, 0}, studs = o.studs})
	for i = 0, 2 do
		add(g, V(0.2, h * 0.3, len * 0.42), top + V(side * 0.13, -h * (0.4 + 0.13 * i), len * (0.34 + 0.13 * i)), (i % 2 == 0) and cols[2] or cols[2]:Lerp(BLACK, 0.12), {rot = {10 + 5 * i, 0, 0}})
	end
	for i = 0, 2 do                                      -- long flight feathers stacked tight into one wingtip
		add(g, V(0.17, h * 0.17, len * 0.45), top + V(side * 0.16, -h * (0.55 + 0.08 * i), len * (0.55 + 0.05 * i)), (i % 2 == 0) and cols[3] or cols[3]:Lerp(BLACK, 0.15), {rot = {14 + 3 * i, 0, 0}, neon = o.tipNeon})
	end
end
-- membraneWing: bat / dragon wing. Arm bone to elbow and wrist, three finger bones fanning out, membrane stretched
-- between the fingers and back to the body, thumb claw at the wrist. Returns the finger tips.
local function membraneWing(g, sh, side, span, boneCol, memCol, o)
	o = o or {}
	local k = span / 3
	local el = sh + V(side * span * 0.38, span * 0.28, span * 0.1)
	local wr = sh + V(side * span * 0.62, span * 0.14, span * 0.15)
	local tips = {
		sh + V(side * span * 1.0, span * 0.42, span * 0.24),
		sh + V(side * span * 1.05, -span * 0.08, span * 0.28),
		sh + V(side * span * 0.82, -span * 0.45, span * 0.26),
		sh + V(side * span * 0.42, -span * 0.5, span * 0.2),
	}
	local up = V(0, 0, 1)
	-- membrane panels (slightly behind the bones)
	local back = V(0, 0, 0.05 * k)
	for i = 1, 3 do
		local a, b = tips[i], tips[i + 1]
		rod(g, wr + back, (a + b) / 2 + back, (a - b).Magnitude * 0.92, memCol, {h = 0.08 * k, up = up, extra = 0})
	end
	rod(g, sh + V(side * span * 0.15, -span * 0.05, span * 0.08) + back, (tips[4] + wr) / 2 + back, span * 0.42, memCol, {h = 0.08 * k, up = up, extra = 0})
	rod(g, el + back, (tips[1] + wr) / 2 + back, (tips[1] - el).Magnitude * 0.45, memCol, {h = 0.08 * k, up = up, extra = 0})
	-- bones
	rod(g, sh, el, 0.26 * k, boneCol); rod(g, el, wr, 0.22 * k, boneCol)
	for i = 1, 3 do rod(g, wr, tips[i], 0.13 * k, boneCol) end
	add(g, V(0.18 * k, 0.3 * k, 0.18 * k), wr + V(0, 0.2 * k, -0.05 * k), o.claw or rgb(240, 230, 210), {shape = "wedge"})   -- thumb claw
	if o.tipCol then for i = 1, 3 do add(g, V(0.26 * k, 0.26 * k, 0.26 * k), tips[i], o.tipCol, {neon = true, rot = {0, 0, 45}}) end end
	return tips
end
-- featherWing: spread feathered wing raised up and out (Pegasus, Griffin). arm = leading edge colour,
-- cols = {flight feathers, flight feathers alt, small coverts}
local function featherWing(g, sh, side, span, armCol, cols)
	local k = span / 3
	local el = sh + V(side * span * 0.38, span * 0.32, span * 0.12)
	local wr = sh + V(side * span * 0.72, span * 0.52, span * 0.26)
	local tip = sh + V(side * span * 1.0, span * 0.6, span * 0.36)
	rod(g, sh, el, 0.34 * k, armCol); rod(g, el, wr, 0.3 * k, armCol); rod(g, wr, tip, 0.24 * k, armCol)
	local edge = (tip - sh).Unit
	local backDir = V(0, -0.45, 1).Unit
	local dir = (backDir - edge * edge:Dot(backDir)).Unit
	local n = edge:Cross(dir).Unit
	for i = 0, 8 do
		local t = i / 8
		local base = sh:Lerp(tip, 0.08 + t * 0.92)
		local len = span * (0.3 + 0.38 * t)
		rod(g, base, base + dir * len, span * 0.15, (i % 2 == 0) and cols[1] or cols[2], {h = 0.08 * k, up = n, extra = 0})
	end
	for i = 0, 6 do
		local base = sh:Lerp(tip, 0.1 + (i / 6) * 0.8)
		rod(g, base + n * 0.04 * k, base + n * 0.04 * k + dir * span * 0.18, span * 0.14, cols[3], {h = 0.08 * k, up = n, extra = 0})
	end
end
-- beeWing: see-through rounded insect wing (two overlapping discs) with veins, root on the body top
local function beeWing(g, root, side, size)
	local tilt = side * 25
	local c1 = root + V(side * size * 0.45, size * 0.15, -size * 0.05)
	add(g, V(0.04, size, size), c1, rgb(220, 240, 255), {shape = "cyl", rot = {0, 0, 90 + tilt}, transp = 0.4})
	add(g, V(0.04, size * 0.7, size * 0.7), c1 + V(side * size * 0.05, -size * 0.02, size * 0.45), rgb(220, 240, 255), {shape = "cyl", rot = {0, 0, 90 + tilt}, transp = 0.4})
	rod(g, root, c1 + V(side * size * 0.4, size * 0.18, -size * 0.2), 0.04, rgb(120, 130, 150))
	rod(g, root, c1 + V(side * size * 0.3, size * 0.12, size * 0.35), 0.035, rgb(120, 130, 150))
end
-------------------------------------------------------------------------------- hands and front paws
-- hand: palm hanging below the wrist with four separate fingers and a thumb on the inner side.
-- o.fist = clenched (row of knuckles on the front), o.knuckle = knuckle-walking (fingers curled under, on the ground)
local function hand(g, wrist, side, s, col, o)
	o = o or {}
	local dark = col:Lerp(BLACK, 0.3)
	local pc = wrist + V(0, -0.28 * s, 0)
	add(g, V(0.62 * s, 0.56 * s, 0.5 * s), pc, col)
	if o.fist then
		for i = 0, 3 do add(g, V(0.14 * s, 0.22 * s, 0.2 * s), pc + V((-0.21 + 0.14 * i) * s, -0.1 * s, -0.3 * s), col) end
		for i = 0, 2 do add(g, V(0.02 * s, 0.2 * s, 0.03 * s), pc + V((-0.14 + 0.14 * i) * s, -0.1 * s, -0.41 * s), dark) end
		add(g, V(0.36 * s, 0.14 * s, 0.16 * s), pc + V(-side * 0.08 * s, 0.06 * s, -0.33 * s), col)         -- thumb across
	elseif o.knuckle then
		for i = 0, 3 do add(g, V(0.14 * s, 0.24 * s, 0.32 * s), pc + V((-0.21 + 0.14 * i) * s, -0.36 * s, -0.12 * s), col) end
		for i = 0, 2 do add(g, V(0.02 * s, 0.22 * s, 0.03 * s), pc + V((-0.14 + 0.14 * i) * s, -0.36 * s, -0.29 * s), dark) end
		add(g, V(0.16 * s, 0.28 * s, 0.2 * s), pc + V(-side * 0.36 * s, -0.12 * s, -0.08 * s), col, {rot = {0, 0, side * 20}})
	else
		for i = 0, 3 do
			local len = (i == 0 or i == 3) and 0.28 or 0.34
			add(g, V(0.13 * s, len * s, 0.16 * s), pc + V((-0.21 + 0.14 * i) * s, -(0.28 + len / 2 - 0.04) * s, -0.06 * s), col, {rot = {-12, 0, 0}})
		end
		add(g, V(0.16 * s, 0.3 * s, 0.18 * s), pc + V(-side * 0.36 * s, -0.12 * s, -0.12 * s), col, {rot = {0, 0, side * 28}})
	end
	return pc
end
-- toePaw: small front paw / foot block with two toe lines (centre c = paw centre)
local function toePaw(g, c, w, h, d, col)
	add(g, V(w, h, d), c, col)
	for _, dx in ipairs({-0.17, 0.17}) do add(g, V(0.04, h * 0.7, 0.04), c + V(dx * w, -h * 0.05, -d / 2 - 0.02), col:Lerp(BLACK, 0.5)) end
end
