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

-- Load modules
local HealthSystem = require(ServerStorage:WaitForChild("Modules"):WaitForChild("HealthSystem"))
local InventorySystem = require(ServerStorage:WaitForChild("Modules"):WaitForChild("InventorySystem"))
local PlayerDataManager = require(ServerStorage:WaitForChild("Modules"):WaitForChild("PlayerDataManager"))
local LevelSystem = require(ServerStorage:WaitForChild("Modules"):WaitForChild("LevelSystem"))

-- Store player systems
local playerSystems = {}

-- Create required events in ReplicatedStorage
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
		"AdminToggle"
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

	local bools = {HealthEnabled = true, InventoryEnabled = true, LevelingEnabled = true}
	for name, default in pairs(bools) do
		if not settings:FindFirstChild(name) then
			local b = Instance.new("BoolValue")
			b.Name = name
			b.Value = default
			b.Parent = settings
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
	local health = HealthSystem.new(player, 100)
	systems.health = health
	
	-- Create InventorySystem
	local inventory = InventorySystem.new(player, 20)
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

	-- Admin toggle handler (only allow game creator or listed admins)
	local admins = {}
	local function isAdmin(player)
		if not player then return false end
		if player.UserId == game.CreatorId then return true end
		-- add admin UserIds to the `admins` table if needed
		return table.find(admins, player.UserId) ~= nil
	end

	events.AdminToggle.OnServerEvent:Connect(function(player, systemName, enabled)
		if not isAdmin(player) then return end
		local settings = ReplicatedStorage:FindFirstChild("Settings")
		if not settings then return end
		if systemName == "Health" then
			settings.HealthEnabled.Value = enabled
		elseif systemName == "Inventory" then
			settings.InventoryEnabled.Value = enabled
		elseif systemName == "Leveling" then
			settings.LevelingEnabled.Value = enabled
		end
		print("Admin " .. player.Name .. " set " .. tostring(systemName) .. " to " .. tostring(enabled))
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
