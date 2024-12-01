---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings");

---@type DP_SettingsDefaults
local DP_SettingsDefaults = DP_ModuleLoader:ImportModule("DP_SettingsDefaults");

---@type DP_SlashCommands
local DP_SlashCommands = DP_ModuleLoader:ImportModule("DP_SlashCommands")

---@type DP_ConfigGroups
local DP_ConfigGroups = DP_ModuleLoader:ImportModule("DP_ConfigGroups")

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---@type DP_Database
local DP_Database = DP_ModuleLoader:ImportModule("DP_Database")

DP_Settings.tabs.general = { ... }
local optionsDefaults = DP_SettingsDefaults:Load()

---Config
---@param order? number
---@return table
function DP_Settings.tabs.general:Initialize(order)
  return {
    name = DisenchanterPlus:DP_i18n("General"),
    order = order,
    type = "group",
    args = {
      general_header = DP_ConfigGroups:Get("general", "header", 1),
      general = DP_ConfigGroups:Get("general", "config", 1.1),
      tooltips_header = DP_ConfigGroups:Get("tooltips", "header", 2),
      tooltips = DP_ConfigGroups:Get("tooltips", "config", 2.1),
      keybinding_header = DP_ConfigGroups:Get("keybinding", "header", 3),
      keybinding = DP_ConfigGroups:Get("keybinding", "config", 3.1),
      disenchant_header = DP_ConfigGroups:Get("disenchant", "header", 4),
      disenchant = DP_ConfigGroups:Get("disenchant", "config", 4.1),
    },
  }
end
