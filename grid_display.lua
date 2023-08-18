local GridDisplay = {}
GridDisplay.__index = GridDisplay

-- Constants
local MIN_TEXT_SCALE = 0.5
local SCALE_DECREMENT = 0.5
local DEFAULT_CELL_WIDTH = 20
local ELLIPSIS = "..."

function GridDisplay.new(monitor, custom_cell_width)
    local self = setmetatable({}, GridDisplay)
    self.monitor = monitor
    self.cell_width = custom_cell_width or DEFAULT_CELL_WIDTH
    self.spacing_x = 1 -- Define the spacing here
    self.spacing_y = 1 -- Define the spacing here
    return self
end

function GridDisplay:setCellParameters(num_items, width, height, max_columns, rows, scale)
    local total_grid_width = (self.cell_width + self.spacing_x) * max_columns - self.spacing_x -- Subtracting the spacing once as it's not needed after the last column
    local total_grid_height = (self.cell_height + self.spacing_y) * rows - self.spacing_y -- Same reasoning for rows

    -- Calculate the leftover spaces
    local leftover_width = width - total_grid_width
    local leftover_height = height - total_grid_height

    -- Set the starting positions
    self.start_x = math.floor(leftover_width / 2)
    self.start_y = math.floor(leftover_height / 2)

    self.columns = max_columns
    self.scale = scale
end

function GridDisplay:determineCellHeight(data, format_callback)
    local formatted = format_callback(data[1])
    return #formatted.lines
end

function GridDisplay:calculate_cells(num_items)
    local scale = 5
    while scale >= MIN_TEXT_SCALE do
        self.monitor.setTextScale(scale)
        local width, height = self.monitor.getSize()

        local max_columns = math.floor((width - self.spacing_x) / (self.cell_width + self.spacing_x))
        local required_rows = math.ceil(num_items / max_columns)

        -- Account for the gaps between cells and borders after determining max_columns and required_rows
        local effective_width = width - (max_columns + 1) * self.spacing_x
        local effective_height = height - (required_rows + 1) * self.spacing_y

        local max_columns = math.floor(effective_width / self.cell_width)
        local max_rows = math.floor(effective_height / self.cell_height)

        if required_rows <= max_rows then
            self:setCellParameters(num_items, width, height, max_columns, required_rows, scale)
            self.rows = required_rows
            return
        end
        scale = scale - SCALE_DECREMENT
    end

    -- Minimum scale settings
    self.scale = MIN_TEXT_SCALE
    self.monitor.setTextScale(self.scale)
    local width, height = self.monitor.getSize()
    self.columns = math.floor(width / self.cell_width)
    self.rows = math.floor(height / self.cell_height)
    self.start_x = 1

    print("Using minimum scale settings") -- Debugging output
    print("Monitor Width:", width, "Monitor Height:", height) -- Debugging output
    print("Columns:", self.columns, "Rows:", self.rows) -- Debugging output
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
    self.cell_height = self:determineCellHeight(data, format_callback)

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
            self.monitor.setCursorPos(self.start_x + (column - 1) * (self.cell_width + self.spacing_x),
                self.start_y + (row - 1) * (self.cell_height + self.spacing_y) + line_idx)
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
