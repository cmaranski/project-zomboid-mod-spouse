require "Spouse/SpouseConfig"

SpouseData = SpouseData or {}

function SpouseData.getWorldAgeHours()
    local gameTime = GameTime and GameTime.getInstance and GameTime:getInstance() or nil

    if gameTime and gameTime.getWorldAgeHours then
        return gameTime:getWorldAgeHours()
    end

    return 0
end

local function shallowCopyArray(items)
    local copy = {}

    for index = 1, #items do
        copy[index] = items[index]
    end

    return copy
end

local function roundCoordinate(value)
    if value == nil then
        return 0
    end

    return math.floor(value + 0.5)
end

function SpouseData.getWorldState()
    local state = ModData.getOrCreate(SpouseConfig.MOD_DATA_KEY)

    state.version = state.version or SpouseConfig.DATA_VERSION
    state.players = state.players or {}
    state.createdAtHours = state.createdAtHours or SpouseData.getWorldAgeHours()

    return state
end

function SpouseData.getPlayerKey(playerObj, playerIndex)
    if playerObj and playerObj.getUsername then
        local username = playerObj:getUsername()

        if username and username ~= "" then
            return "username:" .. tostring(username)
        end
    end

    return "player:" .. tostring(playerIndex or 0)
end

function SpouseData.randomName(playerObj)
    local pool = SpouseConfig.getPreferredPool(playerObj)

    if not pool or #pool == 0 then
        return "Alex"
    end

    return pool[ZombRand(#pool) + 1]
end

function SpouseData.makeProfile(playerObj, playerIndex)
    local x = playerObj and playerObj.getX and roundCoordinate(playerObj:getX()) or 0
    local y = playerObj and playerObj.getY and roundCoordinate(playerObj:getY()) or 0
    local z = playerObj and playerObj.getZ and roundCoordinate(playerObj:getZ()) or 0
    local key = SpouseData.getPlayerKey(playerObj, playerIndex)
    local displayName = SpouseData.randomName(playerObj)

    return {
        version = SpouseConfig.DATA_VERSION,
        id = key .. ":spouse",
        ownerKey = key,
        displayName = displayName,
        alive = true,
        bond = SpouseConfig.DEFAULT_BOND,
        trust = SpouseConfig.DEFAULT_TRUST,
        command = "follow",
        commandLabel = "Following",
        introduction = {
            created = false,
            shown = false,
        },
        spawn = {
            backend = "vanilla-simulated",
            scheduled = true,
            spawned = false,
            retryCount = 0,
        },
        presence = {
            status = SpouseConfig.DEFAULT_STATUS,
            backend = "vanilla-simulated",
            lastSeenHours = SpouseData.getWorldAgeHours(),
            lastKnownCell = {
                x = x,
                y = y,
                z = z,
            },
        },
        home = {
            x = x,
            y = y,
            z = z,
            label = "Home",
        },
        inventory = {
            ownership = "shared",
            loadout = {},
        },
        dialogueFlags = {},
        relationship = {
            stage = "married",
            lastTalkHours = 0,
        },
        runtime = {
            pendingGreeting = true,
            lastUpdateHours = SpouseData.getWorldAgeHours(),
            unavailableReason = nil,
        },
    }
end

function SpouseData.migrateProfile(profile)
    if not profile then
        return nil
    end

    profile.version = profile.version or 0
    profile.ownerKey = profile.ownerKey or profile.id or "player:0"
    profile.displayName = profile.displayName or "Alex"
    profile.alive = profile.alive ~= false
    profile.bond = profile.bond or SpouseConfig.DEFAULT_BOND
    profile.trust = profile.trust or SpouseConfig.DEFAULT_TRUST
    profile.command = profile.command or "follow"
    profile.commandLabel = profile.commandLabel or "Following"
    profile.introduction = profile.introduction or { created = false, shown = false }
    profile.spawn = profile.spawn or {}
    profile.spawn.backend = profile.spawn.backend or "vanilla-simulated"
    profile.spawn.scheduled = profile.spawn.scheduled ~= false
    profile.spawn.spawned = profile.spawn.spawned == true
    profile.spawn.retryCount = profile.spawn.retryCount or 0

    profile.presence = profile.presence or {}
    profile.presence.status = profile.presence.status or SpouseConfig.DEFAULT_STATUS
    profile.presence.backend = profile.presence.backend or "vanilla-simulated"
    profile.presence.lastSeenHours = profile.presence.lastSeenHours or SpouseData.getWorldAgeHours()
    profile.presence.lastKnownCell = profile.presence.lastKnownCell or { x = 0, y = 0, z = 0 }

    profile.home = profile.home or {}
    profile.home.x = profile.home.x or 0
    profile.home.y = profile.home.y or 0
    profile.home.z = profile.home.z or 0
    profile.home.label = profile.home.label or "Home"

    profile.inventory = profile.inventory or {}
    profile.inventory.ownership = profile.inventory.ownership or "shared"
    profile.inventory.loadout = profile.inventory.loadout or {}

    profile.dialogueFlags = profile.dialogueFlags or {}

    profile.relationship = profile.relationship or {}
    profile.relationship.stage = profile.relationship.stage or "married"
    profile.relationship.lastTalkHours = profile.relationship.lastTalkHours or 0

    profile.runtime = profile.runtime or {}
    profile.runtime.pendingGreeting = profile.runtime.pendingGreeting == true
    profile.runtime.lastUpdateHours = profile.runtime.lastUpdateHours or SpouseData.getWorldAgeHours()
    profile.runtime.unavailableReason = profile.runtime.unavailableReason or nil

    profile.version = SpouseConfig.DATA_VERSION

    return profile
end

function SpouseData.ensureProfile(playerObj, playerIndex)
    local state = SpouseData.getWorldState()
    local key = SpouseData.getPlayerKey(playerObj, playerIndex)
    local profile = state.players[key]

    if not profile then
        profile = SpouseData.makeProfile(playerObj, playerIndex)
        state.players[key] = profile
    end

    return SpouseData.migrateProfile(profile)
end

function SpouseData.markIntroduction(profile)
    profile.introduction.created = true
    profile.introduction.shown = true
    profile.spawn.spawned = true
    profile.spawn.scheduled = false
    profile.runtime.pendingGreeting = false
    profile.runtime.lastUpdateHours = SpouseData.getWorldAgeHours()
end

function SpouseData.markDialogueFlag(profile, flagName)
    if flagName then
        profile.dialogueFlags[flagName] = true
    end
end

function SpouseData.setHome(profile, playerObj)
    if not playerObj then
        return
    end

    profile.home.x = roundCoordinate(playerObj:getX())
    profile.home.y = roundCoordinate(playerObj:getY())
    profile.home.z = roundCoordinate(playerObj:getZ())
    profile.home.label = "Safehouse"
    profile.presence.lastKnownCell = {
        x = profile.home.x,
        y = profile.home.y,
        z = profile.home.z,
    }
    profile.runtime.lastUpdateHours = SpouseData.getWorldAgeHours()
end

function SpouseData.setCommand(profile, command, label)
    profile.command = command
    profile.commandLabel = label or command
    profile.runtime.lastUpdateHours = SpouseData.getWorldAgeHours()
end

function SpouseData.bumpBond(profile, amount)
    local nextBond = math.max(0, math.min(100, (profile.bond or 0) + (amount or 0)))
    profile.bond = nextBond
    profile.runtime.lastUpdateHours = SpouseData.getWorldAgeHours()
end

function SpouseData.touchPresence(profile, status, playerObj)
    profile.presence.status = status or profile.presence.status
    profile.presence.lastSeenHours = SpouseData.getWorldAgeHours()

    if playerObj then
        profile.presence.lastKnownCell = {
            x = roundCoordinate(playerObj:getX()),
            y = roundCoordinate(playerObj:getY()),
            z = roundCoordinate(playerObj:getZ()),
        }
    end
end

function SpouseData.getStatusSummary(profile)
    local status = profile.presence and profile.presence.status or SpouseConfig.DEFAULT_STATUS
    local home = profile.home or { x = 0, y = 0, z = 0 }

    return {
        string.format("%s — %s", profile.displayName, profile.commandLabel),
        string.format("Bond %d / Trust %d", profile.bond or 0, profile.trust or 0),
        string.format("Status: %s", status),
        string.format("Home: %d,%d,%d", home.x or 0, home.y or 0, home.z or 0),
    }
end

function SpouseData.getSavedLoadout(profile)
    return shallowCopyArray(profile.inventory.loadout or {})
end

function SpouseData.transmit()
    if ModData and ModData.transmit then
        ModData.transmit(SpouseConfig.MOD_DATA_KEY)
    end
end
