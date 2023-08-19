local Generics = {}

-- Function to find peripheral side
function Generics.findPeripheralSide(name)
    local sides = {"top", "bottom", "left", "right", "front", "back"}
    for _, side in ipairs(sides) do
        if peripheral.isPresent(side) and peripheral.getType(side) == name then
            return side
        end
    end
    return nil
end

function Generics.formatFluidAmount(amount_mB)
    local absAmount_mB = math.abs(amount_mB)
    local absAmount_B = absAmount_mB / 1000

    -- mb
    if absAmount_B < 10 then
        return string.format("%.1fmB", absAmount_mB)
    end

    -- B
    if absAmount_B < 1000 then
        local absAmount_B = absAmount_B / 1000
        return string.format("%.1f B", absAmount_B)
    end

    -- Thousand B
    if absAmount_B < 999999 then
        return string.format("%.1fK B", absAmount_B / 1000)
    end

    -- Million B
    return string.format("%.2fM B", absAmount_B / 1000000)
end

-- Function to shorten item names if they're too long
function Generics.shortenName(name, maxLength)
    if #name <= maxLength then
        return name
    else
        local partLength = math.floor((maxLength - 1) / 2) -- subtract one to account for the hyphen
        return name:sub(1, partLength) .. "-" .. name:sub(-partLength)
    end
end

-- Function to write centered text in a cell
function Generics.writeCentered(monitor, y, totalWidth, text)
    local textScale = monitor.getTextScale()
    local textLength = #text
    local x = math.floor((totalWidth * textScale - textLength) / 2) + 1
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

return Generics
