-- main functions
objects = {}
-- objects[<object>] = {
--     breakable = bool,
--     mass = float
-- }

function setObjectBreakable(object, breakable)
    if not (isElement(object) and getElementType(object) == "object") then
        return false
    end
    if type(breakable) ~= "boolean" then return false end

    if not objects[object] then objects[object] = {} end
    objects[object].breakable = breakable
    triggerClientEvent("server_objects:setObjectBreakable", object, breakable)
    return true
end

function isObjectBreakable(object)
    if not (isElement(object) and getElementType(object) == "object") then
        return nil
    end
    local object_data = objects[object]
    if not object_data then return nil end
    return object_data.breakable
end

function setObjectMass(object, mass)
    if not (isElement(object) and getElementType(object) == "object") then
        return false
    end
    if not (tonumber(mass) and tonumber(mass) == mass) then return false end
    if mass < 0 then return false end

    if not objects[object] then objects[object] = {} end
    objects[object].mass = mass
    triggerClientEvent("server_objects:setObjectMass", object, mass)
    return true
end

function getObjectMass(object)
    if not (isElement(object) and getElementType(object) == "object") then
        return false
    end
    local object_data = objects[object]
    if not object_data then return nil end
    return object_data.mass
end

-- sync functions
clients_synced = {}

function sendData()
    if clients_synced[client] then return end
    triggerClientEvent(client, "server_objects:sendData", root, objects)
    clients_synced[client] = true
end
addEvent("server_objects:requestData", true)
addEventHandler("server_objects:requestData", root, sendData)

function removeDataSentFlag()
    if isElement(source) then clients_synced[source] = nil end
end
addEventHandler("onPlayerQuit", root, removeDataSentFlag)

function forgetObject(object)
    objects[object] = nil
end

function forgetNonExistingObjects()
    local checkedcount = 0
    while true do
        for object, _ in pairs(objects) do
            if not isElement(object) then forgetObject(object) end
            checkedcount = checkedcount + 1
            if checkedcount >= 1000 then
                coroutine.yield()
                checkedcount = 0
            end
        end
        coroutine.yield()
    end
end
clearing_nonexisting_objects = coroutine.create(forgetNonExistingObjects)
setTimer(
    function()
        coroutine.resume(clearing_nonexisting_objects)
    end, 2500, 0
)
