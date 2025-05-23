---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings");

---@type DP_SettingsDefaults
local DP_SettingsDefaults = DP_ModuleLoader:ImportModule("DP_SettingsDefaults");

---@type DP_ConfigGroups
local DP_ConfigGroups = DP_ModuleLoader:ImportModule("DP_ConfigGroups")

DP_Settings.tabs.enchant = { ... }
local optionsDefaults = DP_SettingsDefaults:Load()

---Config
---@param order? number
---@return table
function DP_Settings.tabs.enchant:Initialize(order)
  return {
    name = DisenchanterPlus:DP_i18n("Enchant"),
    order = order,
    type = "group",
    args = {
      disenchant_header = DP_ConfigGroups:Get("enchant", "header", 1),
      disenchant = DP_ConfigGroups:Get("enchant", "config", 1.1),
    },
  }
end
