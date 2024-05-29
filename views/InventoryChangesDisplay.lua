local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')

local module

module = {
    new = function(monitor, config)
        local self = {
            monitor = monitor,
            peripheral = peripheral.find('merequester:requester'),
            display = GridDisplay.new(monitor),
            prevItems = {},
            accumulatedChanges = {},
            config = config or {
                accumulationPeriod = 1800,
                updateInterval = 1
            }
        }
        self.monitor.clear()
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
        local color = item.change > 0 and colors.green or colors.red
        return {
            lines = {Text.prettifyItemIdentifier(item.name), tostring(item.count), tostring(item.change)},
            colors = {colors.white, colors.white, color}
        }
    end,

    render = function(self)
        local items = self.peripheral.items()
        for _, item in ipairs(items) do
            item.name = item.displayName
            item.count = item.count
        end
        table.sort(items, function(a, b)
            return a.count > b.count
        end)
        local currItems = {}
        for i, item in ipairs(items) do
            local itemName = item.name
            local itemCount = item.count
            local itemChange = 0
            if self.prevItems[itemName] then
                itemChange = itemCount - self.prevItems[itemName].count
                self.accumulatedChanges[itemName] = (self.accumulatedChanges[itemName] or 0) + itemChange
            else
                self.accumulatedChanges[itemName] = 0
            end
            self.prevItems[itemName] = {
                count = itemCount
            }
            if self.accumulatedChanges[itemName] ~= 0 then
                currItems[#currItems + 1] = {
                    name = itemName,
                    count = itemCount,
                    change = self.accumulatedChanges[itemName]
                }
            end
        end
        self.display:display(currItems, function(item)
            return module.format_callback(item)
        end)
    end,

    resetAccumulation = function(self)
        self.accumulatedChanges = {}
    end,

    start = function(self)
        while true do
            local status, err = pcall(function()
                self:render()
            end)
            if not status then
                print("Error rendering view: " .. err)
            end
            sleep(self.config.updateInterval)
        end
    end,

    run = function(self)
        while true do
            self:start()
            sleep(self.config.accumulationPeriod)
            self:resetAccumulation()
        end
    end
}

return module
