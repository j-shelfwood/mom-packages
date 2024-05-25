local MonitorDisplay = mpm('views/MonitorDisplay')
local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')

local InventoryDisplay = setmetatable({}, {
    __index = MonitorDisplay
})
InventoryDisplay.__index = InventoryDisplay

function InventoryDisplay.new(monitor, peripheral)
    local self = MonitorDisplay.new(monitor)
    setmetatable(self, InventoryDisplay)
    self.peripheral = peripheral
    self.display = GridDisplay.new(monitor)
    self.prevItems = {}
    return self
end

function InventoryDisplay:format_callback(item)
    local color = item.change == "+" and colors.green or colors.red
    return {
        lines = {Text.prettifyItemIdentifier(item.name), tostring(item.count), item.change},
        colors = {colors.white, colors.white, color}
    }
end

function InventoryDisplay:render()
    local items = self.peripheral.listItems()
    for _, item in ipairs(items) do
        item.name = item.displayName
        item.count = item.amount
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
        return self:format_callback(item)
    end)
end

return InventoryDisplay
