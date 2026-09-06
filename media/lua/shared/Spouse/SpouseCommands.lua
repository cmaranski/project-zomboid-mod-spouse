require "Spouse/SpouseData"
require "Spouse/SpouseDialogue"
require "Spouse/SpouseNpcAdapter"

SpouseCommands = SpouseCommands or {}

SpouseCommands.labels = {
    follow = "Following",
    stay = "Waiting",
    home = "Returning Home",
    rally = "Rejoined",
    talk = "Talking",
    setHome = "Home Updated",
}

function SpouseCommands.apply(playerObj, profile, action)
    local command = action and action.command or nil

    if not command or not profile then
        return nil
    end

    if command == "setHome" then
        SpouseData.setHome(profile, playerObj)
        SpouseData.setCommand(profile, "stay", SpouseCommands.labels.stay)
        SpouseData.markDialogueFlag(profile, "homeSet")
    elseif command == "talk" then
        profile.relationship.lastTalkHours = SpouseData.getWorldAgeHours()
        SpouseData.bumpBond(profile, 1)
        SpouseData.markDialogueFlag(profile, "talked")
    elseif command == "rally" then
        SpouseData.setCommand(profile, "follow", SpouseCommands.labels.follow)
        SpouseData.touchPresence(profile, "nearby", playerObj)
        SpouseData.markDialogueFlag(profile, "rallied")
    elseif command == "stay" then
        SpouseData.setCommand(profile, command, SpouseCommands.labels.stay)
        SpouseData.touchPresence(profile, "holding position", playerObj)
        SpouseData.markDialogueFlag(profile, "staying")
    elseif command == "home" then
        SpouseData.setCommand(profile, command, SpouseCommands.labels.home)
        SpouseData.touchPresence(profile, "at safehouse")
        SpouseData.markDialogueFlag(profile, "sentHome")
    else
        SpouseData.setCommand(profile, "follow", SpouseCommands.labels.follow)
        SpouseData.touchPresence(profile, "nearby", playerObj)
        SpouseData.markDialogueFlag(profile, "following")
    end

    SpouseNpcAdapter.syncProfile(playerObj, profile)
    SpouseData.transmit()

    return {
        command = command,
        line = SpouseDialogue.pick(command),
        statusLines = SpouseData.getStatusSummary(profile),
    }
end
