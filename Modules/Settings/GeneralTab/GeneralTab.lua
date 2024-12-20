---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings");

---@type DP_SettingsDefaults
local DP_SettingsDefaults = DP_ModuleLoader:ImportModule("DP_SettingsDefaults");

---@type DP_ConfigGroups
local DP_ConfigGroups = DP_ModuleLoader:ImportModule("DP_ConfigGroups")


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
    },
  }
end
