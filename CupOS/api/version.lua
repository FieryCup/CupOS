local function getOSVersion()
    local file = fs.open("./version.json", "r")
    local content = file.readAll()
    file.close()
    return textutils.unserializeJSON(content)["version"]
end

local function compare(versionA, versionB)

    if versionA == versionB then
        return 0
    end

    local versionATable = {}
    local versionBTable = {}

    for number in string.gmatch(versionA, "([^'.']+)") do
        table.insert(versionATable, tonumber(number))
    end
    for number in string.gmatch(versionB, "([^'.']+)") do
        table.insert(versionBTable, tonumber(number))
    end

    if #versionATable ~= #versionBTable then
        error("The versions have a different format")
    end

    for index, value in ipairs(versionATable) do
        if value > versionBTable[index] then
            return 1
        end
    end
    return -1
end

local function moreThan(versionA, versionB)
    if compare(versionA, versionB) == 1 then
        return true
    else
        return false
    end
end

return {
    getOSVersion = getOSVersion,
    compare = compare,
    moreThan = moreThan
}