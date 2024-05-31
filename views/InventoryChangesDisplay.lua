local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')

local module

--[[ 
    This view displays the inventory changes of the requester over the last 30 minutes.

    - It displays any inventory changes counting over 5 items. 
    - It updates every second.
]]

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
        self:startTimer()
        self.prevItems = self.peripheral.items()
        return self
    end,

    -- The timer clears the state every 30 minutes
    startTimer = function(self)
        os.startTimer(self.config.accumulationPeriod)
        self:clearState()
    end,

    -- When the state is cleared we reset the self.accumulatedChanges
    clearState = function(self)
        self.accumulatedChanges = {}
    end,

    mount = function()
        if peripheral.find('merequester:requester') then
            return true
        end
        return false
    end,

    format_callback = function(key, value)
        local color = value > 0 and colors.green or colors.red
        return {
            lines = {Text.prettifyItemIdentifier(key), tostring(value), tostring(value)},
            colors = {colors.white, colors.white, color}
        }
    end,

    render = function(self)
        self:updateAccumulatedChanges()
        local currItems = self.peripheral.items()
        self.prevItems = currItems

        self.display:display(self.accumulatedChanges, function(key, value)
            return module.format_callback(key, value)
        end)
    end,

    -- {1 = {"tags" = {"techreborn:raw_metals" = true, "c:raw_ores" = true, "c:raw_iridium_ores" = true}, "name" = "techreborn:raw_iridium", "itemGroups" = {}, "rawName" = "item.techreborn.raw_iridium", "count" = 2, "maxCount" = 64, "displayName" = "Raw Iridium"}}
    -- We first remove the duplicates, then we record the changes
    updateAccumulatedChanges = function(self)
        local currItems = self:cleanDuplicates(self.peripheral.items())
        -- Compare the amounts of items that have changed by subtracting the previous count from the current count. 
        -- If the value is not zero it had a change and we add the item.
        for _, item in pairs(currItems) do
            local prevCount = self.prevItems[item.displayName] or 0
            local change = item.count - prevCount
            if change ~= 0 then
                self.accumulatedChanges[item.displayName] = (self.accumulatedChanges[item.displayName] or 0) + change
            end
            -- If the value is now 0 we remove the item from the accumulated changes.
            if item.count == 0 then
                self.accumulatedChanges[item.displayName] = nil
            end
        end
    end,

    cleanDuplicates = function(items)
        local cleanedItems = {}
        for _, item in pairs(items) do
            cleanedItems[item.displayName] = cleanedItems[item.displayName] or 0
            cleanedItems[item.displayName] = cleanedItems[item.displayName] + item.count
        end
        return cleanedItems
    end
}

return module
