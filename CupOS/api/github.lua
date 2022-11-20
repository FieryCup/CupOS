local cc_expect = require("cc.expect")
local expect, field = cc_expect.expect, cc_expect.field

function getDataFromURL(url, headers)
    expect(1, url, "string")
    expect(2, headers, "table", "nil")

    local response = http.get("https://api.github.com/rate_limit", headers)
    local response_data = textutils.unserializeJSON(response.readAll())
    response.close()
    return response_data
end

function getRateLimit(token)
    expect(1, token, "string")
    
    local headers = {["Authorization"] = "token " .. token}

    return getDataFromURL("https://api.github.com/rate_limit", headers)
end

function getRawFile(token, user, repository, branch, path)
    expect(1, token, "string")
    expect(2, user, "string")
    expect(3, repository, "string")
    expect(4, branch, "string", "nil")
    expect(5, path, "string")

    branch = branch or "main"
    
    local headers = {["Authorization"] = "token " .. token}
    local url = "https://raw.githubusercontent.com/"..user.."/"..repository.."/"..branch.."/"..path

    return getDataFromURL(url, headers)
end

return {
    getRateLimit = getRateLimit,
    getRawFile = getRawFile
}
