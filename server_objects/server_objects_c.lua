-- main functions
local function syncSetObjectBreakable(enabled)
    setObjectBreakable(source, enabled)
end
addEvent("server_objects:setObjectBreakable", true)
addEventHandler("server_objects:setObjectBreakable", root, syncSetObjectBreakable)

local function syncSetObjectMass(value)
    setObjectMass(source, value)
end
addEvent("server_objects:setObjectMass", true)
addEventHandler("server_objects:setObjectMass", root, syncSetObjectMass)

-- sync functions
local function sendReadyMessage()
    triggerServerEvent("server_objects:requestData", resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, sendReadyMessage)

local function receiveData(breakable, new_mass)
    for object, enabled in pairs(breakable) do setObjectBreakable(object, enabled) end
    for object, value in pairs(new_mass) do setObjectMass(object, value) end
end
addEvent("server_objects:sendData", true)
addEventHandler("server_objects:sendData", resourceRoot, receiveData)
