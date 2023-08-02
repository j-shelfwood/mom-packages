-- Function to inspect any detected peripheral and print out its methods (Computercraft/CC:Tweaked)
function inspectPeripheral()
    -- Get a list of all connected peripherals
    local peripherals = peripheral.getNames()

    -- If there are no peripherals available, print a message and return
    if #peripherals == 0 then
        print("No peripherals connected.")
        return
    end

    -- Prompt the user to select a peripheral
    print("Select a peripheral to inspect:")
    for i, peripheralName in ipairs(peripherals) do
        print(i .. ". " .. peripheralName)
    end
    local selection = tonumber(read())

    -- If the user entered an invalid selection, print a message and return
    if selection == nil or selection < 1 or selection > #peripherals then
        print("Invalid selection.")
        return
    end

    -- Get the methods of the selected peripheral
    local peripheralName = peripherals[selection]
    local methods = peripheral.getMethods(peripheralName)

    -- If there are no methods available, print a message and return
    if methods == nil or #methods == 0 then
        print("No methods available for the selected peripheral.")
        return
    end

    -- Print the methods in columns
    print("Methods for the " .. peripheralName .. " peripheral:")
    textutils.pagedPrint(methods)
end

inspectPeripheral()

