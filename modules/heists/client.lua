CurrentHeist = nil

RegisterNetEvent("pickle_heists:heistStarted", function(lobbyId, lobby)
    Lobbies[lobbyId] = lobby
    local heistCfg = Config.Heists[lobbyId]
    if not Lobbies[lobbyId] or not heistCfg then return end
    CurrentHeist = {
        id = lobbyId,
        label = lobby.label,
        description = lobby.description,
        stageDescription = lobby.stage.description,
        reward = lobby.reward,
        objectives = lobby.stage.objectives,
    }
    for i=1, #CurrentHeist.objectives do
        local objective = CurrentHeist.objectives[i]
        if objective.component then
            StartComponentObjective(i, objective.component.params)
        end
    end
    SendNUIMessage({
        type = "setHeistHud",
        heist = CurrentHeist
    })
    FreezeEntityPosition(PlayerPedId(), false)
    Wait(50)
    DoScreenFadeIn(1000)
end)