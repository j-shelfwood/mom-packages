local views = mpm('views/filelist') -- Load the list of view scripts
local peripherals = peripheral.getNames()

-- Function to select a view
local function selectView()
    print("Select a view:")
    for i, view in ipairs(views) do
        local ViewClass = mpm('views/' .. view)
        if ViewClass.mount() then
            print(i .. ". " .. view)
        end
    end
    local choice = tonumber(read())
    return views[choice]
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
    local config = {}
    while true do
        local selectedView = selectView()
        if not selectedView then
            break
        end
        local monitorName = selectMonitor()
        if not monitorName then
            break
        end

        local ViewClass = mpm('views/' .. selectedView)
        local viewConfig = {}
        if ViewClass.configure then
            viewConfig = ViewClass.configure()
        end

        table.insert(config, {
            view = selectedView,
            monitor = monitorName,
            config = viewConfig
        })
        print("Configured " .. selectedView .. " on " .. monitorName)
        print("Do you want to configure another display? (yes/no)")
        local answer = read()
        if answer:lower() ~= "yes" then
            break
        end
    end

    -- Save configuration to displays.config
    local file = fs.open("displays.config", "w")
    file.write(textutils.serialize(config))
    file.close()

    -- Generate startup.lua
    local startup = [[
shell.run('mpm run tools/start_displays')
]]
    local startupFile = fs.open("startup.lua", "w")
    startupFile.write(startup)
    startupFile.close()

    print("Setup complete. Configuration saved to displays.config and startup.lua generated.")
end

main()
