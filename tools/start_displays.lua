local config = textutils.unserialize(fs.open("displays.config", "r").readAll())
while true do
    for _, display in ipairs(config) do
        local ViewClass = mpm('views/' .. display.view)
        local monitor = peripheral.wrap(display.monitor)
        local viewInstance = ViewClass.new(monitor, display.config)
        parallel.waitForAny(function()
            ViewClass.render(viewInstance)
        end)
    end
end

