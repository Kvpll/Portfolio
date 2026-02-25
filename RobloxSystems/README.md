# Roblox Game Systems - Production Ready

Complete, server-sided game systems built for Roblox Studio. All systems are **exploit-proof** with server authority, proper validation, and DataStore integration.

## 📁 Folder Structure

Copy this entire `RobloxSystems` folder structure into your Roblox game:

```
Your Game/
├── ServerStorage/
│   └── Modules/
│       ├── HealthSystem.lua
│       ├── InventorySystem.lua
│       ├── PlayerDataManager.lua
│       └── LevelSystem.lua
└── ServerScriptService/
    └── PlayerManager.lua
```

## 🚀 Installation

1. **Copy Folders**: Drag the `ServerStorage` and `ServerScriptService` folders into your game
2. **Create Events**: In ReplicatedStorage, create a folder called "Events" and add these RemoteEvents:
   - HealthChanged
   - PlayerDied
   - PlayerRevived
   - InventoryUpdated
   - PlayerDataUpdated
   - LevelUp
3. **Start the Script**: `PlayerManager.lua` runs automatically and initializes all systems

## 📚 Systems Overview

### HealthSystem
- Player health management with server authority
- Damage validation prevents exploits
- Health regeneration support
- Death/revive handling

```lua
local health = playerSystems[player.UserId].health
health:takeDamage(10, "Sword")
health:heal(25)
health:die("Fall Damage")
```

### InventorySystem
- Slot-based inventory with server-side validation
- Item stacking with max stack limits
- Whitelist prevents unknown items from being added
- Automatic duplicate prevention

```lua
local inventory = playerSystems[player.UserId].inventory
inventory:addItem("sword", 1)
inventory:removeItem("potion", 1, 5)
local count = inventory:getItemCount("coin")
```

### PlayerDataManager
- AutoSaves every 60 seconds
- DataStore integration with retry logic
- Experience, coins, level management
- Server-side validation prevents value manipulation

```lua
local dataManager = playerSystems[player.UserId].dataManager
dataManager:addExperience(50)
dataManager:addCoins(100)
dataManager:save()
```

### LevelSystem
- Experience-based leveling
- Server-validated level ups
- Experience curve: level * 100 exp needed
- Automatic level progression

```lua
local levelSystem = playerSystems[player.UserId].levelSystem
levelSystem:addExperience(200)
local level, exp, progress = levelSystem:getExpProgress()
```

## 🛡️ Security Features

✅ **Server Authority** - All game logic runs on server only
✅ **Input Validation** - All values checked before processing
✅ **Item Whitelist** - Only predefined items can be added to inventory
✅ **DataStore Retry Logic** - Automatic retries prevent data loss
✅ **Type Checking** - Invalid data types rejected immediately
✅ **Value Bounds** - All values have min/max limits to prevent exploits
✅ **AutoSave** - Player data automatically saved every 60 seconds

## 📝 Valid Items (Inventory)

Edit these in `InventorySystem.lua`:

```lua
local VALID_ITEMS = {
    ["sword"] = {name = "Sword", stackable = false},
    ["potion"] = {name = "Health Potion", stackable = true, maxStack = 99},
    ["coin"] = {name = "Gold Coin", stackable = true, maxStack = 999},
    ["shield"] = {name = "Shield", stackable = false},
    ["bow"] = {name = "Bow", stackable = false},
}
```

Add your own items following this pattern:
```lua
["itemId"] = {
    name = "Display Name",
    stackable = true/false,
    maxStack = 99  -- only if stackable
}
```

## 🔧 How to Use in Your Game

### Example 1: Apply Damage
```lua
-- In a damage script on the server
local PlayerManager = require(game.ServerScriptService.PlayerManager)
local targetPlayer = game.Players:FindFirstChild("PlayerName")
local health = playerSystems[targetPlayer.UserId].health

health:takeDamage(15, "Sword")
```

### Example 2: Give Items
```lua
local inventory = playerSystems[targetPlayer.UserId].inventory
inventory:addItem("sword", 1)
inventory:addItem("potion", 5)
```

### Example 3: Add Rewards
```lua
local levelSystem = playerSystems[targetPlayer.UserId].levelSystem
levelSystem:addExperience(250)

local dataManager = playerSystems[targetPlayer.UserId].dataManager
dataManager:addCoins(50)
```

### Example 4: Check Player Health
```lua
local health = playerSystems[targetPlayer.UserId].health
local current, max = health:getHealth()
if health:isAlive() then
    -- Do something
end
```

## 🎮 Client-Side Integration

LocalScripts receive updates via RemoteEvents:

```lua
-- In a LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local events = ReplicatedStorage.Events

events.HealthChanged:Connect(function(player, currentHealth, maxHealth)
    -- Update UI health bar
    print(player.Name .. " health: " .. currentHealth .. "/" .. maxHealth)
end)

events.LevelUp:Connect(function(player, newLevel)
    print(player.Name .. " leveled up to " .. newLevel)
end)

events.InventoryUpdated:Connect(function(player, items)
    -- Update inventory UI
end)
```

## 📊 Data Persistence

All player data automatically saves to DataStore:
- Saved every 60 seconds
- Automatically loads when player joins
- Includes: Level, Experience, Coins, Inventory

Retrieved data on startup:
```lua
local playerData = dataManager:getData()
-- {level = 5, experience = 250, coins = 500, health = 100, maxHealth = 100}
```

## ⚠️ Important Notes

1. **Server Authority**: Never trust client input. Always validate on server.
2. **DataStore Quotas**: Be aware of DataStore read/write limits
3. **Testing**: Use Studio's "Server" mode to test
4. **Error Handling**: Check console for warnings about invalid operations
5. **Backup**: Export your game regularly to backup player data

## 🔐 Adding More Systems

This architecture makes it easy to add new systems:

1. Create a new module in `ServerStorage/Modules/`
2. Create the class with `.new()` and methods
3. Add it to `PlayerManager.lua`
4. Create RemoteEvents as needed for client communication

## 📞 Troubleshooting

**DataStore errors?** 
- Check Studio settings → Security → Allow HTTP Requests ✓

**Systems not loading?**
- Make sure all module files are in ServerStorage/Modules
- Check that PlayerManager.lua is in ServerScriptService
- Look at Output console for error messages

**Items not adding to inventory?**
- Check that the itemId is in the VALID_ITEMS whitelist
- Verify inventory has space

---

**All code is production-ready and follows Roblox best practices for security and exploit prevention.**
