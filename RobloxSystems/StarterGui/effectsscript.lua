-- ============================================================
-- UI EFFECTS MODULE
-- Place this LocalScript inside StarterGui, name it EffectsScript
-- Runs once on load and provides shared effects for all other scripts
-- via BindableFunctions stored in a folder in PlayerGui
--
-- EFFECTS PROVIDED:
--   Ripple(parent, x, y)         -- click ripple at screen position x,y
--   CountUp(label, target, dur)  -- animate a number label from 0 to target
--   PlayClick()                  -- short UI click sound
--   PlayWhoosh()                 -- transition whoosh sound
--   PlayHover()                  -- subtle hover tick sound
-- ============================================================

-- ============================================================
--   ★ CONFIG ★
-- ============================================================

local CONFIG = {
	-- SCANLINES
	-- Tiling horizontal line texture. Using a simple Roblox stripe asset.
	-- You can replace with your own uploaded texture ID.
	scanlineTransparency = 0.93,   -- lower = more visible, higher = subtler

	-- PARTICLES
	particleCount    = 18,         -- how many particles drift at once
	particleMinSize  = 2,          -- minimum pixel size
	particleMaxSize  = 6,          -- maximum pixel size
	particleMinSpeed = 18,         -- pixels per second (slow drift)
	particleMaxSpeed = 40,
	particleColor    = Color3.fromRGB(255, 80, 80),  -- red tint to match bg
	particleAlphaMin = 0.82,       -- most transparent
	particleAlphaMax = 0.65,       -- least transparent

	-- RIPPLE
	rippleColor      = Color3.fromRGB(255, 255, 255),
	rippleAlpha      = 0.35,       -- starting transparency (lower = more visible)
	rippleDuration   = 0.45,
	rippleMaxSize    = 120,        -- pixel diameter at full expansion

	-- SOUNDS
	-- Free Roblox audio asset IDs — replace with your own if desired
	clickSoundId  = "rbxassetid://6042053626",   -- short click
	hoverSoundId  = "rbxassetid://6042053626",   -- reuse click at lower vol for hover
	whooshSoundId = "rbxassetid://4612418536",   -- whoosh
	clickVolume   = 0.4,
	hoverVolume   = 0.15,
	whooshVolume  = 0.55,
}

-- ============================================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

local player    = Players.LocalPlayer
local playerGui = player.PlayerGui

-- Clean up
if playerGui:FindFirstChild("EffectsFolder") then
	playerGui.EffectsFolder:Destroy()
end

-- Folder to hold BindableFunctions so other scripts can call effects
local folder = Instance.new("Folder")
folder.Name   = "EffectsFolder"
folder.Parent = playerGui

local function tw(obj, props, dur, style, dir)
	local t = TweenService:Create(obj,
		TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
		props)
	t:Play()
	return t
end

-- ============================================================
-- SOUNDS
-- Pre-create Sound objects so they're ready instantly
-- ============================================================

local function makeSound(id, vol, parent)
	local s = Instance.new("Sound")
	s.SoundId          = id
	s.Volume           = vol
	s.RollOffMaxDistance = 0
	s.Parent           = parent or playerGui
	return s
end

local clickSound = makeSound(CONFIG.clickSoundId,  CONFIG.clickVolume,  folder)
local hoverSound = makeSound(CONFIG.hoverSoundId,  CONFIG.hoverVolume,  folder)
local whooshSound = makeSound(CONFIG.whooshSoundId, CONFIG.whooshVolume, folder)
clickSound.Name  = "ClickSound"
hoverSound.Name  = "HoverSound"
whooshSound.Name = "WhooshSound"

local function playClick()
	-- Clone and play so overlapping clicks don't cut each other off
	local c = clickSound:Clone()
	c.Parent = folder
	c:Play()
	game:GetService("Debris"):AddItem(c, 2)
end

local function playHover()
	local c = hoverSound:Clone()
	c.Parent = folder
	c:Play()
	game:GetService("Debris"):AddItem(c, 2)
end

local function playWhoosh()
	local c = whooshSound:Clone()
	c.Parent = folder
	c:Play()
	game:GetService("Debris"):AddItem(c, 3)
end

-- ============================================================
-- SCANLINE OVERLAY
-- A full-screen ImageLabel with a tiling stripe pattern
-- sits at DisplayOrder 998 (just below the TransitionGui)
-- ============================================================

local scanGui = Instance.new("ScreenGui")
scanGui.Name            = "ScanlineGui"
scanGui.ResetOnSpawn    = false
scanGui.IgnoreGuiInset  = true
scanGui.DisplayOrder    = 998
scanGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
scanGui.Parent          = playerGui

