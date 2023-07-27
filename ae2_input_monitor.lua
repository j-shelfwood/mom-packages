local generics = require("generics")
local GridMonitor = require("grid_monitor") -- require the GridMonitor module

local scale = tonumber(arg[1]) or 1

-- Function to track input of items
function trackInput(monitorSide, peripheralSide)
    -- Get a reference to the monitor and the peripheral
    local gm = GridMonitor.new(peripheral.wrap(monitorSide), scale) -- use GridMonitor
    gm:debugInfo() -- print debug information
    local requester = peripheral.wrap(peripheralSide)

    -- Initialize the previous items table and the changes table
    local prevItems = {}
    local changes = {}

    -- Continuously fetch and display the items
    while true do
        -- Get items
        local items = requester.items()

        -- Initialize the current items table
        local currentItems = {}

        for _, item in ipairs(items) do
            local itemName = generics.shortenName(item.name, 13)
            local itemCount = item.count

            -- Save the current count for calculating the change
            currentItems[itemName] = itemCount

            -- If the item was already present, calculate the change
            if prevItems[itemName] then
                local change = itemCount - prevItems[itemName]

                -- If there was a change, store it
                if change ~= 0 then
                    changes[itemName] = {
                        change = math.abs(change),
                        sign = change > 0 and "+" or "-"
                    }
                else
                    changes[itemName] = nil
                end
            end
        end

        -- Update the previous items table
        prevItems = currentItems

        -- Convert the changes table to a list and sort it by absolute value of change
        local sortedChanges = {}
        for itemName, changeData in pairs(changes) do
            table.insert(sortedChanges, {
                name = itemName,
                change = changeData and changeData.change or 0,
                sign = changeData and changeData.sign or "+"
            })
        end
        table.sort(sortedChanges, function(a, b)
            return a.change > b.change
        end)

        -- Keep only the top X changes
        while #sortedChanges > gm.numColumns * gm.numRows do
            table.remove(sortedChanges)
        end

        -- Clear the monitor and redraw the grid
        gm:clearGrid()

        -- Display changes in the grid
        gm:displayData(sortedChanges, function(item)
            return item.name .. "\n" .. item.sign .. " " .. tostring(item.change)
        end)

        sleep(10)
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
