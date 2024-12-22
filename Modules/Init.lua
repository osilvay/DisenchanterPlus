---@class DP_Init
local DP_Init = DP_ModuleLoader:CreateModule("DP_Init")

---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings")

---@type DP_SlashCommands
local DP_SlashCommands = DP_ModuleLoader:ImportModule("DP_SlashCommands")

---@type DP_MinimapIcon
local DP_MinimapIcon = DP_ModuleLoader:ImportModule("DP_MinimapIcon")

---@type DP_WelcomeWindow
local DP_WelcomeWindow = DP_ModuleLoader:ImportModule("DP_WelcomeWindow")

---@type DP_DisenchanterPlusEvents
local DP_DisenchanterPlusEvents = DP_ModuleLoader:ImportModule("DP_DisenchanterPlusEvents")

---@type DP_EnchantingTooltip
local DP_EnchantingTooltip = DP_ModuleLoader:ImportModule("DP_EnchantingTooltip")

---@type DP_Database
local DP_Database = DP_ModuleLoader:ImportModule("DP_Database")

---@type DP_EnchantProcess
local DP_EnchantProcess = DP_ModuleLoader:ImportModule("DP_EnchantProcess")

function DP_Init:Initialize()
  DP_MinimapIcon:Initialize()
  DP_SlashCommands.RegisterSlashCommands()
  DP_WelcomeWindow:Initialize()
  DP_Settings:Initialize()
  DP_Database:Initialize()
  DP_EnchantingTooltip:Initialize()
  DP_DisenchanterPlusEvents:Initialize()
  C_Timer.After(3, function()
    DisenchanterPlus:Print(string.format("%s %s", DisenchanterPlus:DP_i18n("Initialized"), DisenchanterPlus:GetAddonColoredVersion()))
    DisenchanterPlus.started = true
  end)
  C_Timer.After(3, function()
    DP_EnchantProcess:Initialize()
  end)
end
