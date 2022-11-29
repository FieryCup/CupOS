local cc_expect = require("cc.expect")
local expect, field = cc_expect.expect, cc_expect.field
local pretty = require("cc.pretty")

function convertDate(number)
    expect(1, number, "number", "string")
    
    local raw_date = os.date(_, tostring(number):sub(1, 10))

    local date = {}
    for i in string.gmatch(raw_date, "([^%s]+)") do
        table.insert(date, i)
    end

    local raw_time = {}
    for i in string.gmatch(date[4], "([^:]+)") do
        table.insert(raw_time, i)
    end

    local result = {}
    result.weekday = date[1]
    result.month = date[2]
    result.day = date[3]
    result.time = date[4]
    result.hours = raw_time[1]
    result.minutes = raw_time[2]
    result.seconds = raw_time[3]

    result.year = date[5]

    return result
end

return {
    convertDate = convertDate
}