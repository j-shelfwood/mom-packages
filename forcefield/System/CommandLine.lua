local this

this = {
    shouldExit = false,
    start = function(system)
        print("Forcefield system ready. Enter command (enable, disable, change block, invisible, visible, or exit):")
        while true do
            local input = this.waitForCommand()
            this.processCommand(input)
            if this.shouldExit then
                break
            end
        end
        print("Forcefield system exiting...")
    end,
    waitForCommand = function()
        local input = read()
        return input
    end,
    processCommand = function(command)
        if input == "exit" then
            print("Exiting...")
            this.shouldExit = true
            return
        end
        if input == "enable" then
            return system.enable()
        end
        if input == "disable" then
            return system.disable()
        end
        if input == "change block" then
            return system.changeBlock()
        end
        if input == "invisible" then
            return system.enable(true)
        end
        if input == "visible" then
            return system.enable(false)
        end

        print("Unknown command. Available commands: enable, disable, change block, invisible, visible, exit")
    end
}

return this
