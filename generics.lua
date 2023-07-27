local generics = {}

-- Function to find peripheral side
function generics.findPeripheralSide(name)
    local sides = {"top", "bottom", "left", "right", "front", "back"}
    for _, side in ipairs(sides) do
        if peripheral.isPresent(side) and peripheral.getType(side) == name then
            return side
        end
    end
    return nil
end

-- Function to shorten item names if they're too long
function generics.shortenName(name, maxLength)
    if #name <= maxLength then
        return name
    else
        local partLength = math.floor((maxLength - 1) / 2) -- subtract one to account for the hyphen
        return name:sub(1, partLength) .. "-" .. name:sub(-partLength)
    end
end

-- Function to write centered text in a cell
function generics.writeCentered(monitor, y, totalWidth, text)
    local textScale = monitor.getTextScale()
    local textLength = #text
    local x = math.floor((totalWidth * textScale - textLength) / 2) + 1
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

return generics
