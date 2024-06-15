local this

this = {
    sleepTime = 1,
    new = function(monitor, config)
        local self = {
            monitor = monitor,
            machine_type = config.machine_type or "modern_industrialization:electrolyzer",
            bar_width = 7,
            bar_height = 4
        }
        local _, _, machineTypeName = string.find(machine_type, ":(.+)")

        if not machineTypeName then
            print("Error extracting machine type name from:", machine_type)
            return
        end
        machineTypeName = machineTypeName:gsub("_", " ") -- Replace underscores with spaces
        self.title = string.upper(string.sub(machineTypeName, 1, 1)) .. string.sub(machineTypeName, 2) -- Capitalize the first letter

        local width, height = monitor.getSize()
        self.width = width
        self.height = height

        return self
    end,
    mount = function()
        return true
    end,

    configure = function()
        print("Enter the machine type (e.g., modern_industrialization:electrolyzer):")
        local machine_type = read()
        return {
            machine_type = machine_type
        }
    end,

    render = function(self)
        self.monitor.setTextScale(1)

        this.displayMachineStatus(self)
    end,
    fetchData = function(self)
        local machine_data = {}
        local peripherals = peripheral.getNames()

        for _, name in ipairs(peripherals) do
            local machine = peripheral.wrap(name)

            if string.find(name, self.machine_type) then
                print("Fetching data for " .. name)

                -- Extract the name
                local _, _, name = string.find(name, self.machine_type .. "_(.+)")

                -- Call the machine.items using pcall so we have no fail 
                local ok, itemsList = pcall(machine.items)
                if not ok then
                    itemsList = {}
                end

                table.insert(machine_data, {
                    name = name,
                    items = itemsList,
                    isBusy = machine.isBusy()
                })
            end
        end

        return machine_data
    end,
    displayMachineStatus = function(self)
        local machine_data = this.fetch_data(self)

        -- Calculate total grid height based on the number of machines
        local columns = math.min(2, #machine_data)
        local rows = math.ceil(#machine_data / columns)
        local totalGridHeight = rows * (self.bar_height + 1) - 1

        -- Display the title at the top
        self.monitor.setBackgroundColor(colors.black)
        self.monitor.setTextColor(colors.white)
        local linesUsed = self.displayCenteredTitle(2, self.title)

        -- Adjust the topMargin based on the number of lines used by the title
        local topMargin = math.floor((self.height - totalGridHeight - (2 * linesUsed) - 2) / 2) + linesUsed + 1

        for idx, machine in ipairs(machine_data) do
            local column = (idx - 1) % columns
            local row = math.ceil(idx / columns)
            local x = column * (self.bar_width + 2) + 2 -- Adjust gutter for the second column
            local y = (row - 1) * (self.bar_height + 1) + topMargin
            -- Draw a colored bar based on isBusy status
            if machine.isBusy then
                self.monitor.setBackgroundColor(colors.green)
            else
                self.monitor.setBackgroundColor(colors.gray)
            end
            for i = 0, self.bar_height - 1 do
                self.monitor.setCursorPos(x, y + i)
                self.monitor.write(string.rep(" ", self.bar_width))
            end
            -- Write the machine number centered in the bar
            self.monitor.setTextColor(colors.black)
            self.monitor.setCursorPos(x + math.floor((self.bar_width - string.len(machine.name)) / 2),
                y + math.floor(self.bar_height / 2))
            self.monitor.write(machine.name)
        end
        -- Display the title at the bottom
        self.monitor.setBackgroundColor(colors.black)
        self.monitor.setTextColor(colors.white)
        self.displayCenteredTitle(self.height - linesUsed, self.title)
    end,
    displayCenteredTitle = function(self, yPos, title)
        -- Split title at spaces
        local titleParts = {}
        for part in string.gmatch(title, "%S+") do
            table.insert(titleParts, part)
        end

        local currentTitle = titleParts[1]
        local lineCount = 1

        for i = 2, #titleParts do
            -- Check if adding the next word exceeds the width
            if string.len(currentTitle .. " " .. titleParts[i]) <= self.width then
                currentTitle = currentTitle .. " " .. titleParts[i]
            else
                -- Display the current title and reset for next line
                self.monitor.setCursorPos(math.floor((self.width - string.len(currentTitle)) / 2) + 1, yPos)
                self.monitor.write(currentTitle)
                yPos = yPos + 1
                currentTitle = titleParts[i]
                lineCount = lineCount + 1
            end
        end

        -- Display the last part of the title
        self.monitor.setCursorPos(math.floor((self.width - string.len(currentTitle)) / 2) + 1, yPos)
        self.monitor.write(currentTitle)

        return lineCount
    end
}
return this
