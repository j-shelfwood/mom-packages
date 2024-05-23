-- Include Grid Display API
local GridDisplay = mpm('generics/grid_display')
local Generics = mpm('generics/generics')

function findPeripheralSide(name)
    local sides = { "top", "bottom", "left", "right", "front", "back" }

    -- Direct connection
    for _, side in ipairs(sides) do
        if peripheral.isPresent(side) and peripheral.getType(side) == name then
            return side
        end
    end

    -- Check peripherals over network
    local peripheralsList = peripheral.getNames()
    local foundPeripherals = {}
    for _, peripheralName in ipairs(peripheralsList) do
        if peripheral.getType(peripheralName) == name then
            table.insert(foundPeripherals, peripheralName)
        end
    end

    if #foundPeripherals > 0 then
        print("Using peripheral:", foundPeripherals[1])
        return foundPeripherals[1]
    end

    return nil
end

-- Function to display item information in a grid
function displayItemInfo(monitorSide, peripheralSide)
    -- Get a reference to the monitor and the peripheral
    local monitor = peripheral.wrap(monitorSide)
    local interface = peripheral.wrap(peripheralSide)
    local display = GridDisplay.new(monitor)

    -- Initialize the previous items table and current items table
    local prevItems = {}
    local currItems = {}

    -- Define a formatting callback for the grid display
    local function format_callback(item)
        local color = item.change == "+" and colors.green or colors.red
        return {
            lines = { Generics.prettifyItemIdentifier(item.name), tostring(item.count), item.change },
            colors = { colors.white, colors.white, color }
        }
    end

    -- Continuously fetch and display the items
    while true do
        local items = {}
        if peripheral.getType(peripheralSide) == "meBridge" then
            items = interface.listItems()
            for _, item in ipairs(items) do
                item.name = item.displayName
                item.count = item.amount
            end
        else
            items = interface.items()
        end

        -- Sort items
        table.sort(items, function(a, b)
            return a.count > b.count
        end)

        -- Display items in the grid
        for i = 1, #items do
            local item = items[i]
            local itemName = item.name
            local itemCount = item.count
            local itemChange = ""

            -- Calculate the change from the previous count
            if prevItems[itemName] then
                local change = itemCount - prevItems[itemName].count
                if change > 0 then
                    itemChange = "+"
                elseif change < 0 then
                    itemChange = "-"
                end
            end

            -- Save the current count and change for the next update
            prevItems[itemName] = {
                count = itemCount
            }

            -- Update current items table
            currItems[i] = {
                name = itemName,
                count = itemCount,
                change = itemChange
            }
        end

        -- Display the changes on the monitor
        display:display(currItems, format_callback)

        sleep(0.5)
    end
end

-- Automatically find the sides
local monitorSide = findPeripheralSide("monitor")

if not monitorSide then
    print("Monitor not found.")
    return
end

local peripheralSide = findPeripheralSide("meBridge") or findPeripheralSide("merequester:requester")

if not peripheralSide then
    print("Neither ME Bridge nor ME Requester found.")
    return
end

-- Call the function to display the item information
displayItemInfo(monitorSide, peripheralSide)
