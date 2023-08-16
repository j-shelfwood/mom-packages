-- grid_display.lua
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
    return self
end

function GridDisplay:setCellParameters(num_items, width, height, max_columns, max_rows, scale)
    local cell_aspect_ratio = self.cell_width / self.cell_height
    local desired_columns = math.sqrt(num_items * cell_aspect_ratio)
    local desired_rows = num_items / desired_columns
    local actual_columns = math.min(max_columns, math.ceil(desired_columns))
    local actual_rows = math.min(max_rows, math.floor(desired_rows))
    local remaining_width = width - (actual_columns * self.cell_width)
    local remaining_height = height - (actual_rows * self.cell_height)

    self.start_x = math.floor(remaining_width / 2) + 1
    self.start_y = math.floor(remaining_height / 2) + 1
    self.columns = actual_columns
    self.rows = actual_rows
    self.scale = scale
end

function GridDisplay:calculate_cells(num_items)
    local scale = 5 -- start with the largest scale

    while scale >= MIN_TEXT_SCALE do
        self.monitor.setTextScale(scale)
        local width, height = self.monitor.getSize()

        -- Determine the maximum number of columns that can fit
        local max_columns = math.floor(width / self.cell_width)

        -- Determine the total required lines for all items 
        -- (assuming each item takes up at least a minimum of 3 lines)
        local total_required_lines = 3 * num_items

        -- Determine the total number of lines available on the monitor at this scale
        local total_available_lines = height * max_columns

        if total_required_lines <= total_available_lines then
            local required_rows = math.ceil(num_items / max_columns)
            local max_rows_at_current_height = math.floor(height / self.cell_height)

            if required_rows <= max_rows_at_current_height then
                self:setCellParameters(num_items, width, height, max_columns, required_rows, scale)
                return
            end
        end

        scale = scale - SCALE_DECREMENT
    end

    -- If we reach this point, use the minimum scale
    self.scale = MIN_TEXT_SCALE
    self.monitor.setTextScale(self.scale)
    local width, height = self.monitor.getSize()
    self.columns = math.floor(width / self.cell_width)
    self.rows = math.floor(height / DEFAULT_CELL_HEIGHT_PER_LINE)

    -- Calculate the position of the first cell
    self.start_x = 1
    self.start_y = 1
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
    if center_text == nil then
        center_text = true
    end

    -- Determine cell height based on maximum number of lines across all data items
    local max_lines = 0
    for _, item in ipairs(data) do
        local formatted = format_callback(item)
        max_lines = math.max(max_lines, #formatted.lines)
    end
    self.cell_height = DEFAULT_CELL_HEIGHT_PER_LINE * max_lines

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

        local row = math.floor((i - 1) / self.columns) + 1
        local column = (i - 1) % self.columns + 1
        local formatted = format_callback(item)

        for line_idx, line_content in ipairs(formatted.lines) do
            self.monitor.setCursorPos(self.start_x + (column - 1) * self.cell_width + 2,
                self.start_y + (row - 1) * self.cell_height + line_idx)
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
