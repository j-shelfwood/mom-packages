-- Include Data Processing and Grid Display APIs
local wpp = require('wpp')
local GridDisplay = require('grid_display')
local generics = require('generics')

-- Connect to the wireless peripheral network
wpp.wireless.connect("shelfwood")

-- Wrap the monitor
local monitor = peripheral.wrap(generics.findPeripheralSide('monitor'))
local display = GridDisplay.new(monitor)

-- Define a formatting callback for the grid display
local function format_callback(item)
    -- Format the machine data
    return {
        line_1 = item.name,
        color_1 = colors.white,
        line_2 = item.isBusy and "Busy" or "Idle",
        color_2 = item.isBusy and colors.red or colors.green,
        line_3 = "E: " .. tostring(item.energy) .. "/" .. tostring(item.capacity),
        color_3 = colors.blue
    }
end

-- Function to fetch machine data
local function fetch_data(machine_type)
    local machine_data = {}
    local peripherals = wpp.peripheral.getNames()
    -- Display count of peripherals
    print("Found " .. #peripherals .. " peripherals on the network.")

    for _, name in ipairs(peripherals) do
        local machine = wpp.peripheral.wrap(name)

        -- Filter by the given machine type
        if string.find(name, machine_type) then
            print("Fetching data for " .. name)
            machine.wppPrefetch({"getEnergy", "isBusy", "getEnergyCapacity"})

            -- Extract the name
            local _, _, name = string.find(name, machine_type .. "_(.+)")

            table.insert(machine_data, {
                name = name,
                energy = machine.getEnergy(),
                isBusy = machine.isBusy(),
                capacity = machine.getEnergyCapacity()
            })
        end
    end

    return machine_data
end

-- Function to refresh the display
local function refresh_display(machine_type)
    local machine_data = fetch_data(machine_type)

    -- Display the machine data on the monitor
    display:display(machine_data, format_callback)
end

-- Get machine type from command line parameter
local args = {...}
local machine_type = args[1] or "modern_industrialization:electrolyzer" -- Default to 'electrolyzer' if no parameter is provided

-- Check if machine type is valid (can add more checks if needed)
if not machine_type then
    print("Please provide a valid machine type as a command-line parameter.")
    return
end

-- Run the refresh_display function every 15 seconds
while true do
    refresh_display(machine_type)
    os.sleep(15)
end
