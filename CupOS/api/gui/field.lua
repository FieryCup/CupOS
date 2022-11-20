local cc_expect = require("cc.expect")
local expect = cc_expect.expect
local range = cc_expect.range

local pretty = require("cc.pretty").pretty_print

function create(parent, x, y, width, height, backgroundColor)
    expect(1, parent, "table", "nil")
    expect(2, x, "number")
    expect(3, y, "number")
    expect(4, width, "number")
    expect(5, height, "number")
    expect(6, backgroundColor, "number")
    range(backgroundColor, 1, 32768)

    local obj = {}
    obj.type = "field"
    obj.x = x
    obj.y = y
    obj.width = width
    obj.height = height
    obj.backgroundColor = backgroundColor
    obj.child = {}

    if parent == nil then
        obj.parent = {}
        obj.parent.window = term.current()
    else
        obj.parent = parent
    end
    
    obj.window = window.create(obj.parent.window, x, y, width, height)

    function obj:updatePos()
        if obj.parent.absoluteX == nil then
            obj.absoluteX = obj.x
            obj.absoluteY = obj.y
        else
            obj.absoluteX = obj.x + obj.parent.absoluteX - 1
            obj.absoluteY = obj.y + obj.parent.absoluteY - 1
        end

        for _, childObj in ipairs(obj.child) do
            childObj:updatePos(self)
        end
    end

    obj:updatePos()

    function obj:addChild(...)
        for _, child in ipairs(arg) do
            table.insert(self.child, child)
        end
    end

    function obj:kill()
        for _, childObj in ipairs(obj.child) do
            childObj:kill(self)
        end
    end

    function obj:draw()
        obj.window.setBackgroundColor(obj.backgroundColor)
        obj.window.clear()
        
        for _, childObj in ipairs(obj.child) do
            childObj:draw(self)
        end
    end

    return obj
end

return {
    create = create
}