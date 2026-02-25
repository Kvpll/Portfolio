-- ============================================================
-- MAIN MENU
-- Place this LocalScript inside StarterGui
-- Creates all GUI elements automatically
-- ============================================================

-- ============================================================
--
--   ★ CUSTOMIZATION CONFIG — EDIT EVERYTHING HERE ★
--   You don't need to touch anything below this block.
--
-- ============================================================

local CONFIG = {

	-- TITLE BOX
	gameTitle    = "Kvpll menu test",   -- big text at the top of the title box
	menuSubtitle = "MAIN MENU",         -- small yellow bar beneath the title

	-- COIN BADGE (bottom left)
	coinIcon     = "G",                 -- letter/symbol shown in the gold box
	coinStart    = 0,                   -- starting coin amount displayed

	-- MENU BUTTONS
	-- Each entry: text (label), color (RGB for accent + text), action (internal ID)
	-- Actions: "play", "shop", "stats", "health", "inventory", "leveling", "abilities", "leaderboard", "settings", "quit"
	menuItems = {
		{ text = "PLAY",        color = Color3.fromRGB(255, 60,  60),  action = "play"        },
		{ text = "SHOP",        color = Color3.fromRGB(255, 200, 0),  action = "shop"        },
		{ text = "STATS",       color = Color3.fromRGB(100, 180, 255), action = "stats"       },
		{ text = "HEALTH",      color = Color3.fromRGB(220, 80, 80),   action = "health"      },
		{ text = "INVENTORY",   color = Color3.fromRGB(150, 150, 255), action = "inventory"   },
		{ text = "LEVELING",    color = Color3.fromRGB(80, 220, 80),   action = "leveling"    },
		{ text = "ABILITIES",   color = Color3.fromRGB(200, 100, 255), action = "abilities"   },
		{ text = "LEADERBOARD", color = Color3.fromRGB(255, 140, 0),   action = "leaderboard" },
		{ text = "SETTINGS",    color = Color3.fromRGB(255, 255, 255), action = "settings"    },
		{ text = "QUIT",        color = Color3.fromRGB(180, 180, 180), action = "quit"        },
	},

	-- LAYOUT
	-- Shift the entire button list down (0.22 = tight under title, 0.28 = more gap, adjust for more buttons)
	buttonAreaTopOffset = 0.25,

	-- COLORS
	bgColorA     = Color3.fromRGB(220, 20, 20),  -- background pulse color A
	bgColorB     = Color3.fromRGB(160, 5,  5),   -- background pulse color B
	accentYellow = Color3.fromRGB(255, 220, 0),  -- yellow used on title, arrows, hover
}

-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui


-- ============================================================
-- EFFECTS HELPER
-- Gets the shared effects functions from EffectsScript
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
local function attachBtn(btn) local e = getEfx(); if e.attachBtn then e.attachBtn:Invoke(btn) end end
local UserInputService = game:GetService("UserInputService")

-- ============================================================
-- CLEANUP: Remove any existing MainMenuGui so we start fresh
-- ============================================================
if playerGui:FindFirstChild("MainMenuGui") then
	playerGui.MainMenuGui:Destroy()
end

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

-- Creates a UICorner and attaches it to a parent
local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 0)
	corner.Parent = parent
	return corner
end

-- Creates a UIStroke (outline) on a parent
local function addStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(0, 0, 0)
	stroke.Thickness = thickness or 3
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

-- Tween helper: animates properties on an object
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

-- ============================================================
-- BUILD THE SCREENGUI
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainMenuGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true  -- fills the whole screen including topbar
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ============================================================
-- BACKGROUND: Deep red with a black vignette overlay
-- ============================================================

local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundColor3 = Color3.fromRGB(180, 10, 10)  -- deep crimson
background.BorderSizePixel = 0
background.ZIndex = 1
background.Parent = screenGui

-- Gradient on the background to give depth
local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 20, 20)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0)),
})
bgGradient.Rotation = 135
bgGradient.Parent = background

