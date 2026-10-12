--!strict
-- AnimalMotion (ModuleScript -> ReplicatedStorage)
-- Procedural animation for every block model tagged "AnimalRig" (players, pets, zookeepers): one shared client loop
-- drives the Motor6D joints the builder made (named after their body group), so no animation uploads are needed.
--   Idle    breathing, slow tail sway, head looking around, ear flicks
--   Walk / Run / Sprint   leg swing scales with speed; quadrupeds trot, then gallop when sprinting
--   Jump / Fall / Land    legs tuck, body pitches up / down, wings flap, squash on landing
--   Turn    head and body lean into the turn
-- Playback is capped (MAX_CYCLES) so very high speeds don't turn the legs into a blur.
-- Speed comes from the model's own movement, so CFrame-moved pets animate too. Models whose AnimalAnimate clips
-- loaded (attribute "ClipsLoaded") are left to the clips.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local AnimalMotion = {}

local TAG = "AnimalRig"
local MAX_CYCLES = 3.2        -- stride cycles per second, cap
local SPRINT_FROM, SPRINT_FULL = 22, 30
local NEAR, FAR = 90, 220     -- full rate within NEAR, half rate to FAR, frozen beyond
local TAU = math.pi * 2

type Joint = { motor: Motor6D, kind: string, side: number, index: number, offset: number, front: boolean }
type Rig = {
	model: Model, root: BasePart, hum: Humanoid?, joints: { Joint }, legLen: number,
	lastPos: Vector3, lastYaw: number, speed: number, yawRate: number, phase: number, t: number,
	air: number, landT: number, wasAir: boolean, flick: number, flickSide: number, skip: boolean,
}

local rigs: { [Model]: Rig } = {}

local function classify(name: string): (string?, number, number, number, boolean)
	-- returns kind, side (+1 left / -1 right / 0), index, phase offset, front
	local q = name:match("^Leg([FB][LR])$")
	if q then
		local off = (q == "FL" or q == "BR") and 0 or math.pi
		return "leg4", (q:sub(2) == "L") and 1 or -1, 0, off, q:sub(1, 1) == "F"
	end
	local fb, u = name:match("^(%u%l+)Upper([LR])$")          -- two-segment legs (Cheetah): FrontUpperL ...
	if fb == "Front" or fb == "Back" then
		local off = ((fb == "Front") == (u == "L")) and 0 or math.pi
		return "leg4", (u == "L") and 1 or -1, 0, off, fb == "Front"
	end
	fb, u = name:match("^(%u%l+)Lower([LR])$")
	if fb == "Front" or fb == "Back" then
		local off = ((fb == "Front") == (u == "L")) and 0 or math.pi
		return "knee", (u == "L") and 1 or -1, 0, off, fb == "Front"
	end
	if name == "Neck" then return "neck", 0, 0, 0, false end
	local s, n = name:match("^Leg([LR])(%d+)$")                  -- insects: tripod gait
	if s then
		local i = tonumber(n) :: number
		local odd = (s == "L") == (i % 2 == 1)
		return "leg2", (s == "L") and 1 or -1, i, odd and 0 or math.pi, false
	end
	s = name:match("^Leg([LR])$")
	if s then return "leg2", (s == "L") and 1 or -1, 0, (s == "L") and 0 or math.pi, false end
	s = name:match("^Arm([LR])$")
	if s then return "arm", (s == "L") and 1 or -1, 0, (s == "L") and math.pi or 0, false end
	n = name:match("^Arm(%d+)$")
	if n then return "tentacle", 0, tonumber(n) :: number, 0, false end
	n = name:match("^Tail(%d+)$")
	if n then return "tail", 0, tonumber(n) :: number, 0, false end
	s = name:match("^Tail([LR])$") or name:match("^Fin([LR])$") or name:match("^Flip([LR])$")
	if s then return "fin", (s == "L") and 1 or -1, 0, 0, false end
	s = name:match("^Wing([LR])$")
	if s then return "wing", (s == "L") and 1 or -1, 0, 0, false end
	s = name:match("^Ear([LR])$")
	if s then return "ear", (s == "L") and 1 or -1, 0, 0, false end
	if name == "Head" then return "head", 0, 0, 0, false end
	s = name:match("^Head([LR])$")
	if s then return "head", (s == "L") and 1 or -1, 0, (s == "L") and 1.3 or 2.6, false end
	if name == "Torso" then return "torso", 0, 0, 0, false end
	return nil, 0, 0, 0, false
