-- ============================================================
-- INVENTORY SYSTEM UI
-- Place this LocalScript inside StarterGui
-- Displays player inventory with matching main menu aesthetic
-- ============================================================

-- ============================================================
--   ★ CUSTOMIZATION CONFIG ★
-- ============================================================

local CONFIG = {
	-- UI TITLE
	screenTitle    = "INVENTORY",
	screenSubtitle = "ITEM COLLECTION",

	-- SAMPLE INVENTORY ITEMS
	inventoryItems = {
		{ name = "Iron Sword",     count = 1,  icon = "⚔", rarity = "common",   color = Color3.fromRGB(150, 150, 150) },
		{ name = "Health Potion",  count = 5,  icon = "❤", rarity = "common",   color = Color3.fromRGB(220, 80, 80) },
		{ name = "Gold Key",       count = 1,  icon = "🔑", rarity = "rare",     color = Color3.fromRGB(255, 220, 0) },
		{ name = "Mana Crystal",   count = 3,  icon = "◆", rarity = "epic",     color = Color3.fromRGB(150, 100, 255) },
		{ name = "Rope",           count = 8,  icon = "~", rarity = "common",   color = Color3.fromRGB(180, 130, 60) },
		{ name = "Ancient Scroll", count = 1,  icon = "📜", rarity = "legendary", color = Color3.fromRGB(255, 140, 0) },
	},

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

if playerGui:FindFirstChild("InventoryGui") then
	playerGui.InventoryGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryGui"
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
-- INVENTORY GRID CONTAINER
-- ============================================================

local gridContainer = Instance.new("ScrollingFrame")
gridContainer.Name = "InventoryGrid"
gridContainer.Size = UDim2.new(0.35, 0, 0.75, 0)
gridContainer.Position = UDim2.new(0.595, 0, 0.2, 0)
gridContainer.BackgroundColor3 = CONFIG.bgCard
gridContainer.BorderSizePixel = 0
gridContainer.ScrollBarThickness = 8
gridContainer.ScrollBarImageColor3 = CONFIG.accentRed
gridContainer.CanvasSize = UDim2.new(1, 0, 0, 0)
gridContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
gridContainer.ZIndex = 10
gridContainer.Parent = screenGui

addStroke(gridContainer, CONFIG.accentYellow, 3)
addCorner(gridContainer, 8)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Parent = gridContainer

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = gridContainer

-- ============================================================
-- CREATE INVENTORY ITEMS
-- ============================================================

local function rarityToColor(rarity)
	local colors = {
		common = Color3.fromRGB(180, 180, 180),
		rare = Color3.fromRGB(80, 180, 255),
		epic = Color3.fromRGB(200, 100, 255),
		legendary = Color3.fromRGB(255, 140, 0),
	}
	return colors[rarity] or Color3.fromRGB(180, 180, 180)
end

for _, item in ipairs(CONFIG.inventoryItems) do
	local itemCard = Instance.new("Frame")
	itemCard.Name = item.name
	itemCard.Size = UDim2.new(0.9, 0, 0, 60)
	itemCard.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	itemCard.BorderSizePixel = 0
	itemCard.ZIndex = 11
	itemCard.Parent = gridContainer

	addStroke(itemCard, rarityToColor(item.rarity), 2)
	addCorner(itemCard, 4)

	-- Left color stripe
	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(0.05, 0, 1, 0)
	stripe.BackgroundColor3 = rarityToColor(item.rarity)
	stripe.BorderSizePixel = 0
	stripe.ZIndex = 12
	stripe.Parent = itemCard

	-- Icon
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0.2, 0, 1, 0)
	iconLabel.Position = UDim2.new(0.05, 0, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = item.icon
	iconLabel.TextScaled = true
	iconLabel.ZIndex = 12
	iconLabel.Parent = itemCard

	-- Item name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
	nameLabel.Position = UDim2.new(0.25, 0, 0.1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 12
	nameLabel.Parent = itemCard

	-- Count label
	local countLabel = Instance.new("TextLabel")
	countLabel.Size = UDim2.new(0.2, 0, 1, 0)
	countLabel.Position = UDim2.new(0.75, 0, 0, 0)
	countLabel.BackgroundTransparency = 1
	countLabel.Text = "x" .. item.count
	countLabel.TextColor3 = CONFIG.accentYellow
	countLabel.TextScaled = true
	countLabel.Font = Enum.Font.GothamBlack
	countLabel.TextXAlignment = Enum.TextXAlignment.Right
	countLabel.ZIndex = 12
	itemCard.Position = UDim2.new(0, 0, 0, -10)
	countLabel.Parent = itemCard

	-- Hover effect
	itemCard.InputBegan:Connect(function(input, gp)
		if gp then return end
		playHover()
		tween(itemCard, { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }, 0.1)
	end)

	itemCard.InputEnded:Connect(function()
		tween(itemCard, { BackgroundColor3 = Color3.fromRGB(20, 20, 20) }, 0.1)
	end)
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

gridContainer.Position = UDim2.new(0.595, 0, 1.5, 0)
gridContainer.BackgroundTransparency = 1

backBtn.Position = UDim2.new(-0.15, 0, 0.02, 0)
backBtn.BackgroundTransparency = 1

task.wait(0.1)

tween(titleContainer, { Position = UDim2.new(0.595, 0, 0.03, 0), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
tween(gridContainer, { Position = UDim2.new(0.595, 0, 0.2, 0), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
tween(backBtn, { Position = UDim2.new(0.02, 0, 0.02, 0), BackgroundTransparency = 0 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

print("[InventoryUI] Loaded successfully.")
