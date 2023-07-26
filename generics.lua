local generics = {}

-- Function to find peripheral side
function generics.findPeripheralSide(name)
  local sides = {"top", "bottom", "left", "right", "front", "back"}
  for _, side in ipairs(sides) do
    if peripheral.isPresent(side) and peripheral.getType(side) == name then
      return side
    end
  end
  return nil
end

-- Function to shorten item names if they're too long
function generics.shortenName(name)
  if #name <= 18 then
    return name
  elseif #name > 30 then
    return name:sub(1, 10) .. "..." .. name:sub(-10, -1)
  else
    return name:sub(1, 18) .. "..."
  end
end

-- Function to write centered text in a cell
function generics.writeCentered(monitor, row, col, cellWidth, cellHeight, text, line)
  local x = (col - 1) * cellWidth + math.floor((cellWidth - #text) / 2) + 1
  local y = (row - 1) * cellHeight + line
  monitor.setCursorPos(x, y)
  monitor.write(text)
end

-- Function to display items in a grid
function generics.displayItemsInGrid(monitor, items, numColumns, numRows)
  -- Get monitor dimensions and calculate cell dimensions
  local monitorWidth, monitorHeight = monitor.getSize()
  local cellWidth = math.floor(monitorWidth / numColumns)
  local cellHeight = math.floor(monitorHeight / numRows)

  -- Display items in the grid
  for i = 1, math.min(#items, numColumns * numRows) do
    local row = math.floor((i - 1) / numColumns) + 1
    local col = (i - 1) % numColumns + 1
    local item = items[i]
    local itemName = generics.shortenName(item.name)
    local itemCount = item.count

    -- Write the item name and count in their respective cell
    generics.writeCentered(monitor, row, col, cellWidth, cellHeight, itemName, 1)
    generics.writeCentered(monitor, row, col, cellWidth, cellHeight, tostring(itemCount), 2)
  end
end

-- Function to display changes in a grid
function displayChangesInGrid(monitor, changes, numColumns, numRows)
    -- Clear the monitor
    monitor.clear()
  
    -- Write the changes in the grid
    for i = 1, math.min(#changes, numColumns * numRows) do
      local row = math.floor((i - 1) / numColumns) + 1
      local col = (i - 1) % numColumns + 1
      local change = changes[i]
  
      -- Write the item name, count, change and hourly average in their respective cell
      local y = (row - 1) * 3 + 1
      monitor.setCursorPos(col, y)
      monitor.write(change.name)
      monitor.setCursorPos(col, y + 1)
      monitor.write("Count: " .. tostring(change.count))
      monitor.setCursorPos(col, y + 2)
      monitor.write("Last read: " .. (change.change >= 0 and "+" or "") .. tostring(change.change))
      monitor.setCursorPos(col, y + 3)
      monitor.write("Avg. hourly: " .. (change.hourlyAvg >= 0 and "+" or "") .. tostring(change.hourlyAvg))
    end
  end
  

return generics