-- Dark vignette overlay on the left side where the character would stand
local vignette = Instance.new("Frame")
vignette.Name = "Vignette"
vignette.Size = UDim2.new(0.5, 0, 1, 0)
vignette.Position = UDim2.new(0, 0, 0, 0)
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
vigGradient.Rotation = 0
vigGradient.Parent = vignette

-- ============================================================
-- DIAGONAL SLASH DECORATION (the big black angled stripe)
-- Diagonal black bars
-- ============================================================

local slash = Instance.new("Frame")
slash.Name = "DiagonalSlash"
slash.Size = UDim2.new(0.08, 0, 1.5, 0)
slash.Position = UDim2.new(0.52, 0, -0.25, 0)
slash.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
slash.BackgroundTransparency = 0.2
slash.BorderSizePixel = 0
slash.Rotation = 12
slash.ZIndex = 3
slash.Parent = screenGui

local slash2 = Instance.new("Frame")
slash2.Name = "DiagonalSlash2"
slash2.Size = UDim2.new(0.04, 0, 1.5, 0)
slash2.Position = UDim2.new(0.56, 0, -0.25, 0)
slash2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
slash2.BackgroundTransparency = 0.85
slash2.BorderSizePixel = 0
slash2.Rotation = 12
slash2.ZIndex = 3
slash2.Parent = screenGui

-- ============================================================
-- GAME TITLE (top right area, bold and angled)
-- ============================================================

local titleContainer = Instance.new("Frame")
titleContainer.Name = "TitleContainer"
titleContainer.Size = UDim2.new(0.38, 0, 0.22, 0)   -- wider and taller so text fits
titleContainer.Position = UDim2.new(0.595, 0, 0.03, 0)
titleContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleContainer.BackgroundTransparency = 0
titleContainer.BorderSizePixel = 0
titleContainer.Rotation = -3
titleContainer.ZIndex = 10
titleContainer.Parent = screenGui

addStroke(titleContainer, CONFIG.accentYellow, 4)

