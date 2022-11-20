local mainThread = coroutine.running()
local filter = {}
 
local function SingleThread(_sFilter)
    return coroutine.yield(_sFilter)
end
 
local function MultiThread(_sFilter)
    if coroutine.running() == mainThread then
        local event, co
        repeat
            event = {coroutine.yield()}
            co = next(filter)
            if not co then
                os.pullEventRaw = SingleThread
            end
            while co do
                if coroutine.status(co) == "dead" then
                    filter[co], co = nil, next(filter,co)
                else
                    if filter[co] == '' or filter[co] == event[1] or event[1] == "terminate" then
                        local ok, param = coroutine.resume(co, table.unpack(event))

                        if not ok then
                            filter = {}
                            error(param)
                        else
                            filter[co] = param or ''
                        end
                    end
                    co = next(filter,co)
                end
            end
        until _sFilter == nil or _sFilter == event[1] or event[1] == "terminate"

        return table.unpack(event)
    else
        return coroutine.yield( _sFilter )
    end
end
 
function create(f, ...)
    os.pullEventRaw = MultiThread
    local co = coroutine.create(f)
    filter[co] = ''
    local ok, param = coroutine.resume(co, arg)

    if not ok then
        filter = {}
        error(param)
    else
        filter[co] = param or ''
    end

    return co
end
 
function kill(co)
    filter[co] = nil
end
 
function killAll()
    filter = {}
    os.pullEventRaw = SingleThread
end

return {
    create = create,
    kill = kill,
    killAll = killAll
}
