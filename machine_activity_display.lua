-- Include Data Processing and Grid Display APIs
local wpp = require('wpp')
local generics = require('generics')

-- Connect to the wireless peripheral network
wpp.wireless.connect("shelfwood")

-- Wrap the monitor
local monitor = peripheral.wrap(generics.findPeripheralSide('monitor'))
monitor.setTextScale(1)

-- Function to fetch machine data
local function fetch_data(machine_type)
    local machine_data = {}
    local peripherals = wpp.peripheral.getNames()
    for _, name in ipairs(peripherals) do
        local machine = wpp.peripheral.wrap(name)
        -- Filter by the given machine type
        if string.find(name, machine_type) then
            machine.wppPrefetch({"isBusy"})
            -- Extract the name
            local _, _, name = string.find(name, machine_type .. "_(.+)")
            table.insert(machine_data, {
                name = name,
                isBusy = machine.isBusy()
            })
        end
    end
    return machine_data
end

-- Function to display machine status visually
local function display_machine_status(machine_type)
    local machine_data = fetch_data(machine_type)
    if #machine_data > 0 then
        local machine = machine_data[1] -- Display the first machine for simplicity
        monitor.clear()
        -- Display machine name on top and bottom
        monitor.setCursorPos(1, 1)
        monitor.write(machine.name)
        monitor.setCursorPos(1, 10)
        monitor.write(machine.name)
        -- Display squares in between based on isBusy status
        for row = 2, 9 do
            monitor.setCursorPos(1, row)
            if machine.isBusy then
                monitor.setBackgroundColor(colors.green)
            else
                monitor.setBackgroundColor(colors.gray)
            end
            monitor.write("  ") -- Each square is 2 characters wide
        end
        monitor.setBackgroundColor(colors.black) -- Reset background color
    else
        monitor.clear()
        monitor.setCursorPos(1, 5)
        monitor.write("No Data")
    end
end

-- Get machine type from command line parameter
local args = {...}
local machine_type = args[1] or "modern_industrialization:electrolyzer"

-- Check if machine type is valid (additional checks can be added if needed)
if not machine_type then
    print("Please provide a valid machine type as a command-line parameter.")
    return
end

-- Run the display_machine_status function every 15 seconds
while true do
    display_machine_status(machine_type)
    os.sleep(15)
end
