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
    local progressPercentage = string.format("%.1f%%", item.progress * 100) -- Convert the float to a percentage with 1 decimal point
    local efficiencyInfo = tostring(item.currentEfficiency)
    local craftingInfo = "N/A" -- Default value

    if item.items and #item.items > 0 then -- Assuming the items method returns a list
        craftingInfo = item.items[1] -- Display the first item
    end

    return {
        line_1 = (tostring(item.energy) .. "/" .. tostring(item.capacity)) or "N/A",
        color_1 = colors.blue,
        line_2 = progressPercentage .. " | " .. efficiencyInfo,
        color_2 = colors.white,
        line_3 = craftingInfo,
        color_3 = colors.green
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
            machine.wppPrefetch({"getEnergy", "isBusy", "getEnergyCapacity", "getCraftingInformation", "items"})

            -- Extract the name
            local _, _, name = string.find(name, machine_type .. "_(.+)")

            local craftingInfo = machine.getCraftingInformation() or {}
            local itemsList = machine.items() or {}

            table.insert(machine_data, {
                name = name,
                energy = machine.getEnergy(),
                capacity = machine.getEnergyCapacity(),
                progress = craftingInfo.progress or 0,
                currentEfficiency = craftingInfo.currentEfficiency or 0,
                items = itemsList
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
local machine_type = args[1] or "modern_industrialization:electrolyzer"

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
