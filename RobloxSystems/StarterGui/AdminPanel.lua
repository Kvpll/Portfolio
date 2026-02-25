-- AdminPanel LocalScript (place in StarterGui)
-- Simple UI created at runtime that allows the game owner to toggle systems

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Top-level config: change labels/defaults here
local UI_CONFIG = {
    InventoryDefault = 3,
    DamageDefault = 10,
    HealDefault = 10,
    ShowAdminListBox = true,
}

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

-- Extra controls: numeric settings and admin actions
local function createLabel(text, parent, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 200, 0, 24)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.Parent = parent
    return lbl
end

local function createInput(default, parent, y)
    local inp = Instance.new("TextBox")
    inp.Size = UDim2.new(0, 120, 0, 28)
    inp.Position = UDim2.new(0, 90, 0, y)
    inp.Text = tostring(default)
    inp.TextColor3 = Color3.fromRGB(0,0,0)
    inp.BackgroundColor3 = Color3.fromRGB(240,240,240)
    inp.Parent = parent
    return inp
end

-- Inventory slots control
local invLabel = createLabel("Inventory Slots:", frame, 140)
local invInput = createInput(UI_CONFIG.InventoryDefault, frame, 140)
local invDec = createButton("-", frame, 170)
local invInc = createButton("+", frame, 170)
local invSet = createButton("Apply Slots", frame, 170)
invDec.Text = "-"
invInc.Text = "+"
invDec.MouseButton1Click:Connect(function()
    local v = tonumber(invInput.Text) or UI_CONFIG.InventoryDefault
    v = math.max(1, v - 1)
    invInput.Text = tostring(v)
end)
invInc.MouseButton1Click:Connect(function()
    local v = tonumber(invInput.Text) or UI_CONFIG.InventoryDefault
    v = v + 1
    invInput.Text = tostring(v)
end)
invSet.MouseButton1Click:Connect(function()
    local v = tonumber(invInput.Text) or UI_CONFIG.InventoryDefault
    ReplicatedStorage:WaitForChild("Events"):WaitForChild("AdminSetValue"):FireServer("InventorySlots", math.max(1, math.floor(v)))
end)

-- Damage/Heal controls
local dmgLabel = createLabel("Damage:", frame, 210)
local dmgInput = createInput(UI_CONFIG.DamageDefault, frame, 210)
local dmgBtn = createButton("Damage Player", frame, 240)

local healLabel = createLabel("Heal:", frame, 280)
local healInput = createInput(UI_CONFIG.HealDefault, frame, 280)
local healBtn = createButton("Heal Player", frame, 310)

local targetLabel = createLabel("Target (name or id):", frame, 350)
local targetInput = createInput("", frame, 350)

dmgBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(dmgInput.Text) or 0
    local target = targetInput.Text
    ReplicatedStorage:WaitForChild("Events"):WaitForChild("AdminAction"):FireServer("Damage", target, amount)
end)

healBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(healInput.Text) or 0
    local target = targetInput.Text
    ReplicatedStorage:WaitForChild("Events"):WaitForChild("AdminAction"):FireServer("Heal", target, amount)
end)

-- Level control
local lvlLabel = createLabel("Set Level:", frame, 390)
local lvlInput = createInput(1, frame, 390)
local lvlBtn = createButton("Set Level", frame, 420)
lvlBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(lvlInput.Text) or 1
    local target = targetInput.Text
    ReplicatedStorage:WaitForChild("Events"):WaitForChild("AdminAction"):FireServer("SetLevel", target, amount)
end)

-- Player dropdown UI
local function openPlayerList()
    local list = Instance.new("Frame")
    list.Size = UDim2.new(0, 200, 0, 200)
    list.Position = UDim2.new(0, 240, 0, 10)
    list.BackgroundColor3 = Color3.fromRGB(35,35,35)
    list.Parent = screen

    local y = 0
    for _, p in ipairs(Players:GetPlayers()) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -10, 0, 30)
        b.Position = UDim2.new(0, 5, 0, y)
        b.Text = p.Name .. " (" .. tostring(p.UserId) .. ")"
        b.BackgroundColor3 = Color3.fromRGB(60,60,60)
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Parent = list
        b.MouseButton1Click:Connect(function()
            targetInput.Text = tostring(p.Name)
            list:Destroy()
        end)
        y = y + 32
    end
end

local pickBtn = createButton("Pick Player", frame, 450)
pickBtn.MouseButton1Click:Connect(openPlayerList)

-- Admin list editing (comma-separated userIds)
if UI_CONFIG.ShowAdminListBox then
    local adminLabel = createLabel("Admin IDs (csv):", frame, 490)
    local adminInput = createInput("", frame, 490)
    local adminSet = createButton("Set Admins", frame, 520)
    adminSet.MouseButton1Click:Connect(function()
        local csv = adminInput.Text
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("AdminSetAdmins"):FireServer(csv)
    end)
end
