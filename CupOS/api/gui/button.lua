local cc_expect = require("cc.expect")
local expect = cc_expect.expect
local range = cc_expect.range

local thread = require("CupOS/api/thread")
local field = require("CupOS.api.gui.field")

local pretty = require("cc.pretty").pretty_print

function create(parent, x, y, width, height, backgroundColor, onClick)
    expect(1, parent, "table", "nil")
    expect(2, x, "number")
    expect(3, y, "number")
    expect(4, width, "number", "nil")
    expect(5, height, "number", "nil")
    expect(6, backgroundColor, "number")
    range(backgroundColor, 1, 32768)
    expect(7, onClick, "function")


    if parent == nil then
        parent = {}
        parent.window = term.current()
    end

    local obj = field.create(parent, x, y, width, height, backgroundColor)

    obj.type = "button"
    obj.onClick = onClick
    obj.parent = parent
    obj.thread = nil
    obj.actionIsRunned = false

    function obj.action(obj)
        local obj = obj[1]

        while true do
            local _, button, clickX, clickY = os.pullEvent("mouse_click")

            if
            (clickX >= obj.parent.absoluteX and clickX <= obj.parent.absoluteX + obj.parent.width - 1) and
            (clickY >= obj.parent.absoluteY and clickY <= obj.parent.absoluteY + obj.parent.height - 1)
            then
                if
                button == 1 and
                (clickX >= obj.absoluteX and clickX <= obj.absoluteX + obj.width - 1) and
                (clickY >= obj.absoluteY and clickY <= obj.absoluteY + obj.height - 1)
                then
                    local isStoped = obj.onClick(obj)
                    if isStoped then
                        break
                    end
                end
            end
        end
    end

    function obj:kill()
        thread.kill(self.thread)
        self.actionIsRunned = false

        for _, childObj in ipairs(obj.child) do
            childObj:kill(self)
        end
    end

    function obj:draw()
        local previousBackgroundColor = self.window.getBackgroundColor()
        local previousCursorX, previousCursorY = self.window.getCursorPos()

        self.window.setBackgroundColor(self.backgroundColor)
        self.window.clear()

        for _, childObj in ipairs(self.child) do
            childObj:draw(self)
        end

        self.window.setBackgroundColor(previousBackgroundColor)
        self.window.setCursorPos(previousCursorX, previousCursorY)

        self.parent = parent

        if not obj.actionIsRunned then
            obj.actionIsRunned = true
            obj.thread = thread.create(self.action, self)
        end
    end

    return obj
end

return {
    create = create
}
