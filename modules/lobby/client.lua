local CAMERA_VALUES = {}
CAMERA_VALUES.fov = { 10.0, 90.0 }
CAMERA_VALUES.calculatedFov = CAMERA_VALUES.fov[2]
CAMERA_VALUES.speed = { zoom = 10.0, x = 8.0, y = 8.0 }

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
    local positionCfg = Config.LobbyScene.playerPositions[position]
    if not positionCfg or not CurrentLobby then return end
    local lobby = Lobbies[CurrentLobby.id]
    if not lobby then return end
    local positionInfo = lobby.players[position]
    local obj = CreateProp(`prop_tennis_ball`, positionCfg.coords, positionCfg.heading, false, false)
    SetEntityVisible(obj, false, false)
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, false, false)
    local startCoords = GetOffsetFromEntityInWorldCoords(obj, 0.0, 4.0, -1.0)
    local ped = ClonePed(GetPlayerPed(GetPlayerFromServerId(positionInfo.source)), false, false, true)
    SetEntityCoords(ped, startCoords)
    SetEntityHeading(ped, positionCfg.heading)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskGoStraightToCoord(ped, positionCfg.coords, 1.0, -1, positionCfg.heading, 0.0)
    SetEntityAlpha(ped, 0, false)
    SetTimeout(500, function()
        SetEntityAlpha(ped, 255, false)
    end)
    local found, x, y = GetScreenCoordFromWorldCoord(positionCfg.coords.x, positionCfg.coords.y, positionCfg.coords.z)
    CurrentLobby.players[position] = {
        source = positionInfo.source,
        name = positionInfo.name,
        identifier = positionInfo.identifier,
        position = {
            x = x - (positionCfg.interactOffset?.x or 0),
            y = y - (positionCfg.interactOffset?.y or 0),
        }
    }
    print("Player "..position.." added to lobby")
    SendNUIMessage({
        type = "setLobby",
        lobby = CurrentLobby,
    })
    CurrentLobby.playerPositions[position] = { ped = ped }
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
            newPlayers[v.source] = {
                slot = k,
                source = v.source,
                name = v.name,
                identifier = v.identifier,
            }
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
        playerPercentages = ConvertLobbyPlayers(lobby.players, "percentage"),
        playerPositions = {},
        playerTargets = {},
        vehicles = {
            { model = `kuruma`, name = "Karin Kuruma", description = "A heavily armored sports car that is perfect for heists. It can take a lot of damage and has plenty of firepower to help you get out of sticky situations.", price = 50000 },
            { model = `dominator`, name = "Vapid Dominator", description = "A classic muscle car that is fast, powerful, and stylish. It is perfect for making a quick getaway after a heist.", price = 30000 },
        }
    }
    SendNUIMessage({
        type = "setLobby",
        lobby = CurrentLobby,
    })
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
        CurrentLobby = nil
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
    FreezeEntityPosition(vehicle, true)
    SetEntityCollision(vehicle, false, false)
    CurrentLobby.vehicle = vehicle
    print("Vehicle added to lobby", vehicle)
end

function UpdateLobbies(lobbies)
    Lobbies = lobbies
    -- TODO: Create interacts for lobbies
end

RegisterNetEvent("pickle_heists:joinLobby", function(target, lobbyId, lobby)
    Lobbies[lobbyId] = lobby
    local source = GetPlayerServerId(PlayerId())
    if target == source and not CurrentLobby then
        StartLobbyScene(lobbyId)
    else
        local slot = GetPlayerLobbySlot(lobbyId, target)
        if not slot then return end
        AddLobbyPlayer(slot)
    end
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
    SetVehicleCustomPrimaryColour(CurrentLobby.vehicle, color.r, color.g, color.b)
    SetVehicleCustomSecondaryColour(CurrentLobby.vehicle, color.r, color.g, color.b)
    cb("ok")
end)

RegisterNUICallback("updatePlayerPercentages", function(data, cb)
    TriggerServerEvent("pickle_heists:updatePlayerPercentages", data)
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
            end
        end
        CurrentLobby = nil
        ClearTimecycleModifier("" , 4.2)
    end
end)