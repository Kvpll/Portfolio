-- ============================================================
-- PERSONA 5 STYLE SETTINGS SCREEN
-- Place this LocalScript inside StarterGui, name it SettingsScript
-- Full screen takeover with categorized sections
-- ============================================================

-- ============================================================
--
--   ★ CUSTOMIZATION CONFIG — EDIT EVERYTHING HERE ★
--
-- ============================================================

local CONFIG = {

	screenTitle    = "SETTINGS",
	screenSubtitle = "OPTIONS",

	-- CATEGORIES
	-- Order here controls the order they appear on screen
	-- Each category has a label, color, and list of settings
	categories = {
		{
			label = "AUDIO",
			color = Color3.fromRGB(100, 180, 255),
			settings = {
				{
					id      = "music_volume",
					label   = "Music Volume",
					type    = "slider",       -- slider | toggle | dropdown | keybind
					default = 80,             -- 0-100
					min     = 0,
					max     = 100,
				},
				{
					id      = "sfx_volume",
					label   = "SFX Volume",
					type    = "slider",
					default = 100,
					min     = 0,
					max     = 100,
				},
			},
		},
		{
			label = "DISPLAY",
			color = Color3.fromRGB(255, 180, 0),
			settings = {
				{
					id      = "graphics_quality",
					label   = "Graphics Quality",
					type    = "dropdown",
					default = "Auto",
					options = { "Auto", "Low", "Medium", "High", "Ultra" },
				},
				{
					id      = "colorblind_mode",
					label   = "Colorblind Mode",
					type    = "dropdown",
					default = "Off",
					options = { "Off", "Deuteranopia", "Protanopia", "Tritanopia" },
				},
				{
					id      = "text_size",
					label   = "Text Size",
					type    = "dropdown",
					default = "Normal",
					options = { "Small", "Normal", "Large" },
				},
			},
		},
		{
			label = "CONTROLS",
			color = Color3.fromRGB(180, 80, 255),
			settings = {
				{
					id      = "keybind_attack",
					label   = "Attack",
					type    = "keybind",
					default = "E",
				},
				{
					id      = "keybind_dodge",
					label   = "Dodge",
					type    = "keybind",
					default = "Q",
				},
				{
					id      = "keybind_interact",
					label   = "Interact",
					type    = "keybind",
					default = "F",
				},
				{
					id      = "keybind_scoreboard",
					label   = "Scoreboard",
					type    = "keybind",
					default = "Tab",
				},
			},
		},
	},

	-- COLORS
	accentYellow = Color3.fromRGB(255, 220, 0),
	accentRed    = Color3.fromRGB(220, 20,  20),
	bgDark       = Color3.fromRGB(8,   8,   8),
	bgMid        = Color3.fromRGB(18,  18,  18),
	bgCard       = Color3.fromRGB(15,  15,  15),
	bgRow        = Color3.fromRGB(20,  20,  20),
	bgRowAlt     = Color3.fromRGB(14,  14,  14),
}

-- ============================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService     = game:GetService("SoundService")
local Lighting         = game:GetService("Lighting")

local player    = Players.LocalPlayer
local playerGui = player.PlayerGui

local mainMenuGui = playerGui:WaitForChild("MainMenuGui", 10)


-- ============================================================
-- EFFECTS HELPER
-- ============================================================
local _efx = nil
local function getEfx()
	if _efx then return _efx end
	local f = playerGui:WaitForChild("EffectsFolder", 10)
	if not f then return {} end
	_efx = {
		ripple    = f:WaitForChild("RippleFn",      5),
		click     = f:WaitForChild("ClickFn",       5),
		hover     = f:WaitForChild("HoverFn",       5),
		whoosh    = f:WaitForChild("WhooshFn",      5),
	}
	return _efx
end
local function playClick()  local e = getEfx(); if e.click  then e.click:Invoke()  end end
local function playHover()  local e = getEfx(); if e.hover  then e.hover:Invoke()  end end
local function playWhoosh() local e = getEfx(); if e.whoosh then e.whoosh:Invoke() end end
local function doRipple(x, y) local e = getEfx(); if e.ripple then e.ripple:Invoke(x, y) end end
local mouse = player:GetMouse()

