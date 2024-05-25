local MonitorDisplay = mpm('views/MonitorDisplay')
local wpp = mpm('wpp/wpp')
local GridDisplay = mpm('utils/GridDisplay')

local module

module = {
    new = function(monitor)
        local self = {
            monitor = monitor,
            display = GridDisplay.new(monitor)
        }
        wpp.wireless.connect("shelfwood")
        return self
    end,

    format_callback = function(item)
        return {
            line_1 = item.name,
            color_1 = colors.white,
            line_2 = tostring(item.capacity),
            color_2 = colors.white,
            line_3 = tostring(item.energy),
            color_3 = colors.green
        }
    end,

    fetch_energy = function(self)
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
    end,

    refresh_display = function(self)
        local energy_data = module.fetch_energy(self)
        self.display:display(energy_data, function(item)
            return module.format_callback(item)
        end)
    end,

    render = function(self)
        while true do
            module.refresh_display(self)
            os.sleep(15)
        end
    end
}

return module
