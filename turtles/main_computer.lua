-- main_computer.lua
-- Open the modem for Rednet communication
rednet.open("bottom") -- replace "bottom" with the side where the modem is located

-- Define the instructions for each turtle
local instructions = {
    left = {
        side = "left",
        x = 0,
        z = -25,
        width = 26,
        length = 51,
        depth = 20
    },
    right = {
        side = "right",
        x = 0,
        z = -25,
        width = 26,
        length = 51,
        depth = 20
    },
    front = {
        side = "front",
        x = -25,
        z = 0,
        width = 51,
        length = 26,
        depth = 20
    },
    back = {
        side = "back",
        x = -25,
        z = 0,
        width = 51,
        length = 26,
        depth = 20
    }
}

-- Load the turtle_minion.lua script
local file = fs.open("turtle_minion.lua", "r")
local turtleScript = file.readAll()
file.close()

-- Send the instruction file and turtle_minion.lua script to each turtle over Rednet
for side, instruction in pairs(instructions) do
    -- Write the instructions for the turtle
    local file = fs.open("instruction.txt", "w")
    file.write(textutils.serialize(instruction))
    file.close()

    -- Get the ID of the turtle on this side
    local turtleID = peripheral.call(side, "getID")

    -- Send the turtle_minion.lua script to the turtle
    rednet.send(turtleID, turtleScript, "script")
    -- wait a bit to ensure the instruction file is fully received before sending the next message
    sleep(1)

    -- Send the instruction file to the turtle
    rednet.send(turtleID, fs.open("instruction.txt", "r").readAll(), "instruction")
end
