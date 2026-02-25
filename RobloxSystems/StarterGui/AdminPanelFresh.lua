-- AdminPanel LocalScript (place in StarterGui)
-- Redesigned with main menu aesthetic (red/black/yellow)
-- Allows the game owner to toggle systems

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Colors
local COLORS = {
    accentYellow = Color3.fromRGB(255, 220, 0),
    accentRed    = Color3.fromRGB(220, 20,  20),
    bgDark       = Color3.fromRGB(10,  10,  10),
    bgCard       = Color3.fromRGB(20,  20,  20),
}

local function isAdmin()
    return player.UserId == game.CreatorId
end

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
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(0, 0, 0)
    stroke.Thickness = thickness or 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

if not isAdmin() then return end

-- ============================================================
-- CREATE SCREEN GUI WITH NEW STYLE
-- ============================================================

if playerGui:FindFirstChild("AdminPanel") then
    playerGui.AdminPanel:Destroy()
end

local screen = Instance.new("ScreenGui")
screen.Name = "AdminPanel"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = playerGui

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.22, 0, 0.45, 0)
frame.Position = UDim2.new(0.01, 0, 0.01, 0)
frame.BackgroundColor3 = COLORS.bgDark
frame.BorderSizePixel = 0
frame.ZIndex = 10
frame.Parent = screen

addStroke(frame, COLORS.accentYellow, 3)
addCorner(frame, 8)

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0.12, 0)
titleBar.BackgroundColor3 = COLORS.accentRed
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 11
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚙ ADMIN"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.ZIndex = 12
title.Parent = titleBar

-- Content container
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, 0, 0.88, 0)
contentFrame.Position = UDim2.new(0, 0, 0.12, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 4
contentFrame.ScrollBarImageColor3 = COLORS.accentRed
contentFrame.CanvasSize = UDim2.new(1, 0, 0, 0)
contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentFrame.ZIndex = 10
contentFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.Parent = contentFrame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = contentFrame

-- ============================================================
-- CREATE SYSTEM BUTTONS
-- ============================================================

local statusLabels = {}
local buttons = {}
local systems = {"Health", "Inventory", "Leveling"}

for i, systemName in ipairs(systems) do
    -- System container
    local systemContainer = Instance.new("Frame")
    systemContainer.Size = UDim2.new(1, 0, 0, 55)
    systemContainer.BackgroundColor3 = COLORS.bgCard
    systemContainer.BorderSizePixel = 0
    systemContainer.ZIndex = 11
    systemContainer.Parent = contentFrame

    addStroke(systemContainer, COLORS.accentYellow, 1)
    addCorner(systemContainer, 4)

    -- System name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.55, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0.08, 0, 0.06, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = systemName
    nameLabel.TextColor3 = COLORS.accentYellow
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.TextScaled = true
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 12
    nameLabel.Parent = systemContainer

    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0.2, 0, 0.4, 0)
    statusLabel.Position = UDim2.new(0.7, 0, 0.06, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "OFF"
    statusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextScaled = true
    statusLabel.ZIndex = 12
    statusLabel.Parent = systemContainer

    statusLabels[systemName] = statusLabel

    -- Toggle button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.84, 0, 0.45, 0)
    btn.Position = UDim2.new(0.08, 0, 0.5, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = "Toggle"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.Parent = systemContainer

    addStroke(btn, COLORS.accentYellow, 1)
    addCorner(btn, 3)

    buttons[systemName] = btn

    -- Hover effects
    btn.MouseEnter:Connect(function()
        tween(btn, { BackgroundColor3 = Color3.fromRGB(80, 80, 80) }, 0.1)
    end)

    btn.MouseLeave:Connect(function()
        tween(btn, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) }, 0.1)
    end)

    btn.MouseButton1Click:Connect(function()
        local events = ReplicatedStorage:WaitForChild("Events")
        local settings = ReplicatedStorage:FindFirstChild("Settings")
        local current = false
        if settings and settings:FindFirstChild(systemName.."Enabled") then
            current = settings:FindFirstChild(systemName.."Enabled").Value
        end
        local newState = not current
        events.AdminToggle:FireServer(systemName, newState)
        
        -- Update UI immediately for feedback
        task.wait(0.1)
        local v = settings and settings:FindFirstChild(systemName.."Enabled")
        if v then
            local lbl = statusLabels[systemName]
            if v.Value then
                lbl.Text = "ON"
                tween(lbl, { TextColor3 = Color3.fromRGB(80, 220, 80) }, 0.2)
            else
                lbl.Text = "OFF"
                tween(lbl, { TextColor3 = Color3.fromRGB(220, 80, 80) }, 0.2)
            end
        end
    end)
end

-- ============================================================
-- UPDATE DISPLAY FUNCTION
-- ============================================================

local function refresh()
    local settings = ReplicatedStorage:FindFirstChild("Settings")
    if not settings then return end
    for _, name in ipairs(systems) do
        local v = settings:FindFirstChild(name.."Enabled")
        if v then
            local lbl = statusLabels[name]
            if v.Value then
                lbl.Text = "ON"
                lbl.TextColor3 = Color3.fromRGB(80, 220, 80)
            else
                lbl.Text = "OFF"
                lbl.TextColor3 = Color3.fromRGB(220, 80, 80)
            end
        end
    end
end

-- Listen for changes
local settings = ReplicatedStorage:WaitForChild("Settings")
for _, v in ipairs(settings:GetChildren()) do
    if v:IsA("BoolValue") then
        v.Changed:Connect(refresh)
    end
end

-- Initial refresh
refresh()

print("[AdminPanel] Loaded with new style.")
