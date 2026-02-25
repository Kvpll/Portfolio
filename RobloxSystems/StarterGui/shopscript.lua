-- ============================================================
-- SHOP SYSTEM
-- Place this LocalScript inside StarterGui
-- Slides in over the main menu when SHOP is clicked
-- ============================================================

-- ============================================================
--
--   ★ CUSTOMIZATION CONFIG — EDIT EVERYTHING HERE ★
--
-- ============================================================

local CONFIG = {

	-- SHOP TITLE
	shopTitle    = "SHOP",
	shopSubtitle = "ITEM SELECT",

	-- ACCENT COLORS (matches main menu)
	accentYellow = Color3.fromRGB(255, 220, 0),
	accentRed    = Color3.fromRGB(220, 20,  20),
	bgDark       = Color3.fromRGB(10,  10,  10),
	bgMid        = Color3.fromRGB(20,  20,  20),
	bgPanel      = Color3.fromRGB(15,  15,  15),

	-- TAB NAMES (order matters — first tab is selected by default)
	tabs = { "FEATURED", "GAMEPASSES", "CRATES", "ITEMS" },

	-- -------------------------------------------------------
	-- SHOP ITEMS
	-- Each item needs:
	--   name       = display name
	--   tab        = which tab it appears on (must match tabs list exactly)
	--   price      = cost in coins (use 0 for "FREE")
	--   currency   = "coins" or "robux"
	--   tag        = small badge label e.g. "NEW", "SALE", "POPULAR", "" for none
	--   tagColor   = color of the badge
	--   desc       = short description shown on the card
	--   color      = card accent color (the left stripe + icon bg)
	-- -------------------------------------------------------
	items = {
		-- FEATURED
		{
			name = "Starter Bundle", tab = "FEATURED", price = 199, currency = "robux",
			tag = "POPULAR", tagColor = Color3.fromRGB(255, 60, 60),
			desc = "Everything you need to get started.",
			color = Color3.fromRGB(255, 180, 0),
		},
		{
			name = "Double Coins", tab = "FEATURED", price = 99, currency = "robux",
			tag = "SALE", tagColor = Color3.fromRGB(80, 200, 80),
			desc = "Earn 2x coins from every match.",
			color = Color3.fromRGB(80, 200, 80),
		},
		{
			name = "VIP Pass", tab = "FEATURED", price = 499, currency = "robux",
			tag = "NEW", tagColor = Color3.fromRGB(100, 180, 255),
			desc = "Exclusive VIP badge and bonuses.",
			color = Color3.fromRGB(100, 180, 255),
		},
		{
			name = "Daily Gift", tab = "FEATURED", price = 0, currency = "coins",
			tag = "FREE", tagColor = Color3.fromRGB(255, 220, 0),
			desc = "Claim a free reward every day.",
			color = Color3.fromRGB(255, 220, 0),
		},

		-- GAMEPASSES
		{
			name = "VIP", tab = "GAMEPASSES", price = 499, currency = "robux",
			tag = "POPULAR", tagColor = Color3.fromRGB(255, 60, 60),
			desc = "Permanent VIP status and perks.",
			color = Color3.fromRGB(255, 180, 0),
		},
		{
			name = "2x Coins", tab = "GAMEPASSES", price = 99, currency = "robux",
			tag = "", tagColor = Color3.fromRGB(255, 220, 0),
			desc = "Permanently double your coin gain.",
			color = Color3.fromRGB(80, 200, 80),
		},
		{
			name = "Extra Lives", tab = "GAMEPASSES", price = 149, currency = "robux",
			tag = "", tagColor = Color3.fromRGB(255, 220, 0),
			desc = "Respawn one extra time per round.",
			color = Color3.fromRGB(200, 80, 255),
		},
		{
			name = "Speed Boost", tab = "GAMEPASSES", price = 99, currency = "robux",
			tag = "NEW", tagColor = Color3.fromRGB(100, 180, 255),
			desc = "Move 15% faster at all times.",
			color = Color3.fromRGB(100, 180, 255),
		},

		-- CRATES
		{
			name = "Common Crate", tab = "CRATES", price = 100, currency = "coins",
			tag = "", tagColor = Color3.fromRGB(255, 220, 0),
			desc = "Contains common and uncommon items.",
			color = Color3.fromRGB(150, 150, 150),
		},
		{
			name = "Rare Crate", tab = "CRATES", price = 500, currency = "coins",
			tag = "POPULAR", tagColor = Color3.fromRGB(255, 60, 60),
			desc = "Higher chance of rare drops.",
			color = Color3.fromRGB(80, 120, 255),
		},
		{
			name = "Epic Crate", tab = "CRATES", price = 1500, currency = "coins",
			tag = "", tagColor = Color3.fromRGB(255, 220, 0),
			desc = "Guaranteed rare or better item.",
			color = Color3.fromRGB(180, 80, 255),
		},
		{
			name = "Legendary Crate", tab = "CRATES", price = 299, currency = "robux",
			tag = "NEW", tagColor = Color3.fromRGB(100, 180, 255),
			desc = "Contains exclusive legendary items.",
			color = Color3.fromRGB(255, 180, 0),
		},

		-- ITEMS
		{
			name = "Health Potion", tab = "ITEMS", price = 50, currency = "coins",
			tag = "", tagColor = Color3.fromRGB(255, 220, 0),
			desc = "Restore 50 HP during a round.",
			color = Color3.fromRGB(255, 80, 80),
		},
		{
			name = "Shield", tab = "ITEMS", price = 80, currency = "coins",
			tag = "", tagColor = Color3.fromRGB(255, 220, 0),
			desc = "Block the next hit you receive.",
			color = Color3.fromRGB(80, 160, 255),
		},
		{
			name = "Coin Magnet", tab = "ITEMS", price = 120, currency = "coins",
			tag = "SALE", tagColor = Color3.fromRGB(80, 200, 80),
			desc = "Automatically collect nearby coins.",
			color = Color3.fromRGB(255, 220, 0),
		},
		{
			name = "XP Boost", tab = "ITEMS", price = 200, currency = "coins",
			tag = "", tagColor = Color3.fromRGB(255, 220, 0),
			desc = "Gain 1.5x XP for one match.",
			color = Color3.fromRGB(80, 220, 150),
		},
	},
}

