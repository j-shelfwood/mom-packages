local ae2_side = ""
local monitor_side = ""
local sides = {"left", "right", "front", "back", "top", "bottom"}

-- Helper function to clear monitor
function clearMonitor(monitor)
  monitor.clear()
  monitor.setCursorPos(1,1)
end

-- Function to check if a table contains a specific value
function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

-- Detect peripherals
for _, side in pairs(sides) do
  if peripheral.getType(side) == "merequester:requester" then
    ae2_side = side
  elseif peripheral.getType(side) == "monitor" then
    monitor_side = side
  end
end

-- Check for the required peripherals
if ae2_side == "" then
  error("No AE2 system detected. Please ensure the computer is connected to an AE2 system.")
end

if monitor_side == "" then
  print("No monitor detected. Output will be printed to the terminal.")
end

-- Get AE2 system and monitor peripherals
local ae2 = peripheral.wrap(ae2_side)
local monitor = peripheral.wrap(monitor_side)
clearMonitor(monitor)

-- Function to sort items by count
function sortItems(items)
  table.sort(items, function(a, b) return a.count > b.count end)
end

print("Enter the number of items to show:")
local numItemsToShow = tonumber(read())

print("Enter the number of columns for the display grid:")
local numColumns = tonumber(read())

local lastCounts = {}
local items = ae2.listItems()
sortItems(items)

for i = 1, numItemsToShow do
  local item = items[i]
  lastCounts[item.name] = item.count
end

-- Display items in a grid
while true do
  clearMonitor(monitor)
  local items = ae2.listItems()
  sortItems(items)
  
  local rowIndex = 1
  for i = 1, numItemsToShow do
    local item = items[i]
    local itemName = item.name
    local itemCount = item.count
    local difference = itemCount - (lastCounts[itemName] or 0)
    lastCounts[itemName] = itemCount
    
    for j = 1, numColumns do
      monitor.setCursorPos((j - 1) * 12 + 1, rowIndex)
      monitor.write(itemName)
      monitor.setCursorPos((j - 1) * 12 + 1, rowIndex + 1)
      monitor.write("Count: " .. itemCount)
      monitor.setCursorPos((j - 1) * 12 + 1, rowIndex + 2)
      monitor.write("Difference: " .. difference)
      
      i = i + 1
      if i > numItemsToShow then break end
      item = items[i]
      itemName = item.name
      itemCount = item.count
      difference = itemCount - (lastCounts[itemName] or 0)
      lastCounts[itemName] = itemCount
    end
    
    rowIndex = rowIndex + 3
    if rowIndex > monitor.getSize() then break end
  end
  
  sleep(10)
end
