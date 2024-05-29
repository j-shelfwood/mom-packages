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
local realityForger = peripheral.wrap("reality_forger")
if not realityForger then
    error("Reality Forger peripheral not found")
end
local scanner = peripheral.wrap("universal_scanner")
if not scanner then
    error("Universal Scanner peripheral not found")
end

-- Load configuration
local config = require("door.config")
if not config then
    error("Configuration file not loaded")
end

-- Define the block state for open and closed door
local openBlockState = {
    name = "minecraft:air"
}
local closedBlockState = {
    name = "minecraft:iron_door[block_half=lower]"
} -- Example block state

-- Function to detect anchors and forge reality
local function modifyDoor(state)
    local anchors = realityForger.detectAnchors()
    if not anchors then
        print("No anchors detected")
        return
    end
    local coordinates = {}
    for _, anchor in pairs(anchors) do
        table.insert(coordinates, anchor)
    end
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

    for _, player in ipairs(players) do
        if isAuthorized(player.name) then
            doorShouldBeOpen = true
            break
        end
    end

    if doorShouldBeOpen then
        modifyDoor(openBlockState)
        print("Door opened for authorized access")
    else
        modifyDoor(closedBlockState)
        print("Door closed")
    end
end

-- Run the door control function continuously
while true do
    controlDoor()
    sleep(config.sleepInterval or 1) -- Check every second or as configured
end
