local generics = require("generics")
local GridMonitor = require("grid_monitor") -- require the GridMonitor module

local scale = tonumber(arg[1]) or 1

-- Function to track input of items
function trackInput(monitorSide, peripheralSide)
    local monitor = peripheral.wrap(monitorSide)
    local gm = GridMonitor.new(monitor, scale) -- use GridMonitor
    gm:debugInfo() -- print debug information
    local requester = peripheral.wrap(peripheralSide)

    local prevItems = {}
    local changes = {}

    while true do
        local items = requester.items()
        local currentItems = {}

        for _, item in ipairs(items) do
            local itemName = generics.shortenName(item.name, math.floor(monitorWidth / numColumns)) -- changed from item.label to item.name
            local itemCount = item.count

            currentItems[itemName] = itemCount

            if prevItems[itemName] then
                local change = itemCount - prevItems[itemName]

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

        prevItems = currentItems

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

        while #sortedChanges > numColumns * numRows do
            table.remove(sortedChanges)
        end

        gm:clearGrid()
        gm:displayData(sortedChanges, function(item)
            return item.name .. "\n" .. item.sign .. " " .. tostring(item.change)
        end)

        sleep(30)
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
