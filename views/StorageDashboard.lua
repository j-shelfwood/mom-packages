local AEInterface = mpm('peripherals/AEInterface')

local StorageDashboard = {}
StorageDashboard.__index = StorageDashboard

function StorageDashboard.new(monitor)
    local self = setmetatable({}, StorageDashboard)
    self.monitor = monitor
    self.WIDTH, self.HEIGHT = monitor.getSize()
    self.MAX_DATA_POINTS = self.WIDTH
    self.storageData = {}
    self.TITLE = "AE2 Storage Capacity Status"
    return self
end

function StorageDashboard:recordStorageUsage()
    local usedStorage = AEInterface.storage_status().usedItemStorage
    table.insert(self.storageData, usedStorage)
    if #self.storageData > self.MAX_DATA_POINTS then
        table.remove(self.storageData, 1)
    end
end

function StorageDashboard:calculateGraphData()
    local heights = {}
    for _, usage in ipairs(self.storageData) do
        local height = math.floor((usage / AEInterface.storage_status().totalItemStorage) * (self.HEIGHT - 1))
        table.insert(heights, height)
    end
    return heights
end

function StorageDashboard:drawGraph(heights)
    self.monitor.clear()
    local titleStartX = math.floor((self.WIDTH - #self.TITLE) / 2) + 1
    self.monitor.setCursorPos(titleStartX, 1)
    self.monitor.write(self.TITLE)
    local currentBytes = AEInterface.storage_status().usedItemStorage
    self.monitor.setCursorPos(self.WIDTH - #tostring(currentBytes), 1)
    self.monitor.write(tostring(currentBytes) .. "B")
    self.monitor.setCursorPos(1, 2)
    self.monitor.write(tostring(AEInterface.storage_status().totalItemStorage))
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
end

function StorageDashboard:render()
    while true do
        self:recordStorageUsage()
        local graphData = self:calculateGraphData()
        self:drawGraph(graphData)
        sleep(5)
    end
end

return StorageDashboard
