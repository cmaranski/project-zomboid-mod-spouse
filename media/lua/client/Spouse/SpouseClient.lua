require "Spouse/SpouseCommands"

SpouseClient = SpouseClient or {}

local function getLocalPlayer(playerIndex)
    if getSpecificPlayer then
        return getSpecificPlayer(playerIndex)
    end

    if getPlayer then
        return getPlayer()
    end

    return nil
end

function SpouseClient.sayAsSpouse(playerObj, profile, line)
    if not playerObj or not line then
        return
    end

    playerObj:Say(string.format("[%s] %s", profile.displayName or "Spouse", line))
end

function SpouseClient.ensureProfile(playerIndex)
    local playerObj = getLocalPlayer(playerIndex or 0)

    if not playerObj then
        return nil, nil
    end

    local profile = SpouseData.ensureProfile(playerObj, playerIndex or playerObj:getPlayerNum())

    return playerObj, profile
end

function SpouseClient.showIntroduction(playerIndex)
    local playerObj, profile = SpouseClient.ensureProfile(playerIndex)

    if not playerObj or not profile or profile.introduction.shown then
        return
    end

    profile.introduction.created = true
    SpouseClient.sayAsSpouse(playerObj, profile, SpouseDialogue.pick("introduction"))
    SpouseData.markIntroduction(profile)
    SpouseData.transmit()
end

function SpouseClient.issueCommand(playerIndex, command)
    local playerObj, profile = SpouseClient.ensureProfile(playerIndex)

    if not playerObj or not profile then
        return
    end

    local result = SpouseCommands.apply(playerObj, profile, { command = command })

    if result and result.line then
        SpouseClient.sayAsSpouse(playerObj, profile, result.line)
    end
end

function SpouseClient.addWorldContextMenu(playerIndex, context, worldObjects, test)
    if test then
        return
    end

    local playerObj, profile = SpouseClient.ensureProfile(playerIndex)

    if not playerObj or not profile or not context or not ISContextMenu then
        return
    end

    local rootOption = context:addOption(SpouseConfig.MENU_TITLE)
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(rootOption, subMenu)

    local statusLines = SpouseData.getStatusSummary(profile)

    for _, line in ipairs(statusLines) do
        local statusOption = subMenu:addOption(line, nil, nil)
        statusOption.notAvailable = true
    end

    subMenu:addOption("Follow Me", nil, function() SpouseClient.issueCommand(playerIndex, "follow") end)
    subMenu:addOption("Wait Here", nil, function() SpouseClient.issueCommand(playerIndex, "stay") end)
    subMenu:addOption("Rally To Me", nil, function() SpouseClient.issueCommand(playerIndex, "rally") end)
    subMenu:addOption("Set Home Here", nil, function() SpouseClient.issueCommand(playerIndex, "setHome") end)
    subMenu:addOption("Go Home", nil, function() SpouseClient.issueCommand(playerIndex, "home") end)
    subMenu:addOption("Talk", nil, function() SpouseClient.issueCommand(playerIndex, "talk") end)
end

function SpouseClient.onCreatePlayer(playerIndex, playerObj)
    SpouseData.ensureProfile(playerObj, playerIndex)
end

function SpouseClient.onGameStart()
    SpouseClient.showIntroduction(0)
end

Events.OnCreatePlayer.Add(SpouseClient.onCreatePlayer)
Events.OnGameStart.Add(SpouseClient.onGameStart)
Events.OnPreFillWorldObjectContextMenu.Add(SpouseClient.addWorldContextMenu)