end

local function add(model: Model)
	if rigs[model] then return end
	local root = model:FindFirstChild("HumanoidRootPart")
	if not (root and root:IsA("BasePart")) then return end
	local joints = {}
	for _, d in model:GetDescendants() do
		if d:IsA("Motor6D") then
			local kind, side, index, offset, front = classify(d.Name)
			if kind then table.insert(joints, { motor = d, kind = kind, side = side, index = index, offset = offset, front = front }) end
		end
	end
	local legLen = model:GetAttribute("LegLength")
	local _, yaw = root.CFrame:ToOrientation()
	rigs[model] = {
		model = model, root = root, hum = model:FindFirstChildOfClass("Humanoid"), joints = joints,
		legLen = if typeof(legLen) == "number" then legLen else root.Size.Y * 0.4,
		lastPos = root.Position, lastYaw = yaw, speed = 0, yawRate = 0, phase = 0, t = math.random() * 10,
		air = 0, landT = 0, wasAir = false, flick = 2 + math.random() * 3, flickSide = 1, skip = false,
	}
end

local function remove(model: Model)
	local rig = rigs[model]
	if not rig then return end
	for _, j in rig.joints do
		if j.motor.Parent then j.motor.Transform = CFrame.identity end
	end
	rigs[model] = nil
end

local function ramp(x: number, a: number, b: number): number
	return math.clamp((x - a) / (b - a), 0, 1)
end

local function isAirborne(rig: Rig, vy: number): boolean
	local hum = rig.hum
	if hum then
		local st = hum:GetState()
		return st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping
	end
	return math.abs(vy) > 3
end

