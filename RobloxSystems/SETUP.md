# Quick Setup Guide

## 30-Second Setup

### Step 1: Copy Folders
Copy the entire `ServerStorage` and `ServerScriptService` folder structure into your Roblox game.

### Step 2: Create Events
In your game, go to **ReplicatedStorage** and create:
1. New Folder → Name it **"Events"**
2. Inside Events, create 6 RemoteEvents:
   - HealthChanged
   - PlayerDied
   - PlayerRevived
   - InventoryUpdated
   - PlayerDataUpdated
   - LevelUp

### Step 3: Done!
The systems auto-initialize when players join.

---

## File Structure Must Look Like This:

```
ServerStorage/
  Modules/
    - HealthSystem.lua
    - InventorySystem.lua
    - PlayerDataManager.lua
    - LevelSystem.lua

ServerScriptService/
  - PlayerManager.lua

ReplicatedStorage/
  Events/
    - HealthChanged (RemoteEvent)
    - PlayerDied (RemoteEvent)
    - PlayerRevived (RemoteEvent)
    - InventoryUpdated (RemoteEvent)
    - PlayerDataUpdated (RemoteEvent)
    - LevelUp (RemoteEvent)
```

## Using the Systems

Access player systems in your scripts:

```lua
-- In server scripts
local playerSystems = require(game.ServerScriptService.PlayerManager)

-- Get a player's systems
local userId = player.UserId
local health = playerSystems[userId].health
local inventory = playerSystems[userId].inventory
local dataManager = playerSystems[userId].dataManager
local levelSystem = playerSystems[userId].levelSystem

-- Use them
health:takeDamage(20)
inventory:addItem("sword", 1)
dataManager:addCoins(100)
levelSystem:addExperience(50)
```

## That's It!

Your game now has:
- ✅ Server-sided health system
- ✅ Exploit-proof inventory
- ✅ Auto-saving player data with DataStore
- ✅ Level & experience system
- ✅ All validated on server (no exploits)

See **README.md** for detailed documentation.
