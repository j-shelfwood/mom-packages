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

-- Function to render monitor identifiers
local function renderMonitorIdentifiers()
    for i, name in ipairs(peripherals) do
        if peripheral.getType(name) == "monitor" then
            renderMonitorIdentifier(name)
        end
    end
end

-- Load existing configuration
local function loadConfig()
    if fs.exists("displays.config") then
        local file = fs.open("displays.config", "r")
        local config = textutils.unserialize(file.readAll())
        file.close()
        return config
    else
        return {}
    end
end

-- Main function
local function main()
    local existingConfig = loadConfig()
    local configuredMonitors = {}
    for _, entry in ipairs(existingConfig) do
        configuredMonitors[entry.monitor] = true
    end

    renderMonitorIdentifiers()
    local newConfig = {}
    for i, name in ipairs(peripherals) do
        if peripheral.getType(name) == "monitor" and not configuredMonitors[name] then
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

            table.insert(newConfig, {
                view = selectedView,
                monitor = name,
                config = viewConfig
            })
            print("Configured " .. selectedView .. " on " .. name)
        end
        ::continue::
    end

    -- Merge new configuration with existing
    for _, entry in ipairs(newConfig) do
        table.insert(existingConfig, entry)
    end

    -- Save updated configuration to displays.config
    local file = fs.open("displays.config", "w")
    file.write(textutils.serialize(existingConfig))
    file.close()

    -- Generate or update startup.lua
    local startup = [[
shell.run('mpm run tools/start_displays')
]]
    local startupFile = fs.open("startup.lua", "w")
    startupFile.write(startup)
    startupFile.close()

    print("Setup complete. Configuration updated and saved to displays.config. startup.lua generated.")
end

main()
