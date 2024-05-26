local AEInterface = mpm('peripherals/AEInterface')

local module

module = {
    new = function(monitor)
        local self = {
            monitor = monitor,
            interface = AEInterface.new(peripheral.find("merequester:requester")),
            WIDTH = monitor.getSize(),
            HEIGHT = select(2, monitor.getSize()),
            MAX_DATA_POINTS = select(1, monitor.getSize()),
            storageData = {},
            TITLE = "AE2 Capacity Status"
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
    recordStorageUsage = function(self)
        local usedStorage = AEInterface.storage_status(self.interface).usedItemStorage
        table.insert(self.storageData, usedStorage)
        if #self.storageData > self.MAX_DATA_POINTS then
            table.remove(self.storageData, 1)
        end
    end,

    calculateGraphData = function(self)
        local heights = {}
        for _, usage in ipairs(self.storageData) do
            local height = math.floor((usage / AEInterface.storage_status().totalItemStorage) * (self.HEIGHT - 1))
            table.insert(heights, height)
        end
        return heights
    end,

    drawGraph = function(self)
        local heights = module.calculateGraphData(self)
        self.monitor.clear()
        local titleStartX = math.floor((self.WIDTH - #self.TITLE) / 2) + 1
        self.monitor.setCursorPos(titleStartX, 1)
        self.monitor.write(self.TITLE)
        local currentBytes = AEInterface.storage_status(self.interface).usedItemStorage
        self.monitor.setCursorPos(self.WIDTH - #tostring(currentBytes), 1)
        self.monitor.write(tostring(currentBytes) .. "B")
        self.monitor.setCursorPos(1, 2)
        self.monitor.write(tostring(AEInterface.storage_status(self.interface).totalItemStorage))
        self.monitor.setCursorPos(1, self.HEIGHT)
        self.monitor.write("0")
        for x, height in ipairs(heights) do
            local columnPosition = self.WIDTH - #heights + x
            self.monitor.setBackgroundColor(colors.pink)
            for y = self.HEIGHT, self.HEIGHT - height + 2, -1 do
                self.monitor.setCursorPos(columnPosition, y)
                self.monitor.write(" ")
            end
        end
        self.monitor.setBackgroundColor(colors.black)
    end,

    render = function(self)
        module.recordStorageUsage(self)
        module.drawGraph(self, graphData)
    end
}

return module