-- Game name: takes up the top 65% of the container
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -20, 0.62, 0)   -- full width minus padding, 62% height
titleLabel.Position = UDim2.new(0, 10, 0.04, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = CONFIG.gameTitle
titleLabel.TextColor3 = CONFIG.accentYellow
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 11
titleLabel.Parent = titleContainer

-- "MAIN MENU" yellow bar: sits in the bottom 28% of the container
local titleSub = Instance.new("Frame")
titleSub.Name = "TitleSubFrame"
titleSub.Size = UDim2.new(1, 0, 0.3, 0)         -- full width, 30% of container height
titleSub.Position = UDim2.new(0, 0, 0.7, 0)     -- anchored to bottom
titleSub.BackgroundColor3 = CONFIG.accentYellow
titleSub.BackgroundTransparency = 0
titleSub.BorderSizePixel = 0
titleSub.ZIndex = 12
titleSub.Parent = titleContainer

local titleSubLabel = Instance.new("TextLabel")
titleSubLabel.Size = UDim2.new(1, -16, 1, 0)
titleSubLabel.Position = UDim2.new(0, 8, 0, 0)
titleSubLabel.BackgroundTransparency = 1
titleSubLabel.Text = CONFIG.menuSubtitle
titleSubLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
titleSubLabel.TextScaled = true
titleSubLabel.Font = Enum.Font.GothamBlack
titleSubLabel.TextXAlignment = Enum.TextXAlignment.Center
titleSubLabel.ZIndex = 13
titleSubLabel.Parent = titleSub

-- ============================================================
-- MENU ITEMS
-- Each item is a skewed black slab that flies in from the right
-- ============================================================

local menuItems = CONFIG.menuItems

-- The container that holds all menu buttons, anchored to the right-center
local menuContainer = Instance.new("Frame")
menuContainer.Name = "MenuContainer"
menuContainer.Size = UDim2.new(0.38, 0, 0.65, 0)
menuContainer.Position = UDim2.new(0.59, 0, CONFIG.buttonAreaTopOffset, 0)
menuContainer.BackgroundTransparency = 1
menuContainer.BorderSizePixel = 0
menuContainer.ZIndex = 10
menuContainer.Parent = screenGui

-- We'll store button references for animation
local buttons = {}
local buttonFrames = {}
local quitConfirm  -- forward declared, built after button loop

local itemHeight = 0.08  -- each item takes 8% of the container height (reduced for more buttons)
local itemGap = 0.025    -- gap between items

for i, item in ipairs(menuItems) do
	-- Outer slab (the black angled background)
	local slab = Instance.new("Frame")
	slab.Name = "Slab_" .. item.text
	slab.Size = UDim2.new(1, 0, itemHeight, 0)
	slab.Position = UDim2.new(
		1.5,  -- start FAR off screen to the right (we animate this in)
		0,
		(i - 1) * (itemHeight + itemGap),
		0
	)
	slab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	slab.BorderSizePixel = 0
	slab.Rotation = -2
	slab.ZIndex = 10
	slab.Parent = menuContainer

	addStroke(slab, Color3.fromRGB(0, 0, 0), 2)

	-- Colored left accent bar (the little color strip on the left edge)
	local accent = Instance.new("Frame")
	accent.Name = "Accent"
	accent.Size = UDim2.new(0.018, 0, 1, 0)
	accent.Position = UDim2.new(0, 0, 0, 0)
	accent.BackgroundColor3 = item.color
	accent.BorderSizePixel = 0
	accent.ZIndex = 11
	accent.Parent = slab

	-- The menu text
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0.85, 0, 0.75, 0)
	label.Position = UDim2.new(0.04, 0, 0.12, 0)
	label.BackgroundTransparency = 1
	label.Text = item.text
	label.TextColor3 = item.color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 12
	label.Parent = slab

	-- Invisible hit area button on top (cleaner than putting MouseButton1Click on the frame)
	local btn = Instance.new("TextButton")
	btn.Name = "Button"
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.Position = UDim2.new(0, 0, 0, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.ZIndex = 15
	btn.Parent = slab

	-- Selection indicator (yellow arrow that appears on hover, hidden by default)
	local arrow = Instance.new("TextLabel")
	arrow.Name = "Arrow"
	arrow.Size = UDim2.new(0.06, 0, 0.7, 0)
	arrow.Position = UDim2.new(0.88, 0, 0.15, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = ">"
	arrow.TextColor3 = CONFIG.accentYellow
	arrow.TextScaled = true
	arrow.Font = Enum.Font.GothamBlack
	arrow.TextTransparency = 1  -- hidden until hover
	arrow.ZIndex = 13
	arrow.Parent = slab

	buttons[i] = { slab = slab, label = label, btn = btn, arrow = arrow, action = item.action, color = item.color }
	buttonFrames[i] = slab
end

-- ============================================================
-- HOVER & CLICK EFFECTS ON MENU ITEMS
-- ============================================================

for i, item in ipairs(buttons) do
	local slab = item.slab
	local label = item.label
	local btn = item.btn
	local arrow = item.arrow

	-- On hover: slide right slightly, flash yellow, show arrow
	btn.MouseEnter:Connect(function()
		playHover()
		tween(slab, { Position = UDim2.new(0.04, 0, slab.Position.Y.Scale, 0) }, 0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		tween(slab, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }, 0.1)
		tween(label, { TextColor3 = CONFIG.accentYellow }, 0.1)
		tween(arrow, { TextTransparency = 0 }, 0.1)
	end)

	-- On leave: slide back, restore color
	btn.MouseLeave:Connect(function()
		tween(slab, { Position = UDim2.new(0, 0, slab.Position.Y.Scale, 0) }, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		tween(slab, { BackgroundColor3 = Color3.fromRGB(15, 15, 15) }, 0.15)
		tween(label, { TextColor3 = item.color }, 0.15)
		tween(arrow, { TextTransparency = 1 }, 0.15)
	end)

	-- On click: flash white then trigger action
	btn.MouseButton1Click:Connect(function()
		playClick()
		doRipple()
		-- Quick white flash
		tween(slab, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }, 0.05)
		task.wait(0.08)
		tween(slab, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }, 0.15)

		if item.action == "play" then
			-- Animate ALL slabs flying back off screen to the right
			for j, otherItem in ipairs(buttons) do
				task.delay(j * 0.04, function()
					tween(otherItem.slab, { Position = UDim2.new(1.5, 0, otherItem.slab.Position.Y.Scale, 0) }, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				end)
			end
			task.wait(0.5)
			-- Hide the whole menu
			screenGui.Enabled = false
			-- TODO: Fire RemoteEvent to server to start round

		elseif item.action == "shop" then
			playWhoosh()
			local shopGui = playerGui:FindFirstChild("ShopGui")
			if shopGui then
				local openFn = shopGui:FindFirstChild("OpenShopFn")
				if openFn then openFn:Invoke() else shopGui.Enabled = true end
			end

		elseif item.action == "stats" then
			playWhoosh()
			local statsGui = playerGui:FindFirstChild("StatsGui")
			if statsGui then
				local openFn = statsGui:FindFirstChild("OpenStatsFn")
				if openFn then openFn:Invoke() end
			end

		elseif item.action == "health" then
			playWhoosh()
			screenGui.Enabled = false
			local healthGui = playerGui:FindFirstChild("HealthGui")
			if healthGui then
				healthGui.Enabled = true
			end

		elseif item.action == "inventory" then
			playWhoosh()
			screenGui.Enabled = false
			local invGui = playerGui:FindFirstChild("InventoryGui")
			if invGui then
				invGui.Enabled = true
			end

		elseif item.action == "leveling" then
			playWhoosh()
			screenGui.Enabled = false
			local levelGui = playerGui:FindFirstChild("LevelingGui")
			if levelGui then
				levelGui.Enabled = true
			end

		elseif item.action == "abilities" then
			playWhoosh()
			screenGui.Enabled = false
			local abilitiesGui = playerGui:FindFirstChild("AbilitiesGui")
			if abilitiesGui then
				abilitiesGui.Enabled = true
			end

		elseif item.action == "leaderboard" then
			playWhoosh()
			screenGui.Enabled = false
			local leaderboardGui = playerGui:FindFirstChild("LeaderboardGui")
			if leaderboardGui then
				leaderboardGui.Enabled = true
			end

		elseif item.action == "settings" then
			playWhoosh()
			local settingsGui = playerGui:FindFirstChild("SettingsGui")
			if settingsGui then
				local openFn = settingsGui:FindFirstChild("OpenSettingsFn")
				if openFn then openFn:Invoke() end
			end

		elseif item.action == "quit" then
			-- Show quit confirmation dialog
			quitConfirm.Visible          = true
			quitConfirm.BackgroundTransparency = 1
			quitConfirm.Position         = UDim2.new(0.5, 0, 0.4, 0)
			tween(quitConfirm, { BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end)
end

-- ============================================================
-- QUIT CONFIRMATION DIALOG
-- ============================================================

quitConfirm = Instance.new("Frame")
quitConfirm.Name             = "QuitConfirm"
quitConfirm.Size             = UDim2.new(0.32, 0, 0.3, 0)
quitConfirm.AnchorPoint      = Vector2.new(0.5, 0.5)
quitConfirm.Position         = UDim2.new(0.5, 0, 0.5, 0)
quitConfirm.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
quitConfirm.BorderSizePixel  = 0
quitConfirm.ZIndex           = 50
quitConfirm.Visible          = false
quitConfirm.Parent           = screenGui

do
	local s = Instance.new("UIStroke")
	s.Color           = CONFIG.accentYellow
	s.Thickness       = 3
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent          = quitConfirm
end

-- Red top bar
local quitTopBar = Instance.new("Frame")
quitTopBar.Size             = UDim2.new(1, 0, 0.22, 0)
quitTopBar.BackgroundColor3 = Color3.fromRGB(180, 15, 15)
quitTopBar.BorderSizePixel  = 0
quitTopBar.ZIndex           = 51
quitTopBar.Parent           = quitConfirm

local quitTopLabel = Instance.new("TextLabel")
quitTopLabel.Size           = UDim2.new(1, -16, 1, 0)
quitTopLabel.Position       = UDim2.new(0, 8, 0, 0)
quitTopLabel.BackgroundTransparency = 1
quitTopLabel.Text           = "QUIT GAME"
quitTopLabel.TextColor3     = Color3.fromRGB(255, 255, 255)
quitTopLabel.TextScaled     = true
quitTopLabel.Font           = Enum.Font.GothamBlack
quitTopLabel.ZIndex         = 52
quitTopLabel.Parent         = quitTopBar

local quitBody = Instance.new("TextLabel")
quitBody.Size               = UDim2.new(0.9, 0, 0.25, 0)
quitBody.Position           = UDim2.new(0.05, 0, 0.27, 0)
quitBody.BackgroundTransparency = 1
quitBody.Text               = "Are you sure you want to leave?"
quitBody.TextColor3         = Color3.fromRGB(190, 190, 190)
quitBody.TextScaled         = true
quitBody.Font               = Enum.Font.Gotham
quitBody.TextWrapped        = true
quitBody.ZIndex             = 51
quitBody.Parent             = quitConfirm

-- YES button
local yesBtn = Instance.new("TextButton")
yesBtn.Size                 = UDim2.new(0.42, 0, 0.2, 0)
yesBtn.Position             = UDim2.new(0.05, 0, 0.72, 0)
yesBtn.BackgroundColor3     = Color3.fromRGB(180, 15, 15)
yesBtn.Text                 = "LEAVE"
yesBtn.TextColor3           = Color3.fromRGB(255, 255, 255)
yesBtn.TextScaled           = true
yesBtn.Font                 = Enum.Font.GothamBlack
yesBtn.BorderSizePixel      = 0
yesBtn.ZIndex               = 52
yesBtn.Parent               = quitConfirm

do
	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(0,0,0); s.Thickness = 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = yesBtn
end

-- NO button
local noBtn = Instance.new("TextButton")
noBtn.Size                  = UDim2.new(0.42, 0, 0.2, 0)
noBtn.Position              = UDim2.new(0.53, 0, 0.72, 0)
noBtn.BackgroundColor3      = Color3.fromRGB(30, 30, 30)
noBtn.Text                  = "CANCEL"
noBtn.TextColor3            = Color3.fromRGB(255, 255, 255)
noBtn.TextScaled            = true
noBtn.Font                  = Enum.Font.GothamBlack
noBtn.BorderSizePixel       = 0
noBtn.ZIndex                = 52
noBtn.Parent                = quitConfirm

do
	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(60,60,60); s.Thickness = 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = noBtn
end

-- Hover effects
yesBtn.MouseEnter:Connect(function() playHover() tween(yesBtn, { BackgroundColor3 = Color3.fromRGB(220, 30, 30) }, 0.1) end)
yesBtn.MouseLeave:Connect(function() tween(yesBtn, { BackgroundColor3 = Color3.fromRGB(180, 15, 15) }, 0.1) end)
noBtn.MouseEnter:Connect(function()  playHover() tween(noBtn,  { BackgroundColor3 = Color3.fromRGB(50, 50, 50)  }, 0.1) end)
noBtn.MouseLeave:Connect(function()  tween(noBtn,  { BackgroundColor3 = Color3.fromRGB(30, 30, 30)  }, 0.1) end)

local function closeQuitDialog()
	tween(quitConfirm, { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.6, 0) }, 0.2)
	task.wait(0.2)
	quitConfirm.Visible   = false
	quitConfirm.Position  = UDim2.new(0.5, 0, 0.5, 0)
end

noBtn.MouseButton1Click:Connect(closeQuitDialog)

yesBtn.MouseButton1Click:Connect(function()
	-- Kick the player back to Roblox home
	-- Works in a published game; in Studio it will print a warning which is fine
	local ok, err = pcall(function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, player)
	end)
	if not ok then
		-- Fallback for Studio testing
		print("[Quit] TeleportService not available in Studio. In a published game this exits to Roblox home.")
		closeQuitDialog()
	end
end)

-- ============================================================
-- COIN DISPLAY (bottom left)
-- ============================================================

local coinBadge = Instance.new("Frame")
coinBadge.Name = "CoinBadge"
coinBadge.Size = UDim2.new(0.14, 0, 0.07, 0)
coinBadge.Position = UDim2.new(0.02, 0, 0.88, 0)
coinBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
coinBadge.BorderSizePixel = 0
coinBadge.Rotation = -2
coinBadge.ZIndex = 10
coinBadge.Parent = screenGui

addStroke(coinBadge, CONFIG.accentYellow, 3)

local coinIcon = Instance.new("TextLabel")
coinIcon.Size = UDim2.new(0.25, 0, 1, 0)
coinIcon.Position = UDim2.new(0, 0, 0, 0)
coinIcon.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
coinIcon.Text = CONFIG.coinIcon
coinIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
coinIcon.TextScaled = true
coinIcon.Font = Enum.Font.GothamBlack
coinIcon.ZIndex = 11
coinIcon.Parent = coinBadge

local coinAmount = Instance.new("TextLabel")
coinAmount.Name = "CoinAmount"
coinAmount.Size = UDim2.new(0.72, 0, 1, 0)
coinAmount.Position = UDim2.new(0.26, 0, 0, 0)
coinAmount.BackgroundTransparency = 1
coinAmount.Text = tostring(CONFIG.coinStart)
coinAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
coinAmount.TextScaled = true
coinAmount.Font = Enum.Font.GothamBold
coinAmount.TextXAlignment = Enum.TextXAlignment.Right
coinAmount.ZIndex = 11
coinAmount.Parent = coinBadge

-- ============================================================
-- IMPACT FRAME EFFECT
-- Black frame expands from center then shrinks away for dramatic load
-- ============================================================

local impactFrame = Instance.new("Frame")
impactFrame.Name = "ImpactFrame"
impactFrame.Size = UDim2.new(0, 0, 0, 0)
impactFrame.AnchorPoint = Vector2.new(0.5, 0.5)
impactFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
impactFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
impactFrame.BorderSizePixel = 0
impactFrame.ZIndex = 100
impactFrame.Parent = screenGui

-- Expand the impact frame quickly
task.spawn(function()
	tween(impactFrame, { Size = UDim2.new(2, 0, 2, 0) }, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	task.wait(0.15)
	-- Then shrink it away to reveal the menu
	tween(impactFrame, { Size = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	task.wait(0.3)
	impactFrame:Destroy()
end)

-- ============================================================
-- ENTRANCE ANIMATION
-- Slabs fly in from the right one by one with a snap
-- ============================================================

-- First make sure they're all offscreen (already set in creation above)
-- Then stagger them in with short delays

task.wait(0.1)  -- tiny wait to make sure everything is parented

for i, item in ipairs(buttons) do
	-- Target resting position
	local targetPos = UDim2.new(0, 0, (i - 1) * (itemHeight + itemGap), 0)

	-- Delay each one slightly so they cascade in
	task.delay((i - 1) * 0.08, function()
		-- Snap in fast with a slight overshoot feel (Bounce or Back easing)
		local info = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local t = TweenService:Create(item.slab, info, { Position = targetPos })
		t:Play()
	end)
end

-- Also animate title flying in from above
titleContainer.Position = UDim2.new(0.595, 0, -0.25, 0)
titleContainer.BackgroundTransparency = 1
task.wait(0.05)
tween(titleContainer, { Position = UDim2.new(0.595, 0, 0.03, 0), BackgroundTransparency = 0 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Coin badge slides up from below
coinBadge.Position = UDim2.new(0.02, 0, 1.1, 0)
task.delay(0.5, function()
	tween(coinBadge, { Position = UDim2.new(0.02, 0, 0.88, 0) }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end)

-- ============================================================
-- PULSING RED BACKGROUND EFFECT
-- Subtle heartbeat-like pulse on the background color
-- ============================================================

task.spawn(function()
	while screenGui and screenGui.Parent do
		tween(background, { BackgroundColor3 = CONFIG.bgColorA }, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		task.wait(1.2)
		tween(background, { BackgroundColor3 = CONFIG.bgColorB }, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		task.wait(1.2)
	end
end)

print("[MainMenu] menu loaded successfully.")