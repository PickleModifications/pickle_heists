local CAMERA_VALUES = {}
CAMERA_VALUES.fov = { 10.0, 90.0 }
CAMERA_VALUES.calculatedFov = CAMERA_VALUES.fov[2]
CAMERA_VALUES.speed = { zoom = 10.0, x = 8.0, y = 8.0 }

usingCamera = false

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
    if not positionCfg then return end
    local obj = CreateProp(`prop_tennis_ball`, positionCfg.coords, positionCfg.heading, false, false)
    SetEntityVisible(obj, false, false)
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, false, false)
    local startCoords = GetOffsetFromEntityInWorldCoords(obj, 0.0, 4.0, -1.0)
    local ped = CreateNPC(GetHashKey("a_m_y_business_01"), startCoords, positionCfg.heading, false, false)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskGoStraightToCoord(ped, positionCfg.coords, 1.0, -1, positionCfg.heading, 0.0)
    SetEntityAlpha(ped, 0, false)
    SetTimeout(500, function()
        SetEntityAlpha(ped, 255, false)
    end)
    table.insert(spawnedPeds, {ped = ped, obj = obj})
end

function StartLobbyScene()
    if usingCamera then return end
    usingCamera = true
    local playerPed = PlayerPedId()
    
    CreateThread(function()
        local cameraCfg = Config.LobbyScene.camera
        local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cameraCfg.coords, cameraCfg.rotation, 30.0, true, 2)
        RenderScriptCams(true, false, 0, true, false)
        SetTimecycleModifier("fp_vig_blue")
		SetTimecycleModifierStrength(1.0)
        spawnedPeds = {}
        CreateThread(function()
            for i=1, 4 do
                AddLobbyPlayer(i)
                Wait(1000)
            end
        end)
        while usingCamera do
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
        for i=1, #spawnedPeds do
            DeleteEntity(spawnedPeds[i].ped)
            DeleteEntity(spawnedPeds[i].obj)
        end
        DeleteEntity(obj)
        ClearPedTasksImmediately(PlayerPedId())
        usingCamera = false
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

CreateThread(function()
    Wait(1000)
    StartLobbyScene()
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        usingCamera = false
        ClearTimecycleModifier("" , 4.2)
        for i=1, #spawnedPeds do
            DeleteEntity(spawnedPeds[i].ped)
            DeleteEntity(spawnedPeds[i].obj)
        end
    end
end)