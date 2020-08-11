-- main functions
local breakable = {}
local new_mass = {}

function setObjectBreakable(object, enabled)
    if getElementType(object) ~= "object" then return false end
    breakable[object] = enabled
    triggerClientEvent("server_objects:setObjectBreakable", object, enabled)
end

function setObjectMass(object, value)
    if getElementType(object) ~= "object" then return false end
    new_mass[object] = value
    triggerClientEvent("server_objects:setObjectMass", object, value)
end

-- sync functions
local clients_synced = {}

local function sendData()
    if clients_synced[client] then return end
    triggerClientEvent(client, "server_objects:sendData", root, breakable, new_mass)
    clients_synced[client] = true
end
addEvent("server_objects:requestData", true)
addEventHandler("server_objects:requestData", root, sendData)

local function removeDataSentFlag()
    if isElement(source) then clients_synced[source] = nil end
end
addEventHandler("onPlayerQuit", root, removeDataSentFlag)

local function forgetDestroyedObject()
    if isElement(source) and getElementType(source) == "object" then
        breakable[source] = nil
        new_mass[source] = nil
    end
end
addEventHandler("onElementDestroy", root, forgetDestroyedObject)
