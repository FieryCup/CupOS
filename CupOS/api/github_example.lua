local pretty = require("cc.pretty")
local github = require("CupOS.api.github")
local date = require("CupOS.api.date")

-- print("Please paste your Github token using CTRL + V")
-- local _, token = os.pullEvent("paste")

-- local data = github.getRateLimit(token)["resources"]["core"]
-- local data = github.getRawFile(token, "FieryCup", "CupOS", nil, "CupOS/desktop.lua")
-- pretty.pretty_print(data)

term.clear()

-- Имеет ограниченное кол-во запросов в час (Для уменьшения лимита стоит использовать токен)
-- local files = github.getTree(nil, "FieryCup", "CupOS")["tree"]

-- for _, file in ipairs(files) do
--     if file["type"] == "tree" then
--         term.setTextColor(colors.gray)
--     else
--         term.setTextColor(colors.white)
--     end
--     print(file["path"])
--     os.sleep(0.1)
-- end

-- Получение содержимого файла
-- local file = github.getRawFile(nil, "FieryCup", "CupOS", nil, "CupOS/api/github_example.lua")
-- print(file)

-- Скачивание файла
-- downloadFile(nil, "FieryCup", "CupOS", nil, "CupOS/api/github_example.lua", "./github_installer_test/result.txt")

local rate_limit = github.getRateLimit()["resources"]
local core_rate_limit = rate_limit["core"]
print(core_rate_limit["used"] .. " / " .. core_rate_limit["remaining"] .. " / " .. core_rate_limit["limit"])

local time = core_rate_limit["reset"]
print(date.convertDate(time).time)
print(date.convertDate(time).hours)
print(date.convertDate(time).minutes)
print(date.convertDate(time).seconds)