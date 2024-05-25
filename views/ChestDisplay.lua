-- Include Grid Display API
local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')

-- Define the ChestDisplay class
local ChestDisplay = {}
ChestDisplay.__index = ChestDisplay

function ChestDisplay.new(monitor, chests)
    local self = setmetatable({}, ChestDisplay)
    self.monitor = monitor
    self.chests = chests
    self.display = GridDisplay.new(monitor)
    return self
end

function ChestDisplay:fetchItemsFromChests()
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

function ChestDisplay:render()
    local function format_callback(item)
        return {
            lines = {Text.prettifyItemIdentifier(item.name), tostring(item.count)},
            colors = {colors.white, colors.white}
        }
    end

    local items = self:fetchItemsFromChests()

    table.sort(items, function(a, b)
        return a.count > b.count
    end)

    local success, err = pcall(self.display.display, self.display, items, format_callback)
    if not success then
        print("Error displaying items:", err)
    end
end

return ChestDisplay
