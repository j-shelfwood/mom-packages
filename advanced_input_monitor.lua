-- Import the API
local generics = require("generics")

-- Function to track input of items
function trackInput(monitorSide, peripheralSide, numColumns, numRows)
    -- Get a reference to the monitor and the peripheral
    local monitor = peripheral.wrap(monitorSide)
    local interface = peripheral.wrap(peripheralSide)
  
    -- Initialize the previous items table and the hourly counts table
    local prevItems = {}
    local hourlyCounts = {}
  
    -- Continuously fetch and display the items
    while true do
      -- Get items
      local items = interface.items()
  
      -- Sort items
      table.sort(items, function(a, b) return a.count > b.count end)
  
      -- Display items in the grid
      for i = 1, math.min(#items, numColumns * numRows) do
        local item = items[i]
        local itemName = generics.shortenName(item.name)
        local itemCount = item.count
        local change = 0
        local hourlyAvg = 0
  
        -- Calculate the change from the previous count
        if prevItems[itemName] then
          change = itemCount - prevItems[itemName].count
          item.count = change
  
          -- Update the hourly counts table and calculate the hourly average
          if not hourlyCounts[itemName] then
            hourlyCounts[itemName] = {counts = {}, total = 0, count = 0}
          end
          table.insert(hourlyCounts[itemName].counts, change)
          hourlyCounts[itemName].total = hourlyCounts[itemName].total + change
          hourlyCounts[itemName].count = hourlyCounts[itemName].count + 1
          if hourlyCounts[itemName].count > 60 then
            local oldestCount = table.remove(hourlyCounts[itemName].counts, 1)
            hourlyCounts[itemName].total = hourlyCounts[itemName].total - oldestCount
            hourlyCounts[itemName].count = hourlyCounts[itemName].count - 1
          end
          hourlyAvg = math.floor(hourlyCounts[itemName].total / hourlyCounts[itemName].count)
        end
  
        -- Save the current count for the next update
        prevItems[itemName] = {count = itemCount}
  
        -- Update the item count to include the hourly average and the change
        item.count = tostring(itemCount) .. " (" .. tostring(change) .. " / " .. tostring(hourlyAvg) .. ")"
      end
  
      -- Display items in the grid
      generics.displayItemsInGrid(monitor, items, numColumns, numRows)
  
      sleep(60)
    end
  end
  

-- Automatically find the sides
local monitorSide = generics.findPeripheralSide("monitor")
local peripheralSide = generics.findPeripheralSide("merequester:requester")

if not monitorSide then
  print("Monitor not found.")
  return
end

if not peripheralSide then
  print("ME Requester not found.")
  return
end

-- Ask for the number of columns and rows
print("Enter the number of columns for the item grid:")
local numColumns = tonumber(read())

print("Enter the number of rows for the item grid:")
local numRows = tonumber(read())

-- Call the function to track the input of items
trackInput(monitorSide, peripheralSide, numColumns, numRows)
