-- ============================================================
-- PERSONA 5 STYLE STATS SCREEN
-- Place this LocalScript inside StarterGui
-- Full screen takeover with profile card + stat grid below
-- ============================================================

-- ============================================================
--
--   ★ CUSTOMIZATION CONFIG — EDIT EVERYTHING HERE ★
--
-- ============================================================

local CONFIG = {

	-- SCREEN TITLE
	screenTitle    = "STATS",
	screenSubtitle = "PLAYER RECORD",

	-- PROFILE CARD
	-- In a real game these come from DataStore via RemoteFunction.
	-- For now they are placeholders you can swap out.
	profile = {
		displayName = "Kvpll",       -- player's display name (swap with player.DisplayName)
		username    = "@Kvpll",       -- roblox username
		level       = 42,
		levelMax    = 100,            -- used to draw the XP bar fill
		levelXP     = 7400,           -- current XP within this level
		levelXPMax  = 10000,          -- XP needed for next level
		rank        = "GOLD",         -- rank badge label
		rankColor   = Color3.fromRGB(255, 200, 0),
	},

	-- STAT CARDS
	-- Each card: label, value, subvalue (optional smaller line), color (left stripe)
	-- In a real game you'd fill these from a RemoteFunction that returns DataStore values
	stats = {
		{
			label    = "WINS",
			value    = "1,204",
			subvalue = "Win Rate  67%",
			color    = Color3.fromRGB(80, 220, 80),
		},
		{
			label    = "LOSSES",
			value    = "592",
			subvalue = "Loss Rate  33%",
			color    = Color3.fromRGB(220, 80, 80),
		},
		{
			label    = "MATCHES",
			value    = "1,796",
			subvalue = "Time Played  48h 22m",
			color    = Color3.fromRGB(100, 180, 255),
		},
		{
			label    = "COINS EARNED",
			value    = "284,500",
			subvalue = "Spent  121,000",
			color    = Color3.fromRGB(255, 220, 0),
		},
		{
			label    = "BEST STREAK",
			value    = "34",
			subvalue = "Current Streak  12",
			color    = Color3.fromRGB(255, 140, 0),
		},
		{
			label    = "HIGHEST ROUND",
			value    = "Round 18",
			subvalue = "Avg Round  9.4",
			color    = Color3.fromRGB(200, 80, 255),
		},
	},

	-- COLORS
	accentYellow = Color3.fromRGB(255, 220, 0),
	accentRed    = Color3.fromRGB(220, 20,  20),
	bgDark       = Color3.fromRGB(8,   8,   8),
	bgMid        = Color3.fromRGB(18,  18,  18),
	bgCard       = Color3.fromRGB(15,  15,  15),
	bgProfile    = Color3.fromRGB(12,  12,  12),
}

-- ============================================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player.PlayerGui

-- Wait for main menu to exist so we can hook the STATS button
local mainMenuGui  = playerGui:WaitForChild("MainMenuGui", 10)


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
		countUp   = f:WaitForChild("CountUpFn",     5),
		click     = f:WaitForChild("ClickFn",       5),
		hover     = f:WaitForChild("HoverFn",       5),
		whoosh    = f:WaitForChild("WhooshFn",      5),
		attachBtn = f:WaitForChild("AttachButtonFx",5),
	}
	return _efx
end
local function playClick()  local e = getEfx(); if e.click  then e.click:Invoke()  end end
local function playHover()  local e = getEfx(); if e.hover  then e.hover:Invoke()  end end
local function playWhoosh() local e = getEfx(); if e.whoosh then e.whoosh:Invoke() end end
local function doRipple(x, y) local e = getEfx(); if e.ripple then e.ripple:Invoke(x, y) end end
local function doCountUp(lbl, val, dur) local e = getEfx(); if e.countUp then e.countUp:Invoke(lbl, val, dur) end end
local UserInputService = game:GetService("UserInputService")

-- Get the transition BindableFunctions so we can flash between UIs
-- WaitForChild with a timeout so the script doesn't hang if TransitionGui loads slowly
local function getTransition()
	local tGui = playerGui:WaitForChild("TransitionGui", 10)
	if not tGui then return nil, nil end
	return tGui:WaitForChild("CoverFn", 5), tGui:WaitForChild("UncoverFn", 5)
end

-- Clean up old instance
if playerGui:FindFirstChild("StatsGui") then
	playerGui.StatsGui:Destroy()
