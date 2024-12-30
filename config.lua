Config = {}

Config.Debug = true

Config.Language = "en" -- Language to use.

Config.RenderDistance = 20.0 -- Scenario display Radius.

Config.InteractDistance = 1.5 -- Interact Radius

Config.UseTarget = true -- When set to true, it'll use targeting instead of key-presses to interact.

Config.NoModelTargeting = true -- When set to true and using Target, it'll spawn a small invisible prop so you can third-eye when no entity is defined.

Config.InventoryLimit = false -- If using ESX 1.1, this must be on if using a limit-based inventory.

Config.LobbyScene = {
    camera = {
        coords = vector3(405.001, -967.5947, -99.0042),
        rotation = vector3(0.0, 0.0, 0.0),
    },
    playerPositions = { -- These are the places a player can be physically added to the lobby. You must have a position to have the player join. Position starts at #1.
        { coords = vector3(404.6168212890625, -962.9260864257812, -99.0042), heading = 180.0 },
        { coords = vector3(405.2138977050781, -962.9286499023438, -99.0042), heading = 180.0 },
        { coords = vector3(404.061279296875, -962.3641967773438, -99.0042), heading = 180.0 },
        { coords = vector3(405.796630859375, -962.3539428710938, -99.0042), heading = 180.0 },
        { coords = vector3(403.4477233886719, -961.709716796875, -99.0042), heading = 180.0 },
        { coords = vector3(406.4453125, -961.7023315429688, -99.0042), heading = 180.0 },
        { coords = vector3(402.8630065917969, -961.09716796875, -99.0042), heading = 180.0 },
        { coords = vector3(406.9437255859375, -961.1334838867188, -99.0042), heading = 180.0 },
    }
}