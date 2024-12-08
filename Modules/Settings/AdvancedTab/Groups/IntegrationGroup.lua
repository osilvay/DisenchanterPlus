---@class DP_IntegrationGroup
local DP_IntegrationGroup = DP_ModuleLoader:CreateModule("DP_IntegrationGroup");

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---Header
---@param order? number
---@return table
function DP_IntegrationGroup:Header(order)
  return DP_CustomConfig:CreateHeaderConfig(DisenchanterPlus:DP_i18n("Integration"), order or 1, DisenchanterPlus:GetAddonColor())
end

---Config
---@param order? number
---@return table
function DP_IntegrationGroup:Config(order)
  return {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      auctionatorIntegration = {
        type = "toggle",
        order = 9,
        name = DisenchanterPlus:DP_i18n("Auctionator integration"),
        desc = DisenchanterPlus:DP_i18n("Enable integration with Auctionator addon."),
        width = "full",
        disabled = function() return DisenchanterPlus.db.char.general.disableAll or not (Auctionator) end,
        get = function()
          return DisenchanterPlus.db.char.general.auctionatorIntegration
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.auctionatorIntegration = value
        end,
      },
    }
  }
end
