--[[ 

This is a simple door script using a few peripherals from Unlimited Peripheral Works:

- Reality Forger (and Reality Anchors to form the magic door)
    detectAnchors()	table	Returns list of all surrounding anchors with relative coordinates
    forgeRealityPieces(coordinates: list[BlockPos], blockState: BlockState, options?: Options)	Result	Tries to modify the appearance of blocks in the block poses list
    batchForgeRealityPieces(instructions: Instructions))	Result	Tries to modify the appearance of blocks following instructions in one tick
    forgeReality(mimic: blockState: BlockState, options?: Options)	Result	Tries to modify appearance of all surrounding blocks
- Universal Scanner
    scan("item", radius?: number)	table1	Scan surrounded area for items.
    scan("block", radius?: number)	table2	Scan surrounded area for blocks.
    scan("entity", radius?: number)	table3	Scan surrounded area for entities. Entities will be prefiltered by specific peripheral conditions
    scan("player", radius?: number)	table4	Scan surrounded area for players.
    scan("xp", radius?: number)	table5	Scan surrounded area for experience orbs.

It should have a door.config containing player names of people the door should automatically open for. It should also configure the block used to change the anchor's into.
]] -- Load required peripherals
local realityForger = peripheral.find("reality_forger")
if not realityForger then
    error("Reality Forger peripheral not found")
end
local scanner = peripheral.find("universal_scanner")
if not scanner then
    error("Universal Scanner peripheral not found")
end

local configFile = fs.open("door.config", "r")
-- Load configuration
local config = textutils.unserializeJSON(configFile.readAll())
configFile.close()
if not config then
    error("Configuration file not loaded")
end

-- Debug: Print loaded configuration
print("Loaded configuration:", textutils.serialize(config))

-- Define the block state for open and closed door
local openBlockState = {
    block = "minecraft:bedrock",
    invisible = true,
    playerPassable = true
}
local closedBlockState = {
    block = "minecraft:bedrock",
    invisible = false,
    playerPassable = false
}

print("Detecting anchors...")
local anchors = realityForger.detectAnchors()

-- Function to detect anchors and forge reality
local function modifyDoor(state)
    if not anchors then
        print("No anchors detected")
        return
    end
    local coordinates = {}
    for _, anchor in pairs(anchors) do
        table.insert(coordinates, anchor)
    end
    print("Forging reality...")
    realityForger.forgeRealityPieces(coordinates, state)
end

-- Function to check if player is authorized
local function isAuthorized(playerName)
    for _, authorizedPlayer in ipairs(config.authorizedPlayers) do
        if playerName == authorizedPlayer then
            return true
        end
    end
    return false
end

-- Main door control function
local function controlDoor()
    local players = scanner.scan("player", config.scanRadius or 5)
    local doorShouldBeOpen = false

    -- Debug: Print detected players
    print("Detected players:", textutils.serialize(players))

    if players then
        for _, player in ipairs(players) do
            -- Debug: Print player name being checked
            print("Checking player:", player.displayName)
            if isAuthorized(player.displayName) then
                doorShouldBeOpen = true
                break
            end
        end
    end

    if doorShouldBeOpen then
        print("Opening door...")
        modifyDoor(openBlockState)
        print("Door opened for authorized access!")
    else
        print("Closing door...")
        modifyDoor(closedBlockState)
        print("Door closed")
    end
end

-- Run the door control function continuously
while true do
    controlDoor()
    sleep(config.sleepInterval or 1) -- Check every second or as configured
end