-- Transition helper
local function getTransition()
	local tGui = playerGui:WaitForChild("TransitionGui", 10)
	if not tGui then return nil, nil end
	return tGui:WaitForChild("CoverFn", 5), tGui:WaitForChild("UncoverFn", 5)
end

-- Clean up old instance
if playerGui:FindFirstChild("SettingsGui") then
	playerGui.SettingsGui:Destroy()
end

-- ============================================================
-- CURRENT VALUES TABLE
-- Stores live values for all settings so we can read/apply them
-- ============================================================

local values = {}

-- Seed defaults
for _, cat in ipairs(CONFIG.categories) do
	for _, setting in ipairs(cat.settings) do
		values[setting.id] = setting.default
	end
end

-- ============================================================
-- UTILITY
-- ============================================================

local function tw(obj, props, dur, style, dir)
	local t = TweenService:Create(obj,
		TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
		props)
	t:Play()
	return t
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color           = color or Color3.fromRGB(0, 0, 0)
	s.Thickness       = thickness or 3
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent          = parent
	return s
end

local function addCorner(parent, px)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px or 4)
	c.Parent = parent
	return c
end

-- ============================================================
-- APPLY SETTINGS — wire real Roblox APIs here
-- Called whenever any setting changes
-- ============================================================

local function applySettings()
	-- AUDIO
	local musicVol = values["music_volume"]
	local sfxVol   = values["sfx_volume"]
	-- Apply to SoundGroups if you have them, or directly to sounds
	-- Example:
	-- SoundService.Music.Volume    = musicVol / 100
	-- SoundService.SFX.Volume      = sfxVol   / 100

	-- GRAPHICS
	local gfxMap = { Auto = 0, Low = 1, Medium = 3, High = 5, Ultra = 10 }
	local gfxLevel = gfxMap[values["graphics_quality"]] or 0
	if gfxLevel == 0 then
		settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
	else
		settings().Rendering.QualityLevel = Enum.QualityLevel["Level" .. tostring(gfxLevel)]
	end

	-- TEXT SIZE
	-- You would broadcast this to all your UI scripts via a BindableEvent
	-- so they can scale their text. For now we just store the value.

	-- COLORBLIND MODE
	-- Could apply a ColorCorrectionEffect to Lighting based on mode
	-- local mode = values["colorblind_mode"]
	-- Example stub: print("[Settings] Colorblind mode:", mode)

	-- KEYBINDS
	-- Store in a shared location (e.g. ReplicatedStorage) so other scripts read them
	-- Example: game.ReplicatedStorage.Keybinds.Attack.Value = values["keybind_attack"]
end

-- ============================================================
-- BUILD SCREENGUI
-- ============================================================

local settingsGui = Instance.new("ScreenGui")
settingsGui.Name            = "SettingsGui"
settingsGui.ResetOnSpawn    = false
settingsGui.IgnoreGuiInset  = true
settingsGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
settingsGui.Enabled         = false
settingsGui.Parent          = playerGui

-- BACKGROUND
local bg = Instance.new("Frame")
bg.Size              = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3  = CONFIG.bgDark
bg.BorderSizePixel   = 0
bg.ZIndex            = 20
bg.Parent            = settingsGui

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(20, 0, 0)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(8, 8, 8)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(8, 8, 8)),
})
bgGrad.Rotation = 135
bgGrad.Parent   = bg

-- Decorative slash
local slash = Instance.new("Frame")
slash.Size              = UDim2.new(0.05, 0, 1.6, 0)
slash.Position          = UDim2.new(0.92, 0, -0.3, 0)
slash.BackgroundColor3  = CONFIG.accentRed
slash.BackgroundTransparency = 0.75
slash.BorderSizePixel   = 0
slash.Rotation          = 12
slash.ZIndex            = 21
slash.Parent            = settingsGui

local slash2 = Instance.new("Frame")
slash2.Size             = UDim2.new(0.02, 0, 1.6, 0)
slash2.Position         = UDim2.new(0.97, 0, -0.3, 0)
slash2.BackgroundColor3 = CONFIG.accentYellow
slash2.BackgroundTransparency = 0.88
slash2.BorderSizePixel  = 0
slash2.Rotation         = 12
slash2.ZIndex           = 21
slash2.Parent           = settingsGui

