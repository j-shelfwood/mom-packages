-- Inventory_changes.lua
-- Include Data Processing and Grid Display APIs
local DataProcessing = mpm('peripherals/data_processing')
local GridDisplay = mpm('generics/grid_display')
local generics = mpm('generics/generics')

-- Wrap the monitor
local monitor = peripheral.wrap(generics.findPeripheralSide('monitor'))
local display = GridDisplay.new(monitor)

-- Define a formatting callback for the grid display
local function format_callback(item)
    local color = item.operation == "+" and colors.green or colors.red
    return {
        lines = { item.name, tostring(item.count), item.operation .. tostring(item.change) },
        colors = { colors.white, colors.white, color }
    }
end

-- Function to refresh the display
local function refresh_display()
    local curr_items = DataProcessing.fetch_items()

    if prev_items then
        local changes = DataProcessing.calculate_changes(prev_items, curr_items)

        -- Sort the changes by the change amount (descending)
        table.sort(changes, function(a, b)
            return a.change > b.change
        end)
        -- If there are no changes, display a message on the monitor
        if #changes == 0 then
            -- Write it manually
            monitor.clear()
            monitor.setCursorPos(1, 1)
            monitor.write("No changes detected")
            print("No changes detected")
            return
        end

        -- Only display the top 25 changes
        changes = { table.unpack(changes, 1, 30) }

        -- Display the changes on the monitor
        display:display(changes, format_callback)
        print("Detected " .. #changes .. " changes")
    end
    -- Update prev_items for the next iteration
    prev_items = curr_items
end

-- Initialize prev_items
local prev_items = DataProcessing.fetch_items()

-- Run the refresh_display function every 15 seconds
while true do
    refresh_display()
    os.sleep(15)
end
