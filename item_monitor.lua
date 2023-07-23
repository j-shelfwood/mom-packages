-- Function to check if a table contains a specific value
function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

-- Function to validate side input
function validateSide(side)
  local validSides = {"top", "bottom", "left", "right", "front", "back"}
  return tableContains(validSides, side)
end

-- Function to sort items by count
function sortItems(items)
  table.sort(items, function(a, b) return a.count > b.count end)
end

-- Function to display item information in a "powerpoint" style
function displayItemInfo(monitorSide, peripheralSide)
  -- Validate the sides
  if not validateSide(peripheralSide) then
    print("Invalid side: " .. peripheralSide)
    return
  end
  
  if not validateSide(monitorSide) then
    print("Invalid side: " .. monitorSide)
    return
  end

  -- Check if there are peripherals connected on the given sides
  if not peripheral.isPresent(peripheralSide) then
    print("No peripheral present on the " .. peripheralSide .. " side.")
    return
  end
  
  if not peripheral.isPresent(monitorSide) then
    print("No monitor present on the " .. monitorSide .. " side.")
    return
  end

  -- Check if the peripheral has an 'items' method
  local methods = peripheral.getMethods(peripheralSide)
  if not tableContains(methods, "items") then
    print("The peripheral on the " .. peripheralSide .. " side does not have an 'items' method.")
    return
  end

  -- Get a reference to the monitor and the peripheral
  local monitor = peripheral.wrap(monitorSide)
  local interface = peripheral.wrap(peripheralSide)

  local width, height = monitor.getSize()

  -- Continuously fetch and display the items
  while true do
    -- Update items
    local items = interface.items()
    sortItems(items)

    for i = 1, math.min(#items, 50) do
      local item = items[i]
      local itemName = item.name
      local itemCount = item.count
      
      -- Clear the monitor
      monitor.clear()
      
      -- Write the item name and count
      monitor.setCursorPos(math.floor((width - #itemName) / 2) + 1, math.floor(height / 2))
      monitor.write(itemName)
      monitor.setCursorPos(math.floor((width - #tostring(itemCount)) / 2) + 1, math.floor(height / 2) + 1)
      monitor.write(tostring(itemCount))
      
      -- Write the "dots"
      for dot = 3, 1, -1 do
        monitor.setCursorPos(width - dot, height)
        monitor.write(".")
        sleep(1)
      end
    end
  end
end

-- Ask the user to enter the sides
print("Enter the side where the AE2 peripheral is connected (top, bottom, left, right, front or back):")
local peripheralSide = read()

print("Enter the side where the monitor is connected (top, bottom, left, right, front or back):")
local monitorSide = read()

-- Call the function to display the item information
displayItemInfo(monitorSide, peripheralSide)