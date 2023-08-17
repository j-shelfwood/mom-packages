-- data_processing.lua
local DataProcessing = {}
local generics = require('generics')

-- Function to fetch items from the AE2 system
function DataProcessing.fetch_items()
    -- Get a reference to the peripheral
    local interface = peripheral.wrap(generics.findPeripheralSide("merequester:requester"))

    -- Get items
    local allItems = interface.items()

    -- Consolidate items
    local consolidatedItems = {}
    for _, item in ipairs(allItems) do
        local techName = item.technicalName
        if consolidatedItems[techName] then
            consolidatedItems[techName].count = consolidatedItems[techName].count + item.count
        else
            consolidatedItems[techName] = {
                name = item.name,
                technicalName = techName,
                count = item.count
            }
        end
    end

    -- Convert the consolidated items dictionary into a list
    local items = {}
    for _, item in pairs(consolidatedItems) do
        table.insert(items, item)
    end

    return items
end

-- Function to calculate the changes between two item lists
function DataProcessing.calculate_changes(prev_items, curr_items)
    -- Convert the previous item list into a dictionary for easier lookup
    local prev_dict = {}
    for _, item in ipairs(prev_items) do
        prev_dict[item.technicalName] = item.count
    end

    -- Calculate changes
    local changes = {}
    for _, item in ipairs(curr_items) do
        local prev_count = prev_dict[item.technicalName]
        if prev_count and prev_count ~= item.count then
            local change = math.abs(item.count - prev_count)
            local operation = item.count > prev_count and "+" or "-"
            table.insert(changes, {
                name = item.name,
                technicalName = item.technicalName,
                count = item.count,
                change = math.abs(change),
                operation = operation
            })
        end
    end

    return changes
end

return DataProcessing
