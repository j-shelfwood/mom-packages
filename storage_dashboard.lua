local DataProcessing = require('data_processing')
local generics = require('generics')

-- Wrap the tall monitor on top
local monitor = peripheral.wrap("right")

-- Constants
local REFRESH_INTERVAL = 5 -- Seconds
local MAX_DATA_POINTS = monitor.getSize() -- Number of data points to store based on monitor width

local storageData = {} -- To store recent storage usage data

-- Function to record the storage usage
local function recordStorageUsage()
    local usedStorage = DataProcessing.fetch_storage_status().usedItemStorage
    table.insert(storageData, usedStorage)

    -- Ensure we don't exceed the maximum data points
    if #storageData > MAX_DATA_POINTS then
        table.remove(storageData, 1)
    end
end

-- Function to plot the storage trend graph
local function plotGraph()
    monitor.clear()

    local maxHeight = monitor.getSize() -- Height of the monitor
    local maxStorageCapacity = DataProcessing.fetch_storage_status().totalItemStorage

    for x, usage in ipairs(storageData) do
        -- Calculate the height to plot based on the usage relative to max storage capacity
        local height = math.floor((usage / maxStorageCapacity) * maxHeight)

        monitor.setCursorPos(x, maxHeight - height + 1)
        monitor.write(string.rep("#", height))
    end
end

-- Main loop to record and display the storage trend graph
while true do
    recordStorageUsage()
    plotGraph()
    os.sleep(REFRESH_INTERVAL)
end
