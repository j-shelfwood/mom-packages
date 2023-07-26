-- Import monitor API
local generics = require("generics")

-- Function to track input of items
function trackInput(monitorSide, peripheralSide, numColumns, numRows)
  -- Get a reference to the monitor and the peripheral
  local monitor = peripheral.wrap(monitorSide)
  local interface = peripheral.wrap(peripheralSide)

  -- Initialize the previous items table and the changes table
  local prevItems = {}
  local changes = {}

  -- Continuously fetch and display the items
  while true do
    -- Get items
    local items = interface.items()

    for _, item in ipairs(items) do
      local itemName = generics.shortenName(item.name)
      local itemCount = item.count

      -- Calculate the change from the previous count and update the changes table
      if prevItems[itemName] then
        local change = itemCount - prevItems[itemName]
        if changes[itemName] then
          changes[itemName] = changes[itemName] + change
        else
          changes[itemName] = change
        end
      end

      -- Save the current count for the next update
      prevItems[itemName] = itemCount
    end

    -- Convert the changes table to a list and sort it by absolute value of change
    local sortedChanges = {}
    for itemName, change in pairs(changes) do
      table.insert(sortedChanges, {name = itemName, change = change})
    end
    table.sort(sortedChanges, function(a, b) return math.abs(a.change) > math.abs(b.change) end)

    -- Keep only the top X changes
    while #sortedChanges > numColumns * numRows do
      table.remove(sortedChanges)
    end

    -- Display changes in the grid
    generics.displayChangesInGrid(monitor, sortedChanges, numColumns, numRows)

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
