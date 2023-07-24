-- Function to check if a table contains a specific value
function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

-- Function to sort items by count
function sortItems(items)
  table.sort(items, function(a, b) return a.count > b.count end)
end

-- Function to auto-detect peripherals
function detectPeripherals()
  local sides = {"left", "right", "front", "back", "top", "bottom"}
  local monitorSide, peripheralSide

  for _, side in pairs(sides) do
    if peripheral.getType(side) == "monitor" then
      monitorSide = side
    elseif peripheral.getType(side) == "merequester:requester" then
      peripheralSide = side
    end
  end
  
  return monitorSide, peripheralSide
end

-- Function to display item information in a "powerpoint" style
function displayItemInfo(monitorSide, peripheralSide, numItems, numColumns)
  local monitor = peripheral.wrap(monitorSide)
  local interface = peripheral.wrap(peripheralSide)

  local width, height = monitor.getSize()

  local columnWidth = math.floor(width / numColumns)
  local rows = math.ceil(numItems / numColumns)
  
  -- previous state for change calculation
  local prevItems = {}

  -- Continuously fetch and display the items
  while true do
    local items = interface.getItemsInNetwork()
    sortItems(items)

    monitor.clear()

    for row = 1, rows do
      for column = 1, numColumns do
        local index = (row - 1) * numColumns + column
        if index > numItems then
          break
        end

        local item = items[index]
        local itemName = item.label
        local itemCount = item.size
        local itemChange = (prevItems[itemName] or itemCount) - itemCount

        -- Save current count for next loop
        prevItems[itemName] = itemCount

        -- Print item data to screen
        monitor.setCursorPos((column - 1) * columnWidth + 1, row)
        monitor.write(string.format("%s: %d (%+d)", itemName, itemCount, itemChange))
      end
    end

    sleep(10)
  end
end

-- Auto-detect peripherals
local monitorSide, peripheralSide = detectPeripherals()

if not monitorSide or not peripheralSide then
  error("Failed to detect necessary peripherals. Make sure they are connected.")
end

-- Ask the user for the display parameters
print("Enter the number of items to display:")
local numItems = tonumber(read())

print("Enter the number of columns for the display grid:")
local numColumns = tonumber(read())

-- Call the function to display the item information
displayItemInfo(monitorSide, peripheralSide, numItems, numColumns)
