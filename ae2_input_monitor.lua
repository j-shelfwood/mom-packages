-- Function to find peripheral side
function findPeripheralSide(name)
    local sides = {"top", "bottom", "left", "right", "front", "back"}
    for _, side in ipairs(sides) do
        if peripheral.isPresent(side) and peripheral.getType(side) == name then
            return side
        end
    end
    return nil
end

-- Function to write text in a cell
function writeCell(monitor, row, col, cellWidth, cellHeight, text, line, color)
    local x = (col - 1) * cellWidth + math.floor((cellWidth - #text) / 2) + 1
    local y = (row - 1) * cellHeight + line
    monitor.setCursorPos(x, y)
    monitor.setTextColor(color)
    monitor.write(text)
end

-- Function to shorten item names if they're too long
function shortenName(name)
    if #name <= 18 then
        return name
    elseif #name > 30 then
        return name:sub(1, 10) .. "..." .. name:sub(-10, -1)
    else
        return name:sub(1, 18) .. "..."
    end
end

-- Function to display item information in a grid
function displayItemInfo(monitorSide, peripheralSide)
    -- Get a reference to the monitor and the peripheral
    local monitor = peripheral.wrap(monitorSide)
    local interface = peripheral.wrap(peripheralSide)

    -- Initialize the previous items table and current items table
    local prevItems = {}
    local currItems = {}

    -- Continuously fetch and display the items
    while true do
        -- Get items
        local items = interface.items()

        -- Calculate change for each item and store it in the item table
        for _, item in ipairs(items) do
            local itemName = item.name
            local itemCount = item.count
            local itemChangeMagnitude = 0
            local itemChangeSign = "+"

            -- Calculate the change from the previous count
            if prevItems[itemName] then
                local change = itemCount - prevItems[itemName].count
                itemChangeMagnitude = math.abs(change)
                if change > 0 then
                    itemChangeSign = "+"
                elseif change < 0 then
                    itemChangeSign = "-"
                end
            end

            -- Save the current count and change for the next update
            prevItems[itemName] = {
                count = itemCount,
                changeMagnitude = itemChangeMagnitude,
                changeSign = itemChangeSign
            }

            -- Add change info to item table
            item.changeMagnitude = itemChangeMagnitude
            item.changeSign = itemChangeSign
        end

        -- Sort items by change magnitude and sign
        table.sort(items, function(a, b)
            if a.changeMagnitude == b.changeMagnitude then
                return a.changeSign > b.changeSign -- Positive change comes first
            else
                return a.changeMagnitude > b.changeMagnitude
            end
        end)

        -- Get monitor dimensions and calculate cell dimensions
        local monitorWidth, monitorHeight = monitor.getSize()
        local textScale = calculate_text_scale(#items, monitorWidth, monitorHeight)
        local numRows, numColumns = calculate_grid_dimensions(#items, monitorWidth, monitorHeight, textScale)
        local cellWidth = math.floor(monitorWidth / numColumns)
        local cellHeight = math.floor(monitorHeight / numRows)

        -- Display items in the grid
        for i = 1, #items do
            local row = math.floor((i - 1) / numColumns) + 1
            local col = (i - 1) % numColumns + 1
            local item = items[i]
            local itemName = shortenName(item.name)
            local itemCount = item.count
            local itemChange = item.changeSign .. tostring(item.changeMagnitude)

            -- Check if item's info has changed
            if not currItems[i] or currItems[i].name ~= itemName or currItems[i].count ~= itemCount or
                currItems[i].change ~= itemChange then
                -- Update current items table
                currItems[i] = {
                    name = itemName,
                    count = itemCount,
                    change = itemChange
                }

                -- Clear cell
                for line = 1, cellHeight do
                    writeCell(monitor, row, col, cellWidth, cellHeight, string.rep(" ", cellWidth), line, colors.white)
                end

                -- Write the item name, count and change in their respective cell
                writeCell(monitor, row, col, cellWidth, cellHeight, itemName, 1, colors.white)
                writeCell(monitor, row, col, cellWidth, cellHeight, tostring(itemCount), 2, colors.white)
                writeCell(monitor, row, col, cellWidth, cellHeight, itemChange, 3, colors.white)
            end
        end

        sleep(0.5)
    end
end

-- Automatically find the sides
local monitorSide = findPeripheralSide("monitor")
local peripheralSide = findPeripheralSide("merequester:requester")

if not monitorSide then
    print("Monitor not found.")
    return
end

if not peripheralSide then
    print("ME Requester not found.")
    return
end

-- Call the function to display the item information
displayItemInfo(monitorSide, peripheralSide)
