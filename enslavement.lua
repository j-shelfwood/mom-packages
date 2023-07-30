-- enslavement.lua
function findPeripheralSide(name)
    local sides = {"top", "bottom", "left", "right", "front", "back"}
    for _, side in ipairs(sides) do
        if peripheral.isPresent(side) and peripheral.getType(side) == name then
            return side
        end
    end
    return nil
end

-- Automatically detect which side has the modem 
local modemSide = findPeripheralSide("modem")
rednet.open(modemSide)

-- Wait for a Rednet message
local senderID, message, protocol = rednet.receive()

-- Write the received message to a file
local file = fs.open("received_script.lua", "w")
file.write(message)
file.close()

-- Run the received script
shell.run("received_script.lua")
