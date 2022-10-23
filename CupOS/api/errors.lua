local speaker = peripheral.find("speaker")
local strings = require("cc.strings")

if not speaker and ccemux then
    ccemux.attach("left", "speaker")
    speaker = peripheral.find("speaker")
end


function blue_screen_of_death(file, title, err)
    local width, height = term.getSize()

    if err ~= nil then
        local err_table = {}
        for i in err:gmatch("([^:]+)") do
            table.insert(err_table, i)
        end

        if file ~= nil then
            local file_table = {}
            for i in err:gmatch("([^/]+)") do
                table.insert(file_table, i)
            end
            file = file_table[#file_table]
            
            err = file .. ":" .. err_table[2] .. ":" .. err_table[3]
        else
            err = err_table[2] .. ":" .. err_table[3]
        end
    end

    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(3, 4)
    term.write(title)
    term.setCursorPos(3, height - 1)
    term.write("Press any key to continue ...")

    if err then
        local lines = strings.wrap(err, width - 4)

        for i = 1, #lines do
            term.setCursorPos(3, i + 5)
            term.write(lines[i])
        end
    end
    
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.blue)
    term.setCursorPos(3, 2)
    term.write("CupOS")

    if speaker then
        speaker.playNote("bit", 1, 10)
        os.sleep(0.2)
        speaker.playNote("bit", 1, 10)
    end

    os.pullEvent("key")
end

return {
    bsod = bsod
}