-- ============================================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player.PlayerGui

-- ============================================================
-- WAIT FOR MAIN MENU GUI TO EXIST (shop lives alongside it)
-- ============================================================
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
local UserInputService = game:GetService("UserInputService")

-- Transition helper
local function getTransition()
	local tGui = playerGui:WaitForChild("TransitionGui", 10)
	if not tGui then return nil, nil end
	return tGui:WaitForChild("CoverFn", 5), tGui:WaitForChild("UncoverFn", 5)
end

-- Clean up any old shop
if playerGui:FindFirstChild("ShopGui") then
	playerGui.ShopGui:Destroy()
end

-- ============================================================
-- UTILITY
-- ============================================================

local function tween(obj, props, duration, style, direction)
	local t = TweenService:Create(obj,
		TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
		props)
	t:Play()
	return t
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(0,0,0)
	s.Thickness = thickness or 3
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function addCorner(parent, px)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px or 4)
	c.Parent = parent
	return c
end

local function addPadding(parent, top, bottom, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop    = UDim.new(0, top    or 0)
	p.PaddingBottom = UDim.new(0, bottom or 0)
	p.PaddingLeft   = UDim.new(0, left   or 0)
	p.PaddingRight  = UDim.new(0, right  or 0)
	p.Parent = parent
	return p
end

-- ============================================================
-- BUILD SCREENGUI
-- ============================================================

local shopGui = Instance.new("ScreenGui")
shopGui.Name = "ShopGui"
shopGui.ResetOnSpawn = false
shopGui.IgnoreGuiInset = true
shopGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
shopGui.Enabled = false   -- hidden until SHOP button is clicked
shopGui.Parent = playerGui

-- ============================================================
-- DARK OVERLAY (dims the main menu behind the shop)
-- ============================================================

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.4
overlay.BorderSizePixel = 0
overlay.ZIndex = 20
overlay.Parent = shopGui

-- ============================================================
-- MAIN SHOP PANEL (slides in from the right)
-- ============================================================

local panel = Instance.new("Frame")
panel.Name = "ShopPanel"
panel.Size = UDim2.new(0.72, 0, 0.88, 0)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.new(1.5, 0, 0.5, 0)   -- starts off screen right
panel.BackgroundColor3 = CONFIG.bgDark
panel.BorderSizePixel = 0
panel.ZIndex = 21
panel.Parent = shopGui

addStroke(panel, CONFIG.accentYellow, 3)
addCorner(panel, 0)

-- Diagonal red stripe across the top of the panel
local topStripe = Instance.new("Frame")
topStripe.Size = UDim2.new(1, 0, 0.008, 0)
topStripe.Position = UDim2.new(0, 0, 0.11, 0)
topStripe.BackgroundColor3 = CONFIG.accentRed
topStripe.BorderSizePixel = 0
topStripe.ZIndex = 22
topStripe.Parent = panel

-- ============================================================
-- SHOP HEADER (title box top-left of panel)
-- ============================================================

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(0.28, 0, 0.13, 0)
header.Position = UDim2.new(0.01, 0, 0.01, 0)
header.BackgroundColor3 = CONFIG.bgDark
header.BorderSizePixel = 0
header.Rotation = -2
header.ZIndex = 23
header.Parent = panel

addStroke(header, CONFIG.accentYellow, 3)

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -12, 0.6, 0)
headerTitle.Position = UDim2.new(0, 6, 0.02, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = CONFIG.shopTitle
headerTitle.TextColor3 = CONFIG.accentYellow
headerTitle.TextScaled = true
headerTitle.Font = Enum.Font.GothamBlack
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.ZIndex = 24
headerTitle.Parent = header

local headerSub = Instance.new("Frame")
headerSub.Size = UDim2.new(1, 0, 0.32, 0)
headerSub.Position = UDim2.new(0, 0, 0.68, 0)
headerSub.BackgroundColor3 = CONFIG.accentYellow
headerSub.BorderSizePixel = 0
headerSub.ZIndex = 24
headerSub.Parent = header

local headerSubLabel = Instance.new("TextLabel")
headerSubLabel.Size = UDim2.new(1, -8, 1, 0)
headerSubLabel.Position = UDim2.new(0, 4, 0, 0)
headerSubLabel.BackgroundTransparency = 1
headerSubLabel.Text = CONFIG.shopSubtitle
headerSubLabel.TextColor3 = CONFIG.bgDark
headerSubLabel.TextScaled = true
headerSubLabel.Font = Enum.Font.GothamBlack
headerSubLabel.ZIndex = 25
headerSubLabel.Parent = headerSub

-- CLOSE BUTTON (top right of panel)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0.07, 0, 0.08, 0)
closeBtn.Position = UDim2.new(0.92, 0, 0.01, 0)
closeBtn.BackgroundColor3 = CONFIG.bgMid
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 30
closeBtn.Parent = panel

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
-- TAB BAR
-- ============================================================

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(0.98, 0, 0.09, 0)
tabBar.Position = UDim2.new(0.01, 0, 0.12, 0)
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 22
tabBar.Parent = panel

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0.005, 0)
tabLayout.Parent = tabBar

