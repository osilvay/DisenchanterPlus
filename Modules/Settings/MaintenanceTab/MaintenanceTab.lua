---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings");

---@type DP_SettingsDefaults
local DP_SettingsDefaults = DP_ModuleLoader:ImportModule("DP_SettingsDefaults");

---@type DP_ConfigGroups
local DP_ConfigGroups = DP_ModuleLoader:ImportModule("DP_ConfigGroups")

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---@type DP_Database
local DP_Database = DP_ModuleLoader:ImportModule("DP_Database")

DP_Settings.tabs.maintenance = { ... }
local optionsDefaults = DP_SettingsDefaults:Load()

---Config
---@param order? number
---@return table
function DP_Settings.tabs.maintenance:Initialize(order)
  return {
    name = DisenchanterPlus:DP_i18n("Maintenance"),
    order = order,
    type = "group",
    args = {
      stats_header = DP_CustomConfig:CreateHeaderConfig(DisenchanterPlus:DP_i18n("Stats"), 0, DisenchanterPlus:GetAddonColor()),
      stats = DP_CustomConfig:CreateStatsConfig("DisenchanterPlus", DP_Database:GetNumEntries(), 0.1),
      database_header = DP_ConfigGroups:Get("database", "header"),
      database = DP_ConfigGroups:Get("database", "config"),
    },
  }
end
