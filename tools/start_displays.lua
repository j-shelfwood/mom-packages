local config = textutils.unserialize(fs.open("displays.config", "r").readAll())

-- Function to manage display updates
local function manageDisplay(display)
    local ViewClass = mpm('views/' .. display.view)
    local monitor = peripheral.wrap(display.monitor)
    local viewInstance = ViewClass.new(monitor, display.config)

    while true do
        local status, err = pcall(function()
            ViewClass.render(viewInstance)
        end)
        if not status then
            print("Error rendering view: " .. err)
        end
        -- Use the sleep time specified in the view module, default to 1 second if not specified
        if ViewClass.sleepTime then
            sleep(ViewClass.sleepTime)
        end
    end
end

-- Create tasks for each display
local tasks = {}
for _, display in ipairs(config) do
    table.insert(tasks, function()
        manageDisplay(display)
    end)
end

-- Run all tasks in parallel
parallel.waitForAll(table.unpack(tasks))
