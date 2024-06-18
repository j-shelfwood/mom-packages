local this

this = {
    find = function()
        -- Check if the `anchors.json` file exists
        if not fs.exists("anchors.json") then
            print('No `anchors.json` file found, detecting anchors...')
            this.anchors = this.detectAnchors()
        else
            print('Loading anchors from `anchors.json`...')
            this.anchors = this.loadAnchors()
        end
    end,
    detect = function()
        print('Detecting anchors...')
        local anchors = this.forger.detectAnchors()

        -- Save the anchors to the `anchors.json` file
        local file = fs.open("anchors.json", "w")
        file.write(textutils.serializeJSON(anchors))
        file.close()
        print('Anchors saved to `anchors.json`!')
        return anchors
    end,
    load = function()
        print('Loading anchors...')
        local file = fs.open("anchors.json", "r")
        local anchors = textutils.unserializeJSON(file.readAll())
        file.close()
        return anchors
    end
}

return this
