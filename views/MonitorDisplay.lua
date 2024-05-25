local MonitorDisplay = {}
MonitorDisplay.__index = MonitorDisplay

function MonitorDisplay.new(monitor)
    local self = setmetatable({}, MonitorDisplay)
    self.monitor = monitor
    return self
end

function MonitorDisplay:render()
    error("run method not implemented")
end

return MonitorDisplay
