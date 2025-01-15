local CAMERA_VALUES = {}
CAMERA_VALUES.fov = { 10.0, 90.0 }
CAMERA_VALUES.calculatedFov = CAMERA_VALUES.fov[2]
CAMERA_VALUES.speed = { zoom = 10.0, x = 8.0, y = 8.0 }

LocalLobbies = {}
CurrentLobby = nil

local function HideHUD()
    local hiddenComponents = {1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 15, 18, 19}
    for i=1, #hiddenComponents do
        HideHudComponentThisFrame(hiddenComponents[i])
    end
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
end

function CameraControls(cam, zoom)
    local playerPed = PlayerPedId()
    local rightAxis = {x = GetDisabledControlNormal(0, 220), y = GetDisabledControlNormal(0, 221)}
    local rotation = GetCamRot(cam, 2)
    if IsControlJustPressed(0, IsPedSittingInAnyVehicle(playerPed) and 17 or 241) then
        CAMERA_VALUES.calculatedFov = math.max(CAMERA_VALUES.calculatedFov - CAMERA_VALUES.speed.zoom, CAMERA_VALUES.fov[1])
    end
    if IsControlJustPressed(0, IsPedSittingInAnyVehicle(playerPed) and 16 or 242) then
        CAMERA_VALUES.calculatedFov = math.min(CAMERA_VALUES.calculatedFov + CAMERA_VALUES.speed.zoom, CAMERA_VALUES.fov[2])
    end
    local current_fov = GetCamFov(cam)
    if math.abs(CAMERA_VALUES.calculatedFov-current_fov) < 0.1 then
        CAMERA_VALUES.calculatedFov = current_fov
    end
    SetCamFov(cam, current_fov + (CAMERA_VALUES.calculatedFov - current_fov)*0.05)
    SetEntityHeading(playerPed, rotation.z)
    if rightAxis.x ~= 0.0 or rightAxis.y ~= 0.0 then
        local new_z = rotation.z + rightAxis.x*-1.0*(CAMERA_VALUES.speed.y)*(zoom+0.1)
        local new_x = math.max(math.min(20.0, rotation.x + rightAxis.y*-1.0*(CAMERA_VALUES.speed.x)*(zoom+0.1)), -89.5)
        SetCamRot(cam, new_x, 0.0, new_z, 2)
    end
end

function AddLobbyPlayer(position)
    if not CurrentLobby or CurrentLobby.playerPositions[position] then return end
    local positionCfg = Config.LobbyScene.playerPositions[position]
    if not positionCfg or not CurrentLobby then return end
    local lobby = Lobbies[CurrentLobby.id]
    if not lobby then return end
    local positionInfo = lobby.players[position]
    if not positionInfo then return end
    local player = GetPlayerFromServerId(positionInfo.source)
    if player == -1 then return end
    local obj = CreateProp(`prop_tennis_ball`, positionCfg.coords, positionCfg.heading, false, false)
    SetEntityVisible(obj, false, false)
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, false, false)
    local startCoords = GetOffsetFromEntityInWorldCoords(obj, 0.0, 4.0, -1.0)
    local ped = ClonePed(GetPlayerPed(player), false, false, true)
    SetEntityCoords(ped, startCoords)
    SetEntityHeading(ped, positionCfg.heading)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskGoStraightToCoord(ped, positionCfg.coords, 1.0, -1, positionCfg.heading, 0.0)
    SetEntityAlpha(ped, 0, false)
    SetTimeout(500, function()
        SetEntityAlpha(ped, 255, false)
        local found, x, y = GetScreenCoordFromWorldCoord(positionCfg.coords.x, positionCfg.coords.y, positionCfg.coords.z)
        CurrentLobby.players[positionInfo.source] = {
            source = positionInfo.source,
            name = positionInfo.name,
            identifier = positionInfo.identifier,
            position = {
                x = x - (positionCfg.interactOffset?.x or 0),
                y = y - (positionCfg.interactOffset?.y or 0),
            },
            percentage = positionInfo.percentage or 0,
        }
        print("Adding player to lobby", json.encode(CurrentLobby.players))
        SendNUIMessage({
            type = "setLobby",
            lobby = CurrentLobby,
        })
    end)
    SetTimeout(3000, function()
        if CurrentLobby and CurrentLobby.playerPositions[position] then
            FreezeEntityPosition(ped, true)
        end
    end)
    CurrentLobby.playerPositions[position] = { ped = ped, obj = obj }
end

