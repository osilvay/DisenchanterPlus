---@class DP_EventHandler
local DP_EventHandler = DP_ModuleLoader:CreateModule("DP_EventHandler")
local _DP_EventHandler = {}

---@type DP_Init
local DP_Init = DP_ModuleLoader:ImportModule("DP_Init")

function DP_EventHandler:RegisterEarlyEvents()
  DisenchanterPlus:RegisterEvent("PLAYER_LOGIN", _DP_EventHandler.PlayerLogin)
end

function _DP_EventHandler:PlayerLogin()
  -- Check config exists
  if not DisenchanterPlus.db or not DisenchanterPlusDB then
    DisenchanterPlus:Error("Config DB from saved variables is not loaded and initialized. Please report this issue.")
    error("Config DB from saved variables is not loaded and initialized. Please report this issue.")
    return
  end

  do
    -- All this information was researched here: https://www.townlong-yak.com/framexml/live/GlobalStrings.lua
    local realmID, realmName, realmNormalizedRealmName = GetRealmID(), GetRealmName(), GetNormalizedRealmName()
    local name = UnitName("player")
    local className, classFilename, classId = UnitClass("player")
    local raceName, raceFile, raceID = UnitRace("player")
    local level = UnitLevel("player")
    local englishFaction, localizedFaction = UnitFactionGroup("player")
    local version, build, date, tocversion, localizedVersion, buildType = GetBuildInfo()
    local locale = GetLocale()
    local key = name .. " - " .. realmName
    local info = {
      realm = realmName,
      realmID = realmID,
      name = name,
      level = level,
      classFilename = classFilename,
      className = className,
      classId = classId,
      raceName = raceName,
      raceFile = raceFile,
      raceID = raceID,
      faction = localizedFaction,
      factionName = englishFaction,
      locale = locale
    }
    if DisenchanterPlus.db.global.data.characters == nil then DisenchanterPlus.db.global.data.characters = {} end
    DisenchanterPlus.db.global.data.characters[key] = true
    DisenchanterPlus.db.global.data.locale = nil

    if DisenchanterPlus.db.global.characters[DisenchanterPlus.key] == nil then
      DisenchanterPlus.db.global.characters[DisenchanterPlus.key] = {
        info = info,
      }
    else
      DisenchanterPlus.db.global.characters[DisenchanterPlus.key].info = info
    end
  end
  DP_Init:Initialize()
end