end

-- ============================================================
-- UTILITY
-- ============================================================

local function tween(obj, props, duration, style, direction)
	local t = TweenService:Create(obj,
		TweenInfo.new(
			duration  or 0.3,
			style     or Enum.EasingStyle.Quart,
			direction or Enum.EasingDirection.Out
		), props)
	t:Play()
	return t
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color                = color or Color3.fromRGB(0, 0, 0)
	s.Thickness            = thickness or 3
	s.ApplyStrokeMode      = Enum.ApplyStrokeMode.Border
	s.Parent               = parent
	return s
end

local function addCorner(parent, px)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px or 4)
	c.Parent = parent
	return c
end

-- ============================================================
-- BUILD SCREENGUI
-- ============================================================

local statsGui = Instance.new("ScreenGui")
statsGui.Name            = "StatsGui"
statsGui.ResetOnSpawn    = false
statsGui.IgnoreGuiInset  = true
statsGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
statsGui.Enabled         = false
statsGui.Parent          = playerGui

-- ============================================================
-- FULL SCREEN BACKGROUND
-- ============================================================

local bg = Instance.new("Frame")
bg.Name                  = "Background"
bg.Size                  = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3      = CONFIG.bgDark
bg.BorderSizePixel       = 0
bg.ZIndex                = 20
bg.Parent                = statsGui

-- Diagonal red gradient stripe across the bg
local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(25, 0, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8,  8, 8)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,  8, 8)),
})
bgGrad.Rotation = 135
bgGrad.Parent   = bg

-- Thin red horizontal rule near the top
local topRule = Instance.new("Frame")
topRule.Size             = UDim2.new(1, 0, 0.004, 0)
topRule.Position         = UDim2.new(0, 0, 0.09, 0)
topRule.BackgroundColor3 = CONFIG.accentRed
topRule.BorderSizePixel  = 0
topRule.ZIndex           = 21
topRule.Parent           = statsGui

-- Decorative angled slash (same as main menu / shop)
local slash = Instance.new("Frame")
slash.Size               = UDim2.new(0.06, 0, 1.6, 0)
slash.Position           = UDim2.new(-0.01, 0, -0.3, 0)
slash.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
slash.BackgroundTransparency = 0.94
slash.BorderSizePixel    = 0
slash.Rotation           = 12
slash.ZIndex             = 21
slash.Parent             = statsGui

local slash2 = Instance.new("Frame")
slash2.Size              = UDim2.new(0.025, 0, 1.6, 0)
slash2.Position          = UDim2.new(0.06, 0, -0.3, 0)
slash2.BackgroundColor3  = CONFIG.accentRed
slash2.BackgroundTransparency = 0.7
slash2.BorderSizePixel   = 0
slash2.Rotation          = 12
slash2.ZIndex            = 21
slash2.Parent            = statsGui

-- ============================================================
-- HEADER (title box top-left)
-- ============================================================

local headerBox = Instance.new("Frame")
headerBox.Name           = "HeaderBox"
headerBox.Size           = UDim2.new(0.2, 0, 0.11, 0)
headerBox.Position       = UDim2.new(0.02, 0, 0.01, 0)
headerBox.BackgroundColor3 = CONFIG.bgDark
headerBox.BorderSizePixel  = 0
headerBox.Rotation       = -2
headerBox.ZIndex         = 25
headerBox.Parent         = statsGui

addStroke(headerBox, CONFIG.accentYellow, 3)

