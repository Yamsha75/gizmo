-- main functions
vehicles = {}
-- vehicles[<vehicle>] = {
--     visibles = {<component> = bool},
--     positions = {<component> = {x, y, z, base}},
--     rotations = {<rotation> = {rx, ry, rz, base}}
-- }

function setVehicleComponentVisible(vehicle, component, visible)
    if not (isElement(vehicle) and vehicle.type == "vehicle") then return false end
    if type(component) ~= "string" then return false end
    if type(visible) ~= "boolean" then return false end

    if not vehicles[vehicle] then vehicles[vehicle] = {} end
    if not vehicles[vehicle].visibles then vehicles[vehicle].visibles = {} end
    vehicles[vehicle].visibles[component] = visible
    triggerClientEvent(
        "server_vehicle_components:setVehicleComponentVisible", vehicle, component,
            visible
    )
end

-- should be isVehicleComponentVisible, but was named same as client-side equivalent
function getVehicleComponentVisible(vehicle, component)
    if not (isElement(vehicle) and vehicle.type == "vehicle") then return nil end
    if type(component) ~= "string" then return false end

    local vehicle_data = vehicles[vehicle]
    if not (vehicle_data and vehicle_data.visibles) then return nil end
    return vehicle_data.visibles[component]
end

function setVehicleComponentPosition(vehicle, component, x, y, z, base)
    if not (isElement(vehicle) and vehicle.type == "vehicle") then return false end
    if type(component) ~= "string" then return false end
    if not (tonumber(x) and tonumber(x) == x) then return false end
    if not (tonumber(y) and tonumber(y) == y) then return false end
    if not (tonumber(z) and tonumber(z) == z) then return false end
    if base == nil then base = "root" end
    if type(base) ~= "string" then return false end
    if not (base == "parent" or base == "root" or base == "world") then return false end

    if not vehicles[vehicle] then vehicles[vehicle] = {} end
    if not vehicles[vehicle].positions then vehicles[vehicle].positions = {} end
    vehicles[vehicle].positions[component] = {x, y, z, base}
    triggerClientEvent(
        "server_vehicle_components:setVehicleComponentPosition", vehicle, component, x,
            y, z, base
    )
end

function getVehicleComponentPosition(vehicle, component)
    if not (isElement(vehicle) and vehicle.type == "vehicle") then return false end
    if type(component) ~= "string" then return false end
    
    local vehicle_data = vehicles[vehicle]
    if not (vehicle_data and vehicle_data.positions) then return nil end
    local offsets = vehicle_data.positions[component]
    if not offsets then return nil end
    return unpack(offsets)
end

function setVehicleComponentRotation(vehicle, component, rx, ry, rz, base)
    if not (isElement(vehicle) and vehicle.type == "vehicle") then return false end
    if type(component) ~= "string" then return false end
    if not (tonumber(rx) and tonumber(rx) == rx) then return false end
    if not (tonumber(ry) and tonumber(ry) == ry) then return false end
    if not (tonumber(rz) and tonumber(rz) == rz) then return false end
    if base == nil then base = "root" end
    if type(base) ~= "string" then return false end
    if not (base == "parent" or base == "root" or base == "world") then return false end

    if not vehicles[vehicle] then vehicles[vehicle] = {} end
    if not vehicles[vehicle].rotations then vehicles[vehicle].rotations = {} end
    vehicles[vehicle].rotations[component] = {rx, ry, rz, base}
    triggerClientEvent(
        "server_vehicle_components:setVehicleComponentRotation", vehicle, component, rx,
            ry, rz, base
    )
end

function getVehicleComponentRotation(vehicle, component)
    if not (isElement(vehicle) and vehicle.type == "vehicle") then return false end
    if type(component) ~= "string" then return false end

    local vehicle_data = vehicles[vehicle]
    if not (vehicle_data and vehicle_data.rotations) then return nil end
    local offsets = vehicle_data.rotations[component]
    if not offsets then return nil end
    return unpack(offsets)
end

-- sync functions
clients_synced = {}

function sendData()
    if clients_synced[client] then return end
    triggerClientEvent(
        client, "server_vehicle_components:sendData", resourceRoot, vehicles
    )
    clients_synced[client] = true
end
addEvent("server_vehicle_components:requestData", true)
addEventHandler("server_vehicle_components:requestData", root, sendData)

function removeDataSentFlag()
    if isElement(source) then clients_synced[source] = nil end
end
addEventHandler("onPlayerQuit", root, removeDataSentFlag)

function forgetVehicle(vehicle)
    vehicles[vehicle] = nil
end

function forgetVehicleOnModelChange()
    if isElement(source) and source.type == "vehicle" then forgetVehicle(source) end
end
addEventHandler("onElementModelChange", root, forgetVehicle)

function forgetNonExistingVehicles()
    local checkedcount = 0
    while true do
        for vehicle, _ in pairs(vehicles) do
            if not isElement(vehicle) then forgetVehicle(vehicle) end
            checkedcount = checkedcount + 1
            if checkedcount >= 1000 then
                coroutine.yield()
                checkedcount = 0
            end
        end
        coroutine.yield()
    end
end
clearing_nonexisting_vehicles = coroutine.create(forgetNonExistingVehicles)
setTimer(
    function()
        coroutine.resume(clearing_nonexisting_vehicles)
    end, 2500, 0
)
