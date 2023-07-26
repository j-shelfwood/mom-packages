-- Import generics API
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

            -- Calculate the change from the previous count and update the changes table
            if prevItems[itemName] then
                local change = itemCount - prevItems[itemName]
                changes[itemName] = change
            end

            -- Save the current count for the next update
            prevItems[itemName] = itemCount
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

-- Function to display changes in a grid
function generics.displayChangesInGrid(monitor, changes, numColumns, numRows, prevItems) -- Added prevItems
    -- Get monitor dimensions and calculate cell dimensions
    local monitorWidth, monitorHeight = monitor.getSize()
    local cellWidth = math.floor(monitorWidth / numColumns)
    local cellHeight = math.floor(monitorHeight / numRows)

    -- Clear the monitor and write title
    monitor.clear()
    generics.writeCentered(monitor, 1, math.floor(monitorWidth / 2), monitorWidth, 1, "ME SYSTEM INPUT", 1) -- Fixed operator

    -- Display changes in the grid
    for i = 1, math.min(#changes, numColumns * numRows) do
        local row = math.floor((i - 1) / numColumns) + 1 + 1 -- Add 1 to account for title
        local col = (i - 1) % numColumns + 1
        local change = changes[i]
        local changeSign = change.change > 0 and "+" or ""
        local changeColor = change.change > 0 and colors.green or colors.red

        -- Write the item name, change and total change in their respective cell
        generics.writeCentered(monitor, row, col, cellWidth, cellHeight, change.name, 2) -- Updated line number
        generics.writeCentered(monitor, row, col, cellWidth, cellHeight, tostring(prevItems[change.name]), 3) -- Updated line number
        generics.writeWithColor(monitor, row, col, cellWidth, cellHeight, changeSign .. tostring(change.change), 4,
            changeColor) -- Updated line number
    end
end
