-- ============================================================
-- LEADERBOARD SYSTEM UI
-- Place this LocalScript inside StarterGui
-- Displays ranked players and their statistics
-- ============================================================

-- ============================================================
--   ★ CUSTOMIZATION CONFIG ★
-- ============================================================

local CONFIG = {
	-- UI TITLE
	screenTitle    = "LEADERBOARD",
	screenSubtitle = "RANKINGS",

	-- SAMPLE PLAYER DATA
	players = {
		{ rank = 1,  name = "ShadowKing",   level = 87, wins = 2150, xp = 4850000 },
		{ rank = 2,  name = "PhoenixRise",  level = 84, wins = 1980, xp = 4620000 },
		{ rank = 3,  name = "Kvpll",        level = 78, wins = 1750, xp = 4200000 },
		{ rank = 4,  name = "NeonSlash",    level = 75, wins = 1620, xp = 3980000 },
		{ rank = 5,  name = "IceQueen",     level = 72, wins = 1480, xp = 3750000 },
		{ rank = 6,  name = "VortexMage",   level = 70, wins = 1320, xp = 3520000 },
		{ rank = 7,  name = "SilentSorce",  level = 68, wins = 1150, xp = 3280000 },
		{ rank = 8,  name = "NovaForce",    level = 65, wins = 950,  xp = 2950000 },
		{ rank = 9,  name = "EchoStrike",   level = 62, wins = 820,  xp = 2680000 },
		{ rank = 10, name = "LunarEclipse", level = 59, wins = 650,  xp = 2350000 },
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

if playerGui:FindFirstChild("LeaderboardGui") then
	playerGui.LeaderboardGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeaderboardGui"
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
titleContainer.Size = UDim2.new(0.38, 0, 0.12, 0)
titleContainer.Position = UDim2.new(0.595, 0, 0.02, 0)
titleContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleContainer.BorderSizePixel = 0
titleContainer.Rotation = -3
titleContainer.ZIndex = 10
titleContainer.Parent = screenGui

addStroke(titleContainer, CONFIG.accentYellow, 4)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0.6, 0)
titleLabel.Position = UDim2.new(0, 10, 0.05, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = CONFIG.screenTitle
titleLabel.TextColor3 = CONFIG.accentYellow
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 11
titleLabel.Parent = titleContainer

local titleSub = Instance.new("Frame")
titleSub.Size = UDim2.new(1, 0, 0.35, 0)
titleSub.Position = UDim2.new(0, 0, 0.65, 0)
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
-- LEADERBOARD TABLE
-- ============================================================

local tableContainer = Instance.new("ScrollingFrame")
tableContainer.Name = "LeaderboardTable"
tableContainer.Size = UDim2.new(0.35, 0, 0.78, 0)
tableContainer.Position = UDim2.new(0.595, 0, 0.16, 0)
tableContainer.BackgroundColor3 = CONFIG.bgCard
tableContainer.BorderSizePixel = 0
tableContainer.ScrollBarThickness = 8
tableContainer.ScrollBarImageColor3 = CONFIG.accentRed
tableContainer.CanvasSize = UDim2.new(1, 0, 0, 0)
tableContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
tableContainer.ZIndex = 10
tableContainer.Parent = screenGui

addStroke(tableContainer, CONFIG.accentYellow, 3)
addCorner(tableContainer, 8)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 4)
uiListLayout.Parent = tableContainer

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = tableContainer

-- ============================================================
-- CREATE LEADERBOARD ROWS
-- ============================================================

local function rankToColor(rank)
	if rank == 1 then
		return Color3.fromRGB(255, 215, 0)  -- Gold
	elseif rank == 2 then
		return Color3.fromRGB(192, 192, 192) -- Silver
	elseif rank == 3 then
		return Color3.fromRGB(205, 127, 50)  -- Bronze
	else
		return Color3.fromRGB(100, 100, 100) -- Gray
	end
end

for _, p in ipairs(CONFIG.players) do
	local row = Instance.new("Frame")
	row.Name = "Rank_" .. p.rank
	row.Size = UDim2.new(0.92, 0, 0, 50)
	row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	row.BorderSizePixel = 0
	row.ZIndex = 11
	row.Parent = tableContainer

	addStroke(row, rankToColor(p.rank), 2)
	addCorner(row, 4)

	-- Rank number
	local rankLabel = Instance.new("TextLabel")
	rankLabel.Size = UDim2.new(0.12, 0, 1, 0)
	rankLabel.Position = UDim2.new(0, 0, 0, 0)
	rankLabel.BackgroundColor3 = rankToColor(p.rank)
	rankLabel.BorderSizePixel = 0
	rankLabel.Text = "#" .. p.rank
	rankLabel.TextColor3 = p.rank <= 3 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
	rankLabel.TextScaled = true
	rankLabel.Font = Enum.Font.GothamBlack
	rankLabel.ZIndex = 12
	rankLabel.Parent = row

	addCorner(rankLabel, 2)

	-- Player name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
	nameLabel.Position = UDim2.new(0.14, 0, 0.05, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = p.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 12
	nameLabel.Parent = row

	-- Level
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(0.2, 0, 0.5, 0)
	levelLabel.Position = UDim2.new(0.14, 0, 0.5, 0)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "Lv. " .. p.level
	levelLabel.TextColor3 = CONFIG.accentYellow
	levelLabel.TextScaled = true
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.ZIndex = 12
	levelLabel.Parent = row

	-- Wins
	local winsLabel = Instance.new("TextLabel")
	winsLabel.Size = UDim2.new(0.25, 0, 1, 0)
	winsLabel.Position = UDim2.new(0.56, 0, 0, 0)
	winsLabel.BackgroundTransparency = 1
	winsLabel.Text = p.wins .. " wins"
	winsLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
	winsLabel.TextScaled = true
	winsLabel.Font = Enum.Font.GothamBold
	winsLabel.TextXAlignment = Enum.TextXAlignment.Right
	winsLabel.ZIndex = 12
	winsLabel.Parent = row

	-- Hover effect
	row.InputBegan:Connect(function(input, gp)
		if gp then return end
		playHover()
		tween(row, { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }, 0.1)
	end)

	row.InputEnded:Connect(function()
		tween(row, { BackgroundColor3 = Color3.fromRGB(20, 20, 20) }, 0.1)
	end)
end

-- ============================================================
-- BACK BUTTON
-- ============================================================

local backBtn = Instance.new("TextButton")
backBtn.Name = "BackButton"
backBtn.Size = UDim2.new(0.12, 0, 0.05, 0)
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

titleContainer.Position = UDim2.new(0.595, 0, -0.25, 0)
titleContainer.BackgroundTransparency = 1

tableContainer.Position = UDim2.new(0.595, 0, 1.5, 0)
tableContainer.BackgroundTransparency = 1

backBtn.Position = UDim2.new(-0.15, 0, 0.02, 0)
backBtn.BackgroundTransparency = 1

task.wait(0.1)

tween(titleContainer, { Position = UDim2.new(0.595, 0, 0.02, 0), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
tween(tableContainer, { Position = UDim2.new(0.595, 0, 0.16, 0), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
tween(backBtn, { Position = UDim2.new(0.02, 0, 0.02, 0), BackgroundTransparency = 0 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

print("[LeaderboardUI] Loaded successfully.")
