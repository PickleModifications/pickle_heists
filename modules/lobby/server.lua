Lobbies = {}

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

function GetPlayerCurrentLobby()
    local source = source
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
    local source = source
    local lobbyId, playerPosition = GetPlayerCurrentLobby()
    if not lobbyId then return ShowNotification(source, "ERROR: NOT IN A LOBBY") end
    local lobby = Lobbies[lobbyId]
    if not lobby then return ShowNotification(source, "ERROR: LOBBY DOES NOT EXIST") end
    if lobby.leader ~= source then return ShowNotification(source, _L("must_be_leader")) end
end)

RegisterNetEvent("pickle_heists:joinLobby", function(lobbyId)
    local source = source
    local lobby = Lobbies[lobbyId]
    if not lobby then return ShowNotification(source, "ERROR: LOBBY ID "..tostring(lobbyId).." DOES NOT EXIST.") end
    local playerLobby = GetPlayerCurrentLobby()
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
    SendLobbyRelativeEvent(lobbyId, function(target)
        TriggerClientEvent("pickle_heists:joinLobby", target, source, lobbyId, lobby)
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