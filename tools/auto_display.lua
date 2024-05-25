local views = mpm('views/filelist') -- Load the list of view scripts
local peripherals = peripheral.getNames()

-- Filter out the generic MonitorDisplay class
local availableViews = {}
for _, view in ipairs(views) do
    if view ~= "MonitorDisplay" then
        table.insert(availableViews, view)
    end
end

-- Function to select a view
local function selectView()
    print("Select a view:")
    for i, view in ipairs(availableViews) do
        print(i .. ". " .. view)
    end
    local choice = tonumber(read())
    return availableViews[choice]
end

-- Function to select a monitor
local function selectMonitor()
    print("Select a monitor:")
    for i, name in ipairs(peripherals) do
        if peripheral.getType(name) == "monitor" then
            print(i .. ". " .. name)
        end
    end
    local choice = tonumber(read())
    return peripherals[choice]
end

-- Main function
local function main()
    local selectedView = selectView()
    local monitorName = selectMonitor()
    local monitor = peripheral.wrap(monitorName)
    local ViewClass = mpm('views/' .. selectedView)
    local viewInstance = ViewClass.new(monitor)

    while true do
        ViewClass.render(viewInstance)
        sleep(5)
    end
end

main()
