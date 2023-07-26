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

return generics
