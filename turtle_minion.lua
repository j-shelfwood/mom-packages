-- turtle_minion.lua
-- Open the modem for Rednet communication
rednet.open("right") -- replace "left" with the side where the modem is located

-- Wait for the instruction file to be received
local senderID, message, protocol = rednet.receive("instruction")

-- Write the received instruction file
local file = fs.open("instruction.txt", "w")
file.write(message)
file.close()

-- Load the instruction file
local file = fs.open("instruction.txt", "r")
local instruction = textutils.unserialize(file.readAll())
file.close()

-- Get the side of the main computer from the instruction file
local side = instruction.side

-- Equip the pickaxe
turtle.select(1) -- assumes the pickaxe is in the first slot
turtle.equipRight()
turtle.select(1)
turtle.equipLeft()

-- Define the starting position, digging area dimensions, and depth
local startX, startZ, width, length, depth = instruction.x, instruction.z, instruction.width, instruction.length,
    instruction.depth

-- Current position of the turtle, relative to the starting position
local currentPosition = {
    x = 0,
    y = 0,
    z = 0
}

-- Current orientation of the turtle: 0 = east, 1 = south, 2 = west, 3 = north
local orientation = 0

-- Define the coordinates of the fuel and inventory chests based on the side of the main computer
local fuelChest, inventoryChest
fuelChest = {
    x = 0,
    y = 1,
    z = 0
}
inventoryChest = {
    x = 0,
    y = 2,
    z = 0
}

-- Define the coordinates of the fuel and inventory chests based on the side of the main computer
-- Function to turn the turtle to a specified orientation
function turnTo(newOrientation)
    local difference = newOrientation - orientation
    if difference == 1 or difference == -3 then
        turtle.turnRight()
    elseif difference == -1 or difference == 3 then
        turtle.turnLeft()
    elseif difference == 2 or difference == -2 then
        turtle.turnRight()
        turtle.turnRight()
    end
    orientation = newOrientation
end

-- Function to move to a specified relative coordinate
function moveTo(dx, dy, dz)
    -- Move vertically to the desired y-coordinate
    while currentPosition.y < dy do
        if turtle.detectUp() then
            turtle.digUp()
        end
        turtle.up()
        currentPosition.y = currentPosition.y + 1
    end
    while currentPosition.y > dy do
        if turtle.detectDown() then
            turtle.digDown()
        end
        turtle.down()
        currentPosition.y = currentPosition.y - 1
    end

    -- Move horizontally to the desired x-coordinate
    if currentPosition.x < dx then
        turnTo(0) -- face east
        while currentPosition.x < dx do
            if turtle.detect() then
                turtle.dig()
            end
            turtle.forward()
            currentPosition.x = currentPosition.x + 1
        end
    elseif currentPosition.x > dx then
        turnTo(2) -- face west
        while currentPosition.x > dx do
            if turtle.detect() then
                turtle.dig()
            end
            turtle.forward()
            currentPosition.x = currentPosition.x - 1
        end
    end

    -- Move horizontally to the desired z-coordinate
    if currentPosition.z < dz then
        turnTo(1) -- face south
        while currentPosition.z < dz do
            if turtle.detect() then
                turtle.dig()
            end
            turtle.forward()
            currentPosition.z = currentPosition.z + 1
        end
    elseif currentPosition.z > dz then
        turnTo(3) -- face north
        while currentPosition.z > dz do
            if turtle.detect() then
                turtle.dig()
            end
            turtle.forward()
            currentPosition.z = currentPosition.z - 1
        end
    end
end

-- Function to dig a layer of the assigned area
function digLayer(width, length)
    -- Dig rows of the rectangle
    for i = 1, length do
        -- Dig a row
        for j = 1, width - 1 do
            if turtle.detect() then
                turtle.dig()
            end
            turtle.forward()
        end

        -- Turn and start the next row, if there is one
        if i < length then
            if turtle.detect() then
                turtle.dig()
            end
            if i % 2 == 1 then
                turtle.turnRight()
                turtle.forward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                turtle.forward()
                turtle.turnLeft()
            end
        end
    end

    -- Return to the start of the layer
    if length % 2 == 1 then
        turnTo(2) -- face west
        for i = 1, width - 1 do
            turtle.forward()
        end
    end
    turnTo(3) -- face north
    for i = 1, length - 1 do
        turtle.forward()
    end
    turnTo(0) -- face east

    diggingX = currentPosition.x
    diggingZ = currentPosition.z
end

-- Function to refuel and unload
function refuelAndUnload()
    -- Go to the fuel chest and refuel
    moveTo(fuelChest.x, fuelChest.y, fuelChest.z)

    -- Check if the turtle needs refueling
    while turtle.getFuelLevel() < 100 do -- replace 100 with whatever minimum fuel level you want
        -- Select the first slot in the inventory
        turtle.select(1)

        -- If the slot is not empty, drop the item
        if turtle.getItemCount() > 0 then
            turtle.drop()
        end

        -- Suck up some fuel from the chest
        turtle.suckUp()

        -- Refuel using the fuel in the first slot
        turtle.refuel()
    end

    -- Go to the inventory chest and unload
    moveTo(inventoryChest.x, inventoryChest.y, inventoryChest.z)

    -- Unload everything except for the first slot
    for i = 2, 16 do
        turtle.select(i)
        turtle.drop()
    end

    -- Go back to the starting position
    moveTo(diggingX, currentPosition.y, diggingZ)
end

-- Move to the assigned starting position
moveTo(startX, 0, startZ)

-- Dig the assigned area
for k = 1, depth do
    digLayer(width, length)
    -- Check if refuel or unload is needed
    if turtle.getFuelLevel() < width * length or turtle.getItemCount() > turtle.getInventorySize() - 100 then
        refuelAndUnload()
    end
    if k < depth then
        turtle.down()
    end
end
