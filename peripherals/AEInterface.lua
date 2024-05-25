local module

module = {
    new = function(peripheral)
        local self = {
            interface = peripheral
        }
        return self
    end,

    items = function(self)
        local allItems = self.interface.items()

        if not allItems then
            error("No items detected.")
        end

        for _, item in ipairs(allItems) do
            item.id = item.technicalName
            item.name = item.name
            item.count = item.count
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
    end,

    changes = function(self, prev_items)
        -- Fetch current items
        local curr_items = module.items(self)
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
    end,

    fluids = function(self)
        -- Get fluids
        local allFluids = self.interface.tanks()

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
    end,

    fluid_changes = function(self, prev_fluids)
        -- Fetch current fluids
        local curr_fluids = module.fluids(self)
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
    end,

    storage_status = function(self)
        local storageStatus = {
            cells = self.interface.listCells(),
            usedItemStorage = self.interface.getUsedItemStorage(),
            totalItemStorage = self.interface.getTotalItemStorage(),
            availableItemStorage = self.interface.getAvailableItemStorage()
        }

        return storageStatus
    end,

    cells = function(self)
        -- Fetch storage cell details using listCells method
        return self.interface.listCells()
    end,

    categorize_cells = function(self)
        local cells = module.cells(self)
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
}

return module
