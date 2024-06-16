local AEInterface = mpm('peripherals/AEInterface')
local GridDisplay = mpm('utils/GridDisplay')
local Text = mpm('utils/Text')

local module

module = {
    new = function(monitor)
        local self = {
            monitor = monitor,
            display = GridDisplay.new(monitor),
            interface = AEInterface.new(peripheral.find("merequester:requester")),
            prev_fluids = nil
        }
        self.prev_fluids = AEInterface.fluids(self.interface)
        return self
    end,
    mount = function()
        local peripherals = peripheral.getNames()
        for _, name in ipairs(peripherals) do
            if peripheral.getType(name) == "merequester:requester" then
                return true
            end
        end
        return false
    end,
    format_callback = function(fluid)
        local color = fluid.operation == "+" and colors.green or fluid.operation == "-" and colors.red or colors.white
        local _, _, name = string.find(fluid.name, ":(.+)")
        name = name:gsub("^%l", string.upper)
        local change = fluid.change ~= 0 and fluid.operation .. Text.formatFluidAmount(fluid.change) or ""
        return {
            lines = {name, Text.formatFluidAmount(fluid.amount), change},
            colors = {colors.white, colors.white, color}
        }
    end,

    render = function(self)
        local current_fluids = AEInterface.fluids(self.interface)
        local changes = AEInterface.fluid_changes(self.interface, self.prev_fluids or {})

        -- Mark all current fluids with no change as having a change of 0
        for _, fluid in ipairs(current_fluids) do
            local found = false
            for _, change in ipairs(changes) do
                if change.name == fluid.name then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(changes, {
                    name = fluid.name,
                    amount = fluid.amount,
                    change = 0,
                    operation = ""
                })
            end
        end

        -- Sort by fluid.amount in descending order
        table.sort(changes, function(a, b)
            return a.amount > b.amount
        end)
        changes = {table.unpack(changes, 1, 30)}
        self.display:display(changes, function(item)
            return module.format_callback(item)
        end)
        print("Detected " .. #changes .. " changes in fluids")

        self.prev_fluids = current_fluids
    end
}

return module
