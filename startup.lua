
local pretty = require("cc.pretty").pretty_print

local explorer = require("CupOS/programs/explorer/main")

-- pretty(explorer)

-- local desktop = require("CupOS/desktop")

-- desktop.run()

explorer.run("./CupOS/", 1, 1, term.getSize())

-- TODO: Добавить вывод в терминал и на экран

-- TODO: Убрать костыль
-- Нужно для устранения работы ввода консоли
while true do
    os.sleep(100)
end
