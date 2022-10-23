local cc_expect = require("cc.expect")
local expect, field = cc_expect.expect, cc_expect.field

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

    local background = field(image, "background", "table")
    local foreground = field(image, "foreground", "table")
    local text = field(image, "text", "table")
    if not target then target = term end

    local old_background_color = target.getBackgroundColor()
    local old_text_color = target.getTextColor()

    for y = 1, #text do
        for x = 1, #text[1] do
            local background_char = background[y][x]
            local background_char1 = background_char == " " and colors.toBlit(old_background_color) or background_char

            local foreground_char = foreground[y][x]
            local foreground_char1 = foreground_char == " " and colors.toBlit(old_background_color) or foreground_char

            target.setCursorPos(xPos + x - 1, yPos + y - 1)
            target.blit(text[x][y], foreground_char1, background_char1)
        end
    end

    target.setBackgroundColor(old_background_color)
    target.setTextColor(old_text_color)
end

return {
    load = load,
    draw = draw
}
