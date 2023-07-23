-- Constants for the number of items per page
local ITEMS_PER_PAGE = 20

-- Constants for the number of columns
local COLUMNS = 2

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

  local width, height = monitor.getSize()

  -- Initialize the current page
  local currentPage = 1
  local items = {}

  -- Update items every second
  local function updateItems()
    while true do
      items = interface.items()
      sortItems(items)
      sleep(1)
    end
  end

  -- Create parallel process to update items
  local updateProcess = parallel.waitForAny(updateItems, function() os.pullEvent("key") end)

  -- Continuously fetch and display the items
  while true do
    -- Determine the number of pages
    local numPages = math.ceil(#items / ITEMS_PER_PAGE)

    -- Ensure the current page is valid
    currentPage = math.min(currentPage, numPages)
    currentPage = math.max(currentPage, 1)

    -- Determine the range of items to display on this page
    local startItem = (currentPage - 1) * ITEMS_PER_PAGE + 1
    local endItem = math.min(startItem + ITEMS_PER_PAGE - 1, #items)

    -- Clear the monitor
    monitor.clear()
    monitor.setCursorPos(1, 1)

    -- Write the page number and total number of pages to the monitor
    monitor.write("Page " .. tostring(currentPage) .. " of " .. tostring(numPages))

    -- Write the items to the monitor
    local line = 2
    for i = startItem, endItem do
      -- Check if we've reached the maximum number of lines
      if line > height then
        break
      end
      
      -- Write the item to the monitor
      local item = items[i]
      local itemDisplay = string.format("%s %s", item.name, tostring(item.count))
      
      -- Determine the column to write to
      local column = (i - startItem) % COLUMNS
      local columnWidth = math.floor(width / COLUMNS)
      
      -- Right-align the item count within the column
      monitor.setCursorPos(column * columnWidth + 1, line)
      monitor.write(itemDisplay)

      -- Increment the line number
      if column == COLUMNS - 1 then
        line = line + 1
      end
    end

    -- Wait for the user to change the page or for the items to be updated
    local event, key = os.pullEvent()
    if event == "key" then
      if key == keys.right then
        currentPage = currentPage + 1
      elseif key == keys.left then
        currentPage = currentPage - 1
      end
    end
  end
end

-- Ask the user to enter the sides
print("Enter the side where the AE2 peripheral is connected (top, bottom, left, right, front or back):")
local peripheralSide = read()

print("Enter the side where the monitor is connected (top, bottom, left, right, front or back):")
local monitorSide = read()

-- Call the function to display the items
displayItems(monitorSide, peripheralSide)
