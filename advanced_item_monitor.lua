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

-- Function to split text into lines of at most a given length
function wordWrap(text, length)
  local lines = {}
  local line = ""
  for word in text:gmatch("%S+") do
    if #line + #word <= length then
      line = line .. (line == "" and "" or " ") .. word
    else
      table.insert(lines, line)
      line = word
    end
  end
  if line ~= "" then
    table.insert(lines, line)
  end
  return lines
end

-- Function to write centered text in a cell
function writeCentered(monitor, row, col, cellWidth, cellHeight, textLines, lineStart)
  for i, text in ipairs(textLines) do
    local x = (col - 1) * cellWidth + math.floor((cellWidth - #text) / 2) + 1
    local y = (row - 1) * cellHeight + lineStart + i - 1
    monitor.setCursorPos(x, y)
    monitor.write(text)
  end
end

-- Function to display item information in a grid
function displayItemInfo(monitorSide, peripheralSide, numColumns, numRows, textScale)
  -- Get a reference to the monitor and the peripheral
  local monitor = peripheral.wrap(monitorSide)
  local interface = peripheral.wrap(peripheralSide)

  -- Set the text scale
  monitor.setTextScale(textScale)

  -- Get monitor dimensions and calculate cell dimensions
  local monitorWidth, monitorHeight = monitor.getSize()
  local cellWidth = math.floor(monitorWidth / numColumns)
  local cellHeight = math.floor(monitorHeight / numRows)

  -- Initialize the previous items table
  local prevItems = {}

  -- Continuously fetch and display the items
  while true do
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
      local itemNameLines = wordWrap(item.name, cellWidth)
      local itemCount = item.count
      local itemChange = ""

      -- Calculate the change from the previous count
      if prevItems[item.name] then
        local change = itemCount - prevItems[item.name].count
        if change > 0 then
          itemChange = "+"
          prevItems[item.name].noChangeCount = 0
        elseif change < 0 then
          itemChange = "-"
          prevItems[item.name].noChangeCount = 0
        elseif prevItems[item.name].noChangeCount < 10 then
          itemChange = prevItems[item.name].change
          prevItems[item.name].noChangeCount = prevItems[item.name].noChangeCount + 1
        end
      end

      -- Save the current count and change for the next update
      prevItems[item.name] = {count = itemCount, change = itemChange, noChangeCount = (prevItems[item.name] and prevItems[item.name].noChangeCount or 0)}

      -- Write the item name, count and change in their respective cell
      writeCentered(monitor, row, col, cellWidth, cellHeight, itemNameLines, 1)
      writeCentered(monitor, row, col, cellWidth, cellHeight, {tostring(itemCount) .. " " .. itemChange}, #itemNameLines + 1)
    end
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

-- Ask for the text scale
print("Enter the text scale (0.5 - 5):")
local textScale = tonumber(read()) or 0.5

-- Call the function to display the item information
displayItemInfo(monitorSide, peripheralSide, numColumns, numRows, textScale)
