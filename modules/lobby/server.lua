Lobbies = {}
PendingEntries = {}

function GetLobbyFromBucketId(bucketId)
    for id, lobby in pairs(Lobbies) do
        if lobby.bucketId == bucketId then
            return id
        end
    end
    return nil
end

function GenerateUniqueBucketId()
    local bucketId
    repeat
        bucketId = math.random(1, 999999)
    until not GetLobbyFromBucketId(bucketId)
    return bucketId
end

function GetPlayerCurrentLobby(source)
    for id, lobby in pairs(Lobbies) do
        for position, player in pairs(lobby.players) do
            if player.source == source then
                return id, position
            end
        end
    end
    return nil
end

function SendLobbyRelativeEvent(lobbyId, callback)
    local lobby = Lobbies[lobbyId]
    for i=1, lobby.maxPlayers do
        if lobby.players[i] then
            callback(lobby.players[i].source)
        end
    end
end

function RegisterLobby(id, data, dontSync)
    Lobbies[id] = {
        state = "lobby",
        leader = nil,
        bucketId = GenerateUniqueBucketId(),
        players = {},
        kickedPlayers = {},
        enterLocation = data.enterLocation,
        maxPlayers = data.maxPlayers,
    }
    print("Registered lobby "..tostring(id), json.encode(Lobbies[id]))
    if dontSync then return end
    -- TODO: ? Maybe not needed but sync to clients
end

RegisterNetEvent("pickle_heists:updatePlayerPercentages", function(playerPercentages) 
    print("Received player percentages", json.encode(playerPercentages))
    local source = source
    local lobbyId, playerPosition = GetPlayerCurrentLobby(source)
    if not lobbyId then return ShowNotification(source, "ERROR: NOT IN A LOBBY") end
    local lobby = Lobbies[lobbyId]
    if not lobby then return ShowNotification(source, "ERROR: LOBBY DOES NOT EXIST") end
    if lobby.leader ~= source then return ShowNotification(source, _L("must_be_leader")) end
    local remainingPercentage = 100
    for k,v in pairs(lobby.players) do
        local source = v.source
        if remainingPercentage > 0 and playerPercentages[source] then
            if playerPercentages[source] > remainingPercentage then
                playerPercentages[source] = remainingPercentage
            end
            print("Set player percentage", source, remainingPercentage, playerPercentages[v.source])
            lobby.players[k].percentage = playerPercentages[source]
            remainingPercentage = remainingPercentage - playerPercentages[source]
        else
            print("Set 0 player percentage", source, remainingPercentage, playerPercentages[v.source])
            playerPercentages[source] = 0
            lobby.players[k].percentage = 0
        end
    end
    print("Players: ", json.encode(lobby.players))
    for k,v in pairs(playerPercentages) do
        local targetLobbyId = GetPlayerCurrentLobby(tonumber(k))
        if not targetLobbyId or targetLobbyId ~= lobbyId then
            playerPercentages[k] = nil
        end
    end
    print("Updated player percentages", json.encode(playerPercentages))
    SendLobbyRelativeEvent(lobbyId, function(target)
        TriggerClientEvent("pickle_heists:updatePlayerPercentages", target, lobbyId, playerPercentages)
    end)
end)

RegisterNetEvent("pickle_heists:joinLobby", function(lobbyId)
    local source = source
    local lobby = Lobbies[lobbyId]
    if not lobby then return ShowNotification(source, "ERROR: LOBBY ID "..tostring(lobbyId).." DOES NOT EXIST.") end
    if lobby.state ~= "lobby" then return ShowNotification(source, _L("heist_already_started")) end
    local playerLobby = GetPlayerCurrentLobby(source)
    if playerLobby then return ShowNotification(source, "ERROR: ALREADY IN LOBBY "..tostring(playerLobby)) end
    local playerPosition = nil
    local playerCount = 0
    for i=1, lobby.maxPlayers do 
        if not playerPosition and not lobby.players[i] then
            lobby.players[i] = {
                source = source,
                name = GetPlayerCharacterName(source),
                identifier = GetIdentifier(source),
                percentage = 0,
            }
            SetPlayerRoutingBucket(source, lobby.bucketId)
            playerPosition = i
            playerCount = playerCount + 1
        elseif lobby.players[i] then
            playerCount = playerCount + 1
        end
    end
    if playerPosition == nil then return ShowNotification(source, "ERROR: LOBBY IS FULL") end
    if playerCount == 1 then
        lobby.leader = source
        lobby.players[playerPosition].percentage = 100
    end
    PendingEntries[source] = {
        lobbyId = lobbyId
    }
    TriggerClientEvent("pickle_heists:enterLobby", source, playerPosition)
end)

