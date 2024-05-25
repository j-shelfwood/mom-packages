local MonitorDisplay = mpm('monitor_display')
local AEInterface = mpm('peripherals/AEInterface')
local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')

local InventoryChangesDisplay = setmetatable({}, {
    __index = MonitorDisplay
})
InventoryChangesDisplay.__index = InventoryChangesDisplay

function InventoryChangesDisplay.new(monitor, requester)
    local self = MonitorDisplay.new(monitor)
    setmetatable(self, InventoryChangesDisplay)
    self.interface = AEInterface.new(requester)
    self.display = GridDisplay.new(monitor)
    self.prev_items = interface.items()
    return self
end

function InventoryChangesDisplay:format_callback(item)
    local color = item.operation == "+" and colors.green or colors.red
    return {
        lines = {Text.prettifyItemIdentifier(item.name), tostring(item.count), item.operation .. tostring(item.change)},
        colors = {colors.white, colors.white, color}
    }
end

function InventoryChangesDisplay:refresh_display()
    if self.prev_items then
        local changes = self.interface.changes(self.prev_items)
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
            return self:format_callback(item)
        end)
        print("Detected " .. #changes .. " changes")
    end
    self.prev_items = curr_items
end

function InventoryChangesDisplay:render()
    while true do
        self:refresh_display()
        os.sleep(15)
    end
end

return InventoryChangesDisplay
