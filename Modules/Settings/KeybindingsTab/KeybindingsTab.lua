---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings");

---@type DP_SettingsDefaults
local DP_SettingsDefaults = DP_ModuleLoader:ImportModule("DP_SettingsDefaults");

---@type DP_ConfigGroups
local DP_ConfigGroups = DP_ModuleLoader:ImportModule("DP_ConfigGroups")


DP_Settings.tabs.keybindings = { ... }
local optionsDefaults = DP_SettingsDefaults:Load()

---Config
---@param order? number
---@return table
function DP_Settings.tabs.keybindings:Initialize(order)
  return {
    name = DisenchanterPlus:DP_i18n("Keybindings"),
    order = order,
    type = "group",
    args = {
      keybindings_header = DP_ConfigGroups:Get("keybindings", "header", 1),
      keybindings = DP_ConfigGroups:Get("keybindings", "config", 1.1),
    },
  }
end
