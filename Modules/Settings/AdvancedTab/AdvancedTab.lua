---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings");

---@type DP_SettingsDefaults
local DP_SettingsDefaults = DP_ModuleLoader:ImportModule("DP_SettingsDefaults");

---@type DP_ConfigGroups
local DP_ConfigGroups = DP_ModuleLoader:ImportModule("DP_ConfigGroups")

DP_Settings.tabs.advanced = { ... }
local optionsDefaults = DP_SettingsDefaults:Load()

---Config
---@param order? number
---@return table
function DP_Settings.tabs.advanced:Initialize(order)
  return {
    name = DisenchanterPlus:DP_i18n("Advanced"),
    order = order,
    type = "group",
    args = {
      changelog_header = DP_ConfigGroups:Get("advanced", "header"),
      changelog = DP_ConfigGroups:Get("advanced", "config"),
    },
  }
end
