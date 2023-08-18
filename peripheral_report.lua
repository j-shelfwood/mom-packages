-- peripheral_report.lua
-- Helper function to serialize safely
function safeSerialize(value)
    local seen = {}
    local function _serialize(value)
        if type(value) == "table" then
            if seen[value] then
                return '"[Cyclical table reference]"'
            end
            seen[value] = true
            local serializedTable = {}
            for k, v in pairs(value) do
                table.insert(serializedTable, _serialize(k) .. " = " .. _serialize(v))
            end
            return "{" .. table.concat(serializedTable, ", ") .. "}"
        elseif type(value) == "string" then
            return string.format("%q", value)
        else
            return tostring(value)
        end
    end
    return _serialize(value)
end

-- Helper function to save to a file
function saveToFile(filename, data)
    local file = fs.open(filename, "w")
    if file then
        file.write(data)
        file.close()
        print("Saved to " .. filename)
    else
        print("Failed to save to file.")
    end
end

function peripheralReport()
    local peripherals = peripheral.getNames()
    if #peripherals == 0 then
        print("No peripherals connected.")
        return
    end

    -- Select a peripheral
    print("Select a peripheral to create a report for:")
    for i, peripheralName in ipairs(peripherals) do
        print(i .. ". " .. peripheralName)
    end
    local selection = tonumber(read())
    if selection == nil or selection < 1 or selection > #peripherals then
        print("Invalid selection.")
        return
    end

    local peripheralName = peripherals[selection]
    local target = peripheral.wrap(peripheralName)

    -- Begin gathering report details
    local report = {}
    table.insert(report, "Peripheral Report for: " .. peripheralName)
    table.insert(report, "Type: " .. peripheral.getType(target))
    table.insert(report, "Available Methods:")

    local methods = peripheral.getMethods(peripheralName)
    for _, methodName in ipairs(methods) do
        table.insert(report, " - " .. methodName)

        -- Attempt to call the method with no arguments
        -- (This might fail for methods that require arguments)
        local status, result = pcall(function()
            return target[methodName]()
        end)

        if status then
            table.insert(report, "   Sample Output: " .. safeSerialize(result))
        else
            table.insert(report,
                "   Sample Output: Failed to call method (might require arguments or have side-effects).")
        end
    end

    -- Save the report to a file
    local filename = peripheralName .. "_report.txt"
    saveToFile(filename, table.concat(report, "\n"))
end

peripheralReport()
