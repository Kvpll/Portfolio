-- ============================================================
-- LEVELING SYSTEM UI
-- Place this LocalScript inside StarterGui
-- Displays player level, experience, and progression
-- ============================================================

-- ============================================================
--   ★ CUSTOMIZATION CONFIG ★
-- ============================================================

local CONFIG = {
	-- UI TITLE
	screenTitle    = "LEVELING",
	screenSubtitle = "PROGRESSION",

	-- PLAYER STATS
	currentLevel   = 15,
	maxLevel       = 100,
	currentXP      = 4500,
	xpNeeded       = 10000,

	-- COLORS (matched to main menu)
	accentYellow = Color3.fromRGB(255, 220, 0),
	accentRed    = Color3.fromRGB(220, 20,  20),
	accentGreen  = Color3.fromRGB(80, 220, 80),
	bgDark       = Color3.fromRGB(8,   8,   8),
	bgMid        = Color3.fromRGB(15,  15,  15),
	bgCard       = Color3.fromRGB(12,  12,  12),
}

-- ============================================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player.PlayerGui

-- ============================================================
-- EFFECTS HELPER
-- ============================================================

local _efx = nil
local function getEfx()
	if _efx then return _efx end
	local f = playerGui:FindFirstChild("EffectsFolder")
	if not f then return {} end
	_efx = {
		click  = f:FindFirstChild("ClickFn"),
		hover  = f:FindFirstChild("HoverFn"),
		whoosh = f:FindFirstChild("WhooshFn"),
	}
	return _efx
end

local function playClick()  local e = getEfx(); if e.click  then e.click:Invoke()  end end
local function playHover()  local e = getEfx(); if e.hover  then e.hover:Invoke()  end end
local function playWhoosh() local e = getEfx(); if e.whoosh then e.whoosh:Invoke() end end

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

local function tween(obj, props, duration, style, direction)
	local info = TweenInfo.new(
		duration or 0.3,
		style or Enum.EasingStyle.Quart,
		direction or Enum.EasingDirection.Out
	)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 0)
	corner.Parent = parent
	return corner
end

local function addStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(0, 0, 0)
	stroke.Thickness = thickness or 3
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

-- ============================================================
-- CLEANUP & CREATE SCREEN GUI
-- ============================================================

if playerGui:FindFirstChild("LevelingGui") then
	playerGui.LevelingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LevelingGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ============================================================
-- BACKGROUND
-- ============================================================

local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(180, 10, 10)
background.BorderSizePixel = 0
background.ZIndex = 1
background.Parent = screenGui

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 20, 20)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0)),
})
bgGradient.Rotation = 135
bgGradient.Parent = background

-- Vignette
local vignette = Instance.new("Frame")
vignette.Size = UDim2.new(0.5, 0, 1, 0)
vignette.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
vignette.BackgroundTransparency = 0.3
vignette.BorderSizePixel = 0
vignette.ZIndex = 2
vignette.Parent = screenGui

-- ============================================================
-- TITLE
-- ============================================================

local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(0.38, 0, 0.15, 0)
titleContainer.Position = UDim2.new(0.595, 0, 0.03, 0)
titleContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleContainer.BorderSizePixel = 0
titleContainer.Rotation = -3
titleContainer.ZIndex = 10
titleContainer.Parent = screenGui

