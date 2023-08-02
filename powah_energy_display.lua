-- Include Data Processing and Grid Display APIs
local wpp = require('wpp')
local GridDisplay = require('grid_display')
local generics = require('generics')

-- Connect to the wireless peripheral network
wpp.wireless.connect("shelfwood") -- replace with your chosen network name

-- Wrap the monitor
local monitor = peripheral.wrap(generics.findPeripheralSide('monitor')) -- replace "monitor_side" with the actual side of the monitor
local display = GridDisplay.new(monitor)

-- Define a formatting callback for the grid display
local function format_callback(item)
    -- Format the energy data
    return {
        line_1 = item.name,
        color_1 = colors.white,
        line_2 = tostring(item.energy) .. " / " .. tostring(item.capacity),
        color_2 = colors.white,
        line_3 = item.units,
        color_3 = colors.green
    }
end

-- Function to fetch energy data
local function fetch_energy()
    local energy_data = {}
    local peripherals = wpp.peripheral.getNames()
    for _, name in ipairs(peripherals) do
        local cell = wpp.peripheral.wrap(name)
        if string.find(cell.getType(), "powah:energy_cell") then
            cell.wppPrefetch({"getEnergy", "getEnergyUnits", "getEnergyCapacity"})
            table.insert(energy_data, {
                name = name,
                energy = cell.getEnergy(),
                units = cell.getEnergyUnits(),
                capacity = cell.getEnergyCapacity()
            })
        end
    end
    return energy_data
end

-- Function to refresh the display
local function refresh_display()
    -- Fetch energy data
    local energy_data = fetch_energy()

    -- Display the energy data on the monitor
    display:display(energy_data, format_callback)
end

-- Run the refresh_display function every 15 seconds
while true do
    refresh_display()
    os.sleep(15)
end
