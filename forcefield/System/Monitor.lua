local this

this = {
    monitor = nil,
    init = function()
        this.monitor = peripheral.find("monitor")
        if not this.monitor then
            print("No monitor found, cannot initialize monitor interface...")
            return
        end
        this.monitor.setTextScale(1)
        this.clear()
    end,
    clear = function()
        this.monitor.clear()
        this.monitor.setCursorPos(1, 1)
    end,
    render = function(status)
        if not this.monitor then
            return
        end
        this.clear()
        this.monitor.write("Forcefield Status: " .. (status.enabled and "Enabled" or "Disabled"))
        this.monitor.setCursorPos(1, 2)
        this.monitor.write("Block: " .. status.block)
        this.monitor.setCursorPos(1, 3)
        this.monitor.write("Invisible: " .. tostring(status.invisible))
        this.monitor.setCursorPos(1, 4)
        this.monitor.write("Player Passable: " .. tostring(status.playerPassable))
    end
}

return this
