-- Required imports or definitions
local generics = require("generics")
local peripheralSide = generics.findPeripheralSide("merequester:requester")

-- Function to save items to file
function saveItemsToFile(fileName)
    -- Get a reference to the peripheral
    local interface = peripheral.wrap(peripheralSide)

    -- Get items
    local items = interface.items()

    -- Open the file in write mode
    local file = fs.open(fileName, "w")

    -- Write each item to the file
    for _, item in ipairs(items) do
        file.writeLine(textutils.serialize(item))
    end

    -- Close the file
    file.close()

    print("Items saved to " .. fileName)
end

-- Use the function to save items to a file
saveItemsToFile("items.txt")
