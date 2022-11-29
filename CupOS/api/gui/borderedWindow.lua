local thread = require("CupOS.api.thread")
local buttonModule = require("CupOS.api.gui.button")
local textModule = require("CupOS.api.gui.text")
local fieldModule = require("CupOS.api.gui.field")
local imageModule = require("CupOS.api.gui.image")

local pretty = require("cc.pretty").pretty_print
local cc_expect = require("cc.expect")
local expect, range = cc_expect.expect, cc_expect.range

local function create(parent, title, x, y, width, height, frameColor, textColor, backgroundColor)
    expect(1, parent, "table", "nil")
    expect(2, title, "string")
    expect(3, x, "number")
    expect(4, y, "number")
    expect(5, width, "number")
    expect(6, height, "number")
    expect(7, frameColor, "number", "nil")
    expect(8, textColor, "number", "nil")
    expect(9, backgroundColor, "number", "nil")

    if frameColor then
        range(frameColor, 1, 32768)
    end
    if textColor then
        range(textColor, 1, 32768)
    end
    if backgroundColor then
        range(backgroundColor, 1, 32768)
    end

    if parent == nil then
        parent = term.current()
    end

    local framedWindow = fieldModule.create(nil, x, y, width, height, colors.red)

    -- framedWindow.mainThread = nil
    framedWindow.isClosed = false

    framedWindow.title = title
    framedWindow.backgroundColor = backgroundColor or colors.black
    framedWindow.frameColor = frameColor or colors.gray
    framedWindow.textColor = textColor or colors.white

    -- Нижнее меню
    local footerBar = fieldModule.create(framedWindow, 1, framedWindow.height, framedWindow.width, 1, framedWindow.frameColor)
    local footerBarText = textModule.create(footerBar, 2, 1, "", framedWindow.textColor, footerBar.backgroundColor)
    footerBar:addChild(footerBarText)

    framedWindow.workspace = fieldModule.create(framedWindow, 3, 2, framedWindow.width - 4, framedWindow.height - 2, framedWindow.backgroundColor)

    -- Верхнее меню
    local titleBar = fieldModule.create(framedWindow, 1, 1, framedWindow.width, 1, framedWindow.frameColor)
    local windowTitle = textModule.create(titleBar, 2, 1, framedWindow.title, framedWindow.textColor, framedWindow.frameColor)

    local closeFramedWindow = function (obj)
        framedWindow:kill()
        -- thread.kill(framedWindow.mainThread)
        framedWindow.isClosed = true
        -- TODO: Убрать в будущем
        term.clear()

        return false
    end

    local closeWindowButton = buttonModule.create(titleBar, titleBar.width - 2, 1, 3, 1, colors.red, closeFramedWindow)
    local closeWindowText = textModule.create(closeWindowButton, 2, 1, "x", framedWindow.textColor, closeWindowButton.backgroundColor)
    closeWindowButton:addChild(closeWindowText)

    local fullScreen = function (obj)
        return false
    end

    local fullScreenButton = buttonModule.create(titleBar, titleBar.width - 5, 1, 3, 1, framedWindow.frameColor, fullScreen)
    local fullScreenwText = textModule.create(fullScreenButton, 2, 1, "+", framedWindow.textColor, fullScreenButton.backgroundColor)
    fullScreenButton:addChild(fullScreenwText)

    local windowCollapse = function (obj)
        return false
    end

    local windowCollapseButton = buttonModule.create(titleBar, titleBar.width - 8, 1, 3, 1, framedWindow.frameColor, windowCollapse)
    local windowCollapseText = textModule.create(windowCollapseButton, 2, 1, "-", framedWindow.textColor, windowCollapseButton.backgroundColor)
    windowCollapseButton:addChild(windowCollapseText)

    titleBar:addChild(windowTitle, windowCollapseButton, fullScreenButton, closeWindowButton)

    framedWindow:addChild(titleBar, framedWindow.workspace, footerBar)

    function framedWindow:draw()
        self.window.setBackgroundColor(self.backgroundColor)
        self.window.clear()
        
        for i = 2, framedWindow.height - 1 do
            self.window.setBackgroundColor(self.backgroundColor)
            self.window.setTextColor(framedWindow.frameColor)
            self.window.setCursorPos(1, i)
            self.window.write("\149")

            self.window.setBackgroundColor(framedWindow.frameColor)
            self.window.setTextColor(self.backgroundColor)
            self.window.setCursorPos(self.width, i)
            self.window.write("\149")
        end
        
        for _, childObj in ipairs(self.child) do
            childObj:draw()
        end
    end

    return framedWindow
end

return {
    create = create
}