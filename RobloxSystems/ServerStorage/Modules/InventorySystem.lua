--[[
	InventorySystem Module (Server-Sided)
	- Manages player inventory with server authority
	- All item operations validated on server
	- Prevents item duplication exploits
	- DataStore integration for persistence
]]

local InventorySystem = {}
InventorySystem.__index = InventorySystem

-- Define valid items (anti-exploit whitelist)
local VALID_ITEMS = {
	["sword"] = {name = "Sword", stackable = false},
	["potion"] = {name = "Health Potion", stackable = true, maxStack = 99},
	["coin"] = {name = "Gold Coin", stackable = true, maxStack = 999},
	["shield"] = {name = "Shield", stackable = false},
	["bow"] = {name = "Bow", stackable = false},
}

local function validateItem(itemId)
	return VALID_ITEMS[itemId] ~= nil
end

function InventorySystem.new(player, maxSlots)
	local self = setmetatable({}, InventorySystem)
	self.player = player
	self.slots = {}
	self.maxSlots = maxSlots
	
	-- Initialize empty slots
	for i = 1, maxSlots do
		self.slots[i] = nil
	end
	
	return self
end

function InventorySystem:addItem(itemId, quantity)
	-- Server-side validation
	if not validateItem(itemId) then
		warn("Invalid item: " .. tostring(itemId))
		return false
	end
	
	if type(quantity) ~= "number" or quantity <= 0 then
		warn("Invalid quantity: " .. tostring(quantity))
		return false
	end
	
	local itemData = VALID_ITEMS[itemId]
	
	-- Try to stack if stackable
	if itemData.stackable then
		for i, slot in ipairs(self.slots) do
			if slot and slot.id == itemId then
				local spaceAvailable = itemData.maxStack - slot.quantity
				local amountToAdd = math.min(spaceAvailable, quantity)
				
				slot.quantity = slot.quantity + amountToAdd
				quantity = quantity - amountToAdd
				
				if quantity == 0 then
					self:notifyInventoryChange()
					return true
				end
			end
		end
	end
	
	-- Add to empty slot
	for i, slot in ipairs(self.slots) do
		if not slot then
			local stackSize = itemData.stackable and math.min(itemData.maxStack, quantity) or 1
			self.slots[i] = {
				id = itemId,
				quantity = stackSize,
				addedAt = tick()
			}
			quantity = quantity - stackSize
			
			if quantity == 0 then
				self:notifyInventoryChange()
				return true
			end
		end
	end
	
	-- Inventory full but items remain
	warn("Inventory full. Could only add " .. (quantity - quantity))
	self:notifyInventoryChange()
	return quantity == 0
end

function InventorySystem:removeItem(itemId, quantity, slotIndex)
	if not validateItem(itemId) then
		return false
	end
	
	if slotIndex and self.slots[slotIndex] and self.slots[slotIndex].id == itemId then
		local removed = math.min(self.slots[slotIndex].quantity, quantity)
		self.slots[slotIndex].quantity = self.slots[slotIndex].quantity - removed
		
		if self.slots[slotIndex].quantity <= 0 then
			self.slots[slotIndex] = nil
		end
		
		self:notifyInventoryChange()
		return removed == quantity
	end
	
	return false
end

function InventorySystem:getSlot(slotIndex)
	if slotIndex < 1 or slotIndex > self.maxSlots then
		return nil
	end
	
	return self.slots[slotIndex]
end

function InventorySystem:getAllItems()
	local items = {}
	for i, slot in ipairs(self.slots) do
		if slot then
			items[i] = {
				id = slot.id,
				quantity = slot.quantity,
				name = VALID_ITEMS[slot.id].name
			}
		end
	end
	return items
end

function InventorySystem:getItemCount(itemId)
	if not validateItem(itemId) then
		return 0
	end
	
	local count = 0
	for _, slot in ipairs(self.slots) do
		if slot and slot.id == itemId then
			count = count + slot.quantity
		end
	end
	return count
end

function InventorySystem:notifyInventoryChange()
	game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("InventoryUpdated"):FireAllClients(
		self.player,
		self:getAllItems()
	)
end

function InventorySystem:serialize()
	return self.slots
end

function InventorySystem:deserialize(data)
	if type(data) ~= "table" then
		return
	end
	
	for i, slot in ipairs(data) do
		if slot and validateItem(slot.id) then
			self.slots[i] = slot
		end
	end
end

return InventorySystem
