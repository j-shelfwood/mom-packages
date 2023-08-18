local ITEMS_PER_PAGE = 10 -- Adjust based on screen size and readability

function inspectPeripheral()
    local peripherals = peripheral.getNames()
    if #peripherals == 0 then
        print("No peripherals connected.")
        return
    end

    print("Select a peripheral to inspect:")
    for i, peripheralName in ipairs(peripherals) do
        print(i .. ". " .. peripheralName)
    end
    local selection = tonumber(read())
    if selection == nil or selection < 1 or selection > #peripherals then
        print("Invalid selection.")
        return
    end

    local peripheralName = peripherals[selection]
    local methods = peripheral.getMethods(peripheralName)
    local target = peripheral.wrap(peripheralName)
    if methods == nil or #methods == 0 then
        print("No methods available for the selected peripheral.")
        return
    end

    print("Methods for the " .. peripheral.getType(target) .. " peripheral:")
    local currentPage = 1
    while true do
        for i = (currentPage - 1) * ITEMS_PER_PAGE + 1, math.min(#methods, currentPage * ITEMS_PER_PAGE) do
            print(i .. ". " .. methods[i])
        end

        print("Page " .. currentPage .. "/" .. math.ceil(#methods / ITEMS_PER_PAGE))
        print("Enter method number (or 'n' for next page, 'p' for previous page):")
        local input = read()

        if input == "n" and currentPage < math.ceil(#methods / ITEMS_PER_PAGE) then
            currentPage = currentPage + 1
        elseif input == "p" and currentPage > 1 then
            currentPage = currentPage - 1
        elseif tonumber(input) and tonumber(input) > 0 and tonumber(input) <= #methods then
            local methodName = methods[tonumber(input)]
            print("Enter arguments for method " .. methodName .. " (comma separated, leave blank for none):")
            local argsInput = read()
            local args = {}
            for arg in string.gmatch(argsInput, "[^,]+") do
                table.insert(args, arg)
            end
            local result = textutils.serialize(target[methodName](unpack(args)))
            print("Result:")
            print(result)
            break
        else
            print("Invalid input. Try again.")
        end
    end
end

inspectPeripheral()
