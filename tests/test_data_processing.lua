-- test_script.lua
-- Include Data Processing API
local AEInterface = require('data_processing')

-- SECTION: Helper functions

-- Function to get an item from a list by technical name
local function get_item_by_technical_name(items, techName)
    for _, item in ipairs(items) do
        if item.technicalName == techName then
            return item
        end
    end
    return nil
end

-- Function to get the item name from either of two items
local function get_item_name(item1, item2)
    if item1 then
        return item1.name
    elseif item2 then
        return item2.name
    end
    return "Unknown item"
end

-- Function to print an item to the file
local function print_item(file, item)
    if item then
        file.writeLine(item.name .. ": " .. item.count)
    else
        file.writeLine("Item not found.")
    end
end

-- Function to print a change to the file
local function print_change(file, change)
    if change then
        file.writeLine(change.name .. ": " .. change.change .. " (" .. change.operation .. ")")
    else
        file.writeLine("No change.")
    end
end

-- Function to get a change from a list by name
local function get_change_by_name(changes, name)
    for _, change in ipairs(changes) do
        if change.name == name then
            return change
        end
    end
    return nil
end

-- SECTION: Main logic

-- Open the file in write mode
local file = fs.open("test_output.txt", "w")

-- Fetch items twice with a delay
local prev_items = AEInterface.items()
os.sleep(10)
local curr_items = AEInterface.items()

-- Calculate changes
local changes = AEInterface.changes(prev_items, curr_items)

-- List of items to monitor
local items_to_monitor = {"brazier:ash", "minecraft:charcoal", "minecraft:crossbow"}

-- Monitor the specified items
for _, techName in ipairs(items_to_monitor) do
    local prev_item = get_item_by_technical_name(prev_items, techName)
    local curr_item = get_item_by_technical_name(curr_items, techName)
    local itemName = get_item_name(prev_item, curr_item)
    file.writeLine("\nMonitoring: " .. itemName)
    print_item(file, prev_item)
    print_item(file, curr_item)
    print_change(file, get_change_by_name(changes, itemName))
end

-- Close the file
file.close()

print("Test output saved to test_output.txt")
