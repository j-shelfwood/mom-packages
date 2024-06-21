local this

this = {
    shouldExit = false,
    start = function(system)
        print("Forcefield system ready. Enter command (enable, disable, change block, invisible, visible, or exit):")
        while true do
            local command = this.waitForCommand()
            this.processCommand(command, system)
            if this.shouldExit then
                break
            end
        end
        print("Forcefield system exiting...")
    end,
    waitForCommand = function()
        return read()
    end,
    processCommand = function(command, system)
        if command == "exit" then
            print("Exiting...")
            this.shouldExit = true
            return
        end
        if command == "enable" then
            return system.enable()
        end
        if command == "disable" then
            return system.disable()
        end
        if command == "change block" then
            return system.changeBlock()
        end
        if command == "invisible" then
            return system.enable(true)
        end
        if command == "visible" then
            return system.enable(false)
        end

        print("Unknown command. Available commands: enable, disable, change block, invisible, visible, exit")
    end
}

return this
