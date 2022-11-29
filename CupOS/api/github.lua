local cc_expect = require("cc.expect")
local expect, range = cc_expect.expect, cc_expect.range

function getResponseFromURL(token, url, unserialize)
    expect(1, token, "string", "nil")
    expect(2, url, "string")
    expect(3, unserialize, "boolean", "nil")

    if unserialize == nil then
        unserialize = true
    end

    local headers = {}
    if token then
        headers = {["Authorization"] = "token " .. token}
    end

    local response = http.get(url, headers)
    local response_data = nil
    if response then
        if unserialize then
            response_data = textutils.unserializeJSON(response.readAll())
        else
            response_data = response.readAll()
        end
        response.close()
    end
    return response_data
end

function getRateLimit(token)
    expect(1, token, "string", "nil")

    return getResponseFromURL(token, "https://api.github.com/rate_limit")
end

function getTree(token, user, repository, branch)
    expect(1, token, "string", "nil")
    expect(2, user, "string")
    expect(3, repository, "string")
    expect(4, branch, "string", "nil")

    branch = branch or "main"
    
    local url = "https://api.github.com/repos/"..user.."/"..repository.."/git/trees/"..branch.."?recursive=1"

    return getResponseFromURL(token, url)
end

function getRawFile(token, user, repository, branch, path)
    expect(1, token, "string", "nil")
    expect(2, user, "string")
    expect(3, repository, "string")
    expect(4, branch, "string", "nil")
    expect(5, path, "string")

    branch = branch or "main"
    
    local url = "https://raw.githubusercontent.com/"..user.."/"..repository.."/"..branch.."/"..path

    return getResponseFromURL(token, url, false)
end

function downloadFile(token, user, repository, branch, path, installationPath)
    expect(1, token, "string", "nil")
    expect(2, user, "string")
    expect(3, repository, "string")
    expect(4, branch, "string", "nil")
    expect(5, path, "string")
    expect(6, installationPath, "string")

    branch = branch or "main"
    
    local url = "https://raw.githubusercontent.com/"..user.."/"..repository.."/"..branch.."/"..path

    local rawFile = getResponseFromURL(token, url, false)

    local file = fs.open(installationPath, "w")
    file.write(rawFile)
    file.close()
end

return {
    getResponseFromURL = getResponseFromURL,
    getRateLimit = getRateLimit,
    getTree = getTree,
    getRawFile = getRawFile
}
