local GridDisplay = {}
GridDisplay.__index = GridDisplay

-- Constants
local MIN_TEXT_SCALE = 0.5
local SCALE_DECREMENT = 0.5
local DEFAULT_CELL_WIDTH = 22
local DEFAULT_CELL_HEIGHT_PER_LINE = 5
local ELLIPSIS = "..."

-- Constructor
function GridDisplay.new(monitor, custom_cell_width)
    local self = setmetatable({}, GridDisplay)
    self.monitor = monitor
    self.cell_width = custom_cell_width or DEFAULT_CELL_WIDTH
    self.cell_height = DEFAULT_CELL_HEIGHT_PER_LINE * 3 -- Default to 3 lines per cell
    return self
end

function GridDisplay:setCellParameters(num_items, width, height, max_columns, scale)
    local cell_aspect_ratio = self.cell_width / self.cell_height
    local desired_columns = math.sqrt(num_items * cell_aspect_ratio)
    local desired_rows = num_items / desired_columns
    local actual_columns = math.min(max_columns, math.ceil(desired_columns))
    local remaining_width = width - (actual_columns * self.cell_width)
    local spacing_between_cells_x = remaining_width / (actual_columns + 1)

    self.start_x = spacing_between_cells_x + 1
    self.columns = actual_columns
    self.scale = scale
end

function GridDisplay:calculate_cells(num_items)
    local scale = 5 -- start with the largest scale

    while scale >= MIN_TEXT_SCALE do
        self.monitor.setTextScale(scale)
        local width, height = self.monitor.getSize()
        local max_columns = math.floor(width / self.cell_width)

        local required_rows = math.ceil(num_items / max_columns)
        local max_rows_at_current_height = math.floor(height / DEFAULT_CELL_HEIGHT_PER_LINE)

        if required_rows <= max_rows_at_current_height then
            self:setCellParameters(num_items, width, height, max_columns, scale)
            return
        end
        scale = scale - SCALE_DECREMENT
    end

    -- Minimum scale settings
    self.scale = MIN_TEXT_SCALE
    self.monitor.setTextScale(self.scale)
    local width, height = self.monitor.getSize()
    self.columns = math.floor(width / self.cell_width)
    self.rows = math.floor(height / DEFAULT_CELL_HEIGHT_PER_LINE)
    self.start_x = 1
end

function GridDisplay:truncateText(text, maxLength)
    if #text <= maxLength then
        return text
    end
    local prefixLength = math.floor((maxLength - #ELLIPSIS) / 2)
    local suffixLength = maxLength - #ELLIPSIS - prefixLength
    return text:sub(1, prefixLength) .. ELLIPSIS .. text:sub(-suffixLength)
end

function GridDisplay:display(data, format_callback, center_text)
    center_text = center_text or true

    self:calculate_cells(#data)

    if #data == 0 then
        self.monitor.clear()
        local width, height = self.monitor.getSize()
        self.monitor.setCursorPos(math.floor(width / 2) - 4, math.floor(height / 2))
        self.monitor.write("No data")
        return
    end

    self.monitor.clear()

    for i, item in ipairs(data) do
        if i > self.rows * self.columns then
            break
        end

        local formatted = format_callback(item)
        local row = math.floor((i - 1) / self.columns) + 1
        local column = (i - 1) % self.columns + 1
        local actual_cell_height = #formatted.lines * DEFAULT_CELL_HEIGHT_PER_LINE

        for line_idx, line_content in ipairs(formatted.lines) do
            self.monitor.setCursorPos(self.start_x + (column - 1) * (self.cell_width + 1) + 2,
                (row - 1) * actual_cell_height + line_idx)
            self.monitor.setTextColor(formatted.colors[line_idx] or colors.white)

            local content = self:truncateText(tostring(line_content), self.cell_width - 4)

            if center_text then
                local spaces = math.floor((self.cell_width - #content) / 2)
                content = string.rep(" ", spaces) .. content .. string.rep(" ", spaces)
            end
            self.monitor.write(content)
        end
    end
end

return GridDisplay
