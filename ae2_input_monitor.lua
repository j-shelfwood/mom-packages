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

-- Keep track of changes history
local changesHistory = {}

-- Set sleep seconds
local sleepSeconds = 30

-- Initialize the iteration number
local iteration = 0

while true do
    -- Increment the iteration number
    iteration = iteration + 1

    -- Get items
    local items = peripheral.wrap(peripheralSide).items()
    local currentItems = {}

    for _, item in ipairs(items) do
        local itemName = generics.shortenName(item.name, 15)
        local itemCount = item.count

        -- Save the current count for calculating the change
        currentItems[itemName] = itemCount

        -- If the item was already present, calculate the change
        if prevItems[itemName] then
            local change = itemCount - prevItems[itemName]

            -- If there was a change, store it
            if change ~= 0 then
                changesHistory[itemName] = {
                    change = math.abs(change),
                    sign = change > 0 and "+" or "-",
                    iteration = iteration,
                    timestamp = os.time()
                }
            end
        end
    end

    -- Update the previous items table
    prevItems = currentItems

    -- Sort changes history by iteration and change
    local sortedChanges = {}
    for itemName, changeData in pairs(changesHistory) do
        table.insert(sortedChanges, {
            name = itemName,
            change = changeData.change,
            sign = changeData.sign,
            iteration = changeData.iteration,
            timestamp = changeData.timestamp
        })
    end
    table.sort(sortedChanges, function(a, b)
        if a.iteration == b.iteration then
            return a.change > b.change
        else
            return a.iteration > b.iteration
        end
    end)

    -- Prune changes history to keep only the top 84 changes
    changesHistory = {}
    for i = 1, math.min(#sortedChanges, 84) do
        changesHistory[sortedChanges[i].name] = sortedChanges[i]
    end

    -- Display changes in the monitor
    local prevTerm = term.redirect(monitor)
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    paintutils.drawBox(1, 1, monitorWidth, monitorHeight, colors.white)

    for i, item in ipairs(sortedChanges) do
        if i > 84 then
            break
        end
        local itemName = item.name
        local change = item.change
        local sign = item.sign
        local secondsAgo = (iteration - item.iteration) * sleepSeconds

        -- Calculate center of each cell for text placement
        local x = (i - 1) % 7 * cellWidth + math.ceil(cellWidth / 2)
        local y = math.floor((i - 1) / 7) * cellHeight + math.ceil(cellHeight / 2)

        -- Write item name centered
        monitor.setCursorPos(x - math.floor(#itemName / 2), y)
        monitor.setTextColor(colors.white)
        monitor.setBackgroundColor(colors.black)
        monitor.write(itemName)

        -- Write change with color centered
        local changeStr = sign .. tostring(change)
        monitor.setCursorPos(x - math.floor(#changeStr / 2), y + 1)
        if sign == "-" then
            monitor.setTextColor(colors.red)
        else
            monitor.setTextColor(colors.green)
        end
        monitor.setBackgroundColor(colors.black)
        monitor.write(changeStr)

        -- Write seconds ago
        local secondsAgoStr = tostring(secondsAgo) .. " sec. ago"
        monitor.setCursorPos(x - math.floor(#secondsAgoStr / 2), y + 2)
        monitor.setTextColor(colors.yellow)
        monitor.setBackgroundColor(colors.black)
        monitor.write(secondsAgoStr)
    end

    -- Restore original terminal
    term.redirect(prevTerm)

    -- Wait before next iteration
    sleep(sleepSeconds)
end
