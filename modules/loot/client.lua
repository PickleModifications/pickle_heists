local bag

-- function LoadAnim(dict)
--     while not HasAnimDictLoaded(dict) do
--         RequestAnimDict(dict)
--         Citizen.Wait(5)
--     end
-- end

-- function StartGrab()
--     local ped = PlayerPedId()
--     local playerPed = PlayerPedId()
--     local model = "hei_prop_heist_cash_pile"
--     local emptyobj = GetHashKey("ch_prop_gold_trolly_01c_empty")

--     local baghash = GetHashKey("hei_p_m_bag_var22_arm_s")

--     RequestAnimDict("anim@heists@ornate_bank@grab_cash")
--     RequestModel(baghash)
--     RequestModel(emptyobj)
--     while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") and not HasModelLoaded(emptyobj) and not HasModelLoaded(baghash) do
--         Citizen.Wait(0)
--     end
-- 	local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), GetEntityCoords(PlayerPedId()), true, false, false)
--     local scene1 = NetworkCreateSynchronisedScene(GetEntityCoords(playerPed), GetEntityRotation(playerPed), 2, false, false, 1065353216, 0, 1.3)
-- 	NetworkAddPedToSynchronisedScene(ped, scene1, "anim@heists@ornate_bank@grab_cash", "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
--     NetworkAddEntityToSynchronisedScene(bag, scene1, "anim@heists@ornate_bank@grab_cash", "bag_intro", 4.0, -8.0, 1)
--     --SetPedComponentVariation(ped, 5, 0, 0, 0)
-- 	NetworkStartSynchronisedScene(scene1)
-- 	Citizen.Wait(1500)

-- 	local scene2 = NetworkCreateSynchronisedScene(GetEntityCoords(playerPed), GetEntityRotation(playerPed), 2, false, false, 1065353216, 0, 1.3)
-- 	NetworkAddPedToSynchronisedScene(ped, scene2, "anim@heists@ornate_bank@grab_cash", "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
-- 	NetworkAddEntityToSynchronisedScene(bag, scene2, "anim@heists@ornate_bank@grab_cash", "bag_grab", 4.0, -8.0, 1)
-- 	NetworkStartSynchronisedScene(scene2)
-- 	Citizen.Wait(37000)

-- 	local scene3 = NetworkCreateSynchronisedScene(GetEntityCoords(playerPed), GetEntityRotation(playerPed), 2, false, false, 1065353216, 0, 1.3)
-- 	NetworkAddPedToSynchronisedScene(ped, scene3, "anim@heists@ornate_bank@grab_cash", "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
-- 	NetworkAddEntityToSynchronisedScene(bag, scene3, "anim@heists@ornate_bank@grab_cash", "bag_exit", 4.0, -8.0, 1)
-- 	NetworkStartSynchronisedScene(scene3)

--     Citizen.Wait(1800)
--     if DoesEntityExist(bag) then
--         DeleteEntity(bag)
--     end

--     --SetPedComponentVariation(ped, 5, 45, 0, 0)
-- 	RemoveAnimDict("anim@heists@ornate_bank@grab_cash")
-- 	SetModelAsNoLongerNeeded(emptyobj)
--     SetModelAsNoLongerNeeded(GetHashKey("hei_p_m_bag_var22_arm_s"))
-- end

CreateThread(function()
    Wait(1000)
    -- StartGrab()
    local bagComponentId = 45
    local playerPed = PlayerPedId()
    SetPedComponentVariation(playerPed, 5, bagComponentId, 0, 0)
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if bag then
            DeleteEntity(bag)
        end
    end
end)