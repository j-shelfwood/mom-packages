local cobalt = require("cobalt.cobalt")
local generics = require("generics")
local peripheralSide = generics.findPeripheralSide("merequester:requester")

-- Define the format for our items.
local function formatItem(item)
    return item.name .. "\n" .. item.sign .. " " .. tostring(item.change)
end

-- Define our main loop
cobalt.loop = function()
    -- Get our peripheral
    local requester = peripheral.wrap(peripheralSide)
    local items = requester.items()
    local changes = {}

    -- Clear out our view
    cobalt.view.children = {}

    -- Create a row for each item
    for _, item in ipairs(items) do
        local itemName = generics.shortenName(item.name, 15)
        local itemCount = item.count

        -- If the item was already present, calculate the change
        if prevItems and prevItems[itemName] then
            local change = itemCount - prevItems[itemName]
            -- If there was a change, store it
            if change ~= 0 then
                changes[itemName] = {
                    change = math.abs(change),
                    sign = change > 0 and "+" or "-"
                }
            else
                changes[itemName] = nil
            end
        end

        -- Add our item to the view
        local column = cobalt.ui.new("Column", {
            width = 15,
            height = 3
        })
        local label = cobalt.ui.new("Label", {
            text = formatItem({
                name = itemName,
                sign = changes[itemName] and changes[itemName].sign or "+",
                change = changes[itemName] and changes[itemName].change or 0
            })
        })

        column:addChild(label)
        cobalt.view:addChild(column)
    end

    -- Store the current items for the next iteration
    prevItems = items
end

-- Automatically find the sides
local monitorSide = generics.findPeripheralSide("monitor")

if not monitorSide then
    print("Monitor not found.")
    return
end

if not peripheralSide then
    print("ME Requester not found.")
    return
end

-- Start Cobalt
cobalt.init(monitorSide)
cobalt.run()