addStroke(titleContainer, CONFIG.accentYellow, 4)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0.62, 0)
titleLabel.Position = UDim2.new(0, 10, 0.04, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = CONFIG.screenTitle
titleLabel.TextColor3 = CONFIG.accentYellow
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 11
titleLabel.Parent = titleContainer

local titleSub = Instance.new("Frame")
titleSub.Size = UDim2.new(1, 0, 0.3, 0)
titleSub.Position = UDim2.new(0, 0, 0.7, 0)
titleSub.BackgroundColor3 = CONFIG.accentYellow
titleSub.BorderSizePixel = 0
titleSub.ZIndex = 12
titleSub.Parent = titleContainer

local titleSubLabel = Instance.new("TextLabel")
titleSubLabel.Size = UDim2.new(1, -16, 1, 0)
titleSubLabel.Position = UDim2.new(0, 8, 0, 0)
titleSubLabel.BackgroundTransparency = 1
titleSubLabel.Text = CONFIG.screenSubtitle
titleSubLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
titleSubLabel.TextScaled = true
titleSubLabel.Font = Enum.Font.GothamBlack
titleSubLabel.TextXAlignment = Enum.TextXAlignment.Center
titleSubLabel.ZIndex = 13
titleSubLabel.Parent = titleSub

-- ============================================================
-- LEVEL DISPLAY CARD
-- ============================================================

local levelCard = Instance.new("Frame")
levelCard.Size = UDim2.new(0.35, 0, 0.25, 0)
levelCard.Position = UDim2.new(0.595, 0, 0.2, 0)
levelCard.BackgroundColor3 = CONFIG.bgCard
levelCard.BorderSizePixel = 0
levelCard.ZIndex = 10
levelCard.Parent = screenGui

addStroke(levelCard, CONFIG.accentYellow, 3)
addCorner(levelCard, 8)

-- Level label
local levelLabel = Instance.new("TextLabel")
levelLabel.Size = UDim2.new(0.5, 0, 0.3, 0)
levelLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "LEVEL"
levelLabel.TextColor3 = CONFIG.accentYellow
levelLabel.TextScaled = true
levelLabel.Font = Enum.Font.GothamBlack
levelLabel.ZIndex = 11
levelLabel.Parent = levelCard

-- Level number
local levelNumber = Instance.new("TextLabel")
levelNumber.Name = "LevelNumber"
levelNumber.Size = UDim2.new(0.45, 0, 0.3, 0)
levelNumber.Position = UDim2.new(0.5, 0, 0.05, 0)
levelNumber.BackgroundTransparency = 1
levelNumber.Text = CONFIG.currentLevel
levelNumber.TextColor3 = CONFIG.accentRed
levelNumber.TextScaled = true
levelNumber.Font = Enum.Font.GothamBlack
levelNumber.TextXAlignment = Enum.TextXAlignment.Right
levelNumber.ZIndex = 11
levelNumber.Parent = levelCard

-- Progress bar background
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(0.9, 0, 0.25, 0)
progressBg.Position = UDim2.new(0.05, 0, 0.6, 0)
progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
progressBg.BorderSizePixel = 0
progressBg.ZIndex = 11
progressBg.Parent = levelCard

addCorner(progressBg, 3)

-- Progress bar fill
local progressFill = Instance.new("Frame")
progressFill.Name = "ProgressFill"
progressFill.Size = UDim2.new(CONFIG.currentXP / CONFIG.xpNeeded, 0, 1, 0)
progressFill.BackgroundColor3 = CONFIG.accentGreen
progressFill.BorderSizePixel = 0
progressFill.ZIndex = 12
progressFill.Parent = progressBg

addCorner(progressFill, 3)

-- ============================================================
-- EXPERIENCE STATS CARD
-- ============================================================

local xpCard = Instance.new("Frame")
xpCard.Size = UDim2.new(0.35, 0, 0.45, 0)
xpCard.Position = UDim2.new(0.595, 0, 0.48, 0)
xpCard.BackgroundColor3 = CONFIG.bgCard
xpCard.BorderSizePixel = 0
xpCard.ZIndex = 10
xpCard.Parent = screenGui

addStroke(xpCard, CONFIG.accentGreen, 3)
addCorner(xpCard, 8)

-- Current XP label
local xpLabel = Instance.new("TextLabel")
xpLabel.Size = UDim2.new(0.9, 0, 0.15, 0)
xpLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
xpLabel.BackgroundTransparency = 1
xpLabel.Text = "EXPERIENCE"
xpLabel.TextColor3 = CONFIG.accentYellow
xpLabel.TextScaled = true
xpLabel.Font = Enum.Font.GothamBlack
xpLabel.ZIndex = 11
xpLabel.Parent = xpCard

-- XP amount
local xpAmount = Instance.new("TextLabel")
xpAmount.Name = "XPAmount"
xpAmount.Size = UDim2.new(0.9, 0, 0.2, 0)
xpAmount.Position = UDim2.new(0.05, 0, 0.22, 0)
xpAmount.BackgroundTransparency = 1
xpAmount.Text = CONFIG.currentXP .. " / " .. CONFIG.xpNeeded
xpAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
xpAmount.TextScaled = true
xpAmount.Font = Enum.Font.GothamBold
xpAmount.ZIndex = 11
xpAmount.Parent = xpCard

-- XP bar
local xpBarBg = Instance.new("Frame")
xpBarBg.Size = UDim2.new(0.9, 0, 0.15, 0)
xpBarBg.Position = UDim2.new(0.05, 0, 0.48, 0)
xpBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
xpBarBg.BorderSizePixel = 0
xpBarBg.ZIndex = 11
xpBarBg.Parent = xpCard

addCorner(xpBarBg, 3)

local xpBarFill = Instance.new("Frame")
xpBarFill.Name = "XPBarFill"
xpBarFill.Size = UDim2.new(CONFIG.currentXP / CONFIG.xpNeeded, 0, 1, 0)
xpBarFill.BackgroundColor3 = CONFIG.accentGreen
xpBarFill.BorderSizePixel = 0
xpBarFill.ZIndex = 12
xpBarFill.Parent = xpBarBg

addCorner(xpBarFill, 3)

-- Stats labels
local stats = {
	{ label = "Total XP Earned", value = "125,400" },
	{ label = "Next Level XP", value = tostring(CONFIG.xpNeeded - CONFIG.currentXP) },
	{ label = "Playtime", value = "42h 18m" },
}

for i, stat in ipairs(stats) do
	local statLabel = Instance.new("TextLabel")
	statLabel.Size = UDim2.new(0.45, 0, 0.1, 0)
	statLabel.Position = UDim2.new(0.05, 0, 0.68 + (i - 1) * 0.1, 0)
	statLabel.BackgroundTransparency = 1
	statLabel.Text = stat.label
	statLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	statLabel.TextScaled = true
	statLabel.Font = Enum.Font.Gotham
	statLabel.TextXAlignment = Enum.TextXAlignment.Left
	statLabel.ZIndex = 11
	statLabel.Parent = xpCard

	local statValue = Instance.new("TextLabel")
	statValue.Size = UDim2.new(0.45, 0, 0.1, 0)
	statValue.Position = UDim2.new(0.5, 0, 0.68 + (i - 1) * 0.1, 0)
	statValue.BackgroundTransparency = 1
	statValue.Text = stat.value
	statValue.TextColor3 = CONFIG.accentYellow
	statValue.TextScaled = true
	statValue.Font = Enum.Font.GothamBold
	statValue.TextXAlignment = Enum.TextXAlignment.Right
	statValue.ZIndex = 11
	statValue.Parent = xpCard
end

-- ============================================================
-- BACK BUTTON
-- ============================================================

local backBtn = Instance.new("TextButton")
backBtn.Name = "BackButton"
backBtn.Size = UDim2.new(0.12, 0, 0.06, 0)
backBtn.Position = UDim2.new(0.02, 0, 0.02, 0)
backBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
backBtn.Text = "< BACK"
backBtn.TextColor3 = CONFIG.accentYellow
backBtn.TextScaled = true
backBtn.Font = Enum.Font.GothamBlack
backBtn.BorderSizePixel = 0
backBtn.ZIndex = 10
backBtn.Parent = screenGui

addStroke(backBtn, CONFIG.accentYellow, 2)
addCorner(backBtn, 4)

backBtn.MouseEnter:Connect(function()
	playHover()
	tween(backBtn, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }, 0.1)
end)

