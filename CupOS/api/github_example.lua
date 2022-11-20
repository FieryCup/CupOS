local pretty = require("cc.pretty")
local github = require("github")

print("Please paste your Github token using CTRL + V")
local _, token = os.pullEvent("paste")

local data = github.getRateLimit(token)["resources"]["core"]
-- local data = github.getRawFile(token, "FieryCup", "CupOS", nil, "CupOS/desktop.lua")
pretty.pretty_print(data)