RegisterNetEvent("pickle_heists:startHeist", function(lobbyOptions)
    local source = source
    local lobbyId, playerPosition = GetPlayerCurrentLobby(source)
    if not lobbyId then return ShowNotification(source, "ERROR: NOT IN A LOBBY") end
    local lobby = Lobbies[lobbyId]
    if not lobby then return ShowNotification(source, "ERROR: LOBBY DOES NOT EXIST") end
    if lobby.leader ~= source then return ShowNotification(source, _L("must_be_leader")) end
    local percentageLeft = 100
    local playerCount = 0
    for k,v in pairs(lobby.players) do
        if percentageLeft - (v.percentage or 0) < 0 then
            percentageLeft = 0
            v.percentage = 0
        else
            percentageLeft = percentageLeft - (v.percentage or 0)
        end
        playerCount = playerCount + 1
    end
    if percentageLeft > 0 then
        for k,v in pairs(lobby.players) do
            if percentageLeft > 0 then
                v.percentage = v.percentage + math.floor(percentageLeft / playerCount)
            end
        end
    end
    local heistCfg = Config.Heists[lobbyId]
    if not heistCfg then return ShowNotification(source, "ERROR: HEIST CONFIG NOT FOUND") end
    if playerCount < heistCfg.requiredPlayers then return ShowNotification(source, "ERROR: NOT ENOUGH PLAYERS") end
    lobby.state = "active"
    ShowNotification(source, "Starting heist with "..tostring(playerCount).." players")
    SendLobbyRelativeEvent(lobbyId, function(target)
        TriggerClientEvent("pickle_heists:startHeist", target, lobbyId, lobbyOptions)
    end)
    local vehicleEntity
    local maxSeats = 1
    if lobbyOptions.vehicle then
        local vehicle = heistCfg.vehicles[lobbyOptions.vehicle]
        if not vehicle then return ShowNotification(source, "ERROR: VEHICLE NOT FOUND") end
        maxSeats = vehicle.maxSeats or 1
        vehicleEntity = CreateVehicleServerSetter(vehicle.model, "automobile", heistCfg.vehicleLocation.coords, heistCfg.vehicleLocation.heading)
        SetVehicleCustomPrimaryColour(vehicleEntity, lobbyOptions.vehicleColor.r, lobbyOptions.vehicleColor.g, lobbyOptions.vehicleColor.b)
        SetVehicleCustomSecondaryColour(vehicleEntity, lobbyOptions.vehicleColor.r, lobbyOptions.vehicleColor.g, lobbyOptions.vehicleColor.b)
        SetVehicleNumberPlateText(vehicleEntity, "HST" .. math.random(1, 9999))
    end
    SetTimeout(2500, function()
        local seatIndex = -1
        local seats = 0
        for k,v in pairs(lobby.players) do
            local ped = GetPlayerPed(v.source)
            if DoesEntityExist(ped) then
                SetPlayerRoutingBucket(v.source, 0)
                SetEntityCoords(ped, heistCfg.enterLocation.coords)
                SetEntityHeading(ped, heistCfg.enterLocation.heading)
                SetTimeout(100, function()
                    if vehicleEntity and seats < maxSeats  then
                        TaskWarpPedIntoVehicle(ped, vehicleEntity, seatIndex)
                        seatIndex = seatIndex + 1
                        seats = seats + 1
                    end
                    SetTimeout(400, function()
                        TriggerClientEvent("pickle_heists:heistStarted", v.source, lobbyId)
                    end)
                end)
            end
        end
    end)
end)

