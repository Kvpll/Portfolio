--[[
	PlayerDataManager Module (Server-Sided)
	- Manages all player data persistence with DataStore
	- Automatic retries on DataStore failures
	- Server-sided validation only
	- Prevents data corruption from exploits
]]

local PlayerDataManager = {}
PlayerDataManager.__index = PlayerDataManager

local DataStoreService = game:GetService("DataStoreService")
local playerDataStore = DataStoreService:GetDataStore("PlayerData_v1")

-- Config
local SAVE_INTERVAL = 60 -- Save every 60 seconds
local MAX_RETRIES = 3
local RETRY_DELAY = 2

function PlayerDataManager.new(player)
	local self = setmetatable({}, PlayerDataManager)
	self.player = player
	self.userId = player.UserId
	self.data = {
		level = 1,
		experience = 0,
		coins = 0,
		health = 100,
		maxHealth = 100
	}
	self.isDirty = false
	self.lastSave = tick()
	
	return self
end

-- Retry logic for DataStore operations
local function retryOperation(operationFunc, maxRetries)
	local lastError
	for attempt = 1, maxRetries do
		local success, result = pcall(operationFunc)
		
		if success then
			return true, result
		else
			lastError = result
			if attempt < maxRetries then
				wait(RETRY_DELAY)
			end
		end
	end
	
	return false, lastError
end

function PlayerDataManager:load()
	local success, data = retryOperation(function()
		return playerDataStore:GetAsync("player_" .. self.userId)
	end, MAX_RETRIES)
	
	if success and data then
		-- Validate loaded data
		if type(data) == "table" then
			self.data = data
			print("Loaded data for " .. self.player.Name)
			return true
		end
	else
		warn("Failed to load data for " .. self.player.Name .. ": " .. tostring(data))
	end
	
	return false
end

function PlayerDataManager:save()
	if not self.isDirty and (tick() - self.lastSave) < SAVE_INTERVAL then
		return true -- Not dirty, skip save
	end
	
	-- Validate data before saving
	if not self:validateData() then
		warn("Data validation failed for " .. self.player.Name)
		return false
	end
	
	local success, error = retryOperation(function()
		playerDataStore:SetAsync("player_" .. self.userId, self.data)
	end, MAX_RETRIES)
	
	if success then
		self.isDirty = false
		self.lastSave = tick()
		print("Saved data for " .. self.player.Name)
		return true
	else
		warn("Failed to save data for " .. self.player.Name .. ": " .. tostring(error))
		return false
	end
end

function PlayerDataManager:addExperience(amount)
	-- Server-side validation
	if type(amount) ~= "number" or amount < 0 or amount > 10000 then
		warn("Invalid experience amount: " .. tostring(amount))
		return false
	end
	
	self.data.experience = self.data.experience + amount
	self.isDirty = true
	
	-- Update UI
	self:notifyDataChange()
	return true
end

function PlayerDataManager:addCoins(amount)
	-- Server-side validation
	if type(amount) ~= "number" or amount < 0 or amount > 999999 then
		warn("Invalid coin amount: " .. tostring(amount))
		return false
	end
	
	self.data.coins = self.data.coins + amount
	self.isDirty = true
	self:notifyDataChange()
	return true
end

function PlayerDataManager:removeCoins(amount)
	if type(amount) ~= "number" or amount < 0 then
		warn("Invalid coin removal: " .. tostring(amount))
		return false
	end
	
	if self.data.coins < amount then
		return false -- Not enough coins
	end
	
	self.data.coins = self.data.coins - amount
	self.isDirty = true
	self:notifyDataChange()
	return true
end

function PlayerDataManager:levelUp()
	self.data.level = self.data.level + 1
	self.data.experience = 0
	self.isDirty = true
	self:notifyDataChange()
	print(self.player.Name .. " leveled up to " .. self.data.level)
end

function PlayerDataManager:validateData()
	-- Ensure data types are correct and values are reasonable
	if type(self.data.level) ~= "number" or self.data.level < 1 or self.data.level > 999 then
		return false
	end
	if type(self.data.experience) ~= "number" or self.data.experience < 0 then
		return false
	end
	if type(self.data.coins) ~= "number" or self.data.coins < 0 or self.data.coins > 99999999 then
		return false
	end
	
	return true
end

function PlayerDataManager:getData()
	return self.data
end

function PlayerDataManager:notifyDataChange()
	game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerDataUpdated"):FireAllClients(
		self.player,
		self.data
	)
end

return PlayerDataManager
