-- grid_display.lua
local GridDisplay = {}
GridDisplay.__index = GridDisplay

-- Constructor
function GridDisplay.new(monitor)
    local self = setmetatable({}, GridDisplay)
    self.monitor = monitor
    return self
end
-- Function to calculate the number of cells the monitor can display
function GridDisplay:calculate_cells(num_items)
    local scale = 5 -- start with the largest scale

    while scale >= 0.5 do -- minimum text scale is 0.5
        -- Set the text scale
        self.monitor.setTextScale(scale)

        -- Get the monitor size at this scale
        local width, height = self.monitor.getSize()

        -- Initial cell dimensions
        local cell_width = 17
        local cell_height = 5

        local max_columns = math.floor(width / cell_width)
        local max_rows = math.floor(height / cell_height)
        local max_cells = max_rows * max_columns

        if max_cells >= num_items then
            -- We can fit all items at this scale
            -- Now let's try to use the remaining space

            -- Calculate the desired aspect ratio
            local aspect_ratio = (width / height) * (cell_height / cell_width)

            -- Calculate the desired number of columns based on the aspect ratio
            local desired_columns = math.sqrt(num_items * aspect_ratio)
            local desired_rows = num_items / desired_columns

            -- Actual rows and columns that will be filled
            local actual_columns = math.min(max_columns, math.ceil(desired_columns))
            local actual_rows = math.min(max_rows, math.floor(desired_rows))

            -- Calculate remaining space
            local remaining_width = width - (actual_columns * cell_width)
            local remaining_height = height - (actual_rows * cell_height)

            -- Calculate the position of the first cell
            self.start_x = math.floor(remaining_width / 2) + 1
            self.start_y = math.floor(remaining_height / 2) + 1

            -- Store other necessary properties
            self.columns = actual_columns
            self.rows = actual_rows
            self.scale = scale
            self.cell_width = cell_width
            self.cell_height = cell_height

            return
        end

        scale = scale - 0.5 -- decrease scale
    end

    -- If we reach this point, we can't fit all items even at the minimum scale
    -- Set the scale to the minimum and calculate the cells at this scale
    self.scale = 0.5
    self.monitor.setTextScale(self.scale)
    local width, height = self.monitor.getSize()
    self.columns = math.floor(width / 17)
    self.rows = math.floor(height / 5)

    -- Calculate the position of the first cell
    self.start_x = 1
    self.start_y = 1

    -- Set the cell dimensions to the minimum
    self.cell_width = 22
    self.cell_height = 5
end

-- Function to display data in a grid
function GridDisplay:display(data, format_callback, center_text)
    -- If center_text is nil, default to true
    if center_text == nil then
        center_text = true
    end

    -- If the data is empty write No data on the monitor centered.
    if #data == 0 then
        self.monitor.clear()
        self.monitor.setCursorPos(math.floor(self.monitor.getSize() / 2) - 4, math.floor(self.monitor.getSize() / 2))
        self.monitor.write("No data")
        return
    end

    -- Calculate cells
    self:calculate_cells(#data)

    -- Clear monitor
    self.monitor.clear()

    -- Display data
    for i, item in ipairs(data) do
        if i > self.rows * self.columns then
            break
        end -- if there are more items than cells, stop displaying

        local row = math.floor((i - 1) / self.columns) + 1
        local column = (i - 1) % self.columns + 1

        -- Get formatted data
        local formatted = format_callback(item)
        local lines = {formatted.line_1, formatted.line_2, formatted.line_3}
        local colors = {formatted.color_1, formatted.color_2, formatted.color_3}

        -- Write lines
        for line = 1, 3 do
            -- Add offsets to the cursor position
            self.monitor.setCursorPos(self.start_x + (column - 1) * 17 + 2, self.start_y + (row - 1) * 5 + line)
            self.monitor.setTextColor(colors[line] or colors.white)

            -- If center_text is true, add spaces to the lines to center them
            if center_text then
                local content = tostring(lines[line]) -- Ensure that the line content is a string
                local spaces = math.floor((15 - #content) / 2)
                content = string.rep(" ", spaces) .. content .. string.rep(" ", spaces)
                self.monitor.write(content)
            else
                self.monitor.write(tostring(lines[line])) -- Ensure the line content is a string
            end
        end
    end
end

return GridDisplay
