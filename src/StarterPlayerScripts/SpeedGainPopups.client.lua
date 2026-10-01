--!strict
-- SpeedGainPopups (LocalScript -> StarterPlayer/StarterPlayerScripts)
-- While the local player walks/runs and their Speed goes up, a "+X Speed"
-- label pops out of their character and floats up or down. It fades out when
-- it reaches the top or bottom of the popup zone (the middle box of the screen).
-- It's a LocalScript in PlayerGui, so only this player sees it.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

---------------------------------------------------------------- CONFIG
-- Where the Speed value lives. The script checks these in order:
--   1. player attribute "Speed"
--   2. player.leaderstats.Speed
--   3. any NumberValue/IntValue called "Speed" directly under the player
local SPEED_NAME = "Speed"

-- Popup zone as screen fractions (matches the box you drew: ~33%-68% wide,
-- ~25%-75% tall).
local ZONE_LEFT, ZONE_RIGHT = 0.33, 0.68
local ZONE_TOP, ZONE_BOTTOM = 0.25, 0.75

local FLOAT_SPEED = 220 -- pixels per second
local FADE_TIME = 0.25 -- seconds to fade out at the edge
local MIN_INTERVAL = 0.08 -- min seconds between popups (merges fast ticks)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local STROKE_COLOR = Color3.fromRGB(0, 0, 0)
local GAIN_COLOR = Color3.fromRGB(90, 255, 110)
------------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "SpeedGainPopups"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 5
gui.Parent = player:WaitForChild("PlayerGui")

local function formatNumber(n: number): string
	local abs = math.abs(n)
	if abs >= 1e12 then return string.format("%.1fT", n / 1e12) end
	if abs >= 1e9 then return string.format("%.1fB", n / 1e9) end
	if abs >= 1e6 then return string.format("%.1fM", n / 1e6) end
	if abs >= 1e3 then return string.format("%.1fK", n / 1e3) end
	return tostring(math.floor(n + 0.5))
end

local function isMoving(): boolean
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0.05
end

-- Screen position of the character (clamped into the zone).
local function spawnPoint(): Vector2
	local vp = camera.ViewportSize
	local x, y = vp.X * 0.5, vp.Y * 0.5
	local character = player.Character
	local root = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
	if root and root:IsA("BasePart") then
		local pos, onScreen = camera:WorldToViewportPoint(root.Position)
		if onScreen then
			x, y = pos.X, pos.Y
		end
	end
	x = math.clamp(x + math.random(-40, 40), vp.X * ZONE_LEFT + 60, vp.X * ZONE_RIGHT - 60)
	y = math.clamp(y, vp.Y * ZONE_TOP + 20, vp.Y * ZONE_BOTTOM - 20)
	return Vector2.new(x, y)
end

local function popup(amount: number)
	local vp = camera.ViewportSize
	local start = spawnPoint()

	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Size = UDim2.fromOffset(220, 44)
	label.Position = UDim2.fromOffset(start.X, start.Y)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.RichText = true
	label.TextColor3 = TEXT_COLOR
	label.Text = string.format('<font color="#%s">+%s</font> Speed', GAIN_COLOR:ToHex(), formatNumber(amount))
	label.Rotation = math.random(-8, 8)

	local stroke = Instance.new("UIStroke")
	stroke.Color = STROKE_COLOR
	stroke.Thickness = 2.5
	stroke.Parent = label

	local scale = Instance.new("UIScale")
	scale.Scale = 0.4
	scale.Parent = label
	label.Parent = gui

	-- "Pop" out of the player
	TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

	-- Float randomly up or down with a little sideways drift
	local dirY = if math.random() < 0.5 then -1 else 1
	local driftX = math.random(-60, 60)
	local topY, bottomY = vp.Y * ZONE_TOP, vp.Y * ZONE_BOTTOM
	local leftX, rightX = vp.X * ZONE_LEFT, vp.X * ZONE_RIGHT
	local pos = start
	local fading = false

	local conn: RBXScriptConnection
	conn = RunService.RenderStepped:Connect(function(dt)
		pos += Vector2.new(driftX * dt, dirY * FLOAT_SPEED * dt)
		pos = Vector2.new(math.clamp(pos.X, leftX + 40, rightX - 40), pos.Y)
		label.Position = UDim2.fromOffset(pos.X, pos.Y)

		if not fading and (pos.Y <= topY or pos.Y >= bottomY) then
			fading = true
			local info = TweenInfo.new(FADE_TIME)
			TweenService:Create(label, info, { TextTransparency = 1 }):Play()
			local t = TweenService:Create(stroke, info, { Transparency = 1 })
			t.Completed:Once(function()
				conn:Disconnect()
				label:Destroy()
			end)
			t:Play()
		end
	end)
end

---------------------------------------------------------------- tracking
local lastValue: number? = nil
local pending = 0
local lastPopup = 0

local function onSpeedChanged(newValue: any)
	if typeof(newValue) ~= "number" then return end
	local old = lastValue
	lastValue = newValue
	if old == nil or newValue <= old then return end
	if not isMoving() then return end -- only while walking/running
	pending += newValue - old
end

RunService.Heartbeat:Connect(function()
	if pending > 0 and os.clock() - lastPopup >= MIN_INTERVAL then
		lastPopup = os.clock()
		popup(pending)
		pending = 0
	end
end)

local function hookValue(v: Instance)
	if v:IsA("ValueBase") then
		lastValue = (v :: any).Value
		;(v :: any).Changed:Connect(onSpeedChanged)
	end
end

if player:GetAttribute(SPEED_NAME) ~= nil then
	lastValue = player:GetAttribute(SPEED_NAME)
	player:GetAttributeChangedSignal(SPEED_NAME):Connect(function()
		onSpeedChanged(player:GetAttribute(SPEED_NAME))
	end)
else
	local leaderstats = player:WaitForChild("leaderstats", 5)
	local value = (leaderstats and leaderstats:FindFirstChild(SPEED_NAME)) or player:FindFirstChild(SPEED_NAME)
	if value then
		hookValue(value)
	else
		warn("[SpeedGainPopups] Couldn't find a '" .. SPEED_NAME .. "' value; edit SPEED_NAME / the lookup at the bottom of this script.")
	end
end
