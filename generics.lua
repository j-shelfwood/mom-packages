local generics = {}

-- Function to find peripheral side
function generics.findPeripheralSide(name)
    local sides = {"top", "bottom", "left", "right", "front", "back"}
    for _, side in ipairs(sides) do
        if peripheral.isPresent(side) and peripheral.getType(side) == name then
            return side
        end
    end
    return nil
end

-- Function to shorten item names if they're too long
function generics.shortenName(name, maxLength)
    if #name <= maxLength then
        return name
    else
        local partLength = math.floor((maxLength - 1) / 2) -- subtract one to account for the hyphen
        return name:sub(1, partLength) .. "-" .. name:sub(-partLength)
    end
end

-- Function to display changes in a grid
function generics.displayChangesInGrid(monitor, changes, numColumns, numRows)
    -- Get monitor dimensions and calculate cell dimensions
    local monitorWidth, monitorHeight = monitor.getSize()
    local cellWidth = math.floor(monitorWidth / numColumns)
    local cellHeight = math.floor(monitorHeight / numRows)

    -- Clear the monitor and write title
    monitor.clear()
    generics.writeCentered(monitor, 1, 1, monitorWidth, 1, "ME SYSTEM INPUT", 1)

    -- Display changes in the grid
    for i, change in ipairs(changes) do
        local row = math.floor((i - 1) / numColumns) + 2
        local col = (i - 1) % numColumns + 1
        local changeColor = change.sign == "+" and colors.green or colors.white
        if change.sign == "-" then
            changeColor = colors.red
        end

        -- Write the item name, change, and total in their respective cell
        generics.writeCentered(monitor, row, col, cellWidth, cellHeight, change.name, 1)
        monitor.setTextColor(changeColor)
        generics.writeCentered(monitor, row, col, cellWidth, cellHeight, change.sign .. tostring(change.change), 2)
        monitor.setTextColor(colors.white)
    end
end

-- Function to write centered text in a cell
function generics.writeCentered(monitor, row, col, cellWidth, cellHeight, text, line)
    local x = (col - 1) * cellWidth + math.floor((cellWidth - #text) / 2) + 1
    local y = (row - 1) * cellHeight + line
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

return generics
