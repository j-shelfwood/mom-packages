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

    -- Restore original terminal
    term.redirect(prevTerm)

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
        local x = (_ - 1) % 7 * cellWidth + 2 -- Add margin of 1 pixel
        local y = math.floor((_ - 1) / 7) * cellHeight + 2 -- Add margin of 1 pixel

        -- Make sure we're not writing on the grid lines
        if x % cellWidth ~= 1 and y % cellHeight ~= 1 then
            monitor.setCursorPos(x, y)
            monitor.setTextColor(colors.white)
            monitor.write(itemName)

            -- Write change with color
            monitor.setCursorPos(x, y + 1)
            if change < 0 then
                monitor.setTextColor(colors.red)
                monitor.write("-" .. tostring(math.abs(change)))
            else
                monitor.setTextColor(colors.green)
                monitor.write("+" .. tostring(change))
            end
        end
    end

    -- Wait before next iteration
    sleep(10)
end
