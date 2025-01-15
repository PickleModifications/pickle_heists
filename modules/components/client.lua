local registeredComponents = {}

function RegisterComponent(typeName, typeData)
    registeredComponents[typeName] = typeData
end

function RequestObjectiveCompletion(id, params)
    TriggerServerEvent("pickle_heists:requestObjectiveCompletion", id, params)
    -- local component = registeredComponents[componentType]
    -- print("Objective Completed", id, componentType, component.events)
    -- if not component or not component.events or not component.events.objectiveRemoved then
    --     return
    -- end
    -- CurrentHeist.objectives[id].completed = true
    -- SendNUIMessage({
    --     type = "setHeistHud",
    --     heist = CurrentHeist
    -- })
    -- component.events.objectiveRemoved(id, params)
end

function StopComponentObjective(id, params)
    local componentType = CurrentHeist.objectives[id].component?.type
    if not componentType then return dprint("ERR_NO_COMPONENT_NAMED", componentType) end
    local component = registeredComponents[componentType]
    if not component or not component.events or not component.events.objectiveRemoved then
        return
    end
    component.events.objectiveRemoved(id, params)
end

function StartComponentObjective(id, params)
    if not CurrentHeist or not CurrentHeist.objectives[id] then return dprint("ERR_NO_HEIST") end
    local componentType = CurrentHeist.objectives[id].component?.type
    if not componentType then return dprint("ERR_NO_COMPONENT_NAMED", componentType) end
    local component = registeredComponents[componentType]
    if not component or not component.events or not component.events.objectiveAvailable then
        return
    end
    component.events.objectiveAvailable(id, params)
end

RegisterNetEvent("pickle_heists:updateHeistObjective", function(lobbyId, id, objective, updateType)
    if not CurrentHeist or CurrentHeist.id ~= lobbyId then return end
    CurrentHeist.objectives[id] = objective
    SendNUIMessage({
        type = "setHeistHud",
        heist = CurrentHeist
    })
    if updateType == "completed" then
        StopComponentObjective(id, objective.component.params)
    end
end)


CreateThread(function()
    for i=1, #Config.Components do
        local typeName = Config.Components[i]
        local data = require('components.' .. typeName .. '.client')
        RegisterComponent(typeName, data)
    end
end)