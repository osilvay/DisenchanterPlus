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
      priceSource = {
        type = "select",
        order = 9,
        width = "full",
        name = DisenchanterPlus:DP_i18n("Auction house price source"),
        desc = DisenchanterPlus:DP_i18n("Addon used to show auction house prices of disenchant results."),
        values = {
          none = DisenchanterPlus:DP_i18n("None"),
          auctionator = "Auctionator",
          auxforever = "auxForever",
        },
        disabled = function() return DisenchanterPlus.db.char.general.disableAll end,
        get = function()
          return DisenchanterPlus.db.char.general.priceSource
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.priceSource = value
        end,
      },
    }
  }
end
