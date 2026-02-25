--[[
	HealthSystem Module (Server-Sided)
	- Manages player health with server authority
	- Exploit-proof damage validation
	- LocalScript communication via RemoteEvent
	- All logic runs on server only
]]

local HealthSystem = {}
HealthSystem.__index = HealthSystem

-- Server-sided health database
local playerHealth = {}

function HealthSystem.new(player, maxHealth)
	local self = setmetatable({}, HealthSystem)
	self.player = player
	self.maxHealth = maxHealth
	self.currentHealth = maxHealth
	self.isDead = false
	
	-- Store in server table for validation
	playerHealth[player.UserId] = self
	
	return self
end

function HealthSystem:takeDamage(amount, damageType)
	-- Validate damage amount on server
	if type(amount) ~= "number" or amount < 0 then
		warn("Invalid damage amount:", amount)
		return false
	end
	
	if self.isDead then
		return false
	end
	
	self.currentHealth = math.max(0, self.currentHealth - amount)
	
	-- Fire server event (no client authority)
	game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("HealthChanged"):FireAllClients(
		self.player,
		self.currentHealth,
		self.maxHealth
	)
	
	if self.currentHealth <= 0 then
		self:die(damageType)
	end
	
	return true
end

function HealthSystem:heal(amount)
	-- Validate heal amount on server
	if type(amount) ~= "number" or amount < 0 then
		warn("Invalid heal amount:", amount)
		return false
	end
	
	if self.isDead then
		return false
	end
	
	self.currentHealth = math.min(self.maxHealth, self.currentHealth + amount)
	
	game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("HealthChanged"):FireAllClients(
		self.player,
		self.currentHealth,
		self.maxHealth
	)
	
	return true
end

function HealthSystem:revive(spawn)
	self.isDead = false
	self.currentHealth = self.maxHealth
	
	if spawn and spawn:IsA("BasePart") then
		self.player.Character:MoveTo(spawn.Position)
	end
	
	game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerRevived"):FireAllClients(self.player)
end

function HealthSystem:die(damageType)
	self.isDead = true
	print(self.player.Name .. " died from " .. (damageType or "unknown"))
	
	game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerDied"):FireAllClients(
		self.player,
		damageType
	)
end

function HealthSystem:getHealth()
	return self.currentHealth, self.maxHealth
end

function HealthSystem:isAlive()
	return not self.isDead and self.currentHealth > 0
end

-- Clean up on player leave
game:GetService("Players").PlayerRemoving:Connect(function(player)
	playerHealth[player.UserId] = nil
end)

return HealthSystem
