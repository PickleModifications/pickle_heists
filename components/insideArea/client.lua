local registeredObjectives = {}

return {
    -- Labels and parameters are handled server-side.
    events = {
        objectiveAvailable = function(id, params)
            local playerPed = PlayerPedId()
            print("Objective Available", id, params)
            registeredObjectives[id] = {
                position = params.position or vector3(0, 0, 0),
                distance = params.distance or 1.5
            }
            CreateThread(function()
                while registeredObjectives[id] do 
                    local position = registeredObjectives[id].position
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local distance = #(playerCoords - vector3(position.x, position.y, position.z))
                    if distance < registeredObjectives[id].distance then
                        RequestObjectiveCompletion(id, {distance = distance})
                        Wait(1000)
                    end
                    Wait(0)
                end
            end)
        end,
        objectiveRemoved = function(id, params)
            print("Objective Removed", id, params)
            registeredObjectives[id] = nil
        end
    }
}