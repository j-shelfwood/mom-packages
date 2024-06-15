local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')
local PeripheralManager = mpm('utils/PeripheralManager')

local module

module = {
    new = function(monitor)
        local self = {
            monitor = monitor,
            peripheral = PeripheralManager.findPeripheral('merequester:requester'),
            display = GridDisplay.new(monitor),
            prevItems = {}
        }
        return self
    end,
    mount = function()
        return PeripheralManager.findPeripheral('merequester:requester') ~= nil
    end,
    format_callback = function(item)
        local color = item.change == "+" and colors.green or colors.red
        return {
            lines = {Text.prettifyItemIdentifier(item.name), tostring(item.count), item.change},
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
            local itemChange = ""
            if self.prevItems[itemName] then
                local change = itemCount - self.prevItems[itemName].count
                if change > 0 then
                    itemChange = "+"
                elseif change < 0 then
                    itemChange = "-"
                end
            end
            self.prevItems[itemName] = {
                count = itemCount
            }
            currItems[i] = {
                name = itemName,
                count = itemCount,
                change = itemChange
            }
        end
        self.display:display(currItems, function(item)
            return module.format_callback(item)
        end)
    end
}

return module
