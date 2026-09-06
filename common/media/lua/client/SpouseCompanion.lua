SpouseCompanion = {
    runtime = nil,
    recoveryMinutesElapsed = 0,
}

local function log(message)
    if SpouseConfig.DEBUG then
        print("[SpouseCompanion] " .. message)
    end
end

local function playerFor(playerNum)
    return getSpecificPlayer(playerNum or 0)
end

local function nearbySquare(player)
    local cell = getCell()
    local x = math.floor(player:getX())
    local y = math.floor(player:getY())
    local z = player:getZ()

    for distance = SpouseConfig.INTRODUCTION_DISTANCE, 8 do
        local candidates = {
            cell:getGridSquare(x + distance, y, z),
            cell:getGridSquare(x - distance, y, z),
            cell:getGridSquare(x, y + distance, z),
            cell:getGridSquare(x, y - distance, z),
        }
        for _, square in ipairs(candidates) do
            if square and square:isFree(false) then
                return square
            end
        end
    end
    return cell:getGridSquare(x, y + 2, z)
end

local function buildDescriptor(profile)
    local isFemale = profile.identity.sex == "female"
    local ok, descriptor = pcall(function()
        return SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, isFemale)
    end)
    if not ok or not descriptor then
        descriptor = SurvivorDesc.new()
        pcall(function()
            descriptor:setFemale(isFemale)
        end)
    end
    descriptor:setForename(profile.name.forename)
    descriptor:setSurname(profile.name.surname)
    return descriptor
end

local function createSurvivor(square, profile)
    if not square then
        return nil
    end

    local ok, survivor = pcall(function()
        local descriptor = buildDescriptor(profile)
        return IsoSurvivor.new(descriptor, getCell(), square:getX(), square:getY(), square:getZ())
    end)
    if ok and survivor then
        return survivor
    end

    log("This game build could not construct an IsoSurvivor")
    return nil
end

local function placeRuntime(square, data)
    local survivor = createSurvivor(square, SpouseProfile)
    if not survivor then
        return nil
    end

    survivor:setName(data.name)
    pcall(function() survivor:setIgnoreAimingInput(true) end)
    pcall(function() survivor:setAllowBehaviours(true) end)
    SpouseCompanion.runtime = survivor
    data.lastPosition = { x = square:getX(), y = square:getY(), z = square:getZ() }
    return survivor
end

local function ensurePresent(player)
    local data = SpousePersistence.ensure()
    if not data.alive or SpouseCompanion.runtime then
        return SpouseCompanion.runtime
    end

    local square = nearbySquare(player)
    if not data.introduced then
        local survivor = placeRuntime(square, data)
        if survivor then
            data.introduced = true
            SpousePersistence.setHome(square)
            log("Introduced spouse")
        end
        return survivor
    end

    if data.following and square then
        return placeRuntime(square, data)
    end
    return nil
end

local function setFollowing(player, following)
    local data = SpousePersistence.ensure()
    data.following = following
    if SpouseCompanion.runtime then
        if following then
            SpouseCompanion.runtime:pathToCharacter(player)
        else
            SpouseCompanion.runtime:stop()
            SpousePersistence.setLastPosition(SpouseCompanion.runtime)
        end
    end
end

local function isRuntimeDead()
    local runtime = SpouseCompanion.runtime
    if not runtime then
        return false
    end

    local ok, dead = pcall(function() return runtime:isDead() end)
    return ok and dead == true
end

local function say(player, text)
    if player and player.Say then
        player:Say(text)
    end
end

local function addCommands(context, player)
    local data = SpousePersistence.ensure()
    if not data.introduced or not SpouseCompanion.runtime then
        return
    end

    context:addOption("Spouse: Follow", player, function(target)
        setFollowing(target, true)
        say(target, data.name .. " is following you.")
    end)
    context:addOption("Spouse: Stay", player, function(target)
        setFollowing(target, false)
        say(target, data.name .. " will stay here.")
    end)
    context:addOption("Spouse: Talk", player, function(target)
        data.trust = math.min((data.trust or 0) + 1, 100)
        data.dialogueFlags.spoken = true
        say(target, data.name .. " looks glad to see you.")
    end)
    context:addOption("Spouse: Go home", player, function(target)
        data.following = false
        if data.home then
            SpouseCompanion.runtime:setX(data.home.x)
            SpouseCompanion.runtime:setY(data.home.y)
            SpouseCompanion.runtime:setZ(data.home.z)
            say(target, data.name .. " is waiting at home.")
        else
            say(target, "Your spouse does not have a home yet.")
        end
    end)
end

local function onGameStart()
    local player = playerFor(0)
    if player then
        ensurePresent(player)
    end
end

local function onEveryMinute()
    local player = playerFor(0)
    if not player then
        return
    end

    local data = SpousePersistence.ensure()
    if not data.alive then
        return
    end

    if not SpouseCompanion.runtime then
        ensurePresent(player)
        return
    end

    if isRuntimeDead() then
        SpousePersistence.markDead()
        SpouseCompanion.runtime = nil
        return
    end

    if data.following then
        local distance = SpouseCompanion.runtime:DistTo(player)
        if distance > SpouseConfig.RECOVERY_DISTANCE then
            SpouseCompanion.recoveryMinutesElapsed = SpouseCompanion.recoveryMinutesElapsed + 1
            if SpouseCompanion.recoveryMinutesElapsed >= SpouseConfig.RECOVERY_COOLDOWN_MINUTES then
                SpouseCompanion.recoveryMinutesElapsed = 0
                SpouseCompanion.runtime:pathToCharacter(player)
            end
        else
            SpouseCompanion.recoveryMinutesElapsed = 0
        end
    end
    SpousePersistence.setLastPosition(SpouseCompanion.runtime)
end

local function onContextMenu(playerNum, context)
    local player = playerFor(playerNum)
    if player then
        addCommands(context, player)
    end
end

Events.OnGameStart.Add(onGameStart)
Events.EveryOneMinute.Add(onEveryMinute)
Events.OnFillWorldObjectContextMenu.Add(onContextMenu)
