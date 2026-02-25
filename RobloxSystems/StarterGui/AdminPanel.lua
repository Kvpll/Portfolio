-- AdminPanel LocalScript (place in StarterGui)
-- Simple UI created at runtime that allows the game owner to toggle systems

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local function isAdmin()
    return player.UserId == game.CreatorId
end

local function createButton(text, parent, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = parent
    return btn
end

if not isAdmin() then return end

local screen = Instance.new("ScreenGui")
screen.Name = "AdminPanel"
screen.ResetOnSpawn = false
screen.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 160)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = screen

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 10)
title.Text = "Admin Panel"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local statusLabels = {}
local buttons = {}
local systems = {"Health", "Inventory", "Leveling"}

for i, systemName in ipairs(systems) do
    local y = 40 + (i-1) * 40
    local btn = createButton("Toggle "..systemName, frame, y)
    buttons[systemName] = btn
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 80, 0, 30)
    lbl.Position = UDim2.new(0, 220-90, 0, y)
    lbl.Text = ""
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.BackgroundTransparency = 1
    lbl.Parent = frame
    statusLabels[systemName] = lbl

    btn.MouseButton1Click:Connect(function()
        local events = ReplicatedStorage:WaitForChild("Events")
        local current = nil
        local settings = ReplicatedStorage:FindFirstChild("Settings")
        if settings and settings:FindFirstChild(systemName.."Enabled") then
            current = settings:FindFirstChild(systemName.."Enabled").Value
        end
        local newState = not current
        events.AdminToggle:FireServer(systemName, newState)
    end)
end

-- Update labels when settings change
local function refresh()
    local settings = ReplicatedStorage:FindFirstChild("Settings")
    if not settings then return end
    for _, name in ipairs(systems) do
        local v = settings:FindFirstChild(name.."Enabled")
        if v then
            statusLabels[name].Text = v.Value and "ON" or "OFF"
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

-- initial refresh
refresh()
