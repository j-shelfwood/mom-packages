-- Function to check if a table contains a specific value
function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

-- Function to find peripheral side
function findPeripheralSide(name)
  local sides = {"top", "bottom", "left", "right", "front", "back"}
  for _, side in ipairs(sides) do
    if peripheral.isPresent(side) and peripheral.getType(side) == name then
      return side
    end
  end
  return nil
end

-- Function to write centered text in a cell
function writeCentered(monitor, row, col, cellWidth, cellHeight, text, line)
  local x = (col - 1) * cellWidth + math.floor((cellWidth - #text) / 2) + 1
  local y = (row - 1) * cellHeight + line
  monitor.setCursorPos(x, y)
  monitor.write(text)
end

-- Function to display item information in a grid
function displayItemInfo(monitorSide, peripheralSide, numColumns, numRows)
  -- Get a reference to the monitor and the peripheral
  local monitor = peripheral.wrap(monitorSide)
  local interface = peripheral.wrap(peripheralSide)
  
  -- Get monitor dimensions and calculate cell dimensions
  local monitorWidth, monitorHeight = monitor.getSize()
  local cellWidth = math.floor(monitorWidth / numColumns)
  local cellHeight = math.floor(monitorHeight / numRows)
  
  -- Initialize a render counter
  local renderCount = 0
  
  -- Continuously fetch and display the items
  while true do
    -- Increment the render count
    renderCount = renderCount + 1
    
    -- Clear the monitor
    monitor.clear()
    
    -- Get items
    local items = interface.items()
    
    -- Sort items
    table.sort(items, function(a, b) return a.count > b.count end)
    
    -- Display items in the grid
    for i = 1, math.min(#items, numColumns * numRows) do
      local row = math.floor((i - 1) / numColumns) + 1
      local col = (i - 1) % numColumns + 1
      local item = items[i]
      local itemName = item.name
      local itemCount = item.count
      
      -- Write the item name, count and difference in their respective cell
      writeCentered(monitor, row, col, cellWidth, cellHeight, itemName, 1)
      writeCentered(monitor, row, col, cellWidth, cellHeight, tostring(itemCount), 2)
      if renderCount % 4 == 0 then
        if item.lastCount then
          writeCentered(monitor, row, col, cellWidth, cellHeight, "+" .. tostring(itemCount - item.lastCount), 3)
        end
        item.lastCount = itemCount
      end
    end
    
    -- Sleep for a while before the next update
    sleep(0.1)
  end
end


-- Automatically find the sides
local monitorSide = findPeripheralSide("monitor")
local peripheralSide = findPeripheralSide("merequester:requester")

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

-- Call the function to display the item information
displayItemInfo(monitorSide, peripheralSide, numColumns, numRows)
