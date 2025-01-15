registeredObjectives = {}

function RegisterComponent(typeName, typeData)
    registeredObjectives[typeName] = typeData
end

RegisterNetEvent("pickle_heists:requestObjectiveCompletion", function(id, params)
    local source = source
    local lobbyId, playerPosition = GetPlayerCurrentLobby(source)
    if not lobbyId then return ShowNotification(source, "ERROR: NOT IN A LOBBY") end
    local lobby = Lobbies[lobbyId]
    if not lobby then return ShowNotification(source, "ERROR: LOBBY DOES NOT EXIST") end
    local componentType = lobby.stage.objectives[id].component?.type
    if not componentType then return ShowNotification(source, "ERROR: NO COMPONENT NAMED " .. componentType) end
    local component = registeredObjectives[componentType]
    if component and ((not component.events.requestCompletion) or component.events.requestCompletion(source, id, params)) then
        lobby.stage.objectives[id].completed = true
        SendLobbyRelativeEvent(lobbyId, function(target)
            TriggerClientEvent("pickle_heists:updateHeistObjective", target, lobbyId, id, lobby.stage.objectives[id], "completed")
        end)
    end
end)

CreateThread(function()
    for i=1, #Config.Components do
        local typeName = Config.Components[i]
        local data = require('components.' .. typeName .. '.server')
        RegisterComponent(typeName, data)
    end
end)