local scanline = Instance.new("ImageLabel")
scanline.Name                = "Scanline"
scanline.Size                = UDim2.new(1, 0, 1, 0)
scanline.BackgroundTransparency = 1
scanline.BorderSizePixel     = 0
-- This is a Roblox-provided tiling noise/scanline texture.
-- Replace with your own uploaded noise texture for best results.
-- rbxassetid://2454780994 is a subtle diagonal noise pattern.
scanline.Image               = "rbxassetid://2454780994"
scanline.ScaleType           = Enum.ScaleType.Tile
scanline.TileSize            = UDim2.new(0, 128, 0, 128)
scanline.ImageTransparency   = CONFIG.scanlineTransparency
scanline.ZIndex              = 5
scanline.Parent              = scanGui

-- Subtle slow drift on the scanline texture to give it life
task.spawn(function()
	local offset = 0
	while scanGui and scanGui.Parent do
		offset = (offset + 0.15) % 128
		scanline.TileSize = UDim2.new(0, 128, 0, 128)
		RunService.Heartbeat:Wait()
	end
end)

-- ============================================================
-- PARTICLE SYSTEM
-- Small semi-transparent dots drift diagonally across the screen
-- They loop: when one goes off the right/bottom edge it resets
-- ============================================================

local particleGui = Instance.new("ScreenGui")
particleGui.Name           = "ParticleGui"
particleGui.ResetOnSpawn   = false
particleGui.IgnoreGuiInset = true
particleGui.DisplayOrder   = 2    -- just above the background, below UI
particleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
particleGui.Parent         = playerGui

local function randomFloat(a, b)
	return a + math.random() * (b - a)
end

-- Each particle is a plain Frame (square dot)
local particles = {}

for i = 1, CONFIG.particleCount do
	local size = math.random(CONFIG.particleMinSize, CONFIG.particleMaxSize)
	local p = Instance.new("Frame")
	p.Name               = "Particle_" .. i
	p.Size               = UDim2.new(0, size, 0, size)
	p.Position           = UDim2.new(math.random(), 0, math.random(), 0)  -- random start
	p.BackgroundColor3   = CONFIG.particleColor
	p.BackgroundTransparency = randomFloat(CONFIG.particleAlphaMin, CONFIG.particleAlphaMax)
	p.BorderSizePixel    = 0
	p.ZIndex             = 3
	p.Rotation           = math.random(0, 45)
	p.Parent             = particleGui

	particles[i] = {
		frame   = p,
		speed   = randomFloat(CONFIG.particleMinSpeed, CONFIG.particleMaxSpeed),
		xDrift  = randomFloat(-8, 8),   -- slight horizontal drift
		posX    = math.random(),
		posY    = math.random(),
	}
end

-- Drive particles every frame using RunService.Heartbeat
RunService.Heartbeat:Connect(function(dt)
	if not particleGui or not particleGui.Parent then return end
	for _, p in ipairs(particles) do
		-- Move diagonally (mostly downward, slight right drift)
		p.posY = p.posY + (p.speed * dt) / 600
		p.posX = p.posX + (p.xDrift * dt) / 600

		-- Reset when it drifts off the bottom or far right
		if p.posY > 1.05 or p.posX > 1.05 then
			p.posY  = -0.05
			p.posX  = math.random()
			local newSize = math.random(CONFIG.particleMinSize, CONFIG.particleMaxSize)
			p.frame.Size = UDim2.new(0, newSize, 0, newSize)
			p.speed  = randomFloat(CONFIG.particleMinSpeed, CONFIG.particleMaxSpeed)
			p.xDrift = randomFloat(-8, 8)
		end

		p.frame.Position = UDim2.new(p.posX, 0, p.posY, 0)
	end
end)

-- ============================================================
-- RIPPLE EFFECT
-- Called with a parent ScreenGui and the click X,Y in screen coords
-- Creates an expanding circle that fades out then destroys itself
-- ============================================================

local rippleGui = Instance.new("ScreenGui")
rippleGui.Name           = "RippleGui"
rippleGui.ResetOnSpawn   = false
rippleGui.IgnoreGuiInset = true
rippleGui.DisplayOrder   = 997   -- below transition, above everything else
rippleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
rippleGui.Parent         = playerGui

