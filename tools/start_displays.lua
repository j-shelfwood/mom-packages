local config = textutils.unserialize(fs.open("displays.config", "r").readAll())

for _, display in ipairs(config) do
    local ViewClass = mpm('views/' .. display.view)
    local monitor = peripheral.wrap(display.monitor)
    local viewInstance = ViewClass.new(monitor)
    parallel.waitForAny(function()
        while true do
            ViewClass.render(viewInstance)
            sleep(5)
        end
    end)
end
