-- Include Grid Display API
local GridDisplay = mpm('generics/grid_display')
local Generics = mpm('generics/generics')

-- Function to find the side of a peripheral
local function findPeripheralSide(name)
    local sides = { "top", "bottom", "left", "right", "front", "back" }

    -- Direct connection
    for _, side in ipairs(sides) do
        if peripheral.isPresent(side) and peripheral.getType(side) == name then
            return side
        end
    end

    -- Check peripherals over network
    local peripheralsList = peripheral.getNames()
    local foundPeripherals = {}
    for _, peripheralName in ipairs(peripheralsList) do
        if peripheral.getType(peripheralName) == name then
            table.insert(foundPeripherals, peripheralName)
        end
    end

    if #foundPeripherals > 0 then
        print("Using peripheral:", foundPeripherals[1])
        return foundPeripherals[1]
    end

    return nil
end

-- Function to fetch items from all connected chests
local function fetchItemsFromChests()
    local chests = {}
    local peripheralsList = peripheral.getNames()

    for _, peripheralName in ipairs(peripheralsList) do
        if peripheral.hasType(peripheralName, "inventory") then
            table.insert(chests, peripheral.wrap(peripheralName))
        end
    end

    local allItems = {}
    for _, chest in ipairs(chests) do
        local items = chest.list()
        if items then -- Check if items is not nil
            for slot, item in pairs(items) do
                item.slot = slot
                item.chest = chest
                table.insert(allItems, item)
            end
        end
    end

    -- Consolidate items
    local consolidatedItems = {}
    for _, item in ipairs(allItems) do
        local id = item.name
        if consolidatedItems[id] then
            consolidatedItems[id].count = consolidatedItems[id].count + item.count
        else
            consolidatedItems[id] = {
                name = item.name,
                count = item.count
            }
        end
    end

    -- Convert the consolidated items dictionary into a list
    local items = {}
    for _, item in pairs(consolidatedItems) do
        table.insert(items, item)
    end

    return items
end

-- Function to display item information in a grid
local function displayItemInfo(monitorSide)
    -- Get a reference to the monitor
    local monitor = peripheral.wrap(monitorSide)
    local display = GridDisplay.new(monitor)

    -- Define a formatting callback for the grid display
    local function format_callback(item)
        return {
            lines = { Generics.prettifyItemIdentifier(item.name), tostring(item.count) },
            colors = { colors.white, colors.white }
        }
    end

    -- Continuously fetch and display the items
    while true do
        local items = fetchItemsFromChests()
        print(textutils.serialize(items))

        -- Sort items
        table.sort(items, function(a, b)
            return a.count > b.count
        end)

        -- Display the items in the grid
        local success, err = pcall(display.display, display, items, format_callback)
        if not success then
            print("Error displaying items:", err)
        end

        sleep(1)
    end
end

-- Automatically find the monitor side
local monitorSide = findPeripheralSide("monitor")

if not monitorSide then
    print("Monitor not found.")
    return
end

-- Call the function to display the item information
local success, err = pcall(displayItemInfo, monitorSide)
if not success then
    print("Error in displayItemInfo:", err)
end
displayItemInfo(monitorSide)
