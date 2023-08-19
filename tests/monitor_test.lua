local generics = require("generics")

-- This is a test function to print out values
function testFunction(monitorSide)
    local monitor = peripheral.wrap(monitorSide)
    local monitorWidth, monitorHeight = monitor.getSize()

    print("Monitor width:", monitorWidth)
    print("Monitor height:", monitorHeight)

    local numColumns = math.floor(monitorWidth / 15)
    local numRows = math.floor(monitorHeight / 3)

    print("Num columns:", numColumns)
    print("Num rows:", numRows)

    -- Test text scaling and monitor size
    for scale = 0.5, 2, 0.5 do
        monitor.setTextScale(scale)
        monitorWidth, monitorHeight = monitor.getSize()
        print("Monitor width at scale ", scale, ":", monitorWidth)
        print("Monitor height at scale ", scale, ":", monitorHeight)

        local numColumns = math.floor(monitorWidth / 15)
        local numRows = math.floor(monitorHeight / 3)

        print("Num columns at scale ", scale, ":", numColumns)
        print("Num rows at scale ", scale, ":", numRows)
    end

    -- Test centering of title
    for scale = 0.5, 2, 0.5 do
        monitor.setTextScale(scale)
        generics.writeCentered(monitor, 1, 1, monitorWidth, 1, "ME SYSTEM INPUT", 1)
    end
end

-- Automatically find the sides
local monitorSide = generics.findPeripheralSide("monitor")

if not monitorSide then
    print("Monitor not found.")
    return
end

testFunction(monitorSide)
