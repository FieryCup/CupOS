
local speaker = peripheral.find("speaker")

function draw_bsod(file, title, err)
    local strings = require("cc.strings")

    local width, height = term.getSize()

    local file_table = {}
    for i in string.gmatch(file, "([^/]+)") do
        table.insert(file_table, i)
    end
    file = file_table[#file_table]

    local err_table = {}
    for i in string.gmatch(err, "([^:]+)") do
        table.insert(err_table, i)
    end

    err = file .. ":" .. err_table[2] .. ":" .. err_table[3]

    local lines = strings.wrap(err, width - 4)

    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(3, 4)
    term.write(title)
    term.setCursorPos(3, height - 1)
    term.write("Press any key to continue ...")

    for i = 1, #lines do
        term.setCursorPos(3, i + 5)
        term.write(lines[i])
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
    draw_bsod = draw_bsod
}