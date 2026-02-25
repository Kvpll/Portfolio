-- ============================================================
-- LOADING SCREEN TRANSITION
-- Place this LocalScript inside StarterGui, name it "TransitionScript"
--
-- This script does two things:
--   1. Shows a full loading screen when the game first loads
--   2. Provides a shared transition layer any UI can use when
--      switching between full-screen menus so the player never
--      sees the baseplate or world during the swap
--
-- HOW TO USE FROM OTHER SCRIPTS:
--   local Transition = require(player.PlayerGui:WaitForChild("TransitionGui"):WaitForChild("TransitionModule"))
--   Transition.Cover()          -- instantly covers the screen
--   Transition.Uncover(0.4)     -- fades out over 0.4 seconds
--   Transition.Flash(callback)  -- covers, runs callback, then uncovers
-- ============================================================

-- ============================================================
--   ★ CUSTOMIZATION CONFIG ★
-- ============================================================

local CONFIG = {
	-- INITIAL LOAD SCREEN
	gameName        = "Kvpll menu test",
	loadingMessages = {
		"Initializing systems...",
		"Loading assets...",
		"Preparing UI...",
		"Almost ready...",
	},

	-- TRANSITION
	coverDuration   = 0.18,   -- how fast the cover slams in (seconds)
	uncoverDuration = 0.35,   -- how fast it fades out

	-- COLORS
	bgColor         = Color3.fromRGB(8, 8, 8),
	accentYellow    = Color3.fromRGB(255, 220, 0),
	accentRed       = Color3.fromRGB(220, 20, 20),
	barColor        = Color3.fromRGB(255, 220, 0),
}

-- ============================================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player.PlayerGui

-- Clean up old instance
if playerGui:FindFirstChild("TransitionGui") then
	playerGui.TransitionGui:Destroy()
end

local function tw(obj, props, dur, style, dir)
	local t = TweenService:Create(obj,
		TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
		props)
	t:Play()
	return t
end

-- ============================================================
-- BUILD THE TRANSITION GUI
-- This always sits on top of everything (DisplayOrder 999)
-- ============================================================

local transGui = Instance.new("ScreenGui")
transGui.Name           = "TransitionGui"
transGui.ResetOnSpawn   = false
transGui.IgnoreGuiInset = true
transGui.DisplayOrder   = 999          -- renders above ALL other GUIs
transGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
transGui.Parent         = playerGui

-- ============================================================
-- COVER FRAME (the full black screen that hides everything)
-- ============================================================

local cover = Instance.new("Frame")
cover.Name              = "Cover"
cover.Size              = UDim2.new(1, 0, 1, 0)
cover.BackgroundColor3  = CONFIG.bgColor
cover.BorderSizePixel   = 0
cover.ZIndex            = 10
cover.BackgroundTransparency = 0   -- starts fully visible (covers on load)
cover.Parent            = transGui

-- Diagonal slash decoration
local slash = Instance.new("Frame")
slash.Size              = UDim2.new(0.06, 0, 1.6, 0)
slash.Position          = UDim2.new(0.88, 0, -0.3, 0)
slash.BackgroundColor3  = CONFIG.accentRed
slash.BackgroundTransparency = 0.7
slash.BorderSizePixel   = 0
slash.Rotation          = 12
slash.ZIndex            = 11
slash.Parent            = cover

local slash2 = Instance.new("Frame")
slash2.Size             = UDim2.new(0.025, 0, 1.6, 0)
slash2.Position         = UDim2.new(0.94, 0, -0.3, 0)
slash2.BackgroundColor3 = CONFIG.accentYellow
slash2.BackgroundTransparency = 0.85
slash2.BorderSizePixel  = 0
slash2.Rotation         = 12
slash2.ZIndex           = 11
slash2.Parent           = cover

-- ============================================================
-- LOADING SCREEN CONTENT (shown only on first load)
-- Hidden during mid-session transitions
-- ============================================================

local loadContent = Instance.new("Frame")
loadContent.Name            = "LoadContent"
loadContent.Size            = UDim2.new(1, 0, 1, 0)
loadContent.BackgroundTransparency = 1
loadContent.BorderSizePixel = 0
loadContent.ZIndex          = 12
loadContent.Parent          = cover

-- Game title box
local titleBox = Instance.new("Frame")
titleBox.Size               = UDim2.new(0.4, 0, 0.18, 0)
titleBox.Position           = UDim2.new(0.05, 0, 0.35, 0)
titleBox.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
titleBox.BorderSizePixel    = 0
titleBox.Rotation           = -2
titleBox.ZIndex             = 13
titleBox.Parent             = loadContent

local titleStroke = Instance.new("UIStroke")
titleStroke.Color           = CONFIG.accentYellow
titleStroke.Thickness       = 4
titleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
titleStroke.Parent          = titleBox

