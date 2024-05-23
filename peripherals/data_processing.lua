-- data_processing.lua
local DataProcessing = {}
local Generics = mpm('generics/generics')

function detectPeripheralType()
    if Generics.findPeripheralSide("meBridge") then
        return "meBridge"
    end
    if Generics.findPeripheralSide("merequester:requester") then
        return "merequester:requester"
    end

    return nil
end

-- Function to fetch items from the AE2 system
function DataProcessing.fetch_items()
    local peripheralType = detectPeripheralType()
    local interface

    -- Get a reference to the peripheral
    if peripheralType == "meBridge" then
        interface = peripheral.wrap(Generics.findPeripheralSide("meBridge"))
    elseif peripheralType == "merequester:requester" then
        interface = peripheral.wrap(Generics.findPeripheralSide("merequester:requester"))
    else
        error("No compatible peripheral detected.")
    end

    local allItems = {}
    if peripheralType == "meBridge" then
        allItems = interface.listItems()
        for _, item in ipairs(allItems) do
            item.id = item.nbt.id
            item.name = item.displayName
            item.count = item.amount
        end
    elseif peripheralType == "merequester:requester" then
        allItems = interface.items()
        for _, item in ipairs(allItems) do
            item.id = item.technicalName
            item.name = item.name
            item.count = item.count
        end
    end

    -- Consolidate items
    local consolidatedItems = {}
    for _, item in ipairs(allItems) do
        local id = item.id
        if consolidatedItems[id] then
            consolidatedItems[id] = {
                id = id,
                name = item.name,
                count = consolidatedItems[id].count + item.count
            }
        else
            consolidatedItems[id] = {
                id = id,
                name = item.name,
                count = item.count
            }
        end
    end

    -- Convert the consolidated items dictionary into a list
    local items = {}
    for _, item in pairs(consolidatedItems) do
        table.insert(items, item)
    end

    print("Items fetched: " .. #items)
    for i, item in ipairs(items) do
        if not item then
            print("Nil item detected at position " .. i)
        end
    end

    return items
end

-- Function to calculate the changes between two item lists
function DataProcessing.calculate_changes(prev_items, curr_items)
    -- Convert the previous item list into a dictionary for easier lookup
    local prev_dict = {}
    for _, item in ipairs(prev_items) do
        prev_dict[item.id] = item.count
    end

    -- Calculate changes
    local changes = {}
    for _, item in ipairs(curr_items) do
        local prev_count = prev_dict[item.id]
        if prev_count and prev_count ~= item.count then
            local change = math.abs(item.count - prev_count)
            local operation = item.count > prev_count and "+" or "-"
            table.insert(changes, {
                id = item.id,
                name = item.name,
                count = item.count,
                change = math.abs(change),
                operation = operation
            })
        end
    end

    print("Changes calculated: " .. #changes)
    for i, change in ipairs(changes) do
        if not change then
            print("Nil change detected at position " .. i)
        end
    end

    return changes
end

-- Function to fetch fluids from the AE2 system
function DataProcessing.fetch_fluids()
    -- Get a reference to the peripheral (assuming it's named fluid_requester)
    local interface = peripheral.wrap(Generics.findPeripheralSide("merequester:requester"))

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

function DataProcessing.fetch_storage_status()
    local peripheralType = detectPeripheralType()
    local interface

    -- Get a reference to the peripheral
    if peripheralType == "meBridge" then
        interface = peripheral.wrap(Generics.findPeripheralSide("meBridge"))
    elseif peripheralType == "merequester:requester" then
        interface = peripheral.wrap(Generics.findPeripheralSide("merequester:requester"))
    else
        error("No compatible peripheral detected.")
    end

    local storageStatus = {
        cells = interface.listCells(),
        usedItemStorage = interface.getUsedItemStorage(),
        totalItemStorage = interface.getTotalItemStorage(),
        availableItemStorage = interface.getAvailableItemStorage()
    }

    return storageStatus
end

function DataProcessing.fetch_storage_cells_details()
    local peripheralType = detectPeripheralType()
    local interface

    -- Get a reference to the peripheral
    if peripheralType == "meBridge" then
        interface = peripheral.wrap(Generics.findPeripheralSide("meBridge"))
    elseif peripheralType == "merequester:requester" then
        interface = peripheral.wrap(Generics.findPeripheralSide("merequester:requester"))
    else
        error("No compatible peripheral detected.")
    end

    -- Fetch storage cell details using listCells method
    if peripheralType == "meBridge" then
        return interface.listCells()
    elseif peripheralType == "merequester:requester" then
        -- If the "merequester:requester" also supports listCells, fetch it, otherwise return an empty table
        return interface.listCells and interface.listCells() or {}
    end

    return {}
end

function DataProcessing.categorize_storage_cells()
    local cells = DataProcessing.fetch_storage_cells_details()
    local categorized = {}

    for _, cell in ipairs(cells) do
        -- Extracting the storage cell type after the last underscore
        local cellType = cell.item:match(".*_(%w+)$") or "Unknown"

        if not categorized[cellType] then
            categorized[cellType] = 0
        end
        categorized[cellType] = categorized[cellType] + 1
    end

    return categorized
end

return DataProcessing
