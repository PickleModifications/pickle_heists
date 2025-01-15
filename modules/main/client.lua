function GetHUDPosition()
    local kvp = GetResourceKvpString("pickle_heists:position")
    if not kvp or kvp == "" then
        return { x = Config.DefaultPosition.x, y = Config.DefaultPosition.y }
    else
        local data = json.decode(kvp)
        return { x = data.x, y = data.y }
    end
end

function SetHUDPosition(x, y)
    SetResourceKvpString("pickle_heists:position", json.encode({ x = x, y = y }))
end

RegisterNetEvent("pickle_heists:onRestart", function()
    TriggerServerEvent("pickle_heists:initializePlayer")
end)

RegisterNetEvent("pickle_heists:initializePlayer", function(data)
    LOCAL_IDENTIFIER = data.identifier
    UpdateLobbies(data.lobbies)
    -- TriggerServerEvent("pickle_heists:joinLobby", 1)
end)

RegisterNUICallback("updatePosition", function(data, cb)
    SetResourceKvp("pickle_heists:position", json.encode(data))
    cb(true)
end)

RegisterNUICallback("requestConfig", function(data, cb)
    cb({
        type = "setConfig",
        source = GetPlayerServerId(PlayerId()),
        position = GetHUDPosition(),
        locale = Language[Config.Language],
        currency = {
            name = "USD",
            locale = "en-US"
        },
    })
    SetTimeout(1000, function()
        TriggerServerEvent("pickle_heists:startHeist")
    end)
end)