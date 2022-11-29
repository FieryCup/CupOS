local cc_expect = require("cc.expect")
local expect, field, range = cc_expect.expect, cc_expect.field, cc_expect.range

local function textHeight(text)
    local count = 0

    for i in string.gmatch(text, "([^\n]+)") do
       count = count + 1
    end

    return count
 end

function create(parent, x, y, text, textColor, backgroundColor)
    expect(1, parent, "table", "nil")
    expect(2, x, "number")
    expect(3, y, "number")
    expect(4, text, "string")
    expect(5, textColor, "number")
    range(textColor, 1, 32768)
    expect(6, backgroundColor, "number")
    range(backgroundColor, 1, 32768)

    local obj = {}
    obj.type = "text"
    obj.x = x
    obj.y = y
    obj.text = text
    obj.textColor = textColor
    obj.backgroundColor = backgroundColor
    obj.width = text:len()
    obj.height = textHeight(text)

    obj.parent = parent or term.current()
    
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

    function obj:draw(obj)
        local previousBackgroundColor = self.parent.window.getBackgroundColor()
        local previousTextColor = self.parent.window.getTextColor()
        local previousCursorX, previousCursorY = self.parent.window.getCursorPos()

        self.parent.window.setBackgroundColor(self.backgroundColor)
        self.parent.window.setTextColor(self.textColor)
        
        local i = 0
        for str in string.gmatch(self.text, "([^\n]+)") do
            self.parent.window.setCursorPos(self.x, self.y + i)
            self.parent.window.write(str)
            i = i + 1
        end

        self.parent.window.setBackgroundColor(previousBackgroundColor)
        self.parent.window.setTextColor(previousTextColor)
        self.parent.window.setCursorPos(previousCursorX, previousCursorY)
    end

    return obj
end

return {
    create = create
}
