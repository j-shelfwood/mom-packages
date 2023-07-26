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
function generics.shortenName(name)
    if #name <= 18 then
        return name
    elseif #name > 30 then
        return name:sub(1, 10) .. "-" .. name:sub(-10, -1)
    else
        return name:sub(1, 18) .. "-"
    end
end

-- Function to write centered text in a cell
function generics.writeCentered(monitor, row, col, cellWidth, cellHeight, text, line)
    local x = (col - 1) * cellWidth + math.floor((cellWidth - #text) / 2) + 1
    local y = (row - 1) * cellHeight + line
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

-- Function to write text in a cell with color
function generics.writeWithColor(monitor, row, col, cellWidth, cellHeight, text, line, color)
    monitor.setTextColor(color)
    generics.writeCentered(monitor, row, col, cellWidth, cellHeight, text, line)
    monitor.setTextColor(colors.white) -- set the color back to white after writing
end

-- Function to print grid lines
function generics.printGridLines(monitor, numColumns, numRows, cellWidth, cellHeight)
    local monitorWidth, monitorHeight = monitor.getSize()
    for row = 0, numRows do
        local y = row * cellHeight
        monitor.setCursorPos(1, y)
        monitor.write(string.rep("-", monitorWidth))
    end
    for col = 0, numColumns do
        local x = col * cellWidth
        for i = 0, monitorHeight do
            monitor.setCursorPos(x, i)
            monitor.write("|")
        end
    end
end

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

return generics
