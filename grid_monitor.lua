local GridMonitor = {
    scale = 1,
    monitor = nil,
    windows = {},
    numColumns = 0,
    numRows = 0
}

-- Constructor for GridMonitor
function GridMonitor.new(monitor, scale)
    local self = setmetatable({}, {
        __index = GridMonitor
    })

    self.monitor = monitor
    self.scale = scale or self.scale
    self.monitor.setTextScale(self.scale)

    self.monitorWidth, self.monitorHeight = self.monitor.getSize()

    self.numColumns = math.floor(self.monitorWidth / 15)
    self.numRows = math.floor(self.monitorHeight / 3)

    self:initializeGrid()

    return self
end

-- Initialize the grid of windows
function GridMonitor:initializeGrid()
    self.windows = {}

    local windowWidth = self.monitorWidth / self.numColumns
    local windowHeight = self.monitorHeight / self.numRows

    for row = 1, self.numRows do
        for column = 1, self.numColumns do
            local x = (column - 1) * windowWidth
            local y = (row - 1) * windowHeight

            local window = window.create(self.monitor, x + 1, y + 1, windowWidth, windowHeight, false)
            window.setTextScale(self.scale)
            table.insert(self.windows, window)
        end
    end
end

-- Clear all grid windows
function GridMonitor:clearGrid()
    for _, window in ipairs(self.windows) do
        window.clear()
    end
end

-- Display data in the grid
function GridMonitor:displayData(data, formatFunction)
    for i, item in ipairs(data) do
        local window = self.windows[i]

        if window then
            window.clear()

            local output = formatFunction(item)
            local lines = split(output, "\n")

            for lineIndex, line in ipairs(lines) do
                window.setCursorPos(1, lineIndex)
                window.write(line)
            end

            window.redraw()
        end
    end
end

-- Print debug information
function GridMonitor:debugInfo()
    print("Scale: " .. self.scale)
    print("Monitor Size: " .. self.monitorWidth .. "x" .. self.monitorHeight)
    print("Number of Cells: " .. self.numColumns .. "x" .. self.numRows)
end

-- Utility function to split string by separator
function split(input, separator)
    local output = {}
    local pattern = "([^" .. separator .. "]+)"

    for substring in input:gmatch(pattern) do
        table.insert(output, substring)
    end

    return output
end

return GridMonitor