local tabButtons = {}
local activeTab = CONFIG.tabs[1]

local function buildTabs()
	for i, tabName in ipairs(CONFIG.tabs) do
		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = "Tab_" .. tabName
		tabBtn.Size = UDim2.new(1 / #CONFIG.tabs, -4, 1, 0)
		tabBtn.BackgroundColor3 = CONFIG.bgMid
		tabBtn.Text = tabName
		tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		tabBtn.TextScaled = true
		tabBtn.Font = Enum.Font.GothamBlack
		tabBtn.BorderSizePixel = 0
		tabBtn.LayoutOrder = i
		tabBtn.ZIndex = 23
		tabBtn.Parent = tabBar

		-- Bottom accent line (yellow when active)
		local tabLine = Instance.new("Frame")
		tabLine.Name = "TabLine"
		tabLine.Size = UDim2.new(1, 0, 0.06, 0)
		tabLine.Position = UDim2.new(0, 0, 0.94, 0)
		tabLine.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		tabLine.BorderSizePixel = 0
		tabLine.ZIndex = 24
		tabLine.Parent = tabBtn

		tabButtons[tabName] = { btn = tabBtn, line = tabLine }

		tabBtn.MouseEnter:Connect(function()
			if activeTab ~= tabName then
				playHover()
				tween(tabBtn, { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }, 0.1)
				tween(tabBtn, { TextColor3 = Color3.fromRGB(230, 230, 230) }, 0.1)
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if activeTab ~= tabName then
				tween(tabBtn, { BackgroundColor3 = CONFIG.bgMid }, 0.1)
				tween(tabBtn, { TextColor3 = Color3.fromRGB(180, 180, 180) }, 0.1)
			end
		end)
	end
end

buildTabs()

-- ============================================================
-- ITEM GRID (scrollable)
-- ============================================================

local gridFrame = Instance.new("ScrollingFrame")
gridFrame.Name = "ItemGrid"
gridFrame.Size = UDim2.new(0.98, 0, 0.75, 0)
gridFrame.Position = UDim2.new(0.01, 0, 0.22, 0)
gridFrame.BackgroundTransparency = 1
gridFrame.BorderSizePixel = 0
gridFrame.ScrollBarThickness = 4
gridFrame.ScrollBarImageColor3 = CONFIG.accentYellow
gridFrame.CanvasSize = UDim2.new(0, 0, 0, 0)   -- auto-set later
gridFrame.ZIndex = 22
gridFrame.Parent = panel

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 0, 0, 0)    -- overridden below
gridLayout.CellPadding = UDim2.new(0.01, 0, 0.015, 0)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = gridFrame

