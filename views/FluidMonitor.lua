local AEInterface = mpm('peripherals/AEInterface')
local GridDisplay = mpm('utils/GridDisplay')
local Text = require('utils/Text')

local module

module = {
    new = function(monitor, requester)
        local self = {
            monitor = monitor,
            requester = requester,
            display = GridDisplay.new(monitor),
            interface = AEInterface.new(requester),
            prev_fluids = nil
        }
        self.prev_fluids = AEInterface.fluids(self.interface)
        return self
    end,

    format_callback = function(fluid)
        local color = fluid.operation == "+" and colors.green or colors.red
        local _, _, name = string.find(fluid.name, ":(.+)")
        name = name:gsub("^%l", string.upper)
        return {
            lines = {name, Text.formatFluidAmount(fluid.amount), fluid.operation .. Text.formatFluidAmount(fluid.change)},
            colors = {colors.white, colors.white, color}
        }
    end,

    render = function(self)
        if self.prev_fluids then
            local changes = AEInterface.fluid_changes(self.interface, self.prev_fluids)
            table.sort(changes, function(a, b)
                return a.change > b.change
            end)
            changes = {table.unpack(changes, 1, 30)}
            self.display:display(changes, function(item)
                return module.format_callback(item)
            end)
            print("Detected " .. #changes .. " changes in fluids")
        end
        self.prev_fluids = AEInterface.fluids(self.interface)
    end
}

return module