-- Red horizontal rule
local topRule = Instance.new("Frame")
topRule.Size            = UDim2.new(1, 0, 0.004, 0)
topRule.Position        = UDim2.new(0, 0, 0.09, 0)
topRule.BackgroundColor3 = CONFIG.accentRed
topRule.BorderSizePixel = 0
topRule.ZIndex          = 21
topRule.Parent          = settingsGui

-- ============================================================
-- HEADER
-- ============================================================

local headerBox = Instance.new("Frame")
headerBox.Size              = UDim2.new(0.22, 0, 0.11, 0)
headerBox.Position          = UDim2.new(0.02, 0, 0.01, 0)
headerBox.BackgroundColor3  = CONFIG.bgDark
headerBox.BorderSizePixel   = 0
headerBox.Rotation          = -2
headerBox.ZIndex            = 25
headerBox.Parent            = settingsGui

addStroke(headerBox, CONFIG.accentYellow, 3)

local headerTitle = Instance.new("TextLabel")
headerTitle.Size            = UDim2.new(1, -12, 0.58, 0)
headerTitle.Position        = UDim2.new(0, 6, 0.02, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text            = CONFIG.screenTitle
headerTitle.TextColor3      = CONFIG.accentYellow
headerTitle.TextScaled      = true
headerTitle.Font            = Enum.Font.GothamBlack
headerTitle.TextXAlignment  = Enum.TextXAlignment.Left
headerTitle.ZIndex          = 26
headerTitle.Parent          = headerBox

local headerSubBar = Instance.new("Frame")
headerSubBar.Size           = UDim2.new(1, 0, 0.32, 0)
headerSubBar.Position       = UDim2.new(0, 0, 0.68, 0)
headerSubBar.BackgroundColor3 = CONFIG.accentYellow
headerSubBar.BorderSizePixel = 0
headerSubBar.ZIndex         = 26
headerSubBar.Parent         = headerBox

local headerSubLabel = Instance.new("TextLabel")
headerSubLabel.Size         = UDim2.new(1, -8, 1, 0)
headerSubLabel.Position     = UDim2.new(0, 4, 0, 0)
headerSubLabel.BackgroundTransparency = 1
headerSubLabel.Text         = CONFIG.screenSubtitle
headerSubLabel.TextColor3   = CONFIG.bgDark
headerSubLabel.TextScaled   = true
headerSubLabel.Font         = Enum.Font.GothamBlack
headerSubLabel.ZIndex       = 27
headerSubLabel.Parent       = headerSubBar

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton")
closeBtn.Size               = UDim2.new(0.055, 0, 0.065, 0)
closeBtn.Position           = UDim2.new(0.96, 0, 0.02, 0)
closeBtn.BackgroundColor3   = CONFIG.bgMid
closeBtn.Text               = "X"
closeBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled         = true
closeBtn.Font               = Enum.Font.GothamBlack
closeBtn.BorderSizePixel    = 0
closeBtn.ZIndex             = 30
closeBtn.Parent             = settingsGui

addStroke(closeBtn, CONFIG.accentYellow, 2)

closeBtn.MouseEnter:Connect(function()
	playHover()
	tw(closeBtn, { BackgroundColor3 = CONFIG.accentRed }, 0.1)
end)
closeBtn.MouseLeave:Connect(function()
	tw(closeBtn, { BackgroundColor3 = CONFIG.bgMid }, 0.1)
end)
closeBtn.MouseButton1Click:Connect(function() playClick() doRipple(mouse.X, mouse.Y) end)

-- RESET ALL BUTTON
local resetBtn = Instance.new("TextButton")
resetBtn.Size               = UDim2.new(0.12, 0, 0.05, 0)
resetBtn.Position           = UDim2.new(0.79, 0, 0.025, 0)
resetBtn.BackgroundColor3   = CONFIG.bgMid
resetBtn.Text               = "RESET ALL"
resetBtn.TextColor3         = Color3.fromRGB(180, 180, 180)
resetBtn.TextScaled         = true
resetBtn.Font               = Enum.Font.GothamBold
resetBtn.BorderSizePixel    = 0
resetBtn.ZIndex             = 28
resetBtn.Parent             = settingsGui

addStroke(resetBtn, Color3.fromRGB(60, 60, 60), 2)

resetBtn.MouseEnter:Connect(function()
	playHover()
	tw(resetBtn, { BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = CONFIG.accentYellow }, 0.1)
end)
resetBtn.MouseLeave:Connect(function()
	tw(resetBtn, { BackgroundColor3 = CONFIG.bgMid, TextColor3 = Color3.fromRGB(180, 180, 180) }, 0.1)
end)

-- ============================================================
-- MAIN CONTENT SCROLL AREA
-- ============================================================

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name                = "ContentScroll"
scrollFrame.Size                = UDim2.new(0.96, 0, 0.84, 0)
scrollFrame.Position            = UDim2.new(0.02, 0, 0.13, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel     = 0
scrollFrame.ScrollBarThickness  = 4
scrollFrame.ScrollBarImageColor3 = CONFIG.accentYellow
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.CanvasSize          = UDim2.new(0, 0, 0, 0)
scrollFrame.ZIndex              = 22
scrollFrame.Parent              = settingsGui

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.FillDirection      = Enum.FillDirection.Vertical
scrollLayout.SortOrder          = Enum.SortOrder.LayoutOrder
scrollLayout.Padding            = UDim.new(0, 10)
scrollLayout.Parent             = scrollFrame

local scrollPad = Instance.new("UIPadding")
scrollPad.PaddingTop            = UDim.new(0, 6)
scrollPad.PaddingBottom         = UDim.new(0, 16)
scrollPad.Parent                = scrollFrame

-- ============================================================
-- ROW BUILDERS
-- Each setting type gets its own builder function
-- ============================================================

-- Shared: builds the base row frame with label
local function buildRowBase(parent, setting, catColor, index)
	local rowBg = index % 2 == 0 and CONFIG.bgRow or CONFIG.bgRowAlt

	local row = Instance.new("Frame")
	row.Name             = "Row_" .. setting.id
	row.Size             = UDim2.new(1, 0, 0, 52)
	row.BackgroundColor3 = rowBg
	row.BorderSizePixel  = 0
	row.ZIndex           = 24
	row.Parent           = parent

	-- Thin left accent
	local accent = Instance.new("Frame")
	accent.Size          = UDim2.new(0.004, 0, 1, 0)
	accent.BackgroundColor3 = catColor
	accent.BorderSizePixel = 0
	accent.ZIndex        = 25
	accent.Parent        = row

	-- Setting label
	local label = Instance.new("TextLabel")
	label.Size           = UDim2.new(0.35, 0, 1, 0)
	label.Position       = UDim2.new(0.012, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text           = setting.label
	label.TextColor3     = Color3.fromRGB(210, 210, 210)
	label.TextScaled     = true
	label.Font           = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex         = 25
	label.Parent         = row

	return row
end

-- ── SLIDER ──────────────────────────────────────────────────

local function buildSlider(parent, setting, catColor, index)
	local row = buildRowBase(parent, setting, catColor, index)

	local trackBg = Instance.new("Frame")
	trackBg.Size            = UDim2.new(0.38, 0, 0.18, 0)
	trackBg.Position        = UDim2.new(0.38, 0, 0.41, 0)
	trackBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	trackBg.BorderSizePixel = 0
	trackBg.ZIndex          = 25
	trackBg.Parent          = row

	addStroke(trackBg, Color3.fromRGB(50, 50, 50), 1)

	-- Fill bar
	local pct = (values[setting.id] - setting.min) / (setting.max - setting.min)
	local fill = Instance.new("Frame")
	fill.Size               = UDim2.new(pct, 0, 1, 0)
	fill.BackgroundColor3   = catColor
	fill.BorderSizePixel    = 0
	fill.ZIndex             = 26
	fill.Parent             = trackBg

	-- Knob (small square on the fill end)
	local knob = Instance.new("Frame")
	knob.Size               = UDim2.new(0, 10, 1.6, 0)
	knob.AnchorPoint        = Vector2.new(0.5, 0.5)
	knob.Position           = UDim2.new(pct, 0, 0.5, 0)
	knob.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel    = 0
	knob.ZIndex             = 27
	knob.Parent             = trackBg

	-- Value readout
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size         = UDim2.new(0.08, 0, 0.7, 0)
	valueLabel.Position     = UDim2.new(0.77, 0, 0.15, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text         = tostring(values[setting.id])
	valueLabel.TextColor3   = CONFIG.accentYellow
	valueLabel.TextScaled   = true
	valueLabel.Font         = Enum.Font.GothamBlack
	valueLabel.ZIndex       = 25
	valueLabel.Parent       = row

	-- Invisible drag button over the track
	local dragBtn = Instance.new("TextButton")
	dragBtn.Size            = UDim2.new(1, 16, 2, 0)
	dragBtn.Position        = UDim2.new(0, -8, -0.5, 0)
	dragBtn.BackgroundTransparency = 1
	dragBtn.Text            = ""
	dragBtn.ZIndex          = 28
	dragBtn.Parent          = trackBg

	-- Drag logic
	local dragging = false

	local function updateSlider(inputX)
		local trackAbsPos  = trackBg.AbsolutePosition.X
		local trackAbsSize = trackBg.AbsoluteSize.X
		local ratio = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
		local newVal = math.floor(setting.min + ratio * (setting.max - setting.min))

		values[setting.id] = newVal
		fill.Size           = UDim2.new(ratio, 0, 1, 0)
		knob.Position       = UDim2.new(ratio, 0, 0.5, 0)
		valueLabel.Text     = tostring(newVal)
		applySettings()
	end

	dragBtn.MouseButton1Down:Connect(function(x, y)
		playClick()
		dragging = true
		updateSlider(x)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	return row
end

-- ── DROPDOWN ────────────────────────────────────────────────
-- The option list is parented to settingsGui (not the row) so it
-- never gets clipped by parent frames. We position it in screen
-- space using AbsolutePosition each time it opens.

-- One shared overlay list that gets reused for every dropdown
local sharedOptionList = Instance.new("Frame")
sharedOptionList.Name            = "SharedDropdown"
sharedOptionList.Size            = UDim2.new(0, 200, 0, 0)
sharedOptionList.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
sharedOptionList.ClipsDescendants = true
sharedOptionList.BorderSizePixel = 0
sharedOptionList.ZIndex          = 60
sharedOptionList.Visible         = false
sharedOptionList.Parent          = settingsGui

addStroke(sharedOptionList, Color3.fromRGB(70, 70, 70), 2)

local sharedOptLayout = Instance.new("UIListLayout")
sharedOptLayout.SortOrder = Enum.SortOrder.LayoutOrder
sharedOptLayout.Parent    = sharedOptionList

local activeDropBtn  = nil   -- which dropBtn is currently open
local activeArrow    = nil
local optionHeight   = 34

local function closeSharedDropdown()
	if not sharedOptionList.Visible then return end
	tw(sharedOptionList, { Size = UDim2.new(0, sharedOptionList.Size.X.Offset, 0, 0) }, 0.14)
	task.wait(0.15)
	sharedOptionList.Visible = false
	if activeArrow then
		tw(activeArrow, { TextColor3 = Color3.fromRGB(150, 150, 150) }, 0.1)
	end
	activeDropBtn = nil
	activeArrow   = nil
end

local function buildDropdown(parent, setting, catColor, index)
	local row = buildRowBase(parent, setting, catColor, index)

	local dropBtn = Instance.new("TextButton")
	dropBtn.Size            = UDim2.new(0.22, 0, 0.6, 0)
	dropBtn.Position        = UDim2.new(0.38, 0, 0.2, 0)
	dropBtn.BackgroundColor3 = CONFIG.bgMid
	dropBtn.Text            = tostring(values[setting.id])
	dropBtn.TextColor3      = CONFIG.accentYellow
	dropBtn.TextScaled      = true
	dropBtn.Font            = Enum.Font.GothamBlack
	dropBtn.BorderSizePixel = 0
	dropBtn.ZIndex          = 25
	dropBtn.Parent          = row

	addStroke(dropBtn, Color3.fromRGB(55, 55, 55), 2)

	local arrow = Instance.new("TextLabel")
	arrow.Size              = UDim2.new(0.15, 0, 1, 0)
	arrow.Position          = UDim2.new(0.85, 0, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text              = "v"
	arrow.TextColor3        = Color3.fromRGB(150, 150, 150)
	arrow.TextScaled        = true
	arrow.Font              = Enum.Font.GothamBlack
	arrow.ZIndex            = 26
	arrow.Parent            = dropBtn

	dropBtn.MouseButton1Click:Connect(function()
		-- If this dropdown is already open, close it
		if activeDropBtn == dropBtn then
			closeSharedDropdown()
			return
		end

		-- Close any currently open dropdown first
		closeSharedDropdown()
		task.wait(0.05)

		activeDropBtn = dropBtn
		activeArrow   = arrow

		-- Clear old options
		for _, c in ipairs(sharedOptionList:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end

		-- Populate with this setting's options
		local totalH = #setting.options * optionHeight
		local btnW   = dropBtn.AbsoluteSize.X

		sharedOptionList.Size = UDim2.new(0, btnW, 0, 0)

		for i, opt in ipairs(setting.options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Size         = UDim2.new(1, 0, 0, optionHeight)
			optBtn.BackgroundColor3 = opt == values[setting.id]
				and Color3.fromRGB(30, 30, 30)
				or  CONFIG.bgMid
			optBtn.Text         = opt
			optBtn.TextColor3   = opt == values[setting.id]
				and CONFIG.accentYellow
				or  Color3.fromRGB(200, 200, 200)
			optBtn.TextScaled   = true
			optBtn.Font         = Enum.Font.GothamBold
			optBtn.BorderSizePixel = 0
			optBtn.LayoutOrder  = i
			optBtn.ZIndex       = 61
			optBtn.Parent       = sharedOptionList

			optBtn.MouseEnter:Connect(function()
				tw(optBtn, { BackgroundColor3 = Color3.fromRGB(38, 38, 38) }, 0.08)
			end)
			optBtn.MouseLeave:Connect(function()
				tw(optBtn, { BackgroundColor3 = opt == values[setting.id]
					and Color3.fromRGB(30,30,30) or CONFIG.bgMid }, 0.08)
			end)

			optBtn.MouseButton1Click:Connect(function()
				values[setting.id] = opt
				dropBtn.Text       = opt

				for _, child in ipairs(sharedOptionList:GetChildren()) do
					if child:IsA("TextButton") then
						child.TextColor3     = child.Text == opt and CONFIG.accentYellow or Color3.fromRGB(200,200,200)
						child.BackgroundColor3 = child.Text == opt and Color3.fromRGB(30,30,30) or CONFIG.bgMid
					end
				end

				closeSharedDropdown()
				applySettings()
			end)
		end

		-- Position the list just below the button in screen space
		local absPos  = dropBtn.AbsolutePosition
		local absSize = dropBtn.AbsoluteSize
		-- Convert screen position to UDim2 (offset-based, ignores scaling)
		sharedOptionList.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
		sharedOptionList.Visible  = true
		tw(sharedOptionList, { Size = UDim2.new(0, btnW, 0, totalH) }, 0.18, Enum.EasingStyle.Quart)
		tw(arrow, { TextColor3 = CONFIG.accentYellow }, 0.1)
	end)

	dropBtn.MouseEnter:Connect(function()
		if activeDropBtn ~= dropBtn then
			tw(dropBtn, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }, 0.1)
		end
	end)
	dropBtn.MouseLeave:Connect(function()
		if activeDropBtn ~= dropBtn then
			tw(dropBtn, { BackgroundColor3 = CONFIG.bgMid }, 0.1)
		end
	end)

	return row
end

-- ── KEYBIND ─────────────────────────────────────────────────

local function buildKeybind(parent, setting, catColor, index)
	local row = buildRowBase(parent, setting, catColor, index)

	local isListening = false

	local keybindBtn = Instance.new("TextButton")
	keybindBtn.Size         = UDim2.new(0.18, 0, 0.6, 0)
	keybindBtn.Position     = UDim2.new(0.38, 0, 0.2, 0)
	keybindBtn.BackgroundColor3 = CONFIG.bgMid
	keybindBtn.Text         = tostring(values[setting.id])
	keybindBtn.TextColor3   = CONFIG.accentYellow
	keybindBtn.TextScaled   = true
	keybindBtn.Font         = Enum.Font.GothamBlack
	keybindBtn.BorderSizePixel = 0
	keybindBtn.ZIndex       = 25
	keybindBtn.Parent       = row

	addStroke(keybindBtn, Color3.fromRGB(55, 55, 55), 2)

	-- "press any key" hint shown when listening
	local hintLabel = Instance.new("TextLabel")
	hintLabel.Size          = UDim2.new(0.28, 0, 0.5, 0)
	hintLabel.Position      = UDim2.new(0.58, 0, 0.25, 0)
	hintLabel.BackgroundTransparency = 1
	hintLabel.Text          = ""
	hintLabel.TextColor3    = Color3.fromRGB(120, 120, 120)
	hintLabel.TextScaled    = true
	hintLabel.Font          = Enum.Font.Gotham
	hintLabel.TextXAlignment = Enum.TextXAlignment.Left
	hintLabel.ZIndex        = 25
	hintLabel.Parent        = row

	keybindBtn.MouseButton1Click:Connect(function()
		if isListening then return end
		playClick()
		doRipple(mouse.X, mouse.Y)
		isListening = true

		-- Flash yellow to signal listening state
		keybindBtn.Text      = "..."
		keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tw(keybindBtn, { BackgroundColor3 = Color3.fromRGB(40, 40, 10) }, 0.1)
		hintLabel.Text = "Press any key"

		-- Listen for the next key press
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, processed)
			-- Ignore mouse clicks and gamepad — keyboard only
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			-- Ignore modifier-only presses
			local keyName = input.KeyCode.Name
			if keyName == "Unknown" then return end

			conn:Disconnect()
			isListening = false

			values[setting.id]   = keyName
			keybindBtn.Text      = keyName
			keybindBtn.TextColor3 = CONFIG.accentYellow
			tw(keybindBtn, { BackgroundColor3 = CONFIG.bgMid }, 0.15)
			hintLabel.Text = ""
			applySettings()
		end)
	end)

	keybindBtn.MouseEnter:Connect(function()
		if not isListening then
			tw(keybindBtn, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }, 0.1)
		end
	end)
	keybindBtn.MouseLeave:Connect(function()
		if not isListening then
			tw(keybindBtn, { BackgroundColor3 = CONFIG.bgMid }, 0.1)
		end
	end)

	return row
end

-- ============================================================
-- BUILD ALL CATEGORY SECTIONS
-- ============================================================

local categoryFrames = {}  -- stored so we can animate them in

local function buildAllCategories()
	for i, cat in ipairs(CONFIG.categories) do

		-- Category header block
		local catHeader = Instance.new("Frame")
		catHeader.Name          = "CatHeader_" .. cat.label
		catHeader.Size          = UDim2.new(1, 0, 0, 42)
		catHeader.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		catHeader.BorderSizePixel = 0
		catHeader.LayoutOrder   = (i * 10)
		catHeader.ZIndex        = 23
		catHeader.Parent        = scrollFrame

		-- Bold left stripe in the category color
		local catStripe = Instance.new("Frame")
		catStripe.Size          = UDim2.new(0.006, 0, 1, 0)
		catStripe.BackgroundColor3 = cat.color
		catStripe.BorderSizePixel = 0
		catStripe.ZIndex        = 24
		catStripe.Parent        = catHeader

		-- Category label
		local catLabel = Instance.new("TextLabel")
		catLabel.Size           = UDim2.new(0.5, 0, 1, 0)
		catLabel.Position       = UDim2.new(0.014, 0, 0, 0)
		catLabel.BackgroundTransparency = 1
		catLabel.Text           = cat.label
		catLabel.TextColor3     = cat.color
		catLabel.TextScaled     = true
		catLabel.Font           = Enum.Font.GothamBlack
		catLabel.TextXAlignment = Enum.TextXAlignment.Left
		catLabel.ZIndex         = 24
		catLabel.Parent         = catHeader

		-- Thin bottom divider line
		local divider = Instance.new("Frame")
		divider.Size            = UDim2.new(1, 0, 0.04, 0)
		divider.Position        = UDim2.new(0, 0, 0.96, 0)
		divider.BackgroundColor3 = cat.color
		divider.BackgroundTransparency = 0.6
		divider.BorderSizePixel = 0
		divider.ZIndex          = 24
		divider.Parent          = catHeader

		-- Settings rows for this category
		for j, setting in ipairs(cat.settings) do
			local row
			if setting.type == "slider" then
				row = buildSlider(scrollFrame, setting, cat.color, j)
			elseif setting.type == "dropdown" then
				row = buildDropdown(scrollFrame, setting, cat.color, j)
			elseif setting.type == "keybind" then
				row = buildKeybind(scrollFrame, setting, cat.color, j)
			end

			if row then
				row.LayoutOrder = (i * 10) + j
			end
		end

		table.insert(categoryFrames, catHeader)
	end
end

buildAllCategories()

-- ============================================================
-- RESET ALL LOGIC
-- ============================================================

resetBtn.MouseButton1Click:Connect(function()
	playClick()
	doRipple(mouse.X, mouse.Y)
	-- Flash the button red to confirm
	tw(resetBtn, { BackgroundColor3 = CONFIG.accentRed, TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.1)
	task.wait(0.3)
	tw(resetBtn, { BackgroundColor3 = CONFIG.bgMid, TextColor3 = Color3.fromRGB(180, 180, 180) }, 0.2)

	-- Reset all values to defaults
	for _, cat in ipairs(CONFIG.categories) do
		for _, setting in ipairs(cat.settings) do
			values[setting.id] = setting.default
		end
	end

	-- Rebuild all rows to reflect the reset values
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	buildAllCategories()
	applySettings()
end)

-- ============================================================
-- OPEN / CLOSE
-- ============================================================

local isOpen = false

local function closeSettings()
	if not isOpen then return end
	isOpen = false

	local coverFn, uncoverFn = getTransition()
	if coverFn then coverFn:Invoke() end

	-- Force close any open dropdown before hiding
	closeSharedDropdown()

	settingsGui.Enabled          = false
	headerBox.Position           = UDim2.new(0.02, 0, -0.2, 0)
	closeBtn.Position            = UDim2.new(0.93, 0, -0.2, 0)
	resetBtn.Position            = UDim2.new(0.79, 0, -0.2, 0)
	scrollFrame.Position         = UDim2.new(0.02, 0, 1.2,  0)
	scrollFrame.CanvasPosition   = Vector2.new(0, 0)

	if mainMenuGui then mainMenuGui.Enabled = true end
	if uncoverFn then uncoverFn:Invoke(0.35) end
end

local function openSettings()
	if isOpen then return end
	isOpen = true

	local coverFn, uncoverFn = getTransition()
	if coverFn then coverFn:Invoke() end

	if mainMenuGui then mainMenuGui.Enabled = false end

	settingsGui.Enabled          = true
	headerBox.Position           = UDim2.new(0.02, 0, -0.2, 0)
	closeBtn.Position            = UDim2.new(0.93, 0, -0.2, 0)
	resetBtn.Position            = UDim2.new(0.79, 0, -0.2, 0)
	scrollFrame.Position         = UDim2.new(0.02, 0, 1.2,  0)
	scrollFrame.CanvasPosition   = Vector2.new(0, 0)

	if uncoverFn then uncoverFn:Invoke(0.35) end
	task.wait(0.1)

	-- Staggered entrance
	tw(headerBox,    { Position = UDim2.new(0.02, 0, 0.01, 0) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	tw(closeBtn,     { Position = UDim2.new(0.93, 0, 0.01, 0) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	tw(resetBtn,     { Position = UDim2.new(0.79, 0, 0.025, 0) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	task.wait(0.15)
	tw(scrollFrame,  { Position = UDim2.new(0.02, 0, 0.13, 0) }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

closeBtn.MouseButton1Click:Connect(closeSettings)

-- ============================================================
-- HOOK INTO MAIN MENU SETTINGS BUTTON
-- ============================================================

task.spawn(function()
	if not mainMenuGui then return end

	local function findBtn(parent, slabName)
		for _, child in ipairs(parent:GetChildren()) do
			if child.Name == slabName then
				local btn = child:FindFirstChild("Button")
				if btn then return btn end
			end
			local found = findBtn(child, slabName)
			if found then return found end
		end
	end

	local settingsBtn = findBtn(mainMenuGui, "Slab_SETTINGS")
	if settingsBtn then
		settingsBtn.MouseButton1Click:Connect(openSettings)
		print("[SettingsGui] Hooked into SETTINGS button.")
	else
		print("[SettingsGui] Could not find SETTINGS button. Call openSettings() manually.")
	end
end)

-- Expose open function so MainMenu can call it directly
local openSettingsFn = Instance.new("BindableFunction")
openSettingsFn.Name     = "OpenSettingsFn"
openSettingsFn.OnInvoke = openSettings
openSettingsFn.Parent   = settingsGui

print("[SettingsGui] settings screen loaded.")