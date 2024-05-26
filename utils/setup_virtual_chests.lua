-- setup_virtual_environment.lua
-- 1. Check if there is a monitor or minecraft:chest peripheral connected
local monitor = peripheral.find("monitor")
local chest = peripheral.find("minecraft:chest")
local modem = peripheral.find("modem")

print("Setting up missing peripherals...\n")

if modem == nil then
    print("- No modem found: Attaching modem to the back of the computer.")
    periphemu.create('back', 'modem')
end

if monitor == nil then
    print("- No monitors found, adding monitors to the network...")
    periphemu.create(1, 'monitor')
    periphemu.create(2, 'monitor')
end

local function createChest(id)
    print("- No chests found, adding chests to the network...")
    periphemu.create(id, 'minecraft:chest', false)

    -- Add some items to the chest
    print("- Adding some items to the chest...")
    local chest = peripheral.find("minecraft:chest")
    chest.setItem(1, {
        name = "minecraft:diamond",
        count = 42
    })
    chest.setItem(2, {
        name = "minecraft:iron_ingot",
        count = 24
    })
    chest.setItem(3, {
        name = "minecraft:gold_ingot",
        count = 12
    })
end

if chest == nil then
    createChest(1)
    createChest(2)
end

print("\nSetup complete. \n")
print("\n - The chest contains some items for testing purposes.\n")
