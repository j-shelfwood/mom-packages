-- Include Grid Display API
local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')

-- Define the ChestMonitor class
local ChestMonitor = {}
ChestMonitor.__index = ChestMonitor

function ChestMonitor.new(monitor, chests)
    local self = setmetatable({}, ChestMonitor)
    self.monitor = monitor
    self.chests = chests
    self.display = GridDisplay.new(monitor)
    return self
end

function ChestMonitor:fetchItemsFromChests()
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

function ChestMonitor:displayItemInfo()
    local function format_callback(item)
        return {
            lines = {Text.prettifyItemIdentifier(item.name), tostring(item.count)},
            colors = {colors.white, colors.white}
        }
    end

    while true do
        term.clear()
        print("Fetching items from chests...")
        local items = self:fetchItemsFromChests()

        table.sort(items, function(a, b)
            return a.count > b.count
        end)

        local success, err = pcall(self.display.display, self.display, items, format_callback)
        if not success then
            print("Error displaying items:", err)
        end

        sleep(1)
    end
end

return ChestMonitor