local titleLabel = Instance.new("TextLabel")
titleLabel.Size             = UDim2.new(1, -16, 0.62, 0)
titleLabel.Position         = UDim2.new(0, 8, 0.02, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text             = CONFIG.gameName
titleLabel.TextColor3       = CONFIG.accentYellow
titleLabel.TextScaled       = true
titleLabel.Font             = Enum.Font.GothamBlack
titleLabel.TextXAlignment   = Enum.TextXAlignment.Left
titleLabel.ZIndex           = 14
titleLabel.Parent           = titleBox

local subBar = Instance.new("Frame")
subBar.Size                 = UDim2.new(1, 0, 0.3, 0)
subBar.Position             = UDim2.new(0, 0, 0.7, 0)
subBar.BackgroundColor3     = CONFIG.accentYellow
subBar.BorderSizePixel      = 0
subBar.ZIndex               = 14
subBar.Parent               = titleBox

local subLabel = Instance.new("TextLabel")
subLabel.Size               = UDim2.new(1, -8, 1, 0)
subLabel.Position           = UDim2.new(0, 4, 0, 0)
subLabel.BackgroundTransparency = 1
subLabel.Text               = "LOADING"
subLabel.TextColor3         = Color3.fromRGB(0, 0, 0)
subLabel.TextScaled         = true
subLabel.Font               = Enum.Font.GothamBlack
subLabel.ZIndex             = 15
subLabel.Parent             = subBar

-- Loading message (cycles through CONFIG.loadingMessages)
local messageLabel = Instance.new("TextLabel")
messageLabel.Size           = UDim2.new(0.5, 0, 0.06, 0)
messageLabel.Position       = UDim2.new(0.05, 0, 0.58, 0)
messageLabel.BackgroundTransparency = 1
messageLabel.Text           = CONFIG.loadingMessages[1]
messageLabel.TextColor3     = Color3.fromRGB(140, 140, 140)
messageLabel.TextScaled     = true
messageLabel.Font           = Enum.Font.Gotham
messageLabel.TextXAlignment = Enum.TextXAlignment.Left
messageLabel.ZIndex         = 13
messageLabel.Parent         = loadContent

-- Progress bar background
local progressBg = Instance.new("Frame")
progressBg.Size             = UDim2.new(0.5, 0, 0.012, 0)
progressBg.Position         = UDim2.new(0.05, 0, 0.66, 0)
progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
progressBg.BorderSizePixel  = 0
progressBg.ZIndex           = 13
progressBg.Parent           = loadContent

local progressStroke = Instance.new("UIStroke")
progressStroke.Color        = Color3.fromRGB(50, 50, 50)
progressStroke.Thickness    = 1
progressStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
progressStroke.Parent       = progressBg

-- Progress bar fill
local progressFill = Instance.new("Frame")
progressFill.Size           = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = CONFIG.barColor
progressFill.BorderSizePixel = 0
progressFill.ZIndex         = 14
progressFill.Parent         = progressBg

-- Percentage label
local percentLabel = Instance.new("TextLabel")
percentLabel.Size           = UDim2.new(0.1, 0, 0.05, 0)
percentLabel.Position       = UDim2.new(0.56, 0, 0.655, 0)
percentLabel.BackgroundTransparency = 1
percentLabel.Text           = "0%"
percentLabel.TextColor3     = CONFIG.accentYellow
percentLabel.TextScaled     = true
percentLabel.Font           = Enum.Font.GothamBlack
percentLabel.TextXAlignment = Enum.TextXAlignment.Left
percentLabel.ZIndex         = 13
percentLabel.Parent         = loadContent

-- "Press any key" hint (appears at end of loading)
local pressLabel = Instance.new("TextLabel")
pressLabel.Size             = UDim2.new(0.5, 0, 0.05, 0)
pressLabel.Position         = UDim2.new(0.05, 0, 0.74, 0)
pressLabel.BackgroundTransparency = 1
pressLabel.Text             = ""
pressLabel.TextColor3       = Color3.fromRGB(100, 100, 100)
pressLabel.TextScaled       = true
pressLabel.Font             = Enum.Font.Gotham
pressLabel.TextXAlignment   = Enum.TextXAlignment.Left
pressLabel.ZIndex           = 13
pressLabel.Parent           = loadContent

-- Version / small bottom label
local versionLabel = Instance.new("TextLabel")
versionLabel.Size           = UDim2.new(0.3, 0, 0.04, 0)
versionLabel.Position       = UDim2.new(0.05, 0, 0.94, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Text           = "v0.1  |  UI Showcase"
versionLabel.TextColor3     = Color3.fromRGB(55, 55, 55)
versionLabel.TextScaled     = true
versionLabel.Font           = Enum.Font.Gotham
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.ZIndex         = 13
versionLabel.Parent         = loadContent

-- ============================================================
-- TRANSITION MODULE (returned via ModuleScript pattern)
-- Other scripts access these functions through a BindableFunction
-- ============================================================

-- BindableFunctions let other LocalScripts call Cover/Uncover/Flash
-- without needing a direct require (since all scripts run in the same VM)
local coverEvent   = Instance.new("BindableFunction")
coverEvent.Name    = "CoverFn"
coverEvent.Parent  = transGui

local uncoverEvent = Instance.new("BindableFunction")
uncoverEvent.Name  = "UncoverFn"
uncoverEvent.Parent = transGui

local flashEvent   = Instance.new("BindableFunction")
flashEvent.Name    = "FlashFn"
flashEvent.Parent  = transGui

-- COVER: instantly slam the cover on
local function doWhoosh()
	local f = playerGui:FindFirstChild("EffectsFolder")
	if f then
		local fn = f:FindFirstChild("WhooshFn")
		if fn then fn:Invoke() end
	end
end
coverEvent.OnInvoke = function()
	doWhoosh()
	loadContent.Visible          = false
	cover.BackgroundTransparency = 0
	cover.Visible                = true
end

-- UNCOVER: fade the cover out over `duration` seconds
uncoverEvent.OnInvoke = function(duration)
	loadContent.Visible = false
	cover.Visible       = true
	tw(cover, { BackgroundTransparency = 1 }, duration or CONFIG.uncoverDuration)
	task.wait(duration or CONFIG.uncoverDuration)
	cover.Visible                = false
	cover.BackgroundTransparency = 0
end

-- FLASH: covers screen, calls the callback, then uncovers
-- Use this when switching between full-screen UIs
-- Example: Transition.Flash(function() openStats() end)
flashEvent.OnInvoke = function(waitTime)
	-- Slam cover on
	loadContent.Visible          = false
	cover.BackgroundTransparency = 0
	cover.Visible                = true
	-- Wait for caller to swap UIs
	task.wait(waitTime or 0.05)
	-- Fade cover out
	tw(cover, { BackgroundTransparency = 1 }, CONFIG.uncoverDuration)
	task.wait(CONFIG.uncoverDuration)
	cover.Visible                = false
	cover.BackgroundTransparency = 0
end

-- ============================================================
-- INITIAL LOAD SEQUENCE
-- Runs once when the player first joins
-- Simulates loading progress then fades out to the main menu
-- ============================================================

local function runLoadSequence()
	loadContent.Visible          = true
	cover.BackgroundTransparency = 0
	cover.Visible                = true

	-- Animate title box sliding in from left
	titleBox.Position = UDim2.new(-0.5, 0, 0.35, 0)
	task.wait(0.1)
	tw(titleBox, { Position = UDim2.new(0.05, 0, 0.35, 0) }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	task.wait(0.3)

	-- Step through loading messages with progress bar
	local steps = #CONFIG.loadingMessages
	for i, msg in ipairs(CONFIG.loadingMessages) do
		messageLabel.Text = msg

		local targetPct = i / steps
		tw(progressFill, { Size = UDim2.new(targetPct, 0, 1, 0) }, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		-- Animate percentage counting up
		local startPct = math.floor(((i - 1) / steps) * 100)
		local endPct   = math.floor(targetPct * 100)
		task.spawn(function()
			for p = startPct, endPct do
				percentLabel.Text = tostring(p) .. "%"
				task.wait(0.35 / math.max(endPct - startPct, 1))
			end
		end)

		task.wait(0.5)
	end

	-- Make sure bar is full and counter shows 100%
	tw(progressFill, { Size = UDim2.new(1, 0, 1, 0) }, 0.2)
	percentLabel.Text = "100%"
	task.wait(0.3)

	-- Show press-to-continue hint with a slow blink
	pressLabel.Text = "Click anywhere to continue"
	task.spawn(function()
		while pressLabel.Parent do
			tw(pressLabel, { TextTransparency = 0.8 }, 0.6, Enum.EasingStyle.Sine)
			task.wait(0.65)
			tw(pressLabel, { TextTransparency = 0 }, 0.6, Enum.EasingStyle.Sine)
			task.wait(0.65)
		end
	end)

	-- Wait for a click or touch anywhere
	local UserInputService = game:GetService("UserInputService")
	local inputEvent
	local clicked = false
	inputEvent = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			if not clicked then
				clicked = true
				inputEvent:Disconnect()
			end
		end
	end)

	-- Wait until clicked, checking each frame
	while not clicked do task.wait(0.05) end

	-- Slam title box out to the right
	tw(titleBox, { Position = UDim2.new(1.1, 0, 0.35, 0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	task.wait(0.1)

	-- Fade the whole cover out
	tw(cover, { BackgroundTransparency = 1 }, CONFIG.uncoverDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	task.wait(CONFIG.uncoverDuration)

	cover.Visible                = false
	cover.BackgroundTransparency = 0
	loadContent.Visible          = false

	-- Reset title box position for future use
	titleBox.Position = UDim2.new(0.05, 0, 0.35, 0)
end

-- Run the load sequence on startup
runLoadSequence()

print("[TransitionGui] Loading screen complete.")