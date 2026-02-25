--[[
	HealthSystem Module (Server-Sided)
	- Manages player health with server authority
	- Exploit-proof damage validation
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")

	local HealthSystem = {}
	HealthSystem.__index = HealthSystem

	-- Simple server-side store for active health systems
	local activeHealth = {}

	-- Helper: check whether health system is enabled globally
	local function isHealthEnabled()
		local settings = ReplicatedStorage:FindFirstChild("Settings")
		if settings and settings:FindFirstChild("HealthEnabled") then
			return settings.HealthEnabled.Value
		end
		return true
	end

	function HealthSystem.new(player, maxHealth)
		local self = setmetatable({}, HealthSystem)
		self.player = player
		self.maxHealth = maxHealth or 100
		self.currentHealth = self.maxHealth
		self.dead = false

		activeHealth[player.UserId] = self
		return self
	end

	function HealthSystem:takeDamage(amount, damageType)
		if not isHealthEnabled() then
			return false -- health disabled by admin
		end

		amount = tonumber(amount) or 0
		if amount <= 0 then
			return false
		end

		if self.dead then
			return false
		end

		self.currentHealth = math.max(0, self.currentHealth - amount)

		local events = ReplicatedStorage:WaitForChild("Events")
		events.HealthChanged:FireAllClients(self.player, self.currentHealth, self.maxHealth)

		if self.currentHealth <= 0 then
			self:die(damageType)
		end
		return true
	end

	function HealthSystem:heal(amount)
		if not isHealthEnabled() then
			return false
		end
		amount = tonumber(amount) or 0
		if amount <= 0 or self.dead then
			return false
		end
		self.currentHealth = math.min(self.maxHealth, self.currentHealth + amount)
		local events = ReplicatedStorage:WaitForChild("Events")
		events.HealthChanged:FireAllClients(self.player, self.currentHealth, self.maxHealth)
		return true
	end

	function HealthSystem:die(damageType)
		if self.dead then return end
		self.dead = true
		local events = ReplicatedStorage:WaitForChild("Events")
		events.PlayerDied:FireAllClients(self.player, damageType)
		print(self.player.Name .. " died (" .. tostring(damageType) .. ")")
	end

	function HealthSystem:revive(spawn)
		self.dead = false
		self.currentHealth = self.maxHealth
		if spawn and spawn:IsA("BasePart") and self.player.Character then
			self.player.Character:MoveTo(spawn.Position)
		end
		ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerRevived"):FireAllClients(self.player)
	end

	function HealthSystem:get()
		return self.currentHealth, self.maxHealth
	end

	function HealthSystem:isAlive()
		return not self.dead and self.currentHealth > 0
	end

	Players.PlayerRemoving:Connect(function(player)
		activeHealth[player.UserId] = nil
	end)

	return HealthSystem
	playerHealth[player.UserId] = nil
end)

return HealthSystem