RegisterNetEvent("pickle_heists:enterLobby", function()
    local source = source
    local pendingEntry = PendingEntries[source]
    if not pendingEntry then return ShowNotification(source, "ERROR: NO PENDING ENTRY") end
    local lobbyId, position = GetPlayerCurrentLobby(source)
    if not lobbyId or not Lobbies[lobbyId] or not position then return ShowNotification(source, "ERROR: LOBBY DOES NOT EXIST") end
    local lobby = Lobbies[lobbyId]
    SendLobbyRelativeEvent(lobbyId, function(target)
        TriggerClientEvent("pickle_heists:joinLobby", target, source, lobbyId, lobby)
    end)
end)

RegisterNetEvent("pickle_heists:leaveLobby", function()
    local source = source
    local lobbyId, position = GetPlayerCurrentLobby(source)
    if not lobbyId or not Lobbies[lobbyId] or not position then return ShowNotification(source, "ERROR: LOBBY DOES NOT EXIST") end
    if Lobbies[lobbyId].leader == source then
        local foundLeader = false
        for i=1, Lobbies[lobbyId].maxPlayers do
            if Lobbies[lobbyId].players[i] then
                Lobbies[lobbyId].leader = Lobbies[lobbyId].players[i].source
                foundLeader = true
            end
        end
        if not foundLeader then
            Lobbies[lobbyId].leader = nil
            -- TODO: Clean lobby if no players
        end
    end
    SendLobbyRelativeEvent(lobbyId, function(target)
        TriggerClientEvent("pickle_heists:leaveLobby", target, source, lobbyId, Lobbies[lobbyId].leader)
    end)
    SetTimeout(2000, function()
        SetPlayerRoutingBucket(source, 0)
    end)
    Lobbies[lobbyId].players[position] = nil
end)

RegisterNetEvent("pickle_heists:kickPlayer", function(target)
    local source = source
    local target = tonumber(target)
    local lobbyId, position = GetPlayerCurrentLobby(source)
    if not lobbyId or not Lobbies[lobbyId] or not position then return ShowNotification(source, "ERROR: LOBBY DOES NOT EXIST") end
    if Lobbies[lobbyId].leader ~= source or Lobbies[lobbyId].leader == target then return ShowNotification(source, _L("must_be_leader")) end
    local targetId, targetPosition = GetPlayerCurrentLobby(target)
    if not targetId or not Lobbies[targetId] or not targetPosition then return ShowNotification(source, "ERROR: TARGET NOT IN LOBBY") end
    if targetId ~= lobbyId then return ShowNotification(source, "ERROR: TARGET NOT IN LOBBY "..tostring(lobbyId)) end
    SendLobbyRelativeEvent(lobbyId, function(targetId)
        TriggerClientEvent("pickle_heists:leaveLobby", targetId, target, lobbyId, Lobbies[lobbyId].leader)
    end)
    SetTimeout(2000, function()
        SetPlayerRoutingBucket(target, 0)
    end)
    Lobbies[lobbyId].players[targetPosition] = nil
end)

RegisterNetEvent("pickle_heists:promotePlayer", function(target)
    local source = source
    local target = tonumber(target)
    local lobbyId, position = GetPlayerCurrentLobby(source)
    if not lobbyId or not Lobbies[lobbyId] or not position then return ShowNotification(source, "ERROR: LOBBY DOES NOT EXIST") end
    if Lobbies[lobbyId].leader ~= source then return ShowNotification(source, _L("must_be_leader")) end
    local targetId, targetPosition = GetPlayerCurrentLobby(target)
    if not targetId or not Lobbies[targetId] or not targetPosition then return ShowNotification(source, "ERROR: TARGET NOT IN LOBBY") end
    if targetId ~= lobbyId then return ShowNotification(source, "ERROR: TARGET NOT IN LOBBY "..tostring(lobbyId)) end
    Lobbies[lobbyId].leader = target
    SendLobbyRelativeEvent(lobbyId, function(targetId)
        TriggerClientEvent("pickle_heists:promotePlayer", targetId, lobbyId, target)
    end)
end)

CreateThread(function()
    Wait(100)
    for i=1, #Config.Heists do 
        local heistCfg = Config.Heists[i]
        RegisterLobby(i, {
            maxPlayers = heistCfg.maxPlayers,
            enterLocation = heistCfg.enterLocation, 
        }, true)
    end
end)