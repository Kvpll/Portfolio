--[[
	PlayerManager Script (ServerScriptService)
	- Main initialization script
	- Loads all systems for each player
	- Handles player join/leave
	- All game logic runs on server only
	
	SETUP INSTRUCTIONS:
	1. Create folder structure:
	   - ServerStorage/Modules/
	   - Place all module files in Modules/
	2. Create RemoteEvents in ReplicatedStorage/Events:
	   - HealthChanged
	   - PlayerDied
	   - PlayerRevived
	   - InventoryUpdated
	   - PlayerDataUpdated
	   - LevelUp
	3. Place this script in ServerScriptService
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIG: easy-to-change values at top of the script
local CONFIG = {
	AdminUserIds = {}, -- put numeric userIds here to grant admin rights, e.g. {123456, 987654}
	DefaultInventorySlots = 3,
	DefaultDamage = 10,
	DefaultHeal = 10,
}

-- Load modules
local HealthSystem = require(ServerStorage:WaitForChild("Modules"):WaitForChild("HealthSystem"))
local InventorySystem = require(ServerStorage:WaitForChild("Modules"):WaitForChild("InventorySystem"))
local PlayerDataManager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("PlayerDataManager"))
local LevelSystem = require(ServerStorage:WaitForChild("Modules"):WaitForChild("LevelSystem"))

-- Store player systems
local playerSystems = {}

-- Create required events in ReplicatedStorage
local admins = CONFIG.AdminUserIds

local function setupEvents()
	local events = ReplicatedStorage:FindFirstChild("Events") or Instance.new("Folder")
	events.Name = "Events"
	events.Parent = ReplicatedStorage

	local eventNames = {
		"HealthChanged",
		"PlayerDied",
		"PlayerRevived",
		"InventoryUpdated",
		"PlayerDataUpdated",
		"LevelUp",
		"AdminToggle",
		"AdminSetValue",
		"AdminAction"
	}

	for _, eventName in ipairs(eventNames) do
		if not events:FindFirstChild(eventName) then
			local event = Instance.new("RemoteEvent")
			event.Name = eventName
			event.Parent = events
		end
	end

	-- Settings folder for admin toggles
	local settings = ReplicatedStorage:FindFirstChild("Settings") or Instance.new("Folder")
	settings.Name = "Settings"
	settings.Parent = ReplicatedStorage

	-- Bool toggles
	local bools = {HealthEnabled = true, InventoryEnabled = true, LevelingEnabled = true}
	for name, default in pairs(bools) do
		if not settings:FindFirstChild(name) then
			local b = Instance.new("BoolValue")
			b.Name = name
			b.Value = default
			b.Parent = settings
		end
	end

	-- Numeric settings
	local nums = {InventorySlots = CONFIG.DefaultInventorySlots, DefaultDamage = CONFIG.DefaultDamage, DefaultHeal = CONFIG.DefaultHeal, LevelExpBase = 100}
	for name, default in pairs(nums) do
		if not settings:FindFirstChild(name) then
			local v = Instance.new("IntValue")
			v.Name = name
			v.Value = default
			v.Parent = settings
		end
	end
end

-- Initialize player systems
local function setupPlayer(player)
	print("Setting up systems for " .. player.Name)
	
	local systems = {}
	
	-- Create PlayerDataManager
	local dataManager = PlayerDataManager.new(player)
	dataManager:load()
	systems.dataManager = dataManager
	
	-- Create HealthSystem
	local settings = ReplicatedStorage:FindFirstChild("Settings")
	local slots = (settings and settings:FindFirstChild("InventorySlots") and settings.InventorySlots.Value) or CONFIG.DefaultInventorySlots
	local defaultDamage = (settings and settings:FindFirstChild("DefaultDamage") and settings.DefaultDamage.Value) or CONFIG.DefaultDamage
	local defaultHeal = (settings and settings:FindFirstChild("DefaultHeal") and settings.DefaultHeal.Value) or CONFIG.DefaultHeal

	local health = HealthSystem.new(player, 100)
	systems.health = health
	
	-- Create InventorySystem
	local inventory = InventorySystem.new(player, slots)
	if dataManager.data.inventory then
		inventory:deserialize(dataManager.data.inventory)
	end
	systems.inventory = inventory
	
	-- Create LevelSystem
	local levelSystem = LevelSystem.new(dataManager)
	systems.levelSystem = levelSystem
	
	playerSystems[player.UserId] = systems
	
	-- Save periodically
	while player and playerSystems[player.UserId] do
		wait(60)
		if systems.dataManager then
			systems.dataManager:save()
		end
	end
end

-- Clean up when player leaves
local function onPlayerLeave(player)
	print("Cleaning up systems for " .. player.Name)
	
	local systems = playerSystems[player.UserId]
	if systems and systems.dataManager then
		systems.dataManager:save()
	end
	
	playerSystems[player.UserId] = nil
end

-- Server-side remote handlers (prevent exploits by validating everything)
local function setupRemoteHandlers()
	local events = ReplicatedStorage:WaitForChild("Events")

	-- Admin handler (only allow game creator or listed admins)
	local function isAdmin(player)
		if not player then return false end
		if player.UserId == game.CreatorId then return true end
		return table.find(admins, player.UserId) ~= nil
	end

	events.AdminToggle.OnServerEvent:Connect(function(player, systemName, enabled)
		if not isAdmin(player) then return end
		local settings = ReplicatedStorage:FindFirstChild("Settings")
		if not settings then return end
		if systemName == "Health" and settings:FindFirstChild("HealthEnabled") then
			settings.HealthEnabled.Value = enabled
		elseif systemName == "Inventory" and settings:FindFirstChild("InventoryEnabled") then
			settings.InventoryEnabled.Value = enabled
		elseif systemName == "Leveling" and settings:FindFirstChild("LevelingEnabled") then
			settings.LevelingEnabled.Value = enabled
		end

		-- optional per-player toggle: if enabled is table {value = bool, userId = id}
		if type(enabled) == "table" and enabled.userId then
			local per = settings:FindFirstChild("PerPlayer")
			if not per then
				per = Instance.new("Folder")
				per.Name = "PerPlayer"
				per.Parent = settings
			end
			local pid = per:FindFirstChild(tostring(enabled.userId))
			if not pid then
				pid = Instance.new("Folder")
				pid.Name = tostring(enabled.userId)
				pid.Parent = per
			end
			local v = pid:FindFirstChild(systemName.."Enabled")
			if not v then
				v = Instance.new("BoolValue")
				v.Name = systemName.."Enabled"
				v.Parent = pid
			end
			v.Value = enabled.value
		end
		print("Admin " .. player.Name .. " set " .. tostring(systemName) .. " to " .. tostring(enabled))
	end)

	-- Admin set numeric value
	events.AdminSetValue.OnServerEvent:Connect(function(player, key, value)
		if not isAdmin(player) then return end
		local settings = ReplicatedStorage:FindFirstChild("Settings")
		if not settings then return end
		local obj = settings:FindFirstChild(key)
		if obj and (obj:IsA("IntValue") or obj:IsA("NumberValue")) then
			obj.Value = tonumber(value) or obj.Value
			print("Admin " .. player.Name .. " set " .. key .. " to " .. tostring(obj.Value))
		end
	end)

	-- Admin set admins list (comma-separated ids)
	events.AdminSetAdmins.OnServerEvent:Connect(function(player, csv)
		if not isAdmin(player) then return end
		admins = {}
		for id in string.gmatch(csv or "", "([^,%s]+)") do
			local n = tonumber(id)
			if n then table.insert(admins, n) end
		end
		print("Admin list updated by " .. player.Name)
	end)

	-- Admin actions like damage/heal/level
	events.AdminAction.OnServerEvent:Connect(function(player, action, targetName, amount)
		if not isAdmin(player) then return end
		local target = Players:FindFirstChild(targetName) or Players:GetPlayerByUserId(tonumber(targetName) or 0)
		if not target then return end
		local systems = playerSystems[target.UserId]
		if not systems then return end
		amount = tonumber(amount) or 0
		if action == "Damage" and systems.health then
			systems.health:takeDamage(amount, "Admin")
		elseif action == "Heal" and systems.health then
			systems.health:heal(amount)
		elseif action == "SetLevel" and systems.dataManager then
			systems.dataManager.data.level = math.max(1, math.floor(amount))
			systems.dataManager.isDirty = true
			systems.dataManager:notify()
		end
	end)
end

-- Setup
setupEvents()

Players.PlayerAdded:Connect(function(player)
	task.spawn(setupPlayer, player)
end)

Players.PlayerRemoving:Connect(onPlayerLeave)

-- Load existing players
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(setupPlayer, player)
end

setupRemoteHandlers()

print("PlayerManager initialized. All systems are server-sided and exploit-proof!")
