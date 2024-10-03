--Initialized below
---@class DisenchanterPlus : AceAddon, AceConsole-3.0, AceEvent-3.0, AceTimer-3.0, AceComm-3.0, AceBucket-3.0
DisenchanterPlus = LibStub("AceAddon-3.0"):NewAddon("DisenchanterPlus", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceBucket-3.0")

--- Addon is running on Retail client
---@type boolean
DisenchanterPlus.IsMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

--- Addon is running on Classic Cataclysm client
---@type boolean
DisenchanterPlus.IsCataclysm = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

--- Addon is running on Classic Wotlk client
---@type boolean
DisenchanterPlus.IsWotlk = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

--- Addon is running on Classic TBC client
---@type boolean
DisenchanterPlus.IsTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

--- Addon is running on Classic "Vanilla" client: Means Classic Era and its seasons like SoM
---@type boolean
DisenchanterPlus.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

--- Addon is running on Classic "Vanilla" client and on Era realm (non-seasonal)
---@type boolean
DisenchanterPlus.IsEra = DisenchanterPlus.IsClassic and (not C_Seasons.HasActiveSeason())

--- Addon is running on Classic "Vanilla" client and on any Seasonal realm (see: https://wowpedia.fandom.com/wiki/API_C_Seasons.GetActiveSeason )
---@type boolean
DisenchanterPlus.IsEraSeasonal = DisenchanterPlus.IsClassic and C_Seasons.HasActiveSeason()

--- Addon is running on a HardCore realm specifically
---@type boolean
DisenchanterPlus.IsHardcore = false
if (DisenchanterPlus.IsClassic and C_GameRules and C_GameRules.IsHardcoreActive()) or
    (DisenchanterPlus.IsMainline and C_GameRules.IsGameRuleActive(Enum.GameRule.HardcoreRuleset)) then
  DisenchanterPlus.IsHardcore = true
end
