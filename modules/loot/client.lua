local tempEntities = {}

function CreateLootInteraction()
    local coords = vector3(275.4330, -1373.5399, 30.9341)
    local heading = 56.2692
    local model = `xm_prop_x17_bag_01c`
    local prop = CreateProp(model, coords, false, false, false)
    tempEntities.bag = prop
    local lootInfo = {
        
    }
end

CreateThread(function()
    Wait(100)    
    CreateLootInteraction()
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(tempEntities) do
            DeleteEntity(v)
        end
    end
end)