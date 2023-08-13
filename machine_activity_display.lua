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
            -- Extract the machine number
            local _, _, number = string.find(name, "_(%d+)$")
            table.insert(machine_data, {
                number = number,
                isBusy = machine.isBusy()
            })
        end
    end
    -- Sort the machine data by machine number
    table.sort(machine_data, function(a, b)
        return tonumber(a.number) < tonumber(b.number)
    end)
    return machine_data
end

-- Function to display machine status visually
local function display_machine_status(machine_type)
    local machine_data = fetch_data(machine_type)
    monitor.clear()
    for idx, machine in ipairs(machine_data) do
        local column, row = (idx - 1) % 2 + 1, math.ceil(idx / 2)
        monitor.setCursorPos((column - 1) * 3 + 1, row)
        if machine.isBusy then
            monitor.setBackgroundColor(colors.green)
        else
            monitor.setBackgroundColor(colors.gray)
        end
        monitor.write(string.format("%2s", machine.number))
    end
    monitor.setBackgroundColor(colors.black) -- Reset background color
end

-- Get machine type from command line parameter
local args = {...}
local machine_type = args[1] or "modern_industrialization:electrolyzer"

-- Check if machine type is valid (can add more checks if needed)
if not machine_type then
    print("Please provide a valid machine type as a command-line parameter.")
    return
end

-- Run the display_machine_status function every 15 seconds
while true do
    display_machine_status(machine_type)
    os.sleep(15)
end