addPadding(gridFrame, 8, 8, 8, 8)

-- ============================================================
-- PURCHASE CONFIRMATION POPUP
-- ============================================================

local confirmPopup = Instance.new("Frame")
confirmPopup.Name = "ConfirmPopup"
confirmPopup.Size = UDim2.new(0.4, 0, 0.35, 0)
confirmPopup.AnchorPoint = Vector2.new(0.5, 0.5)
confirmPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
confirmPopup.BackgroundColor3 = CONFIG.bgDark
confirmPopup.BorderSizePixel = 0
confirmPopup.ZIndex = 50
confirmPopup.Visible = false
confirmPopup.Parent = shopGui

addStroke(confirmPopup, CONFIG.accentYellow, 3)

-- Red top bar
local popupTopBar = Instance.new("Frame")
popupTopBar.Size = UDim2.new(1, 0, 0.22, 0)
popupTopBar.BackgroundColor3 = CONFIG.accentRed
popupTopBar.BorderSizePixel = 0
popupTopBar.ZIndex = 51
popupTopBar.Parent = confirmPopup

local popupTitle = Instance.new("TextLabel")
popupTitle.Size = UDim2.new(1, -16, 1, 0)
popupTitle.Position = UDim2.new(0, 8, 0, 0)
popupTitle.BackgroundTransparency = 1
popupTitle.Text = "CONFIRM PURCHASE"
popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popupTitle.TextScaled = true
popupTitle.Font = Enum.Font.GothamBlack
popupTitle.ZIndex = 52
popupTitle.Parent = popupTopBar

local popupItemName = Instance.new("TextLabel")
popupItemName.Name = "ItemName"
popupItemName.Size = UDim2.new(0.9, 0, 0.22, 0)
popupItemName.Position = UDim2.new(0.05, 0, 0.25, 0)
popupItemName.BackgroundTransparency = 1
popupItemName.Text = ""
popupItemName.TextColor3 = CONFIG.accentYellow
popupItemName.TextScaled = true
popupItemName.Font = Enum.Font.GothamBlack
popupItemName.ZIndex = 52
popupItemName.Parent = confirmPopup

local popupPrice = Instance.new("TextLabel")
popupPrice.Name = "Price"
popupPrice.Size = UDim2.new(0.9, 0, 0.15, 0)
popupPrice.Position = UDim2.new(0.05, 0, 0.47, 0)
popupPrice.BackgroundTransparency = 1
popupPrice.Text = ""
popupPrice.TextColor3 = Color3.fromRGB(200, 200, 200)
popupPrice.TextScaled = true
popupPrice.Font = Enum.Font.GothamBold
popupPrice.ZIndex = 52
popupPrice.Parent = confirmPopup

-- Confirm button
local confirmBtn = Instance.new("TextButton")
confirmBtn.Name = "ConfirmBtn"
confirmBtn.Size = UDim2.new(0.42, 0, 0.18, 0)
confirmBtn.Position = UDim2.new(0.05, 0, 0.76, 0)
confirmBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
confirmBtn.Text = "BUY"
confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmBtn.TextScaled = true
confirmBtn.Font = Enum.Font.GothamBlack
confirmBtn.BorderSizePixel = 0
confirmBtn.ZIndex = 52
confirmBtn.Parent = confirmPopup

