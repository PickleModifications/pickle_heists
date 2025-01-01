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
        fov = 30.0,
    },
    vehicleCamera = {
        coords = vector3(413.6868, -967.5947, -99.0042),
        rotation = vector3(0.0, 0.0, 0.0),
        fov = 30.0,
    },
    vehiclePosition = {
        coords = vector3(413.6868, -959.2685, -99.1047),
        heading = 145.2820,
    },
    playerPositions = { -- These are the places a player can be physically added to the lobby. You must have a position to have the player join. Position starts at #1.
        { coords = vector3(404.6168212890625, -962.9260864257812, -99.0042), heading = 180.0, interactOffset = {x = 0.005, y = 0.1} },
        { coords = vector3(405.2138977050781, -962.9286499023438, -99.0042), heading = 180.0, interactOffset = {x = 0, y = 0.1} },
        { coords = vector3(404.061279296875, -962.3641967773438, -99.0042), heading = 180.0, interactOffset = {x = 0.005 * 2, y = 0.1} },
        { coords = vector3(405.796630859375, -962.3539428710938, -99.0042), heading = 180.0, interactOffset = {x = -0.005, y = 0.1} },
        { coords = vector3(403.4477233886719, -961.709716796875, -99.0042), heading = 180.0, interactOffset = {x = 0.005 * 3, y = 0.1} },
        { coords = vector3(406.4453125, -961.7023315429688, -99.0042), heading = 180.0, interactOffset = {x = -0.005 * 2, y = 0.1} },
        { coords = vector3(402.8630065917969, -961.09716796875, -99.0042), heading = 180.0, interactOffset = {x = 0.005 * 4, y = 0.1} },
        { coords = vector3(406.9437255859375, -961.1334838867188, -99.0042), heading = 180.0, interactOffset = {x = -0.005 * 3, y = 0.1} },
    },
}

Config.Heists = {
    {
        label = "The Flecca Job",
        description = "A high-stakes bank heist that requires careful planning and precise execution. Assemble your crew, gather intel, and prepare for an intense showdown with law enforcement. The payout is substantial, but so are the risks. Will you and your team make it out with the loot, or will you end up behind bars? The Flecca Job is not for the faint of heart.",
        reward = 1000,
        requiredPlayers = 1,
        maxPlayers = 4,
        vehicles = {
            { model = `kuruma`, name = "Karin Kuruma", description = "A heavily armored sports car that is perfect for heists. It can take a lot of damage and has plenty of firepower to help you get out of sticky situations.", price = 50000 },
            { model = `dominator`, name = "Vapid Dominator", description = "A classic muscle car that is fast, powerful, and stylish. It is perfect for making a quick getaway after a heist.", price = 30000 },
        },
        enterLocation = { coords = vector3(450.0584, -752.6832, 26.3578), heading = 267.0975 },
        vehicleLocation = { coords = vector3(475.0798, -822.3256, 26.0780), heading = 90.6259 },
    },
}