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

-- Function to suggest display settings based on monitor size
function suggestSettings(monitor)
  local width, height = monitor.getSize()
  -- We'll assume that each item needs a 2x2 space to display neatly
  local suggestedColumns = math.floor(width / 2)
  local suggestedRows = math.floor(height / 2)
  
  return suggestedColumns, suggestedRows
end

-- Function to display item information in a "powerpoint" style
function displayItemInfo(monitorSide, peripheralSide, numColumns, numRows)
  -- Get a reference to the monitor and the peripheral
  local monitor = peripheral.wrap(monitorSide)
  local interface = peripheral.wrap(peripheralSide)

  
  -- Continuously fetch and display the items
  while true do
    local items = interface.items()
    sortItems(items)

    monitor.clear()

    for row = 1, numRows do
      for column = 1, numColumns do
        local index = (row - 1) * numColumns + column
        if index > #items then
          break
        end

        local item = items[index]
        local itemName = item.name
        local itemCount = item.count

        -- Calculate positions based on row and column
        local posX = (column - 1) * 2 + 1
        local posY = (row - 1) * 2 + 1

        -- Print item data to screen
        monitor.setCursorPos(posX, posY)
        monitor.write(string.format("%s: %d", itemName, itemCount))
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

-- Detect monitor and suggest settings
local monitor = peripheral.wrap(monitorSide)
local suggestedColumns, suggestedRows = suggestSettings(monitor)

print("Suggested display settings: " .. suggestedColumns .. " columns, " .. suggestedRows .. " rows.")
print("Enter the number of columns for the display grid (or press Enter to use the suggested setting):")
local numColumns = tonumber(read()) or suggestedColumns

print("Enter the number of rows for the display grid (or press Enter to use the suggested setting):")
local numRows = tonumber(read()) or suggestedRows

-- Call the function to display the item information
displayItemInfo(monitorSide, peripheralSide, numColumns, numRows)
