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
	add(g, V(s, s * 1.1, 0.06), V(x, y, z), BLACK)
	if iris then
		add(g, V(s * 0.78, s * 0.85, 0.06), V(x, y, z - 0.02), iris)
		add(g, V(s * 0.22, s * 0.85, 0.06), V(x, y, z - 0.04), BLACK)
	end
	add(g, V(s * 0.3, s * 0.3, 0.06), V(x + (x > 0 and 0.18 or -0.18) * s * 2 * 0.5, y + s * 0.25, z - 0.06), WHITE)
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
