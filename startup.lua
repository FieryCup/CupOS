
local pretty = require("cc.pretty").pretty_print

local explorer = require("CupOS.programs.explorer.main")
local observer = require("CupOS.programs.observer.main")
local borderedWindow = require("CupOS.api.gui.borderedWindow")

local version = require("CupOS.api.version")
local image = require("CupOS.api.gui.image")

-- pretty(explorer)

-- local desktop = require("CupOS/desktop")

-- desktop.run()

-- pretty(version.getOSVersion())
-- pretty(version.compare(version.getOSVersion(), "0.0.1"))
-- pretty(version.moreThan(version.getOSVersion(), "0.0.1"))
-- pretty(version.moreThan(version.getOSVersion(), "0.0.0"))

-- os.run(_ENV, "./CupOS/api/github_example.lua")

explorer.run(nil, "./CupOS/", 1, 1, term.getSize())
-- observer.run(nil, "./CupOS/images/icons/cosif_file.cosif", 1, 1, term.getSize())

-- local framedWindow = borderedWindow.create(nil, "Example", 1, 1, 30, 15)
-- framedWindow:draw()

-- TODO: Убрать костыль
-- Нужно для устранения работы ввода консоли
-- while true do
--     os.sleep(100)
-- end

-- TODO: Создать установщик
-- TODO: Переделать Desktop
-- TODO: Добавить вывод в терминал и на экран
-- TODO: Создать программу для просмотра картинок "Observer" в отдельный репозиторий
-- TODO: Переместить "Explorer" в отдельный репозиторий
