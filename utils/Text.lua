local Text = {}

function Text.formatFluidAmount(amount_mB)
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

-- Function to prettify an item identifier (minecraft:chest -> Chest)
function Text.prettifyItemIdentifier(itemIdentifier)
    -- Remove everything before : (including other values than minecraft:)
    local name = itemIdentifier:match(":(.+)$")
    if name then
        -- Capitalize the first letter and return
        return name:gsub("^%l", string.upper)
    else
        -- If no colon is found, return the original identifier
        return itemIdentifier
    end
end

-- Function to shorten item names if they're too long
function Text.shortenName(name, maxLength)
    if #name <= maxLength then
        return name
    else
        local partLength = math.floor((maxLength - 1) / 2) -- subtract one to account for the hyphen
        return name:sub(1, partLength) .. "-" .. name:sub(-partLength)
    end
end

return Text
