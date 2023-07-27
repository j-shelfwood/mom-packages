local cobalt = dofile("path/to/cobalt") -- replace with the correct path to your Cobalt file
local generics = require("generics")

-- Automatically find the sides
local monitorSide = generics.findPeripheralSide("monitor")
local peripheralSide = generics.findPeripheralSide("merequester:requester")

if not monitorSide then
    print("Monitor not found.")
    return
end

if not peripheralSide then
    print("ME Requester not found.")
    return
end

-- Global variable to store the previous items
prevItems = {}

-- Helper function to format an item
function formatItem(item)
    return item.name .. "\n" .. item.sign .. " " .. tostring(item.change)
end

-- Callback for the update phase
function cobalt.update(dt)
    -- Get the peripheral
    local requester = peripheral.wrap(peripheralSide)
    local items = requester.items()

    -- Clear the term
    term.clear()

    -- Iterate over items and print them
    for _, item in ipairs(items) do
        local itemName = generics.shortenName(item.name, 15)
        local itemCount = item.count

        -- If the item was already present, calculate the change
        local change = 0
        if prevItems[itemName] then
            change = itemCount - prevItems[itemName]
        end

        -- Format the item and print it
        local formattedItem = formatItem({
            name = itemName,
            sign = change >= 0 and "+" or "-",
            change = math.abs(change)
        })
        print(formattedItem)

        -- Update the previous items
        prevItems[itemName] = itemCount
    end

    -- Sleep for a bit to prevent constant updates
    sleep(10)
end

-- Callback for the draw phase
function cobalt.draw()

end

-- Callback for mouse press
function cobalt.mousepressed(x, y, button)

end

-- Callback for mouse release
function cobalt.mousereleased(x, y, button)

end

-- Callback for key press
function cobalt.keypressed(keycode, key)

end

-- Callback for key release
function cobalt.keyreleased(keycode, key)

end

-- Callback for text input
function cobalt.textinput(t)

end

-- Start Cobalt
cobalt.initLoop()
