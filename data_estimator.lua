local ae2_side = ""
local monitor_side = ""
local disk_drive_sides = {}

local sides = {"left", "right", "front", "back", "top", "bottom"}

-- Helper function to clear monitor
function clearMonitor(monitor)
  monitor.clear()
  monitor.setCursorPos(1,1)
end

-- Detect peripherals
for _, side in pairs(sides) do
  if peripheral.getType(side) == "merequester:requester" then
    ae2_side = side
  elseif peripheral.getType(side) == "monitor" then
    monitor_side = side
  elseif peripheral.getType(side) == "drive" then
    table.insert(disk_drive_sides, side)
  end
end

-- Check for the required peripherals
if ae2_side == "" then
  error("No AE2 system detected. Please ensure the computer is connected to an AE2 system.")
end

if monitor_side == "" then
  print("No monitor detected. Output will be printed to the terminal.")
end

if #disk_drive_sides == 0 then
  error("No disk drives detected. Please connect some disk drives.")
end

-- Get AE2 system and monitor peripherals
local ae2 = peripheral.wrap(ae2_side)
local monitor
if monitor_side ~= "" then
  monitor = peripheral.wrap(monitor_side)
  clearMonitor(monitor)
end

local function printOutput(line)
  print(line)
  if monitor ~= nil then
    monitor.write(line)
    x,y = monitor.getCursorPos()
    monitor.setCursorPos(1, y + 1)
  end
end

-- Calculate statistics
local items = ae2.listItems()
local total_items = 0
local total_size = 0

for _, item in pairs(items) do
  total_items = total_items + 1
  total_size = total_size + #textutils.serialize(item)
end

local snapshot_size = total_size
local disk_capacity = #disk_drive_sides * 128 * 1024
local num_snapshots = disk_capacity / snapshot_size

printOutput("Total item types: " .. total_items)
printOutput("Estimated snapshot size (bytes): " .. snapshot_size)
printOutput("Total disk drives: " .. #disk_drive_sides)
printOutput("Total disk capacity (bytes): " .. disk_capacity)
printOutput("Total estimated snapshots: " .. math.floor(num_snapshots))
