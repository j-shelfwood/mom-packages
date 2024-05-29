local AEInterface = mpm('peripherals/AEInterface')
local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')

local module

module = {
    sleepTime = 1, -- Render every second
    accumulationPeriod = 1800, -- 30 minutes in seconds
    new = function(monitor)
        local self = {
            monitor = monitor,
            display = GridDisplay.new(monitor),
            interface = AEInterface.new(peripheral.find('merequester:requester')),
            prev_items = AEInterface.items(self.interface),
            accumulated_changes = {},
            last_reset_time = os.clock()
        }
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
        local currentTime = os.clock()
        if currentTime - self.last_reset_time >= self.accumulationPeriod then
            self.accumulated_changes = {}
            self.last_reset_time = currentTime
        end

        local changes = AEInterface.changes(self.interface, self.prev_items)
        for _, change in ipairs(changes) do
            local existing = self.accumulated_changes[change.id]
            if existing then
                existing.count = existing.count + change.count
                existing.change = existing.change + change.change
            else
                self.accumulated_changes[change.id] = change
            end
        end

        local display_changes = {}
        for _, change in pairs(self.accumulated_changes) do
            table.insert(display_changes, change)
        end

        table.sort(display_changes, function(a, b)
            return a.change > b.change
        end)

        if #display_changes == 0 then
            self.monitor.clear()
            self.monitor.setCursorPos(1, 1)
            self.monitor.write("No changes detected")
            print("No changes detected")
        else
            self.display:display(display_changes, function(item)
                return module.format_callback(item)
            end)
            print("Detected " .. #display_changes .. " changes")
        end

        self.prev_items = AEInterface.items(self.interface)
    end
}

return module
