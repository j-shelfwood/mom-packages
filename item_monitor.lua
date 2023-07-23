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
  
  -- Function to get and display items from a peripheral on a monitor
  function displayItems(monitorSide, peripheralSide)
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
  
    -- Continuously fetch and display the items
    while true do
      -- Fetch the items
      local items = interface.items()
  
      -- Clear the monitor
      monitor.clear()
      monitor.setCursorPos(1, 1)
  
      -- Write the table header
      monitor.write("Items            Count")
  
      -- Write the items to the monitor
      local line = 2
      for _, item in pairs(items) do
        -- Check if we've reached the maximum number of lines
        if line > 19 then
          break
        end
        
        -- Write the item to the monitor
        monitor.setCursorPos(1, line)
        monitor.write(string.format("%-16s %6d", item.name, item.count)) -- formatted string for better alignment
        
        -- Increment the line number
        line = line + 1
      end
  
      -- Draw a horizontal line under the header
      paintutils.drawLine(1, 2, monitor.getSize(), 2, colors.gray)
  
      -- Wait for 1 second before the next update
      sleep(1)
    end
  end
  
  -- Ask the user to enter the sides
  print("Enter the side where the AE2 peripheral is connected (top, bottom, left, right, front or back):")
  local peripheralSide = read()
  
  print("Enter the side where the monitor is connected (top, bottom, left, right, front or back):")
  local monitorSide = read()
  
  -- Call the function to display the items
  displayItems(monitorSide, peripheralSide)
  