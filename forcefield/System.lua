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

this = {
    forger = nil,
    anchors = {},
    configuration = {
        enabled = false,
        block = "minecraft:bedrock"
    },
    start = function()
        print('Starting forcefield system...')
        -- Check if we have a reality forger
        this.findPeripherals()
        -- Get the relevant anchors from the `anchors.json` file or detect them
        this.findAnchors()
        this.startCLI()
    end,
    bootForcefield = function()
        print('Booting forcefield...')
        -- Use the forger to forge the forcefield using the anchors
        this.forger.forgeRealityPieces(this.anchors, {
            block = this.configuration.block,
            invisible = false,
            player_passable = false
        })
    end,
    disableForcefield = function()
        print('Disabling forcefield...')
        -- Forge all the anchors to be invisible and playerPassable
        this.forger.forgeRealityPieces(this.anchors, {
            block = this.configuration.block,
            invisible = true,
            player_passable = true
        })
    end,
    changeBlockType = function()
        print('Changing block type...')
        -- Ask the user to input a block identifier to use for the forcefield
        local block = io.read("Enter a block identifier to use for the forcefield: ")
        this.configuration.block = block
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
    findAnchors = function()
        -- Check if the `anchors.json` file exists
        if not fs.exists("anchors.json") then
            print('No `anchors.json` file found, detecting anchors...')
            this.anchors = this.detectAnchors()
        else
            print('Loading anchors from `anchors.json`...')
            this.anchors = this.loadAnchors()
        end
    end,
    detectAnchors = function()
        print('Detecting anchors...')
        local anchors = this.forger.detectAnchors()

        -- Save the anchors to the `anchors.json` file
        local file = fs.open("anchors.json", "w")
        file.write(textutils.serializeJSON(anchors))
        file.close()
        print('Anchors saved to `anchors.json`!')
        return anchors
    end,
    loadAnchors = function()
        print('Loading anchors...')
        local file = fs.open("anchors.json", "r")
        local anchors = textutils.unserializeJSON(file.readAll())
        file.close()
        return anchors
    end,
    startCLI = function()
        print("Forcefield system ready. Enter commands:")
        while true do
            io.write("> ")
            local input = io.read()
            if input == "exit" then
                print("Exiting...")
                break
            elseif input == "enable" then
                this.bootForcefield()
            elseif input == "disable" then
                this.disableForcefield()
            elseif input == "change block" then
                this.changeBlockType()
            else
                print("Unknown command. Available commands: enable, disable, change block, exit")
            end
        end
    end
}

return this
