--!strict
-- AnimalAnimate (LocalScript -> StarterPlayer/StarterCharacterScripts)
-- Plays the 9 animal clips (Idle, Walk, Run, Sprint, Jump, Fall, Land, TurnL,
-- TurnR) on the local player's animal and replaces Roblox's default "Animate".
--   * Speed picks the blend between Idle / Walk / Run / Sprint.
--   * Playback rate follows the real speed, but is capped so huge speeds don't
--     turn the legs into a blur.
--   * Jump / Fall / Land follow the Humanoid state; TurnL / TurnR play when the
--     animal turns on the spot.
--   * Every change is a smooth weight fade, never a hard cut.
-- Animations started by the local player replicate, so other players see them.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent :: Model
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local root = character:WaitForChild("HumanoidRootPart") :: BasePart

---------------------------------------------------------------- CONFIG
-- Where the clips live. The script checks these in order:
--   1. a Folder called "Animations" inside the character
--   2. ReplicatedStorage.AnimalAnimations.<AnimalName>
-- Each folder holds Animation objects named Idle, Walk, Run, Sprint, Jump,
-- Fall, Land, TurnL, TurnR (missing ones are skipped).
-- AnimalName comes from the "Animal" attribute on the character, then the player.
local ANIM_FOLDER_NAME = "Animations"
local SHARED_FOLDER_NAME = "AnimalAnimations"
local ANIMAL_ATTRIBUTE = "Animal"

-- Speed (studs/s) each locomotion clip was authored for. Override per animal
-- with a "NativeSpeed" number attribute on the Animation object.
local NATIVE_SPEED = { Walk = 8, Run = 18, Sprint = 32 }

-- Blend points (studs/s): below IDLE_MAX is idle, then Walk -> Run -> Sprint.
local IDLE_MAX = 0.75
local WALK_FULL = 6 -- fully Walk from here
local RUN_FULL = 16 -- fully Run from here
local SPRINT_FULL = 30 -- fully Sprint from here (and above)

local MIN_RATE = 0.6 -- slowest playback rate for moving clips
local MAX_RATE = 2.2 -- cap so very high speeds don't look silly
local BLEND_TIME = 0.2 -- seconds to fade locomotion weights
local SPEED_SMOOTH = 10 -- how fast the measured speed follows the real one

local TURN_RATE = 2.5 -- radians/s of yaw needed to play TurnL/TurnR
local TURN_MAX_SPEED = 3 -- only turn-on-the-spot below this speed
local LAND_MIN_FALL = 0.25 -- seconds in the air before Land plays
------------------------------------------------------------------------

-- Stop Roblox's default animations so they don't fight ours.
local defaultAnimate = character:FindFirstChild("Animate")
if defaultAnimate and defaultAnimate:IsA("LocalScript") then
	defaultAnimate.Enabled = false
	defaultAnimate:Destroy()
end

-- A skinned animal model may carry its own AnimationController; use that if
-- there is one, else the Humanoid.
local function getAnimator(): Animator
	local controller = character:FindFirstChildWhichIsA("AnimationController", true)
	local parent: Instance = controller or humanoid
	local animator = parent:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = parent
	end
	return animator :: Animator
end

local function findAnimFolder(): Instance?
	local own = character:FindFirstChild(ANIM_FOLDER_NAME)
	if own then return own end
	local animal = character:GetAttribute(ANIMAL_ATTRIBUTE) or player:GetAttribute(ANIMAL_ATTRIBUTE)
	local shared = ReplicatedStorage:FindFirstChild(SHARED_FOLDER_NAME)
	if shared and typeof(animal) == "string" then
		return shared:FindFirstChild(animal)
	end
	return nil
end

---------------------------------------------------------------- tracks
type Clip = { track: AnimationTrack, native: number }

local LOCOMOTION = { "Idle", "Walk", "Run", "Sprint" }
local clips: { [string]: Clip } = {}
local weights: { [string]: number } = {}

local function stopAll()
	for _, clip in clips do
		clip.track:Stop(BLEND_TIME)
		clip.track:Destroy()
	end
	table.clear(clips)
	table.clear(weights)
end

local function loadClips()
	stopAll()
	local folder = findAnimFolder()
	if not folder then
		-- No uploaded clips for this animal: AnimalMotion (procedural) animates it instead.
		character:SetAttribute("ClipsLoaded", false)
		return
	end
	local animator = getAnimator()
	for _, name in { "Idle", "Walk", "Run", "Sprint", "Jump", "Fall", "Land", "TurnL", "TurnR" } do
		local anim = folder:FindFirstChild(name)
		if anim and anim:IsA("Animation") then
			local track = animator:LoadAnimation(anim)
			local isLoco = table.find(LOCOMOTION, name) ~= nil
			track.Looped = isLoco or name == "Fall" or name == "TurnL" or name == "TurnR"
			track.Priority = if isLoco then Enum.AnimationPriority.Core
				elseif name == "TurnL" or name == "TurnR" then Enum.AnimationPriority.Idle
				else Enum.AnimationPriority.Movement
			local native = anim:GetAttribute("NativeSpeed")
			clips[name] = {
				track = track,
				native = if typeof(native) == "number" and native > 0 then native else (NATIVE_SPEED :: any)[name] or 1,
			}
		end
	end
	character:SetAttribute("ClipsLoaded", next(clips) ~= nil)
	-- Locomotion clips always run; only their weights change.
	for _, name in LOCOMOTION do
		local clip = clips[name]
		if clip then
			clip.track:Play(0, 0.001, 1)
			weights[name] = 0
		end
	end
