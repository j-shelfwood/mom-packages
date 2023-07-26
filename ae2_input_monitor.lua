local generics = require("generics")

-- Get monitor and peripheral
local monitorSide = generics.findPeripheralSide("monitor")
local requesterSide = generics.findPeripheralSide("merequester:requester")

if monitorSide == nil or requesterSide == nil then
    print("Monitor or ME Requester not found")
    return
end

local monitor = peripheral.wrap(monitorSide)
local requester = peripheral.wrap(requesterSide)

-- Initialize previous items table
local prevItems = {}

-- Get monitor dimensions and calculate grid dimensions
local monitorWidth, monitorHeight = monitor.getSize()
local numColumns = 4
local numRows = math.floor(monitorHeight / 2) -- Changed to math.floor

-- Set the text scale
monitor.setTextScale(1)

-- Continuously fetch and display the items
while true do
    -- Get items
    local items = requester.items()

    -- Calculate changes from the previous update
    local changes = {}
    for _, item in pairs(items) do
        local itemName = generics.shortenName(item.label, math.floor(monitorWidth / numColumns))
        local itemCount = item.count

        -- Calculate the change from the previous count
        local prevCount = prevItems[itemName] or 0
        local change = itemCount - prevCount

        -- Save the current count for the next update
        prevItems[itemName] = itemCount

        -- Add to the changes table
        table.insert(changes, {
            name = itemName,
            change = change,
            symbol = change >= 0 and "+" or "-"
        })
    end

    -- Sort the changes table
    table.sort(changes, function(a, b)
        return math.abs(a.change) > math.abs(b.change)
    end)

    -- Display changes in the grid
    generics.displayChangesInGrid(monitor, changes, numColumns, numRows)

    sleep(10)
end
