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

    -- Initialize the flag for the first run
    local isFirstRun = true

    -- Continuously fetch and display the items
    while true do
        -- Get items
        local items = interface.items()

        -- Initialize the changes table
        local changes = {}

        for _, item in ipairs(items) do
            local itemName = generics.shortenName(item.name, math.floor(monitorWidth / numColumns))
            local itemCount = item.count

            -- If not the first run and the item was already present, calculate the change
            if not isFirstRun and prevItems[itemName] then
                local change = itemCount - prevItems[itemName]

                -- If there was a change, store it
                if change ~= 0 then
                    changes[itemName] = {
                        change = math.abs(change),
                        sign = change > 0 and "+" or "-"
                    }
                end
            end

            -- Save the current count for the next update
            prevItems[itemName] = itemCount
        end

        -- If not the first run, sort and display the changes
        if not isFirstRun then
            -- Convert the changes table to a list and sort it by absolute value of change
            local sortedChanges = {}
            for itemName, changeData in pairs(changes) do
                table.insert(sortedChanges, {
                    name = itemName,
                    change = changeData.change,
                    sign = changeData.sign
                })
            end
            table.sort(sortedChanges, function(a, b)
                return a.change > b.change
            end)

            -- Keep only the top X changes
            while #sortedChanges > numColumns * numRows do
                table.remove(sortedChanges)
            end

            -- Display changes in the grid
            generics.displayChangesInGrid(monitor, sortedChanges, numColumns, numRows, prevItems)
        end

        -- After the first run, set the flag to false
        isFirstRun = false

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
