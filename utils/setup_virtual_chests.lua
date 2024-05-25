-- setup_virtual_environment.lua
-- 1. Check if there is a monitor or minecraft:chest peripheral connected
local monitor = peripheral.find("monitor")
local chest = peripheral.find("minecraft:chest")

print("Setting up missing peripherals...\n")

if monitor == nil then
    print("- No monitor found: Attaching monitor to the right side of the computer.")
    periphemu.create('right', 'monitor')
end

if chest == nil then
    print("- No chest found: Attaching chest to the left side of the computer.")
    periphemu.create('left', 'minecraft:chest', false)

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

print("\nSetup complete. \n")
print("\n - The chest contains some items for testing purposes.\n")
