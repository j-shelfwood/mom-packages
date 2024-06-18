local this

this = {
    options = {
        enabled = false,
        state = {
            block = "rechiseled:obsidian_dark_connecting",
            invisible = false,
            playerPassable = true,
            skyLightPassable = true,
            lightPassable = true
        }
    },
    save = function()
        local state = {
            options = this.options
        }
        local file = fs.open("forcefield.json", "w")
        file.write(textutils.serializeJSON(state))
        file.close()
    end,
    load = function()
        if not fs.exists("forcefield.json") then
            print("No forcefield configuration found, using default values.")
            return this
        end
        local file = fs.open("forcefield.json", "r")
        local options = textutils.unserializeJSON(file.readAll())
        file.close()
        this.options = options
        return this
    end
}

return this
