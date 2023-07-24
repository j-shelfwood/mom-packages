local args = {...}
local side = args[1]

local peripheral = peripheral.wrap(side)
local items = peripheral.items()

local itemCount = #items

-- Size of one item entry in bytes. 
-- Consider: timestamp (20 bytes), item name (up to 64 bytes), count (up to 10 bytes), separators (4 bytes)
local itemEntrySize = 20 + 64 + 10 + 4

-- Total size of all items per snapshot
local totalItemDataSize = itemCount * itemEntrySize

-- Calculate how many snapshots could be stored within the ComputerCraft file limit (1,000,000 bytes)
local snapshotCount = math.floor(1000000 / totalItemDataSize)

-- Print results
print("Total item types: " .. itemCount)
print("Estimated size of data per snapshot: " .. totalItemDataSize .. " bytes")
print("Estimated number of snapshots that can be stored: " .. snapshotCount)
