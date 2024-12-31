RegisterNetEvent("pickle_heists:onRestart", function()
    TriggerServerEvent("pickle_heists:initializePlayer")
end)

RegisterNetEvent("pickle_heists:initializePlayer", function(data)
    LOCAL_IDENTIFIER = data.identifier
    UpdateLobbies(data.lobbies)
    TriggerServerEvent("pickle_heists:joinLobby", 1)
end)

RegisterNUICallback("requestConfig", function(data, cb)
    cb({
        type = "setConfig",
        source = GetPlayerServerId(PlayerId()),
        locale = Language[Config.Language],
        currency = {
            name = "USD",
            locale = "en-US"
        },
    })
end)