function RemoveLobbyPlayer(position, source)
    if not CurrentLobby or not CurrentLobby.playerPositions[position] then return end
    local lobby = Lobbies[CurrentLobby.id]
    if not lobby then return end
    local ped = CurrentLobby.playerPositions[position].ped
    if not DoesEntityExist(ped) then return end
    local positionCfg = Config.LobbyScene.playerPositions[position]
    local obj = CurrentLobby.playerPositions[position].obj
    local startCoords = GetOffsetFromEntityInWorldCoords(obj, 0.0, 20.0, -1.0)
    DeleteEntity(obj)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, false)
    TaskGoStraightToCoord(ped, startCoords, 1.0, -1, positionCfg.heading + 180.0, 0.0)
    if not (source == GetPlayerServerId(PlayerId())) then
        CurrentLobby.playerPositions[position] = nil
        CurrentLobby.players[source] = nil
        print("Removing player from lobby", json.encode(CurrentLobby.players))
        SendNUIMessage({
            type = "setLobby",
            lobby = CurrentLobby,
        })
    end
    CreateThread(function()
        Wait(10000)
        DeleteEntity(ped)
    end)
end

function IsPlayerLobbyLeader(lobbyId)
    local lobby = Lobbies[lobbyId]
    if not lobby or lobby.leader == nil then return false end
    return lobby.leader == GetPlayerServerId(PlayerId())
end

function ConvertLobbyPlayers(players, convertType)
    if not convertType or convertType == "source" then
        local newPlayers = {}
        for k,v in pairs(players) do
            newPlayers[v.source] = v
            newPlayers[v.source].slot = k
        end
        return newPlayers
    elseif convertType == "percentage" then
        local newPlayers = {}
        for k,v in pairs(players) do
            newPlayers[v.source] = v.percentage
        end
        return newPlayers
    end
end

function GetPlayerLobbySlot(lobbyId, source)
    local lobby = Lobbies[lobbyId]
    if not lobby then return end
    for k,v in pairs(lobby.players) do
        if v.source == source then
            return k
        end
    end
end

function StartLobbyScene(lobbyId)
    DoScreenFadeIn(1000)
    local lobby = Lobbies[lobbyId]
    local heistCfg = Config.Heists[lobbyId]
    if CurrentLobby or not lobby or not heistCfg then return end
    local position
    for k,v in pairs(lobby.players) do
        if v.source == GetPlayerServerId(PlayerId()) then
            position = k
            break
        end
    end
    if not position then return end
    local positionCfg = Config.LobbyScene.playerPositions[position]
    SetEntityCoords(PlayerPedId(), positionCfg.coords - vector3(0.0, 0.0, 3.0))
    SetEntityHeading(PlayerPedId(), positionCfg.heading)
    FreezeEntityPosition(PlayerPedId(), true)
    local playerPed = PlayerPedId()
    CurrentLobby = {
        id = lobbyId,
        isLeader = IsPlayerLobbyLeader(lobbyId),
        heistInfo = {
            label = heistCfg.label,
            description = heistCfg.description,
            reward = heistCfg.reward,
        },
        players = ConvertLobbyPlayers(lobby.players),
        playerPositions = {},
        playerTargets = {},
        vehicles = Config.Heists[lobbyId].vehicles,
    }
    SendNUIMessage({
        type = "setLobby",
        lobby = CurrentLobby,
    })
    CurrentLobby.playerPercentages = nil
    SetNuiFocus(true, true)
    CreateThread(function()
        local cameraCfg = Config.LobbyScene.camera
        local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cameraCfg.coords, cameraCfg.rotation, cameraCfg.fov, true, 2)
        CurrentLobby.cam = cam
        RenderScriptCams(true, false, 0, true, false)
        SetTimecycleModifier("fp_vig_blue")
		SetTimecycleModifierStrength(1.0)
        CreateThread(function()
            Wait(100)
            for k,v in pairs(lobby.players) do
                AddLobbyPlayer(k)
            end
        end)
        while CurrentLobby do
            HideHUD()
            DisableControlAction(0, 30, true)  -- Disable move left/right
            DisableControlAction(0, 31, true)  -- Disable move up/down
            DisableControlAction(0, 21, true)  -- Disable sprint
            DisableControlAction(0, 22, true)  -- Disable jump
            DisableControlAction(0, 24, true)  -- Disable attack
            DisableControlAction(0, 25, true)  -- Disable aim
            DisableControlAction(0, 37, true)  -- Disable weapon select
            DisableControlAction(0, 44, true)  -- Disable cover
            DisableControlAction(0, 140, true) -- Disable melee attack light
            DisableControlAction(0, 141, true) -- Disable melee attack heavy
            DisableControlAction(0, 142, true) -- Disable melee attack alternate
            DisableControlAction(0, 143, true) -- Disable melee block
            Wait(0)
        end
        ClearTimecycleModifier("" , 4.2)
        DeleteEntity(obj)
        ClearPedTasksImmediately(PlayerPedId())
        cameraState = nil
        SendNUIMessage({
            type = "setCameraState",
            cameraState = cameraState,
        })
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(cam, false)
        CAMERA_VALUES.calculatedFov = CAMERA_VALUES.fov[2]
    end)
