-- main functions
latent_vehicles = {}
-- latent_vehicles[<vehicle>] = {
--     visibles = {<component> = bool},
--     positions = {<component> = {x, y, z, base}},
--     rotations = {<rotation> = {rx, ry, rz, base}}
-- }

function addLatentVehicle(vehicle, data)
    latent_vehicles[vehicle] = data or {}
    addEventHandler("onClientElementStreamIn", vehicle, syncLatentVehicles)
end

function syncVehicleComponentVisible(component, visible)
    if isElementStreamedIn(source) then
        setVehicleComponentVisible(source, component, visible)
    else
        if not latent_vehicles[source] then addLatentVehicle(source) end
        if not latent_vehicles[source].visibles then
            latent_vehicles[source].visibles = {}
        end
        latent_vehicles[source].visibles[component] = visible
    end
end
addEvent("server_vehicle_components:setVehicleComponentVisible", true)
addEventHandler(
    "server_vehicle_components:setVehicleComponentVisible", root,
        syncVehicleComponentVisible
)

function syncVehicleComponentPosition(component, x, y, z, base)
    if isElementStreamedIn(source) then
        setVehicleComponentPosition(source, component, x, y, z, base)
    else
        if not latent_vehicles[source] then addLatentVehicle(source) end
        if not latent_vehicles[source].positions then
            latent_vehicles[source].positions = {}
        end
        latent_vehicles[source].positions[component] = {x, y, z, base}
    end
end
addEvent("server_vehicle_components:setVehicleComponentPosition", true)
addEventHandler(
    "server_vehicle_components:setVehicleComponentPosition", root,
        syncVehicleComponentPosition
)

function syncSetVehicleComponentRotation(component, rx, ry, rz, base)
    if isElementStreamedIn(source) then
        setVehicleComponentRotation(source, component, rx, ry, rz, base)
    else
        if not latent_vehicles[source] then addLatentVehicle(source) end
        if not latent_vehicles[source].rotations then
            latent_vehicles[source].rotations = {}
        end
        latent_vehicles[source].rotations[component] = {rx, ry, rz, base}
    end
end
addEvent("server_vehicle_components:setVehicleComponentRotation", true)
addEventHandler(
    "server_vehicle_components:setVehicleComponentRotation", root,
        syncSetVehicleComponentRotation
)

-- sync functions
function sendReadyMessage()
    triggerServerEvent("server_vehicle_components:requestData", resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, sendReadyMessage)

function receiveData(vehicles)
    for vehicle, vehicle_data in pairs(vehicles) do
        if isElementStreamedIn(vehicle) then
            local visibles = vehicle_data.visibles
            for component, visible in pairs(visibles) do
                setVehicleComponentVisible(vehicle, component, visible)
            end
            local positions = vehicle_data.positions
            for component, offsets in pairs(positions) do
                setVehicleComponentPosition(vehicle, component, unpack(offsets))
            end
            local rotations = vehicle_data.rotations
            for component, angles in pairs(rotations) do
                setVehicleComponentRotation(vehicle, component, unpack(angles))
            end
        else
            addLatentVehicle(vehicle, vehicle_data)
        end
    end
end
addEvent("server_vehicle_components:sendData", true)
addEventHandler("server_vehicle_components:sendData", resourceRoot, receiveData)

function syncLatentVehicles()
    removeEventHandler("onClientElementStreamIn", source, syncLatentVehicles)

    local vehicle_data = latent_vehicles[source]
    if not vehicle_data then return end

    local visibles = vehicle_data.visibles
    if visibles then
        for component, visible in pairs(visibles) do
            setVehicleComponentVisible(source, component, visible)
        end
    end
    local positions = vehicle_data.positions
    if positions then
        for component, offsets in pairs(positions) do
            setVehicleComponentPosition(source, component, unpack(offsets))
        end
    end
    local rotations = vehicle_data.rotations
    if rotations then
        for component, angles in pairs(rotations) do
            setVehicleComponentRotation(source, component, unpack(angles))
        end
    end

    latent_vehicles[source] = nil
end

function forgetVehicle(vehicle)
    latent_vehicles[vehicle] = nil
end

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
