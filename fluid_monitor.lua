-- Include Data Processing and Grid Display APIs
local DataProcessing = require('data_processing')
local GridDisplay = require('grid_display')
local generics = require('generics')

-- Wrap the monitor
local monitor = peripheral.wrap(generics.findPeripheralSide('monitor'))
local display = GridDisplay.new(monitor)

-- Define a formatting callback for the grid display
local function format_callback(fluid)
    local color = fluid.operation == "+" and colors.green or colors.red
    return {
        lines = {fluid.name, tostring(fluid.count) .. " buckets",
                 fluid.operation .. tostring(fluid.change) .. " buckets"},
        colors = {colors.white, colors.white, color}
    }
end

-- Function to refresh the display
local function refresh_display()
    local curr_fluids = DataProcessing.fetch_fluids() -- fetch_fluids instead of fetch_items

    if prev_fluids then
        local changes = DataProcessing.calculate_fluid_changes(prev_fluids, curr_fluids) -- calculate_fluid_changes instead of calculate_changes

        -- Sort the changes by the change amount (descending)
        table.sort(changes, function(a, b)
            return a.change > b.change
        end)

        -- Only display the top 25 changes
        changes = {table.unpack(changes, 1, 30)}

        -- Display the changes on the monitor
        display:display(changes, format_callback)
        print("Detected " .. #changes .. " changes in fluids")
    end
    -- Update prev_fluids for the next iteration
    prev_fluids = curr_fluids
end

-- Initialize prev_fluids
local prev_fluids = DataProcessing.fetch_fluids() -- fetch_fluids instead of fetch_items

-- Run the refresh_display function every 15 seconds
while true do
    refresh_display()
    os.sleep(15)
end
