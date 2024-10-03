---@class DP_AdvancedGroup
local DP_AdvancedGroup = DP_ModuleLoader:CreateModule("DP_AdvancedGroup");

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---Header
---@param order? number
---@return table
function DP_AdvancedGroup:Header(order)
  return DP_CustomConfig:CreateHeaderConfig(DisenchanterPlus:DP_i18n("Advanced"), order or 1, DisenchanterPlus:GetAddonColor())
end

---Config
---@param order? number
---@return table
function DP_AdvancedGroup:Config(order)
  return {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      debug = {
        type = "toggle",
        order = 2,
        name = DisenchanterPlus:DP_i18n("Enable debug"),
        desc = "Toggle the debug mode",
        width = 1.5,
        get = function() return DisenchanterPlus.db.char.advanced.debug end,
        set = function(info, value)
          DisenchanterPlus.db.char.advanced.debug = value
        end,
      },
    }
  }
end
