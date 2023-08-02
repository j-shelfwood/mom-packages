-- Function to inspect a peripheral and print out its methods
function inspectPeripheral(side)
    -- Check if there is a peripheral connected on the given side
    if not peripheral.isPresent(side) then
        print("No peripheral present on the " .. side .. " side.")
        return
    end

    -- Get the methods of the peripheral
    local methods = peripheral.getMethods(side)

    -- If there are no methods available, print a message and return
    if methods == nil or #methods == 0 then
        print("No methods available for the peripheral on the " .. side .. " side.")
        return
    end

    -- Print the methods
    print("Methods for the peripheral on the " .. side .. " side:")
    for _, method in ipairs(methods) do
        print(method)
    end
end

-- Auto-detect any peripherals connected to the computer
local sides = {"top", "bottom", "left", "right", "front", "back"}
for _, side in ipairs(sides) do
    inspectPeripheral(side)
end