end

local function setWeight(name: string, w: number, fade: number)
	local clip = clips[name]
	if not clip then return end
	w = math.max(w, 0.001) -- weight 0 would stop the track
	if math.abs((weights[name] or 0) - w) > 0.02 then
		weights[name] = w
		clip.track:AdjustWeight(w, fade)
	end
end

local function playOnce(name: string, fade: number)
	local clip = clips[name]
	if clip and not clip.track.IsPlaying then
		clip.track:Play(fade, 1, 1)
	end
end

local function stop(name: string, fade: number)
	local clip = clips[name]
	if clip and clip.track.IsPlaying then
		clip.track:Stop(fade)
	end
end

---------------------------------------------------------------- blending
-- Linear ramp from 0 at a to 1 at b.
local function ramp(x: number, a: number, b: number): number
	return math.clamp((x - a) / (b - a), 0, 1)
end

-- Weights for Idle/Walk/Run/Sprint that always add up to 1.
local function locomotionWeights(speed: number): (number, number, number, number)
	local moving = ramp(speed, IDLE_MAX, WALK_FULL)
	local toRun = ramp(speed, WALK_FULL, RUN_FULL)
	local toSprint = ramp(speed, RUN_FULL, SPRINT_FULL)
	local idle = 1 - moving
	local walk = moving * (1 - toRun)
	local run = moving * toRun * (1 - toSprint)
	local sprint = moving * toRun * toSprint
	return idle, walk, run, sprint
end

-- If an animal is missing Run or Sprint, give that weight to the next clip down.
local function fallbackWeights(idle: number, walk: number, run: number, sprint: number)
	if not clips.Sprint then run, sprint = run + sprint, 0 end
	if not clips.Run then walk, run = walk + run, 0 end
	if not clips.Walk then idle, walk = idle + walk, 0 end
	return idle, walk, run, sprint
end

---------------------------------------------------------------- state
local airborne = false
local airTime = 0
local smoothSpeed = 0
local lastYaw: number? = nil

humanoid.StateChanged:Connect(function(_, new)
	if new == Enum.HumanoidStateType.Jumping then
		airborne, airTime = true, 0
		stop("Land", 0.05)
		playOnce("Jump", 0.05)
	elseif new == Enum.HumanoidStateType.Freefall then
		if not airborne then airborne, airTime = true, 0 end
		playOnce("Fall", 0.3)
	elseif new == Enum.HumanoidStateType.Landed
		or new == Enum.HumanoidStateType.Running
		or new == Enum.HumanoidStateType.RunningNoPhysics then
		if airborne then
			airborne = false
			stop("Fall", 0.1)
			stop("Jump", 0.1)
			if airTime >= LAND_MIN_FALL then
				playOnce("Land", 0.05)
			end
		end
	elseif new == Enum.HumanoidStateType.Dead then
		stopAll()
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if humanoid.Health <= 0 or next(clips) == nil then return end
	if airborne then airTime += dt end

	-- Horizontal speed, smoothed so small bumps don't flicker the blend.
	local v = root.AssemblyLinearVelocity
	local speed = Vector3.new(v.X, 0, v.Z).Magnitude
	smoothSpeed += (speed - smoothSpeed) * math.min(1, dt * SPEED_SMOOTH)

	-- In the air the legs keep their last blend but fade toward idle.
	local blendSpeed = if airborne then smoothSpeed * 0.5 else smoothSpeed
	local idle, walk, run, sprint = fallbackWeights(locomotionWeights(blendSpeed))
	setWeight("Idle", idle, BLEND_TIME)
	setWeight("Walk", walk, BLEND_TIME)
	setWeight("Run", run, BLEND_TIME)
	setWeight("Sprint", sprint, BLEND_TIME)

	-- Playback rate follows real speed, clamped.
	for _, name in { "Walk", "Run", "Sprint" } do
		local clip = clips[name]
		if clip then
			local rate = math.clamp(smoothSpeed / clip.native, MIN_RATE, MAX_RATE)
			if math.abs(clip.track.Speed - rate) > 0.03 then
				clip.track:AdjustSpeed(rate)
			end
		end
	end

	-- Turn on the spot.
	local look = root.CFrame.LookVector
	local yaw = math.atan2(-look.X, -look.Z)
	local yawRate = 0
	if lastYaw then
		local d = (yaw - lastYaw + math.pi) % (2 * math.pi) - math.pi
		yawRate = d / math.max(dt, 1e-3)
	end
	lastYaw = yaw
	local turning = not airborne and smoothSpeed < TURN_MAX_SPEED and math.abs(yawRate) > TURN_RATE
	if turning and yawRate > 0 then
		stop("TurnR", 0.15)
		playOnce("TurnL", 0.15)
	elseif turning then
		stop("TurnL", 0.15)
		playOnce("TurnR", 0.15)
	else
		stop("TurnL", 0.2)
		stop("TurnR", 0.2)
	end
end)

-- Reload if the animal changes without a respawn.
character:GetAttributeChangedSignal(ANIMAL_ATTRIBUTE):Connect(loadClips)
player:GetAttributeChangedSignal(ANIMAL_ATTRIBUTE):Connect(loadClips)
character.ChildAdded:Connect(function(child)
	if child.Name == ANIM_FOLDER_NAME then loadClips() end
end)

loadClips()
