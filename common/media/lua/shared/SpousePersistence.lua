SpousePersistence = {}

local function copyPosition(position)
    if not position then
        return nil
    end

    return {
        x = position.x,
        y = position.y,
        z = position.z or 0,
    }
end

function SpousePersistence.get()
    local data = ModData.getOrCreate(SpouseConfig.MOD_ID)
    data.version = data.version or 0
    return data
end

function SpousePersistence.migrate(data)
    local version = data.version or 0
    if version < 1 then
        data.version = 1
        data.id = data.id or "spouse-1"
        data.profileId = data.profileId or SpouseProfile.ID
        data.name = data.name or SpouseConfig.DISPLAY_NAME
        data.forename = data.forename or SpouseProfile.name.forename
        data.surname = data.surname or SpouseProfile.name.surname
        data.nickname = data.nickname or SpouseProfile.name.nickname
        data.alive = data.alive ~= false
        data.trust = data.trust or SpouseConfig.DEFAULT_TRUST
        data.following = data.following == true
        data.dialogueFlags = data.dialogueFlags or {}
        data.inventory = data.inventory or {}
        data.home = data.home or SpouseConfig.DEFAULT_HOME
    end
    if version < 2 then
        data.version = 2
        data.profileId = SpouseProfile.ID
        data.name = SpouseConfig.DISPLAY_NAME
        data.forename = SpouseProfile.name.forename
        data.surname = SpouseProfile.name.surname
        data.nickname = SpouseProfile.name.nickname
        data.trust = SpouseProfile.behavior.startingTrust
    end
    return data
end

function SpousePersistence.ensure()
    return SpousePersistence.migrate(SpousePersistence.get())
end

function SpousePersistence.setHome(square)
    local data = SpousePersistence.ensure()
    data.home = copyPosition(square and {
        x = square:getX(),
        y = square:getY(),
        z = square:getZ(),
    })
end

function SpousePersistence.setLastPosition(character)
    if not character then
        return
    end

    local data = SpousePersistence.ensure()
    data.lastPosition = {
        x = character:getX(),
        y = character:getY(),
        z = character:getZ(),
    }
end

function SpousePersistence.markDead()
    local data = SpousePersistence.ensure()
    data.alive = false
    data.following = false
end