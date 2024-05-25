local MonitorDisplay = mpm('views/MonitorDisplay')
local wpp = mpm('wpp/wpp')
local GridDisplay = mpm('utils/GridDisplay')

local PowahEnergyDisplay = setmetatable({}, {
    __index = MonitorDisplay
})
PowahEnergyDisplay.__index = PowahEnergyDisplay

function PowahEnergyDisplay.new(monitor)
    local self = MonitorDisplay.new(monitor)
    setmetatable(self, PowahEnergyDisplay)
    self.display = GridDisplay.new(monitor)
    wpp.wireless.connect("shelfwood")
    return self
end

function PowahEnergyDisplay:format_callback(item)
    return {
        line_1 = item.name,
        color_1 = colors.white,
        line_2 = tostring(item.capacity),
        color_2 = colors.white,
        line_3 = tostring(item.energy),
        color_3 = colors.green
    }
end

function PowahEnergyDisplay:fetch_energy()
    local energy_data = {}
    local peripherals = wpp.peripheral.getNames()
    for _, name in ipairs(peripherals) do
        local cell = wpp.peripheral.wrap(name)
        if string.find(name, "powah:energy_cell") then
            cell.wppPrefetch({"getEnergy", "getEnergyUnits", "getEnergyCapacity"})
            local _, _, name = string.find(name, "powah:energy_cell_(.+)")
            table.insert(energy_data, {
                name = name,
                energy = cell.getEnergy(),
                units = cell.getEnergyUnits(),
                capacity = cell.getEnergyCapacity()
            })
        end
    end
    return energy_data
end

function PowahEnergyDisplay:refresh_display()
    local energy_data = self:fetch_energy()
    self.display:display(energy_data, function(item)
        return self:format_callback(item)
    end)
end

function PowahEnergyDisplay:render()
    while true do
        self:refresh_display()
        os.sleep(15)
    end
end

return PowahEnergyDisplay
