--[[
	LevelSystem Module (Server-Sided)
	- Manages player leveling and experience
	- All progression validated by server
	- Prevents exp/level manipulation from exploits
	- Integrates with PlayerDataManager
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LevelSystem = {}
LevelSystem.__index = LevelSystem

local function expNeeded(level)
	return (level or 1) * 100
end

function LevelSystem.new(dataManager)
	local self = setmetatable({}, LevelSystem)
	self.dataManager = dataManager
	self.player = dataManager.player
	return self
end

function LevelSystem:addExperience(amount)
	amount = tonumber(amount) or 0
	if amount <= 0 then return false end
	if not self.dataManager:addExperience(amount) then return false end
	self:checkLevelUp()
	return true
end

function LevelSystem:checkLevelUp()
	local data = self.dataManager:getData()
	local needed = expNeeded(data.level)
	while data.experience >= needed do
		data.experience = data.experience - needed
		self.dataManager:levelUp()
		ReplicatedStorage:WaitForChild("Events"):WaitForChild("LevelUp"):FireAllClients(self.player, data.level)
		needed = expNeeded(data.level)
	end
end

function LevelSystem:getLevel()
	return self.dataManager:getData().level
end

function LevelSystem:getExperience()
	return self.dataManager:getData().experience
end

function LevelSystem:getProgress()
	local d = self.dataManager:getData()
	local needed = expNeeded(d.level)
	return d.experience, needed, (d.experience / needed) * 100
end

return LevelSystem