backBtn.MouseLeave:Connect(function()
	tween(backBtn, { BackgroundColor3 = Color3.fromRGB(15, 15, 15) }, 0.1)
end)

backBtn.MouseButton1Click:Connect(function()
	playClick()
	playWhoosh()
	screenGui.Enabled = false
	local mainMenu = playerGui:FindFirstChild("MainMenuGui")
	if mainMenu then mainMenu.Enabled = true end
end)

-- ============================================================
-- ENTRANCE ANIMATION
-- ============================================================

titleContainer.Position = UDim2.new(0.595, 0, -0.2, 0)
titleContainer.BackgroundTransparency = 1

levelCard.Position = UDim2.new(0.595, 0, 1.5, 0)
levelCard.BackgroundTransparency = 1

xpCard.Position = UDim2.new(0.595, 0, 1.5, 0)
xpCard.BackgroundTransparency = 1

backBtn.Position = UDim2.new(-0.15, 0, 0.02, 0)
backBtn.BackgroundTransparency = 1

task.wait(0.1)

tween(titleContainer, { Position = UDim2.new(0.595, 0, 0.03, 0), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
tween(levelCard, { Position = UDim2.new(0.595, 0, 0.2, 0), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
task.wait(0.1)
tween(xpCard, { Position = UDim2.new(0.595, 0, 0.48, 0), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
tween(backBtn, { Position = UDim2.new(0.02, 0, 0.02, 0), BackgroundTransparency = 0 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

print("[LevelingUI] Loaded successfully.")
