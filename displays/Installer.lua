local this

this = {
    run = function()
        local existingConfig = mpm('displays/Config').load()
        local file = fs.open("/mpm/Packages/views/manifest.json", "r")
        local views = textutils.unserialiseJSON(file.readAll()).files
        file.close()

        local peripherals = peripheral.getNames()

        local configuredMonitors = {}
        for _, entry in ipairs(existingConfig) do
            configuredMonitors[entry.monitor] = true
        end

        this.renderIdentifiers()

        local newConfig = {}
        for i, name in ipairs(peripherals) do
            if peripheral.getType(name) == "monitor" and not configuredMonitors[name] then
                print("Configuring monitor: " .. name)
                local selectedView = this.selectView(views)
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
        local startup = [[shell.run('mpm run displays/start')]]
        local startupFile = fs.open("startup.lua", "w")
        startupFile.write(startup)
        startupFile.close()

        print("Setup complete. Configuration updated and saved to displays.config. startup.lua generated.")
    end,
    selectView = function(views)
        print("Select a view:")
        for i, view in ipairs(views) do
            local ViewClass = mpm('views/' .. view)
            if ViewClass.mount() then
                print(i .. ". " .. view)
            end
        end
        local choice = tonumber(read())
        return views[choice]
    end,
    renderIdentifiers = function()
        local monitors = peripheral.getNames()
        for i, name in ipairs(monitors) do
            if peripheral.getType(name) == "monitor" then
                local monitor = peripheral.wrap(name)
                monitor.clear()
                monitor.setCursorPos(1, 1)
                monitor.write("Monitor: " .. name)
            end
        end
    end
}

return this