local function step(rig: Rig, dt: number)
	local root = rig.root
	local pos = root.Position
	local vel = (pos - rig.lastPos) / dt
	rig.lastPos = pos
	local _, yaw = root.CFrame:ToOrientation()
	local dyaw = (yaw - rig.lastYaw + math.pi) % TAU - math.pi
	rig.lastYaw = yaw
	local k = math.min(1, dt * 8)
	rig.speed += (Vector3.new(vel.X, 0, vel.Z).Magnitude - rig.speed) * k
	rig.yawRate += (dyaw / dt - rig.yawRate) * k
	rig.t += dt

	local airNow = isAirborne(rig, vel.Y)
	rig.air += ((airNow and 1 or 0) - rig.air) * math.min(1, dt * 10)
	if rig.wasAir and not airNow then rig.landT = 0.18 end
	rig.wasAir = airNow
	rig.landT = math.max(0, rig.landT - dt)

	local L = rig.legLen
	local speed, t, air = rig.speed, rig.t, rig.air
	local cycles = math.min(speed / (L * 2.4 + 0.5), MAX_CYCLES)
	rig.phase = (rig.phase + TAU * cycles * dt) % TAU
	local ph = rig.phase
	local move = ramp(speed, 0.3, 4) * (1 - air)
	local amp = (0.35 + 0.4 * ramp(speed, 4, SPRINT_FULL)) * move
	local gallop = ramp(speed, SPRINT_FROM, SPRINT_FULL)
	local idle = 1 - ramp(speed, 0.3, 3)
	local turn = math.clamp(rig.yawRate * 0.12, -0.45, 0.45)
	local rising = math.clamp(vel.Y / 30, -1, 1)

	rig.flick -= dt
	if rig.flick < -0.18 then rig.flick = 2 + math.random() * 4; rig.flickSide = math.random() < 0.5 and 1 or -1 end
	local flicking = rig.flick < 0

	for _, j in rig.joints do
		local kind, cf = j.kind, CFrame.identity
		if kind == "leg4" then
			local off = j.offset
			if gallop > 0 then                                        -- gallop: front pair together, back pair together
				local g = (j.front and 0 or math.pi) + (j.side > 0 and 0 or 0.35)
				off = off + (g - off) * gallop
			end
			local swing = amp * math.sin(ph + off)
			local tuck = (j.front and 0.6 or -0.5) * air
			cf = CFrame.Angles(swing + tuck, 0, 0)
		elseif kind == "knee" then
			local off = j.offset
			if gallop > 0 then
				local g = (j.front and 0 or math.pi) + (j.side > 0 and 0 or 0.35)
				off = off + (g - off) * gallop
			end
			local bend = math.max(0, -math.sin(ph + off + 0.6)) * (amp + 0.3 * move) * 1.1   -- lift the foot on the back swing
			local dir = j.front and -1 or 1
			cf = CFrame.Angles(dir * (bend + 0.7 * air), 0, 0)
		elseif kind == "neck" then
			cf = CFrame.Angles(0.05 * amp * math.sin(ph * 2) - 0.1 * air * rising, turn * 0.4, 0)
		elseif kind == "leg2" then
			local swing = amp * math.sin(ph + j.offset) * (j.index > 0 and 0.6 or 1)
			cf = CFrame.Angles(swing + (j.offset == 0 and 0.35 or -0.15) * air, 0, 0)
		elseif kind == "arm" then
			cf = CFrame.Angles(-amp * 0.8 * math.sin(ph + j.offset) + 0.9 * air, 0, j.side * (0.35 * air + 0.03 * math.sin(t * 2) * idle))
		elseif kind == "tentacle" then
			local w = t * (2 + speed * 0.15) + j.index * 0.8
			cf = CFrame.Angles(0.22 * math.sin(w), 0, 0.18 * math.cos(w) - 0.25 * air)
		elseif kind == "tail" then
			local i = j.index
			local sway = (0.12 + 0.12 * idle) * math.sin(t * (2 + speed * 0.05) - i * 0.7) * (0.6 + i * 0.15)
			local bob = 0.12 * amp * math.sin(ph * 2 - i * 0.5)
			cf = CFrame.Angles(bob - 0.25 * air * (i == 1 and 1 or 0.3) + 0.15 * rising * 0, sway - turn * 0.3, 0)
		elseif kind == "fin" then
			cf = CFrame.Angles(0, 0, j.side * 0.18 * math.sin(t * 3 + ph))
		elseif kind == "wing" then
			local flap = air * (0.25 + 0.75 * math.sin(t * 12)) + 0.25 * gallop * math.sin(ph) + 0.05 * math.sin(t * 2) * idle
			cf = CFrame.Angles(0, 0, j.side * flap)
		elseif kind == "ear" then
			local f = (flicking and j.side == rig.flickSide) and 0.45 or 0
			cf = CFrame.Angles(-0.1 * amp * math.sin(ph * 2) - 0.25 * air, 0, j.side * (f - 0.05 * math.sin(ph * 2) * amp))
		elseif kind == "head" then
			local look = 0.25 * math.sin(t * 0.45 + j.offset) * idle
			local bob = 0.07 * amp * math.sin(ph * 2 + 0.6)
			cf = CFrame.Angles(bob + 0.2 * air * rising + 0.03 * math.sin(t * 1.6 + j.offset) * idle, look + turn, 0)
		elseif kind == "torso" then
			local bobY = -math.abs(math.sin(ph)) * 0.07 * L * amp + 0.025 * L * math.sin(t * 2) * idle - rig.landT * 0.9 * L
			local pitch = 0.18 * air * rising + 0.06 * gallop * math.sin(ph) * move
			cf = CFrame.new(0, bobY, 0) * CFrame.Angles(pitch, 0, -turn * 0.25 * move)
		end
		j.motor.Transform = cf
	end
end

local running = false
function AnimalMotion.start()
	if running then return end
	running = true
	for _, m in CollectionService:GetTagged(TAG) do if m:IsA("Model") then add(m) end end
	CollectionService:GetInstanceAddedSignal(TAG):Connect(function(m) if m:IsA("Model") then add(m) end end)
	CollectionService:GetInstanceRemovedSignal(TAG):Connect(function(m) if m:IsA("Model") then remove(m) end end)
	local frame = 0
	RunService.PreSimulation:Connect(function(dt)
		frame += 1
		local cam = workspace.CurrentCamera
		local eye = cam and cam.CFrame.Position or Vector3.zero
		for model, rig in rigs do
			if not model.Parent or not rig.root.Parent then
				rigs[model] = nil
			elseif model:GetAttribute("ClipsLoaded") ~= true then
				local d = (rig.root.Position - eye).Magnitude
				if d < NEAR then
					step(rig, dt)
				elseif d < FAR and frame % 2 == 0 then
					step(rig, dt * 2)
				end
			end
		end
	end)
end

return AnimalMotion