local headerTitle = Instance.new("TextLabel")
headerTitle.Size             = UDim2.new(1, -12, 0.58, 0)
headerTitle.Position         = UDim2.new(0, 6, 0.02, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text             = CONFIG.screenTitle
headerTitle.TextColor3       = CONFIG.accentYellow
headerTitle.TextScaled       = true
headerTitle.Font             = Enum.Font.GothamBlack
headerTitle.TextXAlignment   = Enum.TextXAlignment.Left
headerTitle.ZIndex           = 26
headerTitle.Parent           = headerBox

local headerSubBar = Instance.new("Frame")
headerSubBar.Size            = UDim2.new(1, 0, 0.32, 0)
headerSubBar.Position        = UDim2.new(0, 0, 0.68, 0)
headerSubBar.BackgroundColor3 = CONFIG.accentYellow
headerSubBar.BorderSizePixel = 0
headerSubBar.ZIndex          = 26
headerSubBar.Parent          = headerBox

local headerSubLabel = Instance.new("TextLabel")
headerSubLabel.Size          = UDim2.new(1, -8, 1, 0)
headerSubLabel.Position      = UDim2.new(0, 4, 0, 0)
headerSubLabel.BackgroundTransparency = 1
headerSubLabel.Text          = CONFIG.screenSubtitle
headerSubLabel.TextColor3    = CONFIG.bgDark
headerSubLabel.TextScaled    = true
headerSubLabel.Font          = Enum.Font.GothamBlack
headerSubLabel.ZIndex        = 27
headerSubLabel.Parent        = headerSubBar

-- CLOSE BUTTON (top right)
local closeBtn = Instance.new("TextButton")
closeBtn.Name            = "CloseBtn"
closeBtn.Size            = UDim2.new(0.055, 0, 0.065, 0)
closeBtn.Position        = UDim2.new(0.93, 0, 0.01, 0)
closeBtn.BackgroundColor3 = CONFIG.bgMid
closeBtn.Text            = "X"
closeBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled      = true
closeBtn.Font            = Enum.Font.GothamBlack
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex          = 30
closeBtn.Parent          = statsGui

addStroke(closeBtn, CONFIG.accentYellow, 2)

closeBtn.MouseEnter:Connect(function()
	playHover()
	tween(closeBtn, { BackgroundColor3 = CONFIG.accentRed }, 0.1)
end)
closeBtn.MouseLeave:Connect(function()
	tween(closeBtn, { BackgroundColor3 = CONFIG.bgMid }, 0.1)
end)
closeBtn.MouseButton1Click:Connect(function() playClick() doRipple() end)

-- ============================================================
-- PROFILE CARD (top section)
-- ============================================================

local profileCard = Instance.new("Frame")
profileCard.Name             = "ProfileCard"
profileCard.Size             = UDim2.new(0.96, 0, 0.26, 0)
profileCard.Position         = UDim2.new(0.02, 0, 0.11, 0)
profileCard.BackgroundColor3 = CONFIG.bgProfile
profileCard.BorderSizePixel  = 0
profileCard.ZIndex           = 22
profileCard.Parent           = statsGui

addStroke(profileCard, Color3.fromRGB(40, 40, 40), 2)

-- Yellow left accent bar on profile card
local profileAccent = Instance.new("Frame")
profileAccent.Size           = UDim2.new(0.006, 0, 1, 0)
profileAccent.BackgroundColor3 = CONFIG.accentYellow
profileAccent.BorderSizePixel = 0
profileAccent.ZIndex         = 23
profileAccent.Parent         = profileCard

-- Avatar: real Roblox headshot via GetUserThumbnailAsync
-- Falls back to initial letter if the fetch fails
local avatarBg = Instance.new("Frame")
avatarBg.Name                = "AvatarBg"
avatarBg.Size                = UDim2.new(0.11, 0, 0.82, 0)
avatarBg.Position            = UDim2.new(0.012, 0, 0.09, 0)
avatarBg.BackgroundColor3    = Color3.fromRGB(20, 20, 20)
avatarBg.BorderSizePixel     = 0
avatarBg.ZIndex              = 23
avatarBg.Parent              = profileCard

addStroke(avatarBg, CONFIG.accentYellow, 3)

-- ImageLabel that will hold the headshot once loaded
local avatarImage = Instance.new("ImageLabel")
avatarImage.Size             = UDim2.new(1, 0, 1, 0)
avatarImage.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
avatarImage.BorderSizePixel  = 0
avatarImage.Image            = ""
avatarImage.ScaleType        = Enum.ScaleType.Crop
avatarImage.ZIndex           = 24
avatarImage.Parent           = avatarBg

-- Letter shown while image is fetching
local avatarFallback = Instance.new("TextLabel")
avatarFallback.Size          = UDim2.new(1, 0, 1, 0)
avatarFallback.BackgroundTransparency = 1
avatarFallback.Text          = string.upper(string.sub(player.DisplayName, 1, 1))
avatarFallback.TextColor3    = Color3.fromRGB(180, 180, 180)
avatarFallback.TextScaled    = true
avatarFallback.Font          = Enum.Font.GothamBlack
avatarFallback.ZIndex        = 25
avatarFallback.Parent        = avatarBg

-- GetUserThumbnailAsync must run in a task.spawn so it does not yield the main thread
task.spawn(function()
	local ok, url = pcall(function()
		return Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
	end)
	if ok and url then
		avatarImage.Image      = url
		avatarFallback.Visible = false
	end
end)

-- Override CONFIG placeholders with live Player data
CONFIG.profile.displayName = player.DisplayName
CONFIG.profile.username    = "@" .. player.Name

-- Player name block (right of avatar)
local nameBlock = Instance.new("Frame")
nameBlock.Size               = UDim2.new(0.35, 0, 0.82, 0)
nameBlock.Position           = UDim2.new(0.14, 0, 0.09, 0)
nameBlock.BackgroundTransparency = 1
nameBlock.BorderSizePixel    = 0
nameBlock.ZIndex             = 23
nameBlock.Parent             = profileCard

local displayNameLabel = Instance.new("TextLabel")
displayNameLabel.Size        = UDim2.new(1, 0, 0.42, 0)
displayNameLabel.BackgroundTransparency = 1
displayNameLabel.Text        = CONFIG.profile.displayName
displayNameLabel.TextColor3  = Color3.fromRGB(255, 255, 255)
displayNameLabel.TextScaled  = true
displayNameLabel.Font        = Enum.Font.GothamBlack
displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
displayNameLabel.ZIndex      = 24
displayNameLabel.Parent      = nameBlock

local usernameLabel = Instance.new("TextLabel")
usernameLabel.Size           = UDim2.new(1, 0, 0.22, 0)
usernameLabel.Position       = UDim2.new(0, 0, 0.4, 0)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Text           = CONFIG.profile.username
usernameLabel.TextColor3     = Color3.fromRGB(140, 140, 140)
usernameLabel.TextScaled     = true
usernameLabel.Font           = Enum.Font.Gotham
usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
usernameLabel.ZIndex         = 24
usernameLabel.Parent         = nameBlock

-- Rank badge
local rankBadge = Instance.new("Frame")
rankBadge.Size               = UDim2.new(0.28, 0, 0.28, 0)
rankBadge.Position           = UDim2.new(0, 0, 0.65, 0)
rankBadge.BackgroundColor3   = CONFIG.profile.rankColor
rankBadge.BorderSizePixel    = 0
rankBadge.ZIndex             = 24
rankBadge.Parent             = nameBlock

addCorner(rankBadge, 2)
addStroke(rankBadge, CONFIG.bgDark, 2)

local rankLabel = Instance.new("TextLabel")
rankLabel.Size               = UDim2.new(1, -8, 1, 0)
rankLabel.Position           = UDim2.new(0, 4, 0, 0)
rankLabel.BackgroundTransparency = 1
rankLabel.Text               = CONFIG.profile.rank
rankLabel.TextColor3         = Color3.fromRGB(0, 0, 0)
rankLabel.TextScaled         = true
rankLabel.Font               = Enum.Font.GothamBlack
rankLabel.ZIndex             = 25
rankLabel.Parent             = rankBadge

-- Level + XP bar (right side of profile card)
local levelBlock = Instance.new("Frame")
levelBlock.Size              = UDim2.new(0.38, 0, 0.82, 0)
levelBlock.Position          = UDim2.new(0.54, 0, 0.09, 0)
levelBlock.BackgroundTransparency = 1
levelBlock.BorderSizePixel   = 0
levelBlock.ZIndex            = 23
levelBlock.Parent            = profileCard

-- "LEVEL" small label
local levelCaption = Instance.new("TextLabel")
levelCaption.Size            = UDim2.new(1, 0, 0.22, 0)
levelCaption.BackgroundTransparency = 1
levelCaption.Text            = "LEVEL"
levelCaption.TextColor3      = Color3.fromRGB(140, 140, 140)
levelCaption.TextScaled      = true
levelCaption.Font            = Enum.Font.GothamBold
levelCaption.TextXAlignment  = Enum.TextXAlignment.Left
levelCaption.ZIndex          = 24
levelCaption.Parent          = levelBlock

-- Big level number
local levelNumber = Instance.new("TextLabel")
levelNumber.Size             = UDim2.new(0.5, 0, 0.45, 0)
levelNumber.Position         = UDim2.new(0, 0, 0.2, 0)
levelNumber.BackgroundTransparency = 1
levelNumber.Text             = tostring(CONFIG.profile.level)
levelNumber.TextColor3       = CONFIG.accentYellow
levelNumber.TextScaled       = true
levelNumber.Font             = Enum.Font.GothamBlack
levelNumber.TextXAlignment   = Enum.TextXAlignment.Left
levelNumber.ZIndex           = 24
levelNumber.Parent           = levelBlock

-- "/ MAX" next to level
local levelMax = Instance.new("TextLabel")
levelMax.Size                = UDim2.new(0.45, 0, 0.28, 0)
levelMax.Position            = UDim2.new(0.5, 0, 0.35, 0)
levelMax.BackgroundTransparency = 1
levelMax.Text                = "/ " .. tostring(CONFIG.profile.levelMax)
levelMax.TextColor3          = Color3.fromRGB(100, 100, 100)
levelMax.TextScaled          = true
levelMax.Font                = Enum.Font.GothamBold
levelMax.TextXAlignment      = Enum.TextXAlignment.Left
levelMax.ZIndex              = 24
levelMax.Parent              = levelBlock

-- XP bar background
local xpBarBg = Instance.new("Frame")
xpBarBg.Size                 = UDim2.new(1, 0, 0.12, 0)
xpBarBg.Position             = UDim2.new(0, 0, 0.72, 0)
xpBarBg.BackgroundColor3     = Color3.fromRGB(35, 35, 35)
xpBarBg.BorderSizePixel      = 0
xpBarBg.ZIndex               = 24
xpBarBg.Parent               = levelBlock

addStroke(xpBarBg, Color3.fromRGB(50, 50, 50), 1)

-- XP bar fill
local xpRatio = math.clamp(CONFIG.profile.levelXP / CONFIG.profile.levelXPMax, 0, 1)

-- Glow: a UIGradient on xpFill itself fades to transparent at the right edge
-- giving a glowing tip effect without any overflow outside the bar bounds.
-- We also add a second subtler fill behind it for the glow body.
local xpGlow = Instance.new("Frame")
xpGlow.Size                  = UDim2.new(0, 0, 1, 0)
xpGlow.BackgroundColor3      = Color3.fromRGB(255, 240, 120)  -- lighter yellow
xpGlow.BackgroundTransparency = 0.45
xpGlow.BorderSizePixel       = 0
xpGlow.ZIndex                = 24
xpGlow.Parent                = xpBarBg

-- Clip children so glow never escapes the bar
xpBarBg.ClipsDescendants = true

local xpFill = Instance.new("Frame")
xpFill.Size                  = UDim2.new(0, 0, 1, 0)   -- starts at 0, animates in
xpFill.BackgroundColor3      = CONFIG.accentYellow
xpFill.BorderSizePixel       = 0
xpFill.ZIndex                = 25
xpFill.Parent                = xpBarBg

-- XP label
local xpLabel = Instance.new("TextLabel")
xpLabel.Size                 = UDim2.new(1, 0, 0.14, 0)
xpLabel.Position             = UDim2.new(0, 0, 0.86, 0)
xpLabel.BackgroundTransparency = 1
xpLabel.Text                 = tostring(CONFIG.profile.levelXP) .. " / " .. tostring(CONFIG.profile.levelXPMax) .. " XP"
xpLabel.TextColor3           = Color3.fromRGB(120, 120, 120)
xpLabel.TextScaled           = true
xpLabel.Font                 = Enum.Font.Gotham
xpLabel.TextXAlignment       = Enum.TextXAlignment.Left
xpLabel.ZIndex               = 24
xpLabel.Parent               = levelBlock

-- ============================================================
-- STAT CARDS GRID
-- ============================================================

local gridFrame = Instance.new("ScrollingFrame")
gridFrame.Name               = "StatGrid"
gridFrame.Size               = UDim2.new(0.96, 0, 0.56, 0)
gridFrame.Position           = UDim2.new(0.02, 0, 0.4, 0)
gridFrame.BackgroundTransparency = 1
gridFrame.BorderSizePixel    = 0
gridFrame.ScrollBarThickness = 4
gridFrame.ScrollBarImageColor3 = CONFIG.accentYellow
gridFrame.CanvasSize         = UDim2.new(0, 0, 0, 0)
gridFrame.ZIndex             = 22
gridFrame.Parent             = statsGui

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellPadding       = UDim2.new(0, 8, 0, 10)  -- fixed pixel gaps, predictable on all screen sizes
gridLayout.SortOrder         = Enum.SortOrder.LayoutOrder
gridLayout.Parent            = gridFrame

local gridPad = Instance.new("UIPadding")
gridPad.PaddingTop           = UDim.new(0, 6)
gridPad.PaddingBottom        = UDim.new(0, 6)
gridPad.PaddingLeft          = UDim.new(0, 4)
gridPad.PaddingRight         = UDim.new(0, 4)
gridPad.Parent               = gridFrame

-- Build stat cards
local function buildStatCards()
	-- Clear old
	for _, c in ipairs(gridFrame:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	-- Compute cell size (3 columns)
	local cols = 3
	local gw   = gridFrame.AbsoluteSize.X
	if gw < 10 then gw = math.floor(1280 * 0.96) - 8 end
	local cellW = math.floor((gw - 24) / cols)
	local cellH = math.floor(cellW * 0.62)
	gridLayout.CellSize = UDim2.new(0, cellW, 0, cellH)

	for i, stat in ipairs(CONFIG.stats) do
		local card = Instance.new("Frame")
		card.Name            = "StatCard_" .. i
		card.BackgroundColor3 = CONFIG.bgCard
		card.BorderSizePixel = 0
		card.LayoutOrder     = i
		card.ZIndex          = 23
		card.Parent          = gridFrame

		addStroke(card, Color3.fromRGB(35, 35, 35), 2)

		-- Left accent stripe
		local stripe = Instance.new("Frame")
		stripe.Size          = UDim2.new(0.018, 0, 1, 0)
		stripe.BackgroundColor3 = stat.color
		stripe.BorderSizePixel = 0
		stripe.ZIndex        = 24
		stripe.Parent        = card

		-- Top colored bar (thin highlight)
		local topBar = Instance.new("Frame")
		topBar.Size          = UDim2.new(1, 0, 0.06, 0)
		topBar.BackgroundColor3 = stat.color
		topBar.BackgroundTransparency = 0.7
		topBar.BorderSizePixel = 0
		topBar.ZIndex        = 24
		topBar.Parent        = card

		-- Stat label (e.g. "WINS")
		local labelText = Instance.new("TextLabel")
		labelText.Size       = UDim2.new(0.95, 0, 0.25, 0)
		labelText.Position   = UDim2.new(0.03, 0, 0.07, 0)
		labelText.BackgroundTransparency = 1
		labelText.Text       = stat.label
		labelText.TextColor3 = Color3.fromRGB(160, 160, 160)
		labelText.TextScaled = true
		labelText.Font       = Enum.Font.GothamBold
		labelText.TextXAlignment = Enum.TextXAlignment.Left
		labelText.ZIndex     = 25
		labelText.Parent     = card

		-- Big value (e.g. "1,204") — counts up when card appears
		local valueText = Instance.new("TextLabel")
		valueText.Size       = UDim2.new(0.95, 0, 0.42, 0)
		valueText.Position   = UDim2.new(0.03, 0, 0.3, 0)
		valueText.BackgroundTransparency = 1
		valueText.Text       = "0"
		valueText.TextColor3 = stat.color
		valueText.TextScaled = true
		valueText.Font       = Enum.Font.GothamBlack
		valueText.TextXAlignment = Enum.TextXAlignment.Left
		valueText.ZIndex     = 25
		valueText.Parent     = card

		-- Subvalue (e.g. "Win Rate 67%")
		if stat.subvalue and stat.subvalue ~= "" then
			local subText = Instance.new("TextLabel")
			subText.Size     = UDim2.new(0.95, 0, 0.2, 0)
			subText.Position = UDim2.new(0.03, 0, 0.76, 0)
			subText.BackgroundTransparency = 1
			subText.Text     = stat.subvalue
			subText.TextColor3 = Color3.fromRGB(120, 120, 120)
			subText.TextScaled = true
			subText.Font     = Enum.Font.Gotham
			subText.TextXAlignment = Enum.TextXAlignment.Left
			subText.ZIndex   = 25
			subText.Parent   = card
		end

		-- Hover effect: stripe flashes yellow
		card.MouseEnter:Connect(function()
			tween(card,   { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }, 0.1)
			tween(stripe, { BackgroundColor3 = CONFIG.accentYellow },        0.1)
		end)
		card.MouseLeave:Connect(function()
			tween(card,   { BackgroundColor3 = CONFIG.bgCard },  0.15)
			tween(stripe, { BackgroundColor3 = stat.color },     0.15)
		end)

		-- Count up the value with a stagger per card
		task.delay(i * 0.08, function()
			doCountUp(valueText, stat.value, 0.7)
		end)
	end

	-- Let Roblox auto-size the canvas so all cards are always reachable,
	-- regardless of screen size. AutomaticCanvasSize expands the canvas to
	-- fit all children — no manual row math needed.
	gridFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	gridFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  -- Y is auto, X stays 0
end

-- ============================================================
-- OPEN / CLOSE
-- ============================================================

local isOpen = false

local function closeStats()
	if not isOpen then return end
	isOpen = false

	-- Flash the transition cover on so the player never sees the bare world
	local coverFn, uncoverFn = getTransition()
	if coverFn then coverFn:Invoke() end

	-- Instantly reset everything behind the cover
	statsGui.Enabled             = false
	bg.BackgroundTransparency    = 0
	profileCard.Position         = UDim2.new(0.02, 0, 1.2, 0)
	gridFrame.Position           = UDim2.new(0.02, 0, 1.5, 0)
	headerBox.Position           = UDim2.new(0.02, 0, -0.2, 0)
	closeBtn.Position            = UDim2.new(0.93, 0, -0.2, 0)
	xpFill.Size                  = UDim2.new(0, 0, 1, 0)
	xpGlow.Size                  = UDim2.new(0, 0, 1, 0)

	-- Re-enable main menu
	if mainMenuGui then mainMenuGui.Enabled = true end

	-- Fade the cover out revealing the main menu cleanly
	if uncoverFn then uncoverFn:Invoke(0.35) end
end

local function openStats()
	if isOpen then return end
	isOpen = true

	-- Cover the screen during the swap
	local coverFn, uncoverFn = getTransition()
	if coverFn then coverFn:Invoke() end

	-- Hide main menu, set up stats screen behind the cover
	if mainMenuGui then mainMenuGui.Enabled = false end
	statsGui.Enabled             = true
	bg.BackgroundTransparency    = 0
	headerBox.Position           = UDim2.new(0.02, 0, -0.2,  0)
	closeBtn.Position            = UDim2.new(0.93, 0, -0.2,  0)
	profileCard.Position         = UDim2.new(0.02, 0,  1.2,  0)
	gridFrame.Position           = UDim2.new(0.02, 0,  1.5,  0)
	xpFill.Size                  = UDim2.new(0, 0, 1, 0)
	xpGlow.Size                  = UDim2.new(0, 0, 1, 0)
	buildStatCards()

	-- Reveal the stats screen by fading the cover out
	if uncoverFn then uncoverFn:Invoke(0.35) end
	task.wait(0.1)

	-- Staggered entrance animations play as cover fades
	tween(headerBox, { Position = UDim2.new(0.02, 0, 0.01, 0) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	tween(closeBtn,  { Position = UDim2.new(0.93, 0, 0.01, 0) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	task.wait(0.12)
	tween(profileCard, { Position = UDim2.new(0.02, 0, 0.11, 0) }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	task.wait(0.18)
	tween(gridFrame, { Position = UDim2.new(0.02, 0, 0.4, 0) }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	task.wait(0.3)
	tween(xpFill, { Size = UDim2.new(xpRatio, 0, 1, 0) }, 0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	tween(xpGlow, { Size = UDim2.new(xpRatio, 0, 1, 0) }, 0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
end

closeBtn.MouseButton1Click:Connect(closeStats)

-- ============================================================
-- HOOK INTO MAIN MENU STATS BUTTON
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

	local statsBtn = findBtn(mainMenuGui, "Slab_STATS")
	if statsBtn then
		statsBtn.MouseButton1Click:Connect(openStats)
		print("[StatsGui] Hooked into STATS button.")
	else
		print("[StatsGui] Could not find STATS button. Call openStats() manually.")
	end
end)

-- ============================================================
-- PUBLIC: hook openStats() from other scripts if needed
-- ============================================================

-- Expose open function so MainMenu can call it
local openStatsFn = Instance.new("BindableFunction")
openStatsFn.Name     = "OpenStatsFn"
openStatsFn.OnInvoke = openStats
openStatsFn.Parent   = statsGui

print("[StatsGui] stats screen loaded.")