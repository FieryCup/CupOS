local expect = require("cc.expect").expect

local function load(path)
    expect(1, path, "string")

    local file, err = io.open(path, "r")

    if not file then return nil, err end

    local result = file:read("*a")
    file:close()

    return textutils.unserialize(result)
end

local function draw(image, xPos, yPos, target)
    expect(1, image, "table")
    expect(2, xPos, "number")
    expect(3, yPos, "number")
    expect(4, target, "table", "nil")

    if not target then target = term end

    local old_background_color = target.getBackgroundColor()
    local old_text_color = target.getTextColor()

    for y, line in ipairs(image) do

        if string.match(line.background, " ") or string.match(line.foreground, ".") then
            local foreground_table = {}
            local text_table = {}

            for i = 1, #line.text do
                text_table[i] = line.text:sub(i, i)
            end
            
            for x=1, #line.text do
                local background_char = line.background:sub(x, x)
                local background = background_char == " " and colors.toBlit(old_background_color) or background_char

                local foreground_char = line.foreground:sub(x, x)
                local foreground = foreground_char == " " and colors.toBlit(old_background_color) or foreground_char

                target.setCursorPos(xPos + x - 1, yPos + y - 1)
                target.blit(line.text:sub(x, x), foreground, background)
            end
        else
            for y, line in ipairs(image) do
                target.setCursorPos(xPos, yPos + y - 1)
                target.blit(line.text, line.foreground, line.background)
            end
        end
    end

    target.setBackgroundColor(old_background_color)
    target.setTextColor(old_text_color)
end

return {
    load = load,
    draw = draw
}
