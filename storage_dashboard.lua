local DataProcessing = require('data_processing')
local monitor = peripheral.find("monitor")

-- Set text scale for better visibility
monitor.setTextScale(0.5)

local WIDTH, HEIGHT = monitor.getSize()

-- Helper function to draw capacity bars
local function drawCapacityBar(x, y, width, height, percentage)
    local filledWidth = math.floor(width * percentage / 100)
    for i = 1, height do
        monitor.setCursorPos(x, y + i - 1)
        monitor.setBackgroundColor(colors.green)
        monitor.write(string.rep(" ", filledWidth))
        monitor.setBackgroundColor(colors.gray)
        monitor.write(string.rep(" ", width - filledWidth))
    end
    monitor.setBackgroundColor(colors.black) -- Reset background color
end

local function displayStorageInfo()
    monitor.clear()

    -- Fetch storage cell details
    local cells = DataProcessing.fetch_storage_cells_details()

    if not cells or #cells == 0 then
        monitor.setCursorPos(1, 1)
        monitor.write("No storage cells detected.")
        return
    end

    local totalUsedBytes = 0
    local totalBytes = 0
    for _, cell in ipairs(cells) do
        totalUsedBytes = totalUsedBytes + (cell.totalBytes - cell.bytesPerType)
        totalBytes = totalBytes + cell.totalBytes
    end

    -- Display total storage info
    monitor.setCursorPos(1, 1)
    monitor.write("Used: " .. totalUsedBytes .. "/" .. totalBytes .. " Bytes")

    -- Display each cell's info
    for i, cell in ipairs(cells) do
        if i > HEIGHT - 2 then -- Save space for capacity bars
            break
        end
        local percentageUsed = ((cell.totalBytes - cell.bytesPerType) / cell.totalBytes) * 100
        monitor.setCursorPos(1, i + 1)
        monitor.write(cell.item .. ": " .. math.floor(percentageUsed) .. "%")
        drawCapacityBar(1, HEIGHT - i + 1, WIDTH, 1, percentageUsed)
    end
end

displayStorageInfo()

while true do
    displayStorageInfo()
    os.sleep(5)
end
