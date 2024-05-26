-- Include Grid Display API
local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')
local module

module = {
    new = function(monitor, chests)
        local self = {
            monitor = monitor,
            chests = module.resolvePeripherals(),
            display = GridDisplay.new(monitor)
        }
        return self
    end,
    mount = function()
        local peripherals = peripheral.getNames()
        for _, name in ipairs(peripherals) do
            if peripheral.hasType(name, "inventory") then
                return true
            end
        end
        return false
    end,
    resolvePeripherals = function(self)
        local peripherals = peripheral.getNames()
        local chests = {}
        for _, name in ipairs(peripherals) do
            if peripheral.hasType(name, "inventory") then
                table.insert(chests, peripheral.wrap(name))
            end
        end
        return chests
    end,
    --[[
        This function renders the chest display.
    ]]
    render = function(self)
        local function format_callback(item)
            return {
                lines = {Text.prettifyItemIdentifier(item.name), tostring(item.count)},
                colors = {colors.white, colors.white}
            }
        end

        local items = module.fetchItemsFromChests(self)

        table.sort(items, function(a, b)
            return a.count > b.count
        end)

        local success, err = pcall(self.display.display, self.display, items, format_callback)
        if not success then
            print("Error displaying items:", err)
        end
    end,
    --[[
        This function fetches items from all the chests and consolidates them into a list of items.
    ]]
    fetchItemsFromChests = function(self)
        local allItems = {}
        for _, chest in ipairs(self.chests) do
            local items = chest.list()
            if items then
                for slot, item in pairs(items) do
                    item.slot = slot
                    item.chest = chest
                    table.insert(allItems, item)
                end
            end
        end

        local consolidatedItems = {}
        for _, item in ipairs(allItems) do
            local id = item.name
            if consolidatedItems[id] then
                consolidatedItems[id].count = consolidatedItems[id].count + item.count
            else
                consolidatedItems[id] = {
                    name = item.name,
                    count = item.count
                }
            end
        end

        local items = {}
        for _, item in pairs(consolidatedItems) do
            table.insert(items, item)
        end

        return items
    end
}

return module
