-- This module is responsible for accessing peripherals through 
-- all of the proxies of the network at once.
local this

this = {
    getPeripherals = function()
        local peripherals = peripheral.getNames()
        local proxy = peripheral.find("peripheral_proxy")
        if proxy then
            local proxyPeripherals = proxy.getNamesRemote()
            for _, name in ipairs(proxyPeripherals) do
                table.insert(peripherals, name)
            end
        end
        return peripherals
    end,
    wrapPeripheral = function(name)
        local proxy = peripheral.find("peripheral_proxy")
        if proxy and proxy.hasPeripheral(name) then
            return proxy.wrapRemote(name)
        else
            return peripheral.wrap(name)
        end
    end
}

return this
