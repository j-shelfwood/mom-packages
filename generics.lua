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

function generics.formatFluidAmount(amount_mB)
    local amount_B = amount_mB / 1000

    -- mb
    if amount_B < 10 then
        return tostring(math.floor(amount_mB)) .. "mB"
    end

    -- B
    if amount_B < 100 then
        local amount_B = amount_B / 1000
        return tostring(math.floor(amount_B)) .. "B"
    end

    -- kB
    if amount_B < 1000 then
        return tostring(math.floor(amount_B / 1000)) .. "K B"
    end

    -- MB
    if amount_B > 9999 then
        local amount_MB = amount_B / 1000
        return tostring(math.floor(amount_MB)) .. "M B"
    end

    return tostring(math.floor(amount_B / 1000)) .. "K B"
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
