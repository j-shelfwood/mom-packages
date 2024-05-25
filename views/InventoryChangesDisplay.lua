local AEInterface = mpm('peripherals/AEInterface')
local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')

local module

module = {
    new = function(monitor, requester)
        local self = {
            monitor = monitor,
            requester = requester,
            interface = AEInterface.new(requester),
            display = GridDisplay.new(monitor),
            prev_items = nil
        }
        self.prev_items = AEInterface.items(self.interface)
        return self
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
