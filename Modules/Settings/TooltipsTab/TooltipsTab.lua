---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings");

---@type DP_SettingsDefaults
local DP_SettingsDefaults = DP_ModuleLoader:ImportModule("DP_SettingsDefaults");

---@type DP_ConfigGroups
local DP_ConfigGroups = DP_ModuleLoader:ImportModule("DP_ConfigGroups")

DP_Settings.tabs.tooltips = { ... }
local optionsDefaults = DP_SettingsDefaults:Load()

---Config
---@param order? number
---@return table
function DP_Settings.tabs.tooltips:Initialize(order)
  return {
    name = DisenchanterPlus:DP_i18n("Tooltips"),
    order = order,
    type = "group",
    args = {
      tooltips_header = DP_ConfigGroups:Get("tooltips", "header", 1),
      tooltips = DP_ConfigGroups:Get("tooltips", "config", 1.1)
    },
  }
end