end

function DisplayLobbyVehicle()
    if not CurrentLobby.currentVehicle then return end
    if CurrentLobby.vehicle then
        DeleteEntity(CurrentLobby.vehicle)
    end
    local vehicleInfo = CurrentLobby.vehicles[CurrentLobby.currentVehicle]
    local vehiclePositionCfg = Config.LobbyScene.vehiclePosition
    local vehicle = CreateVeh(vehicleInfo.model, vehiclePositionCfg.coords, vehiclePositionCfg.heading, true, false)
    if not CurrentLobby.vehicleColor then
        CurrentLobby.vehicleColor = { r = 0, g = 0, b = 0 }
    end
    local color = CurrentLobby.vehicleColor
    SetVehicleCustomPrimaryColour(vehicle, color.r, color.g, color.b)
    SetVehicleCustomSecondaryColour(vehicle, color.r, color.g, color.b)
    FreezeEntityPosition(vehicle, true)
    SetEntityCollision(vehicle, false, false)
    CurrentLobby.vehicle = vehicle
end

function UpdateLobbies(lobbies)
    Lobbies = lobbies
    for k,v in pairs(LocalLobbies) do 
        if not lobbies[k] then
            DeleteInteraction(LocalLobbies[k].interact)
            LocalLobbies[k] = nil
        end
    end
    for k,v in pairs(lobbies) do
        if not LocalLobbies[k] then
            LocalLobbies[k] = {
                interact = CreateInteraction({
                    label = Config.Heists[k].label,
                    coords = Config.Heists[k].enterLocation.coords + vector3(0.0, 0.0, 1.0),
                }, function()
                    TriggerServerEvent("pickle_heists:joinLobby", k)
                end),
            }
        end
    end

    -- TODO: Create interacts for lobbies
end

RegisterNetEvent("pickle_heists:enterLobby", function(position) 
    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    local positionCfg = Config.LobbyScene.playerPositions[position]
    SetEntityCoords(PlayerPedId(), positionCfg.coords - vector3(0.0, 0.0, 3.0))
    SetEntityHeading(PlayerPedId(), positionCfg.heading)
    TriggerServerEvent("pickle_heists:enterLobby")
end)

RegisterNetEvent("pickle_heists:joinLobby", function(target, lobbyId, lobby)
    Lobbies[lobbyId] = lobby
    local source = GetPlayerServerId(PlayerId())
    if not CurrentLobby and source == target then
        local slot = GetPlayerLobbySlot(lobbyId, target)
        StartLobbyScene(lobbyId)
    elseif source ~= target then
        local slot = GetPlayerLobbySlot(lobbyId, target)
        if not slot then return end
        AddLobbyPlayer(slot)
    end
end)

RegisterNetEvent("pickle_heists:leaveLobby", function(target, lobbyId, newLeader)
    local source = GetPlayerServerId(PlayerId())
    if source == target then
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "setLobby",
            lobby = nil,
        })
        CreateThread(function()
            DoScreenFadeOut(2000)
            Wait(2050)
            for k,v in pairs(CurrentLobby.playerPositions or {}) do
                DeleteEntity(v.ped)
                DeleteEntity(v.obj)
            end
            local enterLocation = Config.Heists[lobbyId].enterLocation
            SetEntityCoords(PlayerPedId(), enterLocation.coords)
            SetEntityHeading(PlayerPedId(), enterLocation.heading)
            FreezeEntityPosition(PlayerPedId(), false)
            Wait(50)
            DoScreenFadeIn(1000)
            CurrentLobby = nil
        end)
    end
    if Lobbies[lobbyId] then
        local slot = GetPlayerLobbySlot(lobbyId, target)
        if slot then
            RemoveLobbyPlayer(slot, Lobbies[lobbyId].players[slot].source)
            Lobbies[lobbyId].players[slot] = nil
        end
        if source ~= target then
            Lobbies[lobbyId].leader = newLeader
            CurrentLobby.isLeader = IsPlayerLobbyLeader(lobbyId)
            SendNUIMessage({
                type = "setLobby",
                lobby = CurrentLobby,
            })
        end
    end
end)

