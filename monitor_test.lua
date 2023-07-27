local generics = require("generics")

-- Function to display test data in a grid
function displayTestData(monitor, textScale)
    -- Set text scale
    monitor.setTextScale(textScale)

    -- Get monitor dimensions and calculate the number of columns and rows
    local monitorWidth, monitorHeight = monitor.getSize()
    local numColumns = math.floor(monitorWidth / 15)
    local numRows = math.floor(monitorHeight / 3)

    -- Clear the monitor and write title
    monitor.clear()
    generics.writeCentered(monitor, 1, monitorWidth, "ME SYSTEM INPUT")

    -- Display test data in the grid
    for i = 1, numColumns * numRows do
        local row = math.floor((i - 1) / numColumns) + 2
        local col = (i - 1) % numColumns + 1
        local cellWidth = math.floor(monitorWidth / numColumns)
        local cellHeight = math.floor(monitorHeight / numRows)

        -- Write some test data in each cell
        for line = 1, cellHeight do
            generics.writeCentered(monitor, (row - 1) * cellHeight + line, cellWidth, "Test data " .. i)
        end
    end
end

-- Automatically find the monitor
local monitorSide = generics.findPeripheralSide("monitor")

if not monitorSide then
    print("Monitor not found.")
    return
end

local monitor = peripheral.wrap(monitorSide)

-- Cycle through different text scales and display test data
local textScales = {0.5, 1, 1.5, 2}
while true do
    for _, textScale in ipairs(textScales) do
        displayTestData(monitor, textScale)
        sleep(5)
    end
end
