AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        SetTimeout(1000, function()
            TriggerClientEvent("pickle_heists:onRestart", -1)
        end)
    end
end)

RegisterNetEvent("pickle_heists:initializePlayer", function()
    local source = source
    TriggerClientEvent("pickle_heists:initializePlayer", source, {
        identifier = GetIdentifier(source),
        lobbies = Lobbies,
    })
end)