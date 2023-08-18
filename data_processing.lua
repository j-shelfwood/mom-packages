-- data_processing.lua
local DataProcessing = {}
local generics = require('generics')

-- Function to fetch items from the AE2 system
function DataProcessing.fetch_items()
    -- Get a reference to the peripheral
    local interface
    if peripheralType == "meBridge" then
        interface = peripheral.wrap(generics.findPeripheralSide("meBridge"))
    elseif peripheralType == "merequester:requester" then
        interface = peripheral.wrap(generics.findPeripheralSide("merequester:requester"))
    else
        error("No compatible peripheral detected.")
    end

    local allItems = {}
    if peripheralType == "meBridge" then
        allItems = interface.listItems()
        for _, item in ipairs(allItems) do
            item.technicalName = item.nbt.id
            item.name = item.nbt.displayName
            item.count = item.amount
        end
    elseif peripheralType == "merequester:requester" then
        allItems = interface.items()
    end

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

-- Function to fetch fluids from the AE2 system
function DataProcessing.fetch_fluids()
    -- Get a reference to the peripheral (assuming it's named fluid_requester)
    local interface = peripheral.wrap(generics.findPeripheralSide("merequester:requester"))

    -- Get fluids
    local allFluids = interface.tanks()

    -- Consolidate fluids
    local consolidatedFluids = {}
    for _, fluid in ipairs(allFluids) do
        if consolidatedFluids[fluid.name] then
            consolidatedFluids[fluid.name].amount = consolidatedFluids[fluid.name].amount + fluid.amount
        else
            consolidatedFluids[fluid.name] = {
                name = fluid.name,
                amount = fluid.amount
            }
        end
    end

    -- Convert the consolidated fluids dictionary into a list
    local fluids = {}
    for _, fluid in pairs(consolidatedFluids) do
        table.insert(fluids, fluid)
    end

    return fluids
end

-- Function to calculate the changes between two fluid lists
function DataProcessing.calculate_fluid_changes(prev_fluids, curr_fluids)
    -- Convert the previous fluid list into a dictionary for easier lookup
    local prev_dict = {}
    for _, fluid in ipairs(prev_fluids) do
        prev_dict[fluid.name] = fluid.amount
    end

    -- Calculate changes
    local changes = {}
    for _, fluid in ipairs(curr_fluids) do
        local prev_amount = prev_dict[fluid.name]
        if prev_amount and prev_amount ~= fluid.amount then
            local change = math.abs(fluid.amount - prev_amount)
            local operation = fluid.amount > prev_amount and "+" or "-"
            table.insert(changes, {
                name = fluid.name,
                amount = fluid.amount,
                change = math.abs(change),
                operation = operation
            })
        end
    end

    return changes
end

return DataProcessing
