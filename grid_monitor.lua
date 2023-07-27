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
    self.cellWidth = 15
    self.cellHeight = 3

    -- Create windows for each cell
    self.windows = {}
    for i = 1, self.numRows do
        self.windows[i] = {}
        for j = 1, self.numColumns do
            self.windows[i][j] = window.create(self.monitor, (j - 1) * self.cellWidth + 1,
                (i - 1) * self.cellHeight + 1, self.cellWidth, self.cellHeight, false -- invisible by default
            )
        end
    end

    return self
end

-- Print debug information
function GridMonitor:debugInfo()
    print("Monitor scale: " .. self.scale)
    print("Monitor size: " .. self.monitor.getSize())
    print("Number of cells: " .. self.numColumns .. "x" .. self.numRows)
    print("Cell size: " .. self.cellWidth .. "x" .. self.cellHeight)
end

-- Clear the grid
function GridMonitor:clearGrid()
    self.monitor.clear()
    for i = 1, self.numRows do
        for j = 1, self.numColumns do
            self.windows[i][j].setVisible(false)
        end
    end
end

-- Display data
function GridMonitor:displayData(data, convertToString)
    self:clearGrid()

    for i, item in ipairs(data) do
        local row = math.floor((i - 1) / self.numColumns) + 1
        local col = (i - 1) % self.numColumns + 1
        local win = self.windows[row][col]
        win.clear()
        win.setCursorPos(1, 1)
        win.write(convertToString(item))
        win.setVisible(true)
    end
end

return GridMonitor
