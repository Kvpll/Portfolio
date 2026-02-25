--[[
	PlayerDataManager Module (Server-Sided)
	- Manages all player data persistence with DataStore
	- Automatic retries on DataStore failures
	- Server-sided validation only
	- Prevents data corruption from exploits
]]
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerDataManager = {}
PlayerDataManager.__index = PlayerDataManager

local store = DataStoreService:GetDataStore("PlayerData_v1")

local SAVE_INTERVAL = 60
local MAX_RETRIES = 3
local RETRY_DELAY = 2

local function retry(func)
	for i = 1, MAX_RETRIES do
		local ok, res = pcall(func)
		if ok then return true, res end
		wait(RETRY_DELAY)
	end
	return false, "DataStore failed"
end

function PlayerDataManager.new(player)
	local self = setmetatable({}, PlayerDataManager)
	self.player = player
	self.userId = player.UserId
	self.data = {level = 1, experience = 0, coins = 0, inventory = {}}
	self.isDirty = false
	self.lastSave = tick()
	return self
end

function PlayerDataManager:load()
	local ok, data = retry(function() return store:GetAsync("player_" .. self.userId) end)
	if ok and type(data) == "table" then
		self.data = data
		print("Loaded data for " .. self.player.Name)
		return true
	end
	warn("No data for " .. self.player.Name)
	return false
end

function PlayerDataManager:save()
	if not self.isDirty and (tick() - self.lastSave) < SAVE_INTERVAL then return true end
	if type(self.data) ~= "table" then return false end
	local ok = retry(function() store:SetAsync("player_" .. self.userId, self.data) end)
	if ok then
		self.isDirty = false
		self.lastSave = tick()
		print("Saved data for " .. self.player.Name)
		return true
	end
	warn("Failed to save for " .. self.player.Name)
	return false
end

function PlayerDataManager:addExperience(amount)
	amount = tonumber(amount) or 0
	if amount <= 0 or amount > 5000 then return false end
	self.data.experience = self.data.experience + amount
	self.isDirty = true
	self:notify()
	return true
end

function PlayerDataManager:addCoins(amount)
	amount = tonumber(amount) or 0
	if amount <= 0 or amount > 1000000 then return false end
	self.data.coins = self.data.coins + amount
	self.isDirty = true
	self:notify()
	return true
end

function PlayerDataManager:removeCoins(amount)
	amount = tonumber(amount) or 0
	if amount <= 0 or self.data.coins < amount then return false end
	self.data.coins = self.data.coins - amount
	self.isDirty = true
	self:notify()
	return true
end

function PlayerDataManager:levelUp()
	self.data.level = (self.data.level or 1) + 1
	self.data.experience = 0
	self.isDirty = true
	self:notify()
	print(self.player.Name .. " leveled up to " .. self.data.level)
end

function PlayerDataManager:validate()
	if type(self.data.level) ~= "number" or self.data.level < 1 then return false end
	if type(self.data.experience) ~= "number" or self.data.experience < 0 then return false end
	if type(self.data.coins) ~= "number" or self.data.coins < 0 then return false end
	return true
end

function PlayerDataManager:getData()
	return self.data
end

function PlayerDataManager:notify()
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerDataUpdated"):FireAllClients(self.player, self.data)
end

Players.PlayerRemoving:Connect(function(player)
	-- nothing here; saving handled elsewhere
end)

return PlayerDataManager
return PlayerDataManager
