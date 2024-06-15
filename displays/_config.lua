local this

this = {
    load = function()
        if fs.exists("displays.config") then
            local file = fs.open("displays.config", "r")
            local config = textutils.unserialize(file.readAll())
            file.close()
            return config
        else
            return {}
        end
    end
}

return this
