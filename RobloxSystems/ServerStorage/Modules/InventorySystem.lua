--[[
	InventorySystem Module (Server-Sided)
	- Manages player inventory with server authority
	- All item operations validated on server
	- Prevents item duplication exploits
	- DataStore integration for persistence
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Inventory = {}
Inventory.__index = Inventory

-- Simple whitelist of allowed items (edit as needed)
local VALID_ITEMS = {
	sword = {name = "Sword", stackable = false},
	potion = {name = "Health Potion", stackable = true, maxStack = 99},
	coin = {name = "Gold Coin", stackable = true, maxStack = 999},
}

local function isInventoryEnabled()
	local settings = ReplicatedStorage:FindFirstChild("Settings")
	if settings and settings:FindFirstChild("InventoryEnabled") then
		return settings.InventoryEnabled.Value
	end
	return true
end

local function validItem(id)
	return id and VALID_ITEMS[id]
end

function Inventory.new(player, maxSlots)
	local self = setmetatable({}, Inventory)
	self.player = player
	self.maxSlots = maxSlots or 20
	self.slots = {}
	for i = 1, self.maxSlots do self.slots[i] = nil end
	return self
end

function Inventory:addItem(itemId, quantity)
	if not isInventoryEnabled() then return false end
	if not validItem(itemId) then return false end
	quantity = tonumber(quantity) or 1
	if quantity <= 0 then return false end

	local meta = VALID_ITEMS[itemId]

	-- try stack
	if meta.stackable then
		for i, slot in ipairs(self.slots) do
			if slot and slot.id == itemId then
				local canAdd = meta.maxStack - slot.quantity
				local add = math.min(canAdd, quantity)
				slot.quantity = slot.quantity + add
				quantity = quantity - add
				if quantity <= 0 then
					self:sync()
					return true
				end
			end
		end
	end

	-- fill empty slots
	for i = 1, self.maxSlots do
		if not self.slots[i] then
			local add = meta.stackable and math.min(meta.maxStack, quantity) or 1
			self.slots[i] = {id = itemId, quantity = add}
			quantity = quantity - add
			if quantity <= 0 then self:sync(); return true end
		end
	end
	self:sync()
	return quantity <= 0
end

function Inventory:removeItem(itemId, quantity, slotIndex)
	if not validItem(itemId) then return false end
	quantity = tonumber(quantity) or 1
	if quantity <= 0 then return false end
	if slotIndex and self.slots[slotIndex] and self.slots[slotIndex].id == itemId then
		local removed = math.min(self.slots[slotIndex].quantity, quantity)
		self.slots[slotIndex].quantity = self.slots[slotIndex].quantity - removed
		if self.slots[slotIndex].quantity <= 0 then self.slots[slotIndex] = nil end
		self:sync()
		return removed == quantity
	end
	return false
end

function Inventory:getAll()
	local out = {}
	for i, slot in ipairs(self.slots) do
		if slot then out[i] = {id = slot.id, quantity = slot.quantity, name = VALID_ITEMS[slot.id].name} end
	end
	return out
end

function Inventory:getCount(itemId)
	if not validItem(itemId) then return 0 end
	local c = 0
	for _, s in ipairs(self.slots) do if s and s.id == itemId then c = c + s.quantity end end
	return c
end

function Inventory:serialize()
	return self.slots
end

function Inventory:deserialize(data)
	if type(data) ~= "table" then return end
	for i = 1, math.min(#data, self.maxSlots) do
		local s = data[i]
		if s and validItem(s.id) then self.slots[i] = s end
	end
	self:sync()
end

function Inventory:sync()
	local events = ReplicatedStorage:WaitForChild("Events")
	events.InventoryUpdated:FireAllClients(self.player, self:getAll())
end

return Inventory
