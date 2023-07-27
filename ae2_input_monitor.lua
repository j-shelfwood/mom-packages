local generics = require("generics")
local peripheralSide = generics.findPeripheralSide("merequester:requester")
local monitorSide = generics.findPeripheralSide("monitor")

-- Set up monitor
local monitor = peripheral.wrap(monitorSide)
monitor.setTextScale(0.7)

-- Get monitor dimensions
local monitorWidth, monitorHeight = monitor.getSize()

-- Calculate cell dimensions for a 7x12 grid
local cellWidth = monitorWidth / 7
local cellHeight = monitorHeight / 12

-- Store previous items
local prevItems = {}

-- Store previous changes and timestamps
local changes = {}
local changeTimestamps = {}

-- Maximum changes to display
local maxChanges = 7 * 12

-- Function to track input of items
while true do
    -- Get items
    local items = peripheral.wrap(peripheralSide).items()
    local currentItems = {}

    -- Calculate changes and sort items
    for _, item in ipairs(items) do
        local itemName = generics.shortenName(item.name, 15)
        local itemCount = item.count

        -- Save the current count for calculating the change
        currentItems[itemName] = itemCount

        -- If the item was already present, calculate the change
        if prevItems[itemName] then
            local change = itemCount - prevItems[itemName]

            -- If there was a change, store it and update the timestamp
            if change ~= 0 then
                changes[itemName] = {
                    change = math.abs(change),
                    sign = change > 0 and "+" or "-"
                }
                -- Update the timestamp only if the count changes
                changeTimestamps[itemName] = os.time()
            elseif changes[itemName] then
                -- If no change, but item exists in changes, remove it
                changes[itemName] = nil
                changeTimestamps[itemName] = nil
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
            change = changeData.change,
            sign = changeData.sign,
            time = changeTimestamps[itemName]
        })
    end

    -- Sort by change (desc) and time (desc)
    table.sort(sortedChanges, function(a, b)
        if a.change == b.change then
            return a.time > b.time
        else
            return a.change > b.change
        end
    end)

    -- If fewer changes than display slots, fill with non-changed items
    if #sortedChanges < maxChanges then
        for itemName, itemCount in pairs(currentItems) do
            if not changes[itemName] then
                table.insert(sortedChanges, {
                    name = itemName,
                    change = 0,
                    sign = "+",
                    time = changeTimestamps[itemName] or 0
                })
                if #sortedChanges >= maxChanges then
                    break
                end
            end
        end
    end

    -- Save previous terminal and redirect to monitor
    local prevTerm = term.redirect(monitor)

    -- Clear the monitor
    monitor.setBackgroundColor(colors.black)
    monitor.clear()

    -- Draw grid
    paintutils.drawBox(1, 1, monitorWidth, monitorHeight, colors.white)

    -- Handle each item
    for _, item in ipairs(sortedChanges) do
        local itemName = item.name
        local change = item.change
        local sign = item.sign
        local time = item.time

        -- Calculate center of each cell for text placement
        local x = (_ - 1) % 7 * cellWidth + math.ceil(cellWidth / 2)
        local y = math.floor((_ - 1) / 7) * cellHeight + math.ceil(cellHeight / 2)

        -- Write item name centered
        monitor.setCursorPos(x - math.floor(#itemName / 2), y)
        monitor.setTextColor(colors.white)
        monitor.setBackgroundColor(colors.black) -- Reset the background color before writing
        monitor.write(itemName)

        -- Write change with color centered
        local changeStr = sign .. tostring(change)
        monitor.setCursorPos(x - math.floor(#changeStr / 2), y + 1)
        if sign == "-" then
            monitor.setTextColor(colors.red)
        else
            monitor.setTextColor(colors.green)
        end
        monitor.setBackgroundColor(colors.black) -- Reset the background color before writing
        monitor.write(changeStr)

        -- Write time since change
        if change ~= 0 then
            local timeStr = os.time() - time .. " sec. ago"
            monitor.setCursorPos(x - math.floor(#timeStr / 2), y + 2)
            monitor.setTextColor(colors.gray)
            monitor.setBackgroundColor(colors.black) -- Reset the background color before writing
            monitor.write(timeStr)
        end
    end

    -- Restore original terminal
    term.redirect(prevTerm)

    -- Wait before next iteration
    sleep(30)
end
