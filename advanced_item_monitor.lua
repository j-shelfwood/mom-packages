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

-- Function to shorten item names if they're too long
function shortenName(name)
  if #name <= 18 then
    return name
  elseif #name > 30 then
    return name:sub(1, 10) .. "..." .. name:sub(-10, -1)
  else
    return name:sub(1, 18) .. "..."
  end
end

-- Function to display item information in a grid
function displayItemInfo(monitorSide, peripheralSide, numColumns, numRows)
  -- Get a reference to the monitor and the peripheral
  local monitor = peripheral.wrap(monitorSide)
  local interface = peripheral.wrap(peripheralSide)

  print("Monitor and interface wrapped")

  -- Get monitor dimensions and calculate cell dimensions
  local monitorWidth, monitorHeight = monitor.getSize()
  local cellWidth = math.floor(monitorWidth / numColumns)
  local cellHeight = math.floor(monitorHeight / numRows)

  print("Monitor dimensions calculated")

  -- Initialize the previous items table
  local prevItems = {}

  print("Previous items table initialized")

  -- Continuously fetch and display the items
  while true do
    print("Start of new iteration")

    -- Clear the monitor
    monitor.clear()

    print("Monitor cleared")

    -- Get items
    local items = interface.items()

    print("Items fetched")

    -- Sort items
    table.sort(items, function(a, b) return a.count > b.count end)

    print("Items sorted")

    -- Display items in the grid
    for i = 1, math.min(#items, numColumns * numRows) do
      print("Start of new item")

      local row = math.floor((i - 1) / numColumns) + 1
      local col = (i - 1) % numColumns + 1
      local item = items[i]
      local itemName = shortenName(item.name)
      local itemCount = item.count
      local itemChange = ""

      -- Calculate the change from the previous count
      if prevItems[itemName] then
        local change = itemCount - prevItems[itemName].count
        if change > 0 then
          itemChange = "+"
          prevItems[itemName].noChangeCount = 0
        elseif change < 0 then
          itemChange = "-"
          prevItems[itemName].noChangeCount = 0
        elseif prevItems[itemName].noChangeCount < 10 then
          itemChange = prevItems[itemName].change
          prevItems[itemName].noChangeCount = prevItems[itemName].noChangeCount + 1
        end
      end

      print("Item change calculated")

      -- Save the current count and change for the next update
      prevItems[itemName] = {count = itemCount, change = itemChange, noChangeCount = (prevItems[itemName] and prevItems[itemName].noChangeCount or 0)}

      print("Current item saved for next update")

      -- Write the item name, count and change in their respective cell
      writeCentered(monitor, row, col, cellWidth, cellHeight, itemName, 1)
      writeCentered(monitor, row, col, cellWidth, cellHeight, tostring(itemCount) .. " " .. itemChange, 2)

      print("Item information written to monitor")
    end
    sleep(0.25)
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
