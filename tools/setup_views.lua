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

-- Function to render monitor identifier
local function renderMonitorIdentifier(monitorName)
    local monitor = peripheral.wrap(monitorName)
    if monitor then
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("Monitor: " .. monitorName)
    end
end

-- Function to render monitor identifier
local function renderMonitorIdentifiers()
    for i, name in ipairs(peripherals) do
        if peripheral.getType(name) == "monitor" then
            renderMonitorIdentifier(name)
        end
    end
end

-- Main function
local function main()
    local config = {}
    renderMonitorIdentifiers()
    for i, name in ipairs(peripherals) do
        if peripheral.getType(name) == "monitor" then
            print("Configuring monitor: " .. name)
            local selectedView = selectView()
            if not selectedView then
                print("No view selected. Skipping monitor: " .. name)
                goto continue
            end

            local ViewClass = mpm('views/' .. selectedView)
            local viewConfig = {}
            if ViewClass.configure then
                viewConfig = ViewClass.configure()
            end

            table.insert(config, {
                view = selectedView,
                monitor = name,
                config = viewConfig
            })
            print("Configured " .. selectedView .. " on " .. name)
        end
        ::continue::
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
