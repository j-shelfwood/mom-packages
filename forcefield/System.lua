--[[ 

This script is used to create a forcefield using:

Reality Forger (and Reality Anchors to form the magic door)
    detectAnchors()	table	Returns list of all surrounding anchors with relative coordinates
    forgeRealityPieces(coordinates: list[BlockPos], blockState: BlockState, options?: Options)	Result	Tries to modify the appearance of blocks in the block poses list
    batchForgeRealityPieces(instructions: Instructions))	Result	Tries to modify the appearance of blocks following instructions in one tick
    forgeReality(mimic: blockState: BlockState, options?: Options)	Result	Tries to modify appearance of all surrounding blocks

The computer will allow the user to:
- Switch the forcefield on/off
- Change the block type used to change the Reality Anchors into (create the forcefield)
]] local this

local Monitor = mpm('forcefield/Monitor')
local Configuration = mpm('forcefield/Configuration')
local Anchors = mpm('forcefield/Anchors')

this = {
    forger = nil,
    anchors = {},
    configuration = Configuration.load(),
    start = function()
        print('Starting forcefield system...')
        -- Check if we have a reality forger
        this.findPeripherals()
        -- Get the relevant anchors from the `anchors.json` file or detect them
        Anchors.find()
        this.startCLI()
    end,
    findPeripherals = function()
        print('Finding peripherals...')
        local forger = peripheral.find("reality_forger")

        if not forger then
            print('No Reality Forger found, cannot start forcefield system...')
            return
        end

        print('Reality Forger found!')
        this.forger = forger
    end,
    startCLI = function()
        print("Forcefield system ready. Enter command (enable, disable, change block, invisible, visible, or exit):")
        while true do
            local input = read()
            if input == "exit" then
                print("Exiting...")
                break
            elseif input == "enable" then
                this.enable()
            elseif input == "disable" then
                this.disable()
            elseif input == "change block" then
                this.changeBlock()
            elseif input == "invisible" then
                this.enable(true)
            elseif input == "visible" then
                this.enable(false)
            else
                print("Unknown command. Available commands: enable, disable, change block, invisible, visible, exit")
            end
        end
    end,
    enable = function(invisible)
        print('Booting forcefield...')
        this.forgeState({
            invisible = invisible or false,
            playerPassable = false
        })
        this.configuration.save()
    end,
    disable = function()
        print('Disabling forcefield...')
        this.forgeState({
            invisible = true,
            playerPassable = true
        })
        this.configuration.save()
    end,
    changeBlock = function()
        print("Enter a block identifier to use for the forcefield (e.g. 'minecraft:bedrock'): ")
        local block = read()
        this.configuration.options.state.block = block
        this.configuration.save()
    end,
    forgeState = function(overrides)
        -- Loop over the overrides and assign them to this.configuration.options.state
        for k, v in pairs(overrides) do
            this.configuration.options.state[k] = v
        end
        this.forger.forgeRealityPieces(this.anchors, this.configuration.options.state)
    end
}

return this
