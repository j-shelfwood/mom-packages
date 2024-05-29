local AEInterface = mpm('peripherals/AEInterface')
local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')

local module

module = {
    sleepTime = 10, -- Sleep time in seconds
    new = function(monitor)
        local self = {
            monitor = monitor,
            display = GridDisplay.new(monitor),
            interface = AEInterface.new(peripheral.find('merequester:requester')),
            prev_items = nil
        }
        self.prev_items = AEInterface.items(self.interface)
        return self
    end,
    mount = function()
        local peripherals = peripheral.getNames()
        for _, name in ipairs(peripherals) do
            if peripheral.getType(name) == "merequester:requester" then
                return true
            end
        end
        return false
    end,
    format_callback = function(item)
        local color = item.operation == "+" and colors.green or colors.red
        return {
            lines = {Text.prettifyItemIdentifier(item.name), tostring(item.count),
                     item.operation .. tostring(item.change)},
            colors = {colors.white, colors.white, color}
        }
    end,

    render = function(self)
        if self.prev_items then
            local changes = AEInterface.changes(self.interface, self.prev_items)
            table.sort(changes, function(a, b)
                return a.change > b.change
            end)
            if #changes == 0 then
                self.monitor.clear()
                self.monitor.setCursorPos(1, 1)
                self.monitor.write("No changes detected")
                print("No changes detected")
                return
            end
            changes = {table.unpack(changes, 1, 30)}
            self.display:display(changes, function(item)
                return module.format_callback(item)
            end)
            print("Detected " .. #changes .. " changes")
        end
        self.prev_items = AEInterface.items(self.interface)
    end
}

return module
