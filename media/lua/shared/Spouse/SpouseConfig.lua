SpouseConfig = SpouseConfig or {}

SpouseConfig.MOD_ID = "Spouse"
SpouseConfig.MOD_DATA_KEY = "Spouse.WorldState"
SpouseConfig.DATA_VERSION = 1
SpouseConfig.DEFAULT_BOND = 50
SpouseConfig.DEFAULT_TRUST = 50
SpouseConfig.DEFAULT_STATUS = "nearby"
SpouseConfig.MENU_TITLE = "Spouse"

SpouseConfig.NAME_POOLS = {
    female = { "Alex", "Casey", "Jamie", "Jordan", "Morgan", "Riley", "Taylor" },
    male = { "Alex", "Blake", "Cameron", "Drew", "Elliot", "Logan", "Rowan" },
}

function SpouseConfig.getPreferredPool(playerObj)
    if playerObj and playerObj.isFemale and playerObj:isFemale() then
        return SpouseConfig.NAME_POOLS.male
    end

    return SpouseConfig.NAME_POOLS.female
end
