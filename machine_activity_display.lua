-- Include generics for peripheral discovery
local generics = require('generics')

-- Wrap the monitor and the modem
local monitor = peripheral.wrap(generics.findPeripheralSide('monitor'))
local modem = peripheral.wrap("back") -- Assuming the wired modem is on the back

-- Ensure the modem is open
if not modem.isOpen() then
    modem.open()
end

local width, height = monitor.getSize()
print("Monitor resolution:", width, "x", height) -- Debug output for monitor resolution

if width ~= 18 or height < 69 then
    print("Invalid monitor size! Expected: 18x69 or larger")
    return
end

monitor.setTextScale(1)

-- Fixed box sizes and borders
local bar_width = 7 -- 18 width minus 1 for left, 1 for right, 1 for middle, and 7 for the second column
local bar_height = 4 -- (69 - 25) / 24

-- Function to fetch machine data
local function fetch_data(machine_type)
    local machine_data = {}
    local peripherals = peripheral.getNames()

    for _, name in ipairs(peripherals) do
        local machine = peripheral.wrap(name)

        if string.find(name, machine_type) then
            print("Fetching data for " .. name)

            -- Extract the name
            local _, _, name = string.find(name, machine_type .. "_(.+)")

            -- Call the machine.items using pcal so we have no fail 
            local ok, itemsList = pcall(machine.items)
            if not ok then
                itemsList = {}
            end

            -- Do the same for local craftingInfo = machine.getCraftingInformation() or {}
            local ok, craftingInfo = pcall(machine.getCraftingInformation)
            if not ok then
                craftingInfo = {
                    progress = 0,
                    currentEfficiency = 0
                }
            end

            table.insert(machine_data, {
                name = name,
                energy = machine.getEnergy(),
                capacity = machine.getEnergyCapacity(),
                progress = craftingInfo.progress or 0,
                currentEfficiency = craftingInfo.currentEfficiency or 0,
                items = itemsList,
                isBusy = machine.isBusy()
            })
        end
    end

    return machine_data
end

local function display_machine_status(machine_type)
    local machine_data = fetch_data(machine_type)
    print("Found", #machine_data, "machines") -- Debug output for number of machines found
    monitor.clear()

    for idx, machine in ipairs(machine_data) do
        local column = (idx - 1) % 2
        local row = math.ceil(idx / 2)
        local x = column * (bar_width + 1) + 2 -- +2 to account for left border and space between bars
        local y = (row - 1) * (bar_height + 1) + 2 -- +2 to account for top border and space between bars
        -- Draw a colored bar based on isBusy status
        if machine.isBusy then
            monitor.setBackgroundColor(colors.green)
        else
            monitor.setBackgroundColor(colors.gray)
        end
        for i = 0, bar_height - 1 do
            monitor.setCursorPos(x, y + i)
            monitor.write(string.rep(" ", bar_width))
        end
        -- Write the machine number centered in the bar
        monitor.setTextColor(colors.black)
        monitor.setCursorPos(x + math.floor((bar_width - string.len(machine.name)) / 2), y + math.floor(bar_height / 2))
        monitor.write(machine.name)
    end
    monitor.setBackgroundColor(colors.black) -- Reset background color
    monitor.setTextColor(colors.white) -- Reset text color
end

-- Get machine type from command line parameter
local args = {...}
local machine_type = args[1] or "modern_industrialization:electrolyzer"

-- Check if machine type is valid (can add more checks if needed)
if not machine_type then
    print("Please provide a valid machine type as a command-line parameter.")
    return
end

-- Run the display_machine_status function every 5 seconds
while true do
    display_machine_status(machine_type)
    os.sleep(5)
end
