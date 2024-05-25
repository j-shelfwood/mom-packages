local MonitorDisplay = mpm('views/MonitorDisplay')
local AEInterface = mpm('peripherals/AEInterface')
local GridDisplay = mpm('utils/grid_display')
local Text = require('utils/text')

local FluidMonitor = setmetatable({}, {
    __index = MonitorDisplay
})
FluidMonitor.__index = FluidMonitor

function FluidMonitor.new(monitor, requester)
    local self = MonitorDisplay.new(monitor)
    setmetatable(self, FluidMonitor)
    self.display = GridDisplay.new(monitor)
    self.interface = AEInterface.new(requester)
    self.prev_fluids = self.interface:fluids()
    return self
end

function FluidMonitor:format_callback(fluid)
    local color = fluid.operation == "+" and colors.green or colors.red
    local _, _, name = string.find(fluid.name, ":(.+)")
    name = name:gsub("^%l", string.upper)
    return {
        lines = {name, Text.formatFluidAmount(fluid.amount), fluid.operation .. Text.formatFluidAmount(fluid.change)},
        colors = {colors.white, colors.white, color}
    }
end

function FluidMonitor:refresh_display()
    if self.prev_fluids then
        local changes = self.interface.fluid_changes(self.prev_fluids)
        table.sort(changes, function(a, b)
            return a.change > b.change
        end)
        changes = {table.unpack(changes, 1, 30)}
        self.display:display(changes, function(item)
            return self:format_callback(item)
        end)
        print("Detected " .. #changes .. " changes in fluids")
    end
    self.prev_fluids = curr_fluids
end

function FluidMonitor:render()
    while true do
        self:refresh_display()
        os.sleep(15)
    end
end

return FluidMonitor
