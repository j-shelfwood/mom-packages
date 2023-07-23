-- Function to check if a table contains a specific value
function tableContains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  end
  
  -- Function to fetch and print items from a peripheral
  function printItems(side)
    -- Check if there is a peripheral connected on the given side
    if not peripheral.isPresent(side) then
      print("No peripheral present on the " .. side .. " side.")
      return
    end
    
    -- Check if the peripheral has an 'items' method
    local methods = peripheral.getMethods(side)
    if not tableContains(methods, "items") then
      print("The peripheral on the " .. side .. " side does not have an 'items' method.")
      return
    end
  
    -- Get a reference to the peripheral
    local interface = peripheral.wrap(side)
  
    -- Fetch the items
    local items = interface.items()
  
    -- Print the items
    print("Items in the peripheral on the " .. side .. " side:")
    for _, item in pairs(items) do
      print(item.name .. ": " .. item.count)
    end
  end
  
  -- Ask the user to enter the side
  print("Enter the side where the peripheral is connected (top, bottom, left, right, front or back):")
  local side = read()
  
  -- Call the function to print the items
  printItems(side)
  