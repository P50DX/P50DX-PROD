-- AnimalPicker (LocalScript -> StarterPlayer/StarterPlayerScripts)
-- "Change Animal" button + picker window: tabs (Animals / Pets / Zookeepers), version chips (Normal, Golden, ...),
-- search box and a grid of 3D thumbnails. Clicking one asks AnimalSwitchService to turn you into it.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("ChangeAnimal")
local previews = ReplicatedStorage:WaitForChild("AnimalPreviews")
local AnimalVariants = require(ReplicatedStorage:WaitForChild("AnimalVariants"))

local VERSIONS = { "Normal", "Golden", "Rainbow", "Diamond", "Shadow", "Celestial", "Cosmic" }
local VERSION_COLOURS = {
	Normal = Color3.fromRGB(120, 200, 110), Golden = Color3.fromRGB(255, 196, 40), Rainbow = Color3.fromRGB(255, 110, 170),
	Diamond = Color3.fromRGB(110, 210, 255), Shadow = Color3.fromRGB(110, 80, 160), Celestial = Color3.fromRGB(250, 236, 180),
	Cosmic = Color3.fromRGB(160, 100, 240),
}
local FONT = Enum.Font.FredokaOne
local DARK = Color3.fromRGB(30, 34, 52)

local state = { tab = "Animals", version = "Normal", search = "" }

local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 12); c.Parent = p; return c end
local function stroke(p, t, col) local s = Instance.new("UIStroke"); s.Thickness = t or 3; s.Color = col or DARK; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s end
local function label(parent, text, size)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1; l.Font = FONT; l.Text = text; l.TextColor3 = Color3.new(1, 1, 1); l.TextScaled = true
	l.Size = size or UDim2.fromScale(1, 1); l.Parent = parent
	local ts = Instance.new("UIStroke"); ts.Thickness = 2; ts.Color = DARK; ts.Parent = l
	return l
end
local function button(parent, text, colour)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true; b.BackgroundColor3 = colour; b.Text = ""; b.Parent = parent
	corner(b, 10); stroke(b, 3)
	local l = label(b, text, UDim2.new(1, -12, 1, -8)); l.Position = UDim2.fromOffset(6, 4)
	return b, l
end

local gui = Instance.new("ScreenGui")
gui.Name = "AnimalPicker"; gui.ResetOnSpawn = false; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- open button (bottom-left)
local open = button(gui, "🐾 Change Animal", Color3.fromRGB(255, 150, 40))
open.AnchorPoint = Vector2.new(0, 1); open.Position = UDim2.new(0, 16, 1, -16); open.Size = UDim2.fromOffset(190, 52)

-- window
local win = Instance.new("Frame")
win.AnchorPoint = Vector2.new(0.5, 0.5); win.Position = UDim2.fromScale(0.5, 0.5); win.Size = UDim2.fromScale(0.72, 0.78)
win.BackgroundColor3 = Color3.fromRGB(60, 70, 110); win.Visible = false; win.Parent = gui
corner(win, 18); stroke(win, 4)
local lim = Instance.new("UISizeConstraint"); lim.MaxSize = Vector2.new(820, 560); lim.MinSize = Vector2.new(320, 300); lim.Parent = win
local grad = Instance.new("UIGradient"); grad.Rotation = 90
grad.Color = ColorSequence.new(Color3.fromRGB(90, 110, 190), Color3.fromRGB(50, 56, 96)); grad.Parent = win

local title = label(win, "Pick an Animal", UDim2.new(1, -120, 0, 40)); title.Position = UDim2.fromOffset(16, 10); title.TextXAlignment = Enum.TextXAlignment.Left
local close = button(win, "X", Color3.fromRGB(235, 70, 70))
close.AnchorPoint = Vector2.new(1, 0); close.Position = UDim2.new(1, -12, 0, 10); close.Size = UDim2.fromOffset(44, 40)

-- tabs
local tabs = Instance.new("Frame"); tabs.BackgroundTransparency = 1; tabs.Position = UDim2.fromOffset(16, 58); tabs.Size = UDim2.new(1, -32, 0, 38); tabs.Parent = win
local tl = Instance.new("UIListLayout"); tl.FillDirection = Enum.FillDirection.Horizontal; tl.Padding = UDim.new(0, 8); tl.Parent = tabs
local tabButtons = {}
for _, t in { "Animals", "Pets", "Zookeepers" } do
	local b = button(tabs, t, Color3.fromRGB(80, 90, 140)); b.Size = UDim2.fromOffset(140, 38); tabButtons[t] = b
end

-- version chips
local chips = Instance.new("Frame"); chips.BackgroundTransparency = 1; chips.Position = UDim2.fromOffset(16, 104); chips.Size = UDim2.new(1, -32, 0, 32); chips.Parent = win
local cl = Instance.new("UIListLayout"); cl.FillDirection = Enum.FillDirection.Horizontal; cl.Padding = UDim.new(0, 6); cl.Parent = chips
local chipButtons = {}
for _, v in VERSIONS do
	local b = button(chips, v, VERSION_COLOURS[v]); b.Size = UDim2.fromOffset(96, 32); chipButtons[v] = b
end

-- search
local search = Instance.new("TextBox")
search.PlaceholderText = "Search..."; search.Text = ""; search.Font = FONT; search.TextScaled = true; search.ClearTextOnFocus = false
search.TextColor3 = DARK; search.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
search.AnchorPoint = Vector2.new(1, 0); search.Position = UDim2.new(1, -16, 0, 58); search.Size = UDim2.fromOffset(170, 38); search.Parent = win
corner(search, 10); stroke(search, 3)

-- grid
local grid = Instance.new("ScrollingFrame")
grid.Position = UDim2.fromOffset(16, 146); grid.Size = UDim2.new(1, -32, 1, -162)
grid.BackgroundColor3 = Color3.fromRGB(40, 46, 78); grid.BackgroundTransparency = 0.2; grid.BorderSizePixel = 0
grid.ScrollBarThickness = 8; grid.AutomaticCanvasSize = Enum.AutomaticSize.Y; grid.CanvasSize = UDim2.new()
grid.Parent = win; corner(grid, 12)
local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0, 8); pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8); pad.PaddingBottom = UDim.new(0, 8); pad.Parent = grid
local gl = Instance.new("UIGridLayout"); gl.CellSize = UDim2.fromOffset(112, 132); gl.CellPadding = UDim2.fromOffset(8, 8); gl.SortOrder = Enum.SortOrder.Name; gl.Parent = grid

local cards = {} -- [tab] = { {frame, model, name} }

local function frameModel(vp: ViewportFrame, model: Model)
	local cam = Instance.new("Camera"); cam.FieldOfView = 40; cam.Parent = vp; vp.CurrentCamera = cam
	local cf, size = model:GetBoundingBox()
	local dist = size.Magnitude * 1.25
	cam.CFrame = CFrame.lookAt(cf.Position + Vector3.new(-0.55, 0.35, -1).Unit * dist, cf.Position)
end

local function buildTab(tab: string)
	if cards[tab] then return end
	cards[tab] = {}
	for _, src in previews:WaitForChild(tab):GetChildren() do
		local card = Instance.new("TextButton")
		card.Name = src.Name; card.Text = ""; card.AutoButtonColor = true
		card.BackgroundColor3 = Color3.fromRGB(70, 80, 130); card.Visible = false; card.Parent = grid
		corner(card, 12); stroke(card, 3)
		local vp = Instance.new("ViewportFrame")
		vp.BackgroundTransparency = 1; vp.Size = UDim2.new(1, 0, 1, -28); vp.Ambient = Color3.fromRGB(200, 200, 210)
		vp.LightDirection = Vector3.new(-1, -2, -1); vp.Parent = card
		local m = src:Clone(); m.Parent = vp
		frameModel(vp, m)
		local name = string.gsub(src.Name, "(%l)(%u)", "%1 %2") -- "BabyPanda" -> "Baby Panda"
		local l = label(card, name, UDim2.new(1, -8, 0, 24)); l.Position = UDim2.new(0, 4, 1, -27)
		card.Activated:Connect(function()
			remote:FireServer(tab, src.Name, state.version)
			win.Visible = false
		end)
		table.insert(cards[tab], { frame = card, model = m, name = src.Name })
	end
end

local function refresh()
	buildTab(state.tab)
	for t, list in cards do
		for _, c in list do
			local match = state.search == "" or string.find(string.lower(c.name), string.lower(state.search), 1, true) ~= nil
			c.frame.Visible = (t == state.tab) and match
			if t == state.tab then
				AnimalVariants.apply(c.model, if state.version == "Normal" then nil else state.version)
			end
		end
	end
	for t, b in tabButtons do b.BackgroundColor3 = (t == state.tab) and Color3.fromRGB(255, 170, 50) or Color3.fromRGB(80, 90, 140) end
	for v, b in chipButtons do
		local s = b:FindFirstChildOfClass("UIStroke")
		if s then s.Color = (v == state.version) and Color3.new(1, 1, 1) or DARK; s.Thickness = (v == state.version) and 4 or 3 end
	end
	title.Text = (state.tab == "Animals" and "Pick an Animal") or (state.tab == "Pets" and "Pick a Pet") or "Pick a Zookeeper"
end

for t, b in tabButtons do b.Activated:Connect(function() state.tab = t; refresh() end) end
for v, b in chipButtons do b.Activated:Connect(function() state.version = v; refresh() end) end
search:GetPropertyChangedSignal("Text"):Connect(function() state.search = search.Text; refresh() end)
open.Activated:Connect(function() win.Visible = not win.Visible; if win.Visible then refresh() end end)
close.Activated:Connect(function() win.Visible = false end)
