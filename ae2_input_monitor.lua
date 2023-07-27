local generics = require("generics")
local peripheralSide = generics.findPeripheralSide("merequester:requester")
local monitorSide = generics.findPeripheralSide("monitor")

-- Set up monitor
local monitor = peripheral.wrap(monitorSide)
monitor.setTextScale(0.7)

-- Get monitor dimensions
local monitorWidth, monitorHeight = monitor.getSize()

-- Calculate cell dimensions for a 5x7 grid
local cellWidth = math.floor(monitorWidth / 7)
local cellHeight = math.floor(monitorHeight / 5)

-- Store previous items
local prevItems = {}

-- Function to track input of items
while true do
    -- Get items
    local items = peripheral.wrap(peripheralSide).items()
    local changes = {}

    -- Save previous terminal and redirect to monitor
    local prevTerm = term.redirect(monitor)

    -- Clear the monitor
    monitor.setBackgroundColor(colors.black)
    monitor.clear()

    -- Draw grid
    paintutils.drawBox(1, 1, monitorWidth, monitorHeight, colors.white)

    -- Handle each item
    for _, item in ipairs(items) do
        local itemName = generics.shortenName(item.name, 15)
        local itemCount = item.count
        local change = 0

        -- If the item was already present, calculate the change
        if prevItems[itemName] then
            change = itemCount - prevItems[itemName]
        end

        -- Save the current count for next iteration
        prevItems[itemName] = itemCount

        -- Display the changes
        -- Calculate center of each cell for text placement
        local x = (_ - 1) % 7 * cellWidth + math.floor(cellWidth / 2)
        local y = math.floor((_ - 1) / 7) * cellHeight + math.floor(cellHeight / 2)

        -- Write item name centered
        monitor.setCursorPos(x - math.floor(#itemName / 2), y)
        monitor.setTextColor(colors.white)
        monitor.setBackgroundColor(colors.black) -- Reset the background color before writing
        monitor.write(itemName)

        -- Write change with color centered
        local changeStr = change < 0 and "-" .. tostring(math.abs(change)) or "+" .. tostring(change)
        monitor.setCursorPos(x - math.floor(#changeStr / 2), y + 1)
        if change < 0 then
            monitor.setTextColor(colors.red)
        else
            monitor.setTextColor(colors.green)
        end
        monitor.setBackgroundColor(colors.black) -- Reset the background color before writing
        monitor.write(changeStr)
    end

    -- Restore original terminal
    term.redirect(prevTerm)

    -- Wait before next iteration
    sleep(10)
end
