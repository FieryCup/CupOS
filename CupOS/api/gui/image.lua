local cc_expect = require("cc.expect")
local expect = cc_expect.expect
local field = cc_expect.field

function load(path)
    expect(1, path, "string")

    local file, err = io.open(path, "r")

    if not file then return nil, err end

    local result = file:read("*a")
    file:close()

    return textutils.unserialize(result)
end

function draw(target, xPos, yPos, image)
    expect(1, target, "table", "nil")
    expect(2, xPos, "number")
    expect(3, yPos, "number")
    expect(4, image, "table")
    
    target = target or term.current()

    local background = field(image, "background", "table")
    local foreground = field(image, "foreground", "table")
    local text = field(image, "text", "table")

    local old_background_color = target.getBackgroundColor()
    local old_text_color = target.getTextColor()

    for y = 1, #text do
        for x = 1, #text[1] do
            local background_char = background[y]:sub(x, x)
            local background_char1 = background_char == " " and colors.toBlit(old_background_color) or background_char

            local foreground_char = foreground[y]:sub(x, x)
            local foreground_char1 = foreground_char == " " and colors.toBlit(old_background_color) or foreground_char

            target.setCursorPos(xPos + x - 1, yPos + y - 1)
            target.blit(text[y]:sub(x, x), foreground_char1, background_char1)
        end
    end

    target.setBackgroundColor(old_background_color)
    target.setTextColor(old_text_color)
end

function create(parent, x, y, image)
    expect(1, parent, "table", "nil")
    expect(2, x, "number")
    expect(3, y, "number")
    expect(4, image, "table")

    local obj = {}
    obj.type = "image"
    obj.parent = parent or term.current()
    obj.x = x
    obj.y = y
    obj.image = image
    
    function obj:updatePos()
        if obj.parent.absoluteX == nil then
            obj.absoluteX = obj.x
            obj.absoluteY = obj.y
        else
            obj.absoluteX = obj.x + obj.parent.absoluteX - 1
            obj.absoluteY = obj.y + obj.parent.absoluteY - 1
        end
    end

    function obj:kill()
    end

    function obj:draw(parent)
        draw(parent.window, obj.x, obj.y, obj.image)
    end

    return obj
end

return {
    load = load,
    draw = draw,
    create = create
}