-- enslavement.lua
-- Open the modem for Rednet communication
-- Automatically detect which side has the modem 
-- and open it for Rednet communication (without using generics)
rednet.open(peripheral.find("modem").getName())

-- Wait for a Rednet message
local senderID, message, protocol = rednet.receive()

-- Write the received message to a file
local file = fs.open("received_script.lua", "w")
file.write(message)
file.close()

-- Run the received script
shell.run("received_script.lua")
