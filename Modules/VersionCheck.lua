--Initialized below
---@class DisenchanterPlus : AceAddon, AceConsole-3.0, AceEvent-3.0, AceTimer-3.0, AceComm-3.0, AceBucket-3.0
DisenchanterPlus = LibStub("AceAddon-3.0"):NewAddon("DisenchanterPlus", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceBucket-3.0")

--- Addon is running on Classic WoW Forever (client 1.60.x). It reports the Mainline project ID, so it is identified by build.
--- Some Forever builds also expose WOW_PROJECT_CAMELOT, so accept that when available.
---@type boolean
DisenchanterPlus.IsForever = (select(1, GetBuildInfo()) or ""):match("^1%.60%.") ~= nil
    or (WOW_PROJECT_CAMELOT ~= nil and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT)

--- Addon is running on Retail client
---@type boolean
DisenchanterPlus.IsMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and not DisenchanterPlus.IsForever

--- Addon is running on Classic "Vanilla" client: Means Classic Era and its seasons like SoM. Forever uses the Classic (Era) profession and disenchant data.
---@type boolean
DisenchanterPlus.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or DisenchanterPlus.IsForever

--- Addon is running on Classic TBC client (interface 20505 and 20506 share this project ID)
---@type boolean
DisenchanterPlus.IsTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

local hasActiveSeason = C_Seasons ~= nil and C_Seasons.HasActiveSeason ~= nil and C_Seasons.HasActiveSeason() or false

--- Addon is running on Classic "Vanilla" client and on Era realm (non-seasonal)
---@type boolean
DisenchanterPlus.IsEra = DisenchanterPlus.IsClassic and not hasActiveSeason

--- Addon is running on Classic "Vanilla" client and on any Seasonal realm (see: https://wowpedia.fandom.com/wiki/API_C_Seasons.GetActiveSeason )
---@type boolean
DisenchanterPlus.IsEraSeasonal = DisenchanterPlus.IsClassic and hasActiveSeason

--- Addon is running on a HardCore realm specifically
---@type boolean
DisenchanterPlus.IsHardcore = false
if (DisenchanterPlus.IsClassic and C_GameRules and C_GameRules.IsHardcoreActive()) or
    (DisenchanterPlus.IsMainline and C_GameRules.IsGameRuleActive(Enum.GameRule.HardcoreRuleset)) then
  DisenchanterPlus.IsHardcore = true
end
