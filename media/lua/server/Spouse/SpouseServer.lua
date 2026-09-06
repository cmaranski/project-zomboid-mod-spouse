require "Spouse/SpouseData"
require "Spouse/SpouseNpcAdapter"

SpouseServer = SpouseServer or {}

local function getPlayerByIndex(playerIndex)
    if getSpecificPlayer then
        return getSpecificPlayer(playerIndex)
    end

    return nil
end

function SpouseServer.ensurePlayerState(playerIndex, playerObj)
    local player = playerObj or getPlayerByIndex(playerIndex)

    if not player then
        return nil
    end

    local profile = SpouseData.ensureProfile(player, playerIndex)

    if profile.home and profile.home.x == 0 and profile.home.y == 0 then
        SpouseData.setHome(profile, player)
    end

    SpouseNpcAdapter.syncProfile(player, profile)
    SpouseData.transmit()

    return profile
end

function SpouseServer.onCreatePlayer(playerIndex, playerObj)
    SpouseServer.ensurePlayerState(playerIndex, playerObj)
end

function SpouseServer.onGameStart()
    local player = getPlayer and getPlayer() or nil

    if player then
        SpouseServer.ensurePlayerState(player:getPlayerNum(), player)
    end
end

function SpouseServer.onSave()
    SpouseData.transmit()
end

Events.OnCreatePlayer.Add(SpouseServer.onCreatePlayer)
Events.OnGameStart.Add(SpouseServer.onGameStart)
Events.OnSave.Add(SpouseServer.onSave)
