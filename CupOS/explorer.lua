local thread = require("CupOS/api/thread")
local pretty = require("cc.pretty").pretty_print

local buttonModule = require("CupOS.api.gui.button")
local textModule = require("CupOS.api.gui.text")
local fieldModule = require("CupOS.api.gui.field")

local imageModule = require("CupOS.api.gui.image")

local cc_expect = require("cc.expect")
local expect, range = cc_expect.expect, cc_expect.range

function move_to_previous_folder(current_folder)
    expect(1, current_folder, "string")

    if current_folder ~= "./" then
        local current_folder_table = {}

        for i in string.gmatch(current_folder, "([^/]+)") do
            table.insert(current_folder_table, i)
        end

        previous_folder = {}
        for i=0, #current_folder_table - 1 do
            table.insert(previous_folder, current_folder_table[i])
        end

        previous_folder = table.concat(previous_folder, "/")
    end
    return previous_folder
end


local function run(startPath, x, y, width, height, backgroundColor, frameColor, textColor, filesTitleColor)
    expect(1, startPath, "string")
    expect(2, x, "number")
    expect(3, y, "number")
    expect(4, width, "number")
    expect(5, height, "number")
    expect(6, backgroundColor, "number")
    range(backgroundColor, 1, 32768)
    expect(7, frameColor, "number")
    range(frameColor, 1, 32768)
    expect(8, textColor, "number")
    range(textColor, 1, 32768)
    expect(9, filesTitleColor, "number")
    range(filesTitleColor, 1, 32768)

    local data = {}
    data.scroll = 0
    data.path = startPath
    data.files = {}

    -- TODO: Убрать в будущем
    term.clear()

    local explorer = fieldModule.create(nil, 2, 3, 20, 20, colors.red)
    explorer.mainThread = nil

    explorer.width = width or 40
    explorer.height = height or 15

    explorer.backgroundColor = backgroundColor or colors.black
    explorer.frameColor = frameColor or colors.gray
    explorer.textColor = textColor or colors.white
    explorer.filesTitleColor = filesTitleColor or colors.lightGray
    explorer:updatePos()
    error("1")

    -- Нижнее меню
    local footerBar = fieldModule.create(explorer, 1, explorer.height, explorer.width, 1, explorer.frameColor)
    local footerBarText = textModule.create(footerBar, 2, 1, "", explorer.textColor, footerBar.backgroundColor)
    footerBar:addChild(footerBarText)

    local workspace = fieldModule.create(explorer, 3, 2, explorer.width - 4, explorer.height - 2, explorer.backgroundColor)

    -- Верхнее меню
    local titleBar = fieldModule.create(explorer, 1, 1, explorer.width, 1, explorer.frameColor)
    local windowTitle = textModule.create(titleBar, 2, 1, "Explorer", explorer.textColor, explorer.frameColor)

    local closeExplorer = function (obj)
        explorer:kill()
        thread.kill(explorer.mainThread)
        -- TODO: Убрать в будущем
        term.clear()

        return false
    end

    local closeWindowButton = buttonModule.create(titleBar, titleBar.width - 2, 1, 3, 1, colors.red, closeExplorer)
    local closeWindowText = textModule.create(closeWindowButton, 2, 1, "x", explorer.textColor, closeWindowButton.backgroundColor)
    closeWindowButton:addChild(closeWindowText)

    local fullScreen = function (obj)
        return false
    end

    local fullScreenButton = buttonModule.create(titleBar, titleBar.width - 5, 1, 3, 1, explorer.frameColor, fullScreen)
    local fullScreenwText = textModule.create(fullScreenButton, 2, 1, "+", explorer.textColor, fullScreenButton.backgroundColor)
    fullScreenButton:addChild(fullScreenwText)

    local windowCollapse = function (obj)
        return false
    end

    local windowCollapseButton = buttonModule.create(titleBar, titleBar.width - 8, 1, 3, 1, explorer.frameColor, windowCollapse)
    local windowCollapseText = textModule.create(windowCollapseButton, 2, 1, "-", explorer.textColor, windowCollapseButton.backgroundColor)
    windowCollapseButton:addChild(windowCollapseText)

    titleBar:addChild(windowTitle, windowCollapseButton, fullScreenButton, closeWindowButton)

    -- Путь директории
    local pathFrame = fieldModule.create(workspace, 4, 1, workspace.width - 3, 3, explorer.backgroundColor)
    local path = fieldModule.create(pathFrame, 3, 2, pathFrame.width - 4, 1, pathFrame.backgroundColor)
    local pathText = textModule.create(path, 1, 1, "", explorer.textColor, path.backgroundColor)

    -- Файлы
    local filesHeader = textModule.create(workspace, 1, 4, "Name            \149Type     \149Size", explorer.filesTitleColor, explorer.backgroundColor)
    local filesTable = fieldModule.create(workspace, 1, 6, workspace.width, workspace.height - 6, explorer.backgroundColor)

    -- Кнопка назад
    local previousPath = function (obj)
        data.path = move_to_previous_folder(data.path) .. "/"
        data:updateFiles()

        filesTable:draw()
        footerBar:draw()
        path:draw()
        return false
    end

    local backButton = buttonModule.create(workspace, 1, 1, 3, 3, explorer.backgroundColor, previousPath)
    local backText = textModule.create(backButton, 2, 2, "\27", explorer.textColor, backButton.backgroundColor)
    backButton:addChild(backText)

    pathFrame:addChild(path)
    path:addChild(pathText)

    explorer:addChild(titleBar, workspace, footerBar)
    workspace:addChild(backButton, pathFrame, filesHeader, filesTable)

    -- Измененные функции отрисовки
    function filesTable:draw()
        self.window.setBackgroundColor(self.backgroundColor)
        self.window.clear()

        for i, file in ipairs(data.files) do
            self.window.setTextColor(self.backgroundColor)
            if file.type == "folder" then
                self.window.setBackgroundColor(colors.yellow)
            else
                self.window.setBackgroundColor(colors.white)
            end
            self.window.setCursorPos(1, i)
            self.window.write("\131")

            self.window.setTextColor(explorer.textColor)
            self.window.setBackgroundColor(self.backgroundColor)
            self.window.setCursorPos(3, i)
            self.window.write(file.name)
            self.window.setCursorPos(17, i)
            self.window.write(file.type)

            if file.type ~= "folder" then
                self.window.setCursorPos(27, i)
                self.window.write(math.ceil(file.size / 1024) .. " KB")
            end
        end
    end

    function pathFrame:draw()
        self.window.setBackgroundColor(self.backgroundColor)
        self.window.clear()
        
        for i = 2, self.height - 1 do
            self.window.setBackgroundColor(explorer.frameColor)
            self.window.setTextColor(self.backgroundColor)
            self.window.setCursorPos(1, i)
            self.window.write("\149")

            self.window.setBackgroundColor(self.backgroundColor)
            self.window.setTextColor(explorer.frameColor)
            self.window.setCursorPos(self.width, i)
            self.window.write("\149")
        end

        for i = 2, self.width - 1 do
            self.window.setBackgroundColor(self.backgroundColor)
            self.window.setTextColor(explorer.frameColor)
            self.window.setCursorPos(i, 1)
            self.window.write("\140")
            self.window.setCursorPos(i, self.height)
            self.window.write("\140")
        end

        self.window.setBackgroundColor(self.backgroundColor)
        self.window.setTextColor(explorer.frameColor)

        self.window.setCursorPos(self.width, 1)
        self.window.write("\148")
        self.window.setCursorPos(self.width, self.height)
        self.window.write("\133")
        self.window.setCursorPos(1, self.height)
        self.window.write("\138")
        self.window.setBackgroundColor(explorer.frameColor)
        self.window.setTextColor(self.backgroundColor)
        self.window.setCursorPos(1, 1)
        self.window.write("\151")

        for _, childObj in ipairs(self.child) do
            childObj:draw()
        end
    end

    function explorer:draw()
        self.window.setBackgroundColor(self.backgroundColor)
        self.window.clear()
        
        for i = 2, explorer.height - 1 do
            self.window.setBackgroundColor(self.backgroundColor)
            self.window.setTextColor(explorer.frameColor)
            self.window.setCursorPos(1, i)
            self.window.write("\149")

            self.window.setBackgroundColor(explorer.frameColor)
            self.window.setTextColor(self.backgroundColor)
            self.window.setCursorPos(self.width, i)
            self.window.write("\149")
        end

        
        for _, childObj in ipairs(self.child) do
            childObj:draw()
        end
    end


    function data:updateFiles()
        self.files = {}
        local files = fs.list(self.path)
        
        pathText.text = data.path
        footerBarText.text = "Items: " .. #files .. " Scroll: " .. data.scroll
            
        for i, file in ipairs(table.pack(table.unpack(files, 1 + self.scroll, filesTable.height + self.scroll))) do
            self.files[i] = {}
            self.files[i].name = file
            self.files[i].size = fs.getSize(self.path .. file)
            if fs.isDir(self.path .. file) then
                self.files[i].type = "folder"
            else
                self.files[i].type = "file"
            end
        end
    end

    -- Главная функция отрисовки
    local function drawExplorer(data)
        data:updateFiles()

        explorer:draw()
    end


    -- Функция, вызываемая при прокрутке колеса мыши
    local function scrollEvent(dir)
        local previousScroll = data.scroll
        local maxScroll = #fs.list(data.path) - filesTable.height
        if maxScroll < 0 then
            maxScroll = 0
        end
        
        data.scroll = data.scroll + dir * 2 - 1

        if data.scroll < 0 then
            data.scroll = 0
        end

        if data.scroll > maxScroll then
            data.scroll = maxScroll
        end
        
        if previousScroll ~= data.scroll then
            data:updateFiles()
            filesTable:draw()
            footerBar:draw()
        end
    end

    local function openFolder(folder)
        data.path = data.path .. folder .. "/"
        data.scroll = 0

        drawExplorer(data)
    end

    local function openFile(filePath)
        explorer.window.setVisible(false)
        explorer:kill()

        os.run(_ENV, "./rom/programs/edit.lua", filePath)

        explorer.window.setVisible(true)
        explorer:draw()
    end

    -- Функция, вызываемая при нажатии кнопки мыши
    local function clickEvent(button, x, y)
        if 
        button == 1 and
        (x >= filesTable.absoluteX and x <= filesTable.absoluteX + filesTable.width - 1) and
        (y >= filesTable.absoluteY and y <= filesTable.absoluteY + filesTable.height - 1)
        then
            local filePos = y - filesTable.absoluteY + 1 + data.scroll
        
            local file = fs.list(data.path)[filePos]
            
            if file then
                local filePath = data.path .. file
                if fs.isDir(filePath) then
                    openFolder(file)
                else
                    openFile(filePath)
                end
            end
        end
    end

    drawExplorer(data)

    local function mainLoop()
        while true do
            local event, a, b, c = os.pullEvent()

            if event == "mouse_scroll" then
                scrollEvent(a)
            elseif event == "mouse_click" then
                clickEvent(a, b, c)
            end
        end
    end

    explorer.mainThread = thread.create(mainLoop)
end

return {
    run = run
}