addStroke(confirmBtn, CONFIG.bgDark, 2)

-- Cancel button
local cancelBtn = Instance.new("TextButton")
cancelBtn.Name = "CancelBtn"
cancelBtn.Size = UDim2.new(0.42, 0, 0.18, 0)
cancelBtn.Position = UDim2.new(0.53, 0, 0.76, 0)
cancelBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
cancelBtn.Text = "CANCEL"
cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cancelBtn.TextScaled = true
cancelBtn.Font = Enum.Font.GothamBlack
cancelBtn.BorderSizePixel = 0
cancelBtn.ZIndex = 52
cancelBtn.Parent = confirmPopup

addStroke(cancelBtn, CONFIG.bgDark, 2)

-- ============================================================
-- ITEM CARD BUILDER
-- ============================================================

-- Figures out the right label for the price
local function priceText(item)
	if item.price == 0 then return "FREE" end
	if item.currency == "robux" then
		return "R$ " .. tostring(item.price)
	else
		return "G " .. tostring(item.price)   -- G for Gold/coins, no emoji
	end
end

local function buildCard(item, index)
	local card = Instance.new("TextButton")
	card.Name = "Card_" .. item.name
	card.Size = UDim2.new(0, 0, 0, 0)   -- controlled by UIGridLayout
	card.BackgroundColor3 = CONFIG.bgPanel
	card.Text = ""
	card.BorderSizePixel = 0
	card.LayoutOrder = index
	card.AutoButtonColor = false
	card.ZIndex = 23
	card.Parent = gridFrame

	addStroke(card, Color3.fromRGB(40, 40, 40), 2)

	-- Left accent stripe
	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(0.025, 0, 1, 0)
	stripe.BackgroundColor3 = item.color
	stripe.BorderSizePixel = 0
	stripe.ZIndex = 24
	stripe.Parent = card

	-- Icon area (colored square top portion)
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0.975, 0, 0.48, 0)
	iconBg.Position = UDim2.new(0.025, 0, 0, 0)
	iconBg.BackgroundColor3 = item.color
	iconBg.BackgroundTransparency = 0.82
	iconBg.BorderSizePixel = 0
	iconBg.ZIndex = 24
	iconBg.Parent = card

	-- Icon letter (first letter of item name, big and bold)
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0.5, 0, 0.8, 0)
	iconLabel.Position = UDim2.new(0.25, 0, 0.1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = string.upper(string.sub(item.name, 1, 1))
	iconLabel.TextColor3 = item.color
	iconLabel.TextScaled = true
	iconLabel.Font = Enum.Font.GothamBlack
	iconLabel.ZIndex = 25
	iconLabel.Parent = iconBg

	-- Tag badge (e.g. "NEW", "SALE") — only shown if tag is not empty
	if item.tag ~= "" then
		local tag = Instance.new("Frame")
		tag.Size = UDim2.new(0.42, 0, 0.28, 0)
		tag.Position = UDim2.new(0.53, 0, 0.04, 0)
		tag.BackgroundColor3 = item.tagColor
		tag.BorderSizePixel = 0
		tag.ZIndex = 26
		tag.Parent = iconBg

		addCorner(tag, 2)

		local tagLabel = Instance.new("TextLabel")
		tagLabel.Size = UDim2.new(1, -4, 1, 0)
		tagLabel.Position = UDim2.new(0, 2, 0, 0)
		tagLabel.BackgroundTransparency = 1
		tagLabel.Text = item.tag
		tagLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		tagLabel.TextScaled = true
		tagLabel.Font = Enum.Font.GothamBlack
		tagLabel.ZIndex = 27
		tagLabel.Parent = tag
	end

	-- Item name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.95, 0, 0.22, 0)
	nameLabel.Position = UDim2.new(0.03, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 25
	nameLabel.Parent = card

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.95, 0, 0.16, 0)
	descLabel.Position = UDim2.new(0.03, 0, 0.7, 0)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = item.desc
	descLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
	descLabel.TextScaled = true
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 25
	descLabel.Parent = card

	-- Price label (bottom right)
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0.6, 0, 0.16, 0)
	priceLabel.Position = UDim2.new(0.37, 0, 0.83, 0)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = priceText(item)
	priceLabel.TextColor3 = item.price == 0 and Color3.fromRGB(80, 220, 80) or CONFIG.accentYellow
	priceLabel.TextScaled = true
	priceLabel.Font = Enum.Font.GothamBlack
	priceLabel.TextXAlignment = Enum.TextXAlignment.Right
	priceLabel.ZIndex = 25
	priceLabel.Parent = card

	-- -------------------------------------------------------
	-- CARD HOVER + CLICK
	-- -------------------------------------------------------
	local originalColor = CONFIG.bgPanel

	card.MouseEnter:Connect(function()
		playHover()
		tween(card, { BackgroundColor3 = Color3.fromRGB(28, 28, 28) }, 0.1)
		tween(stripe, { BackgroundColor3 = CONFIG.accentYellow }, 0.1)
	end)

	card.MouseLeave:Connect(function()
		tween(card, { BackgroundColor3 = originalColor }, 0.15)
		tween(stripe, { BackgroundColor3 = item.color }, 0.15)
	end)

	card.MouseButton1Click:Connect(function()
		playClick()
		doRipple()
		-- Flash
		tween(card, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) }, 0.05)
		task.wait(0.08)
		tween(card, { BackgroundColor3 = Color3.fromRGB(28, 28, 28) }, 0.1)

		-- Show confirm popup
		popupItemName.Text = item.name
		popupPrice.Text = "Price: " .. priceText(item)
		confirmPopup.Visible = true
		confirmPopup.BackgroundTransparency = 1
		confirmPopup.Position = UDim2.new(0.5, 0, 0.4, 0)
		tween(confirmPopup, { BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		-- Wire confirm button for this item
		local confirmConn, cancelConn

		confirmConn = confirmBtn.MouseButton1Click:Connect(function()
			confirmConn:Disconnect()
			cancelConn:Disconnect()

			-- Close popup
			tween(confirmPopup, { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.6, 0) }, 0.2)
			task.wait(0.2)
			confirmPopup.Visible = false

			-- -----------------------------------------------
			-- PURCHASE LOGIC GOES HERE
			-- For Robux items: use MarketplaceService:PromptGamePassPurchase()
			-- For coin items: fire a RemoteEvent to the server to deduct coins
			-- -----------------------------------------------
			if item.currency == "robux" then
				print("[SHOP] Player wants to buy Robux item: " .. item.name .. " for R$" .. item.price)
				-- Example (replace 000000 with your real gamepass ID):
				-- game:GetService("MarketplaceService"):PromptGamePassPurchase(player, YOUR_GAMEPASS_ID)
			else
				print("[SHOP] Player wants to buy coin item: " .. item.name .. " for " .. item.price .. " coins")
				-- Example:
				-- game.ReplicatedStorage.PurchaseItem:FireServer(item.name, item.price)
			end
		end)

		cancelConn = cancelBtn.MouseButton1Click:Connect(function()
			confirmConn:Disconnect()
			cancelConn:Disconnect()
			tween(confirmPopup, { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.6, 0) }, 0.2)
			task.wait(0.2)
			confirmPopup.Visible = false
		end)
	end)

	return card
end

-- ============================================================
-- TAB SWITCHING LOGIC
-- Clears the grid and rebuilds it with only items for that tab
-- ============================================================

-- Cell size is fixed at script load time (not during tab switch)
-- This avoids AbsoluteSize returning 0 and causing layout thrashing
-- 3 columns, panel is 72% of screen width, grid is 98% of panel, minus padding
local COLS = 3
local CELL_W = 0  -- set once panel is on screen
local CELL_H = 0

local function computeCellSize()
	-- Only compute once AbsoluteSize is available (non-zero)
	local gw = gridFrame.AbsoluteSize.X
	if gw < 10 then
		-- Fallback: estimate based on a 1280px screen at 72% panel, 98% grid, minus 16px padding
		gw = math.floor(1280 * 0.72 * 0.98) - 16
	end
	CELL_W = math.floor((gw - 32) / COLS)
	CELL_H = math.floor(CELL_W * 1.15)
	gridLayout.CellSize = UDim2.new(0, CELL_W, 0, CELL_H)
end

local function setActiveTab(tabName)
	activeTab = tabName

	-- Update tab button visuals instantly (no tween needed here, keeps it snappy)
	for name, tabData in pairs(tabButtons) do
		if name == tabName then
			tabData.btn.BackgroundColor3 = CONFIG.bgDark
			tabData.btn.TextColor3 = CONFIG.accentYellow
			tabData.line.BackgroundColor3 = CONFIG.accentYellow
		else
			tabData.btn.BackgroundColor3 = CONFIG.bgMid
			tabData.btn.TextColor3 = Color3.fromRGB(180, 180, 180)
			tabData.line.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		end
	end

	-- Hide grid during rebuild so there's no flash
	gridFrame.Visible = false
	for _, child in ipairs(gridFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	-- Compute cell size if not done yet
	if CELL_W == 0 then computeCellSize() end

	-- Build new cards
	local count = 0
	for i, item in ipairs(CONFIG.items) do
		if item.tab == tabName then
			count += 1
			buildCard(item, count)
		end
	end

	-- Update canvas height
	local rows = math.ceil(count / COLS)
	gridFrame.CanvasSize = UDim2.new(0, 0, 0, rows * (CELL_H + 14) + 16)
	gridFrame.CanvasPosition = Vector2.new(0, 0)

	-- Show grid again
	gridFrame.Visible = true
end

-- Wire tab buttons
for _, tabName in ipairs(CONFIG.tabs) do
	tabButtons[tabName].btn.MouseButton1Click:Connect(function()
		playClick()
		doRipple()
		setActiveTab(tabName)
	end)
end

-- ============================================================
-- OPEN / CLOSE SHOP FUNCTIONS
-- Call openShop() from the main menu SHOP button
-- ============================================================

local function closeShop()
	-- Cover screen so player never sees the bare world during swap
	local coverFn, uncoverFn = getTransition()
	if coverFn then coverFn:Invoke() end

	-- Instantly hide shop behind the cover
	shopGui.Enabled = false
	panel.Position  = UDim2.new(1.5, 0, 0.5, 0)
	overlay.BackgroundTransparency = 1

	-- Re-enable main menu
	if mainMenuGui then mainMenuGui.Enabled = true end

	-- Fade cover out revealing the main menu
	if uncoverFn then uncoverFn:Invoke(0.35) end
end

local function openShop()
	-- Cover screen during swap
	local coverFn, uncoverFn = getTransition()
	if coverFn then coverFn:Invoke() end

	-- Set up shop behind the cover
	shopGui.Enabled                = true
	overlay.BackgroundTransparency = 0.4
	panel.Position                 = UDim2.new(0.5, 0, 0.5, 0)
	CELL_W = 0
	task.wait(0.05)
	setActiveTab(CONFIG.tabs[1])

	-- Reveal shop
	playWhoosh()
	if uncoverFn then uncoverFn:Invoke(0.35) end
end

closeBtn.MouseButton1Click:Connect(closeShop)

-- ============================================================
-- HOOK INTO MAIN MENU SHOP BUTTON
-- Finds the ShopButton inside the main menu and connects to it
-- ============================================================

task.spawn(function()
	if mainMenuGui then
		local mainFrame = mainMenuGui:FindFirstChild("MainFrame")
		-- The shop button is inside MenuContainer in our procedural menu
		-- We search the whole GUI for it
		local function findShopButton(parent)
			for _, child in ipairs(parent:GetChildren()) do
				if child.Name == "Slab_SHOP" then
					local btn = child:FindFirstChild("Button")
					if btn then return btn end
				end
				local found = findShopButton(child)
				if found then return found end
			end
		end

		local shopBtn = findShopButton(mainMenuGui)
		if shopBtn then
			shopBtn.MouseButton1Click:Connect(function()
				openShop()
			end)
			print("[ShopGui] Successfully hooked into main menu SHOP button.")
		else
			print("[ShopGui] Could not find SHOP button in main menu. Call openShop() manually.")
		end
	end
end)

-- ============================================================
-- PUBLIC API
-- Other scripts can call these via a BindableFunction if needed
-- ============================================================
-- To open from another script:
--   local shopGui = player.PlayerGui:WaitForChild("ShopGui")
--   -- (you'd use a BindableEvent for cross-script calls)

-- Expose open function so MainMenu can call it directly
local openShopFn = Instance.new("BindableFunction")
openShopFn.Name     = "OpenShopFn"
openShopFn.OnInvoke = openShop
openShopFn.Parent   = shopGui

print("[ShopGui] shop loaded.")