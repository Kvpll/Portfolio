-- ============================================================
-- HEALTH SYSTEM UI
-- Place this LocalScript inside StarterGui
-- Displays player health with matching main menu aesthetic
-- ============================================================

-- ============================================================
--   ★ CUSTOMIZATION CONFIG ★
-- ============================================================

local CONFIG = {
	-- UI TITLE
	screenTitle    = "HEALTH",
	screenSubtitle = "VITAL STATS",

	-- HEALTH CONFIG
	maxHealth      = 100,
	currentHealth  = 100,

	-- COLORS (matched to main menu)
	accentYellow = Color3.fromRGB(255, 220, 0),
	accentRed    = Color3.fromRGB(220, 20,  20),
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

if playerGui:FindFirstChild("HealthGui") then
	playerGui.HealthGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HealthGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ============================================================
-- BACKGROUND
-- ============================================================

local background = Instance.new("Frame")
background.Name = "Background"
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

-- Dark vignette
local vignette = Instance.new("Frame")
vignette.Size = UDim2.new(0.5, 0, 1, 0)
vignette.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
vignette.BackgroundTransparency = 0.3
vignette.BorderSizePixel = 0
vignette.ZIndex = 2
vignette.Parent = screenGui

local vigGradient = Instance.new("UIGradient")
vigGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})
vigGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(1, 1),
})
vigGradient.Parent = vignette

-- ============================================================
-- TITLE
-- ============================================================

local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(0.38, 0, 0.22, 0)
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
-- HEALTH DISPLAY CARD
-- ============================================================

local healthCard = Instance.new("Frame")
healthCard.Name = "HealthCard"
healthCard.Size = UDim2.new(0.35, 0, 0.4, 0)
healthCard.Position = UDim2.new(0.595, 0, 0.28, 0)
healthCard.BackgroundColor3 = CONFIG.bgCard
healthCard.BorderSizePixel = 0
healthCard.ZIndex = 10
healthCard.Parent = screenGui

addStroke(healthCard, CONFIG.accentRed, 3)
addCorner(healthCard, 8)

-- Health label
local healthLabel = Instance.new("TextLabel")
healthLabel.Size = UDim2.new(0.9, 0, 0.2, 0)
healthLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
healthLabel.BackgroundTransparency = 1
healthLabel.Text = "HEALTH"
healthLabel.TextColor3 = CONFIG.accentYellow
healthLabel.TextScaled = true
healthLabel.Font = Enum.Font.GothamBlack
healthLabel.ZIndex = 11
healthLabel.Parent = healthCard

-- Health number display
local healthValue = Instance.new("TextLabel")
healthValue.Name = "HealthValue"
healthValue.Size = UDim2.new(0.9, 0, 0.25, 0)
healthValue.Position = UDim2.new(0.05, 0, 0.25, 0)
healthValue.BackgroundTransparency = 1
healthValue.Text = CONFIG.currentHealth .. " / " .. CONFIG.maxHealth
healthValue.TextColor3 = Color3.fromRGB(255, 255, 255)
healthValue.TextScaled = true
healthValue.Font = Enum.Font.GothamBold
healthValue.ZIndex = 11
healthValue.Parent = healthCard

-- Health bar background
local healthBarBg = Instance.new("Frame")
healthBarBg.Size = UDim2.new(0.9, 0, 0.15, 0)
healthBarBg.Position = UDim2.new(0.05, 0, 0.55, 0)
healthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
healthBarBg.BorderSizePixel = 0
healthBarBg.ZIndex = 11
healthBarBg.Parent = healthCard

addStroke(healthBarBg, Color3.fromRGB(60, 60, 60), 1)
addCorner(healthBarBg, 4)

-- Health bar fill
local healthBarFill = Instance.new("Frame")
healthBarFill.Name = "HealthBarFill"
healthBarFill.Size = UDim2.new(1, 0, 1, 0)
healthBarFill.Position = UDim2.new(0, 0, 0, 0)
healthBarFill.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
healthBarFill.BorderSizePixel = 0
healthBarFill.ZIndex = 12
healthBarFill.Parent = healthBarBg

addCorner(healthBarFill, 4)

-- Status text
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0.15, 0)
statusLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Healthy"
statusLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.ZIndex = 11
statusLabel.Parent = healthCard

-- ============================================================
-- BACK BUTTON
-- ============================================================

local backBtn = Instance.new("TextButton")
backBtn.Name = "BackButton"
backBtn.Size = UDim2.new(0.12, 0, 0.08, 0)
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

-- Back button hover effects
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
-- UPDATE HEALTH DISPLAY
-- ============================================================

local function updateHealthDisplay(currentHp, maxHp)
	currentHp = math.max(0, math.min(currentHp, maxHp))
	local healthPercent = currentHp / maxHp
	
	healthValue.Text = math.floor(currentHp) .. " / " .. maxHp
	
	-- Update bar width
	tween(healthBarFill, { Size = UDim2.new(healthPercent, 0, 1, 0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	
	-- Update bar color based on health percentage
	if healthPercent > 0.5 then
		-- Green
		tween(healthBarFill, { BackgroundColor3 = Color3.fromRGB(80, 220, 80) }, 0.3)
		statusLabel.Text = "Healthy"
		tween(statusLabel, { TextColor3 = Color3.fromRGB(80, 220, 80) }, 0.3)
	elseif healthPercent > 0.2 then
		-- Yellow
		tween(healthBarFill, { BackgroundColor3 = Color3.fromRGB(255, 220, 0) }, 0.3)
		statusLabel.Text = "Caution"
		tween(statusLabel, { TextColor3 = Color3.fromRGB(255, 220, 0) }, 0.3)
	else
		-- Red
		tween(healthBarFill, { BackgroundColor3 = Color3.fromRGB(220, 80, 80) }, 0.3)
		statusLabel.Text = "Critical"
		tween(statusLabel, { TextColor3 = Color3.fromRGB(220, 80, 80) }, 0.3)
	end
end

-- ============================================================
-- ENTRANCE ANIMATION
-- ============================================================

titleContainer.Position = UDim2.new(0.595, 0, -0.25, 0)
titleContainer.BackgroundTransparency = 1

healthCard.Position = UDim2.new(0.595, 0, 1.5, 0)
healthCard.BackgroundTransparency = 1

backBtn.Position = UDim2.new(-0.15, 0, 0.02, 0)
backBtn.BackgroundTransparency = 1

task.wait(0.1)

tween(titleContainer, { Position = UDim2.new(0.595, 0, 0.03, 0), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
tween(healthCard, { Position = UDim2.new(0.595, 0, 0.28, 0), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
tween(backBtn, { Position = UDim2.new(0.02, 0, 0.02, 0), BackgroundTransparency = 0 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Initialize display
updateHealthDisplay(CONFIG.currentHealth, CONFIG.maxHealth)

-- Simulate health changes for demo
task.wait(2)
updateHealthDisplay(75, CONFIG.maxHealth)
task.wait(2)
updateHealthDisplay(35, CONFIG.maxHealth)

print("[HealthUI] Loaded successfully.")
