local GridMonitor = {}

-- Constructor
function GridMonitor.new(monitor, scale)
    local self = setmetatable({}, {
        __index = GridMonitor
    })

    self.monitor = monitor
    self.scale = scale or 1

    monitor.setTextScale(scale)
    local monitorWidth, monitorHeight = monitor.getSize()

    self.numColumns = math.floor(monitorWidth / 15)
    self.numRows = math.floor(monitorHeight / 3)

    return self
end

-- Print debug information
function GridMonitor:debugInfo()
    print("Monitor scale: " .. self.scale)
    print("Monitor size: " .. self.monitor.getSize())
    print("Number of cells: " .. self.numColumns .. "x" .. self.numRows)
end

-- Clear the grid
function GridMonitor:clearGrid()
    self.monitor.clear()
end

-- Draw a grid
function GridMonitor:drawGrid()
    -- your grid drawing logic here
end

-- Write in a cell
function GridMonitor:writeInCell(x, y, text)
    local cellWidth = 15
    local cellHeight = 3

    -- calculate the start coordinates of the cell
    local startX = (x - 1) * cellWidth + 1
    local startY = (y - 1) * cellHeight + 1

    -- write in the cell
    self.monitor.setCursorPos(startX, startY)
    self.monitor.write(text)
end

-- Display data
function GridMonitor:displayData(data, convertToString)
    self:clearGrid()
    self:drawGrid()

    for i, item in ipairs(data) do
        local x = (i - 1) % self.numColumns + 1
        local y = math.floor((i - 1) / self.numColumns) + 1
        self:writeInCell(x, y, convertToString(item))
    end
end

return GridMonitor
