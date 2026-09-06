require "Spouse/SpouseData"

SpouseNpcAdapter = SpouseNpcAdapter or {}

function SpouseNpcAdapter.getBackend()
    if BanditManager or Bandits then
        return "bandits-compatible"
    end

    return "vanilla-simulated"
end

function SpouseNpcAdapter.syncProfile(playerObj, profile)
    local backend = SpouseNpcAdapter.getBackend()
    profile.spawn.backend = backend
    profile.presence.backend = backend

    if backend == "vanilla-simulated" then
        if profile.command == "follow" or profile.command == "rally" then
            SpouseData.touchPresence(profile, "nearby", playerObj)
        elseif profile.command == "stay" then
            SpouseData.touchPresence(profile, "holding position", playerObj)
        elseif profile.command == "home" then
            profile.presence.status = "at safehouse"
        end
    end
end
