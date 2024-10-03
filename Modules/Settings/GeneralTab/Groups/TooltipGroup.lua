---@class DP_TooltipGroup
local DP_TooltipGroup = DP_ModuleLoader:CreateModule("DP_TooltipGroup");

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---Header
---@param order? number
---@return table
function DP_TooltipGroup:Header(order)
  return DP_CustomConfig:CreateHeaderConfig(DisenchanterPlus:DP_i18n("Tooltips"), order or 1, DisenchanterPlus:GetAddonColor())
end

---Config
---@param order? number
---@return table
function DP_TooltipGroup:Config(order)
  return {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      tooltipsEnabled = {
        type = "toggle",
        order = 1,
        name = DisenchanterPlus:DP_i18n("Enable"),
        desc = DisenchanterPlus:DP_i18n("Enable tooltips about enchanting materials."),
        width = "full",
        disabled = false,
        get = function()
          return DisenchanterPlus.db.char.general.tooltipsEnabled
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.tooltipsEnabled = value
        end,
      },
    }
  }
end
