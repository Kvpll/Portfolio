--[[
	LevelSystem Module (Server-Sided)
	- Manages player leveling and experience
	- All progression validated by server
	- Prevents exp/level manipulation from exploits
	- Integrates with PlayerDataManager
]]

local LevelSystem = {}
LevelSystem.__index = LevelSystem

-- Experience curve: exp needed = level * 100
local function getExpNeeded(level)
	return level * 100
end

function LevelSystem.new(playerDataManager)
	local self = setmetatable({}, LevelSystem)
	self.playerDataManager = playerDataManager
	self.player = playerDataManager.player
	
	return self
end

function LevelSystem:addExperience(amount)
	-- Validate on server only
	if type(amount) ~= "number" or amount < 0 or amount > 5000 then
		warn("Invalid experience amount from " .. self.player.Name .. ": " .. tostring(amount))
		return false
	end
	
	if not self.playerDataManager:addExperience(amount) then
		return false
	end
	
	-- Check for level ups
	self:checkLevelUp()
	return true
end

function LevelSystem:checkLevelUp()
	local data = self.playerDataManager:getData()
	local expNeeded = getExpNeeded(data.level)
	
	while data.experience >= expNeeded do
		data.experience = data.experience - expNeeded
		self.playerDataManager:levelUp()
		self:notifyLevelUp(data.level)
		expNeeded = getExpNeeded(data.level)
	end
end

function LevelSystem:getLevel()
	return self.playerDataManager:getData().level
end

function LevelSystem:getExperience()
	return self.playerDataManager:getData().experience
end

function LevelSystem:getExpNeeded()
	return getExpNeeded(self:getLevel())
end

function LevelSystem:getExpProgress()
	local current = self:getExperience()
	local needed = self:getExpNeeded()
	return current, needed, (current / needed) * 100
end

function LevelSystem:notifyLevelUp(newLevel)
	print(self.player.Name .. " reached level " .. newLevel)
	
	game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("LevelUp"):FireAllClients(
		self.player,
		newLevel
	)
end

return LevelSystem