RegisterNetEvent("pickle_heists:promotePlayer", function(lobbyId, newLeader)
    if CurrentLobby and CurrentLobby.id == lobbyId then
        Lobbies[lobbyId].leader = newLeader
        CurrentLobby.isLeader = IsPlayerLobbyLeader(lobbyId)
        SendNUIMessage({
            type = "setLobby",
            lobby = CurrentLobby,
        })
    end
end)

RegisterNetEvent("pickle_heists:updatePlayerPercentages", function(lobbyId, playerPercentages)
    if not CurrentLobby or CurrentLobby.id ~= lobbyId then return end
    for k,v in pairs(CurrentLobby.players) do
        if playerPercentages[v.source] then
            v.percentage = playerPercentages[v.source]
        end
    end
    SendNUIMessage({
        type = "setLobby",
        lobby = CurrentLobby,
    })
end)

RegisterNetEvent("pickle_heists:startHeist", function(lobbyId, lobbyOptions)
    if not CurrentLobby or CurrentLobby.id ~= lobbyId then return end
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "setLobby",
        lobby = nil,
    })
    DoScreenFadeOut(2000)
    Wait(2050)
    for k,v in pairs(CurrentLobby.playerPositions or {}) do
        DeleteEntity(v.ped)
        DeleteEntity(v.obj)
    end
    CurrentLobby = nil
end)

RegisterNUICallback("setSection", function(sectionId, cb)
    local camTransitionTime = 1000
    if sectionId == "main" then
        SetCamParams(CurrentLobby.cam, Config.LobbyScene.camera.coords.x, Config.LobbyScene.camera.coords.y, Config.LobbyScene.camera.coords.z, Config.LobbyScene.camera.rotation.x, Config.LobbyScene.camera.rotation.y, Config.LobbyScene.camera.rotation.z, Config.LobbyScene.camera.fov, camTransitionTime, 1, 3, 1)
    elseif sectionId == "vehicle" then
        local vehicleCameraCfg = Config.LobbyScene.vehicleCamera
        SetCamParams(CurrentLobby.cam, vehicleCameraCfg.coords.x, vehicleCameraCfg.coords.y, vehicleCameraCfg.coords.z, vehicleCameraCfg.rotation.x, vehicleCameraCfg.rotation.y, vehicleCameraCfg.rotation.z, vehicleCameraCfg.fov, camTransitionTime, 1, 3, 1)
        if not CurrentLobby.currentVehicle then
            CurrentLobby.currentVehicle = 1
            DisplayLobbyVehicle()
        end
    end
    cb("ok")
end)

RegisterNUICallback("setVehicle", function(vehicleId, cb)
    CurrentLobby.currentVehicle = vehicleId
    DisplayLobbyVehicle()
    cb("ok")
end)

RegisterNUICallback("setVehicleColor", function(color, cb)
    if not CurrentLobby.vehicle then return end
    CurrentLobby.vehicleColor = color
    SetVehicleCustomPrimaryColour(CurrentLobby.vehicle, color.r, color.g, color.b)
    SetVehicleCustomSecondaryColour(CurrentLobby.vehicle, color.r, color.g, color.b)
    cb("ok")
end)

RegisterNUICallback("updatePlayerPercentages", function(data, cb)
    local percentages = {}
    for k, v in pairs(data) do
        percentages[v.source] = v.percentage or 0
    end
    TriggerServerEvent("pickle_heists:updatePlayerPercentages", percentages)
    cb("ok")
end)

RegisterNUICallback("startHeist", function(data, cb)
    TriggerServerEvent("pickle_heists:startHeist", {
        vehicle = CurrentLobby.currentVehicle,
        vehicleColor = CurrentLobby.vehicleColor,
    })
    cb("ok")
end)

RegisterNUICallback("leaveHeist", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "setLobby",
        lobby = nil,
    })
    TriggerServerEvent("pickle_heists:leaveLobby")
    cb("ok")
end)

RegisterNUICallback("kickPlayer", function(data, cb)
    TriggerServerEvent("pickle_heists:kickPlayer", data)
    cb("ok")
end)

RegisterNUICallback("promotePlayer", function(data, cb)
    TriggerServerEvent("pickle_heists:promotePlayer", data)
    cb("ok")
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if (CurrentLobby) then
            if (CurrentLobby.vehicle) then
                DeleteEntity(CurrentLobby.vehicle)
            end
            for k,v in pairs(CurrentLobby.playerPositions or {}) do
                DeleteEntity(v.ped)
                DeleteEntity(v.obj)
            end
        end
        CurrentLobby = nil
        ClearTimecycleModifier("" , 4.2)
    end
end)