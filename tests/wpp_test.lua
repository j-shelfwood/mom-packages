local wpp = require("wpp")

wpp.wireless.connect("shelfwood") -- Network name is used as a namespace esque thing so you can have multible different wireless peripheral systems going

-- Then just use it like the normal peripheral api:
local peripherals = wpp.peripheral.getNames() -- etc etc

-- Show the names of the connected peripherals
print("Connected peripherals:")
for i, peripheralName in ipairs(peripherals) do
    print(i .. ". " .. peripheralName)
end
