-- Import monitor API
local generics = require("generics")

-- Function to track input of items
function trackInput(monitorSide, peripheralSide)
    -- Get a reference to the monitor and the peripheral
    local monitor = peripheral.wrap(monitorSide)
    local interface = peripheral.wrap(peripheralSide)

    -- Get the monitor dimensions and calculate the number of columns and rows
    local monitorWidth, monitorHeight = monitor.getSize()
    local numColumns = math.floor(monitorWidth / 15)
    local numRows = math.floor(monitorHeight / 3)

    -- Initialize the previous items table and the changes table
    local prevItems = {}
    local changes = {}

    -- Continuously fetch and display the items
    while true do
        -- Get items
        local items = interface.items()

        for _, item in ipairs(items) do
            local itemName = generics.shortenName(item.name, math.floor(monitorWidth / numColumns)) -- Fixed operator
            local itemCount = item.count

            -- Save the current count for the next update
            local prevCount = prevItems[itemName] or 0
            prevItems[itemName] = itemCount

            -- Calculate the change from the previous count and update the changes table
            local change = itemCount - prevCount
            changes[itemName] = change

        end

        -- Convert the changes table to a list and sort it by absolute value of change
        local sortedChanges = {}
        for itemName, change in pairs(changes) do
            table.insert(sortedChanges, {
                name = itemName,
                change = change
            })
        end
        table.sort(sortedChanges, function(a, b)
            return math.abs(a.change) > math.abs(b.change)
        end)

        -- Keep only the top X changes
        while #sortedChanges > numColumns * numRows do
            table.remove(sortedChanges)
        end

        -- Display changes in the grid
        generics.displayChangesInGrid(monitor, sortedChanges, numColumns, numRows, prevItems) -- Added prevItems

        sleep(60)
    end
end

-- Automatically find the sides
local monitorSide = generics.findPeripheralSide("monitor")
local peripheralSide = generics.findPeripheralSide("merequester:requester")

if not monitorSide then
    print("Monitor not found.")
    return
end

if not peripheralSide then
    print("ME Requester not found.")
    return
end

-- Call the function to track the input of items
trackInput(monitorSide, peripheralSide)