local function spawnRipple(screenX, screenY)
	local ripple = Instance.new("Frame")
	ripple.Name              = "Ripple"
	ripple.Size              = UDim2.new(0, 0, 0, 0)
	ripple.AnchorPoint       = Vector2.new(0.5, 0.5)
	ripple.Position          = UDim2.new(0, screenX, 0, screenY)
	ripple.BackgroundColor3  = CONFIG.rippleColor
	ripple.BackgroundTransparency = CONFIG.rippleAlpha
	ripple.BorderSizePixel   = 0
	ripple.ZIndex            = 5
	ripple.Parent            = rippleGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)   -- makes it a circle
	corner.Parent = ripple

	-- Expand outward and fade simultaneously
	tw(ripple,
		{ Size = UDim2.new(0, CONFIG.rippleMaxSize, 0, CONFIG.rippleMaxSize),
			BackgroundTransparency = 1 },
		CONFIG.rippleDuration,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.Out
	)

	game:GetService("Debris"):AddItem(ripple, CONFIG.rippleDuration + 0.1)
end

-- ============================================================
-- COUNT UP ANIMATION
-- Animates a TextLabel's text from 0 up to a target number
-- Handles comma-formatted numbers like "1,204"
-- ============================================================

local function countUp(label, targetStr, duration)
	-- Strip commas and parse the raw number
	local raw = tostring(targetStr):gsub(",", "")
	local target = tonumber(raw)
	if not target then
		label.Text = targetStr
		return
	end

	duration = duration or 0.8
	local startTime = tick()

	-- Check if original had commas so we format the output the same way
	local function formatNum(n)
		local s = tostring(math.floor(n))
		-- Insert commas every 3 digits from the right
		local result = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
		-- Remove leading comma if present
		result = result:gsub("^,", "")
		return result
	end

	task.spawn(function()
		while true do
			local elapsed = tick() - startTime
			local progress = math.min(elapsed / duration, 1)
			-- Ease out quad so it slows down at the end
			local eased = 1 - (1 - progress) ^ 2
			local current = math.floor(eased * target)
			label.Text = formatNum(current)
			if progress >= 1 then break end
			RunService.Heartbeat:Wait()
		end
		label.Text = formatNum(target)
	end)
end

-- ============================================================
-- EXPOSE ALL EFFECTS VIA BINDABLE FUNCTIONS
-- Other scripts call: playerGui.EffectsFolder.RippleFn:Invoke(x, y)
-- ============================================================

-- Use UserInputService:GetMouseLocation() for accurate screen coords.
-- This returns Vector2 in absolute screen space matching IgnoreGuiInset=true,
-- so the ripple always appears exactly where the cursor is.
local UserInputService = game:GetService("UserInputService")
local GuiService       = game:GetService("GuiService")

local rippleFn = Instance.new("BindableFunction")
rippleFn.Name   = "RippleFn"
rippleFn.OnInvoke = function()
	-- Ignore passed x,y — always sample the real mouse position
	local pos = UserInputService:GetMouseLocation()
	spawnRipple(pos.X, pos.Y)
end
rippleFn.Parent = folder

local countUpFn = Instance.new("BindableFunction")
countUpFn.Name   = "CountUpFn"
countUpFn.OnInvoke = function(label, targetStr, duration)
	countUp(label, targetStr, duration)
end
countUpFn.Parent = folder

local clickFn = Instance.new("BindableFunction")
clickFn.Name     = "ClickFn"
clickFn.OnInvoke = playClick
clickFn.Parent   = folder

local hoverFn = Instance.new("BindableFunction")
hoverFn.Name     = "HoverFn"
hoverFn.OnInvoke = playHover
hoverFn.Parent   = folder

local whooshFn = Instance.new("BindableFunction")
whooshFn.Name     = "WhooshFn"
whooshFn.OnInvoke = playWhoosh
whooshFn.Parent   = folder

-- ============================================================
-- HELPER: wires all effects onto a button automatically
-- Call attachButtonEffects(btn) on any TextButton to get
-- hover sound, click sound, and ripple for free
-- ============================================================

local function attachButtonEffects(btn)
	btn.MouseEnter:Connect(function()
		playHover()
	end)
	btn.MouseButton1Click:Connect(function()
		playClick()
		local pos = UserInputService:GetMouseLocation()
		spawnRipple(pos.X, pos.Y)
	end)
end

-- Expose as a BindableFunction too
local attachFn = Instance.new("BindableFunction")
attachFn.Name     = "AttachButtonFx"
attachFn.OnInvoke = attachButtonEffects
attachFn.Parent   = folder

print("[EffectsScript] Loaded. Scanlines, particles, ripple, countup, sounds ready.")