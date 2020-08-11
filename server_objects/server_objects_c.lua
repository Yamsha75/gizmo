-- main functions
latent_objects = {}
-- latent_objects[<object>] = {
--     breakable = bool,
--     mass = float
-- }

function addLatentObject(object, data)
    print("latent object!")
    latent_objects[object] = data or {}
    addEventHandler("onClientElementStreamIn", object, syncLatentObject)
end

function syncSetObjectBreakable(breakable)
    if isElementStreamedIn(source) then
        setObjectBreakable(source, breakable)
    else
        if not latent_objects[source] then addLatentObject(source) end
        latent_objects[source].breakable = breakable
    end
end
addEvent("server_objects:setObjectBreakable", true)
addEventHandler("server_objects:setObjectBreakable", root, syncSetObjectBreakable)

function syncSetObjectMass(mass)
    if isElementStreamedIn(source) then
        setObjectMass(source, mass)
    else
        if not latent_objects[source] then addLatentObject(source) end
        latent_objects[source].mass = mass
    end
end
addEvent("server_objects:setObjectMass", true)
addEventHandler("server_objects:setObjectMass", root, syncSetObjectMass)

-- sync functions
function sendReadyMessage()
    triggerServerEvent("server_objects:requestData", resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, sendReadyMessage)

function receiveData(objects)
    for object, object_data in pairs(objects) do
        if isElementStreamedIn(object) then
            local breakable = object_data.breakable
            if breakable then setObjectBreakable(object, breakable) end
            local mass = object_data.mass
            if mass then setObjectMass(object, mass) end
        else
            addLatentObject(object, object_data)
        end
    end
end
addEvent("server_objects:sendData", true)
addEventHandler("server_objects:sendData", resourceRoot, receiveData)

function syncLatentObject()
    print("syncing latent object!")
    removeEventHandler("onClientElementStreamIn", source, syncLatentObject)

    local object_data = latent_objects[source]
    if not object_data then return end

    local breakable = object_data.breakable
    if breakable ~= nil then setObjectBreakable(source, breakable) end
    local mass = object_data.mass
    if mass then setObjectMass(source, mass) end

    forgetObject(source)
end

function forgetObject(object)
    latent_objects[object] = nil
end

function forgetNonExistingObjects()
    local checkedcount = 0
    while true do
        for object, _ in pairs(latent_objects) do
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
