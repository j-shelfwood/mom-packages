-- Include Data Processing and Grid Display APIs
local DataProcessing = require('data_processing')
local GridDisplay = require('grid_display')
local generics = require('generics')

-- Wrap the monitor
local monitor = peripheral.wrap(generics.findPeripheralSide('monitor')) -- replace "monitor_side" with the actual side of the monitor
local display = GridDisplay.new(monitor)

-- Define a formatting callback for the grid display
local function format_callback(item)
    -- If item.operation = '+' then color = 'green' else color = 'red
    local color = item.operation == "+" and colors.green or colors.red
    return {
        line_1 = item.name,
        color_1 = colors.white,
        line_2 = tostring(item.count),
        color_2 = colors.white,
        line_3 = item.operation .. tostring(item.change),
        color_3 = color
    }
end

-- Function to refresh the display
local function refresh_display()
    -- Fetch items from the AE2 system
    local curr_items = DataProcessing.fetch_items()

    if prev_items then
        changes = DataProcessing.calculate_changes(prev_items, curr_items)

        -- Sort the changes by the change amount (descending)
        table.sort(changes, function(a, b)
            return a.change > b.change
        end)

        -- Only display the top 25 changes
        changes = {table.unpack(changes, 1, 30)}
        -- Display the changes on the monitor
        display:display(changes, format_callback)
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
