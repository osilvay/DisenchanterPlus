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
  local function auctionOptionsDisabled()
    local settings = DisenchanterPlus.db.char.general
    return not settings.tooltipsEnabled or settings.priceSource == nil or settings.priceSource == "none"
  end

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
        disabled = function() return DisenchanterPlus.db.char.general.disableAll end,
        get = function()
          return DisenchanterPlus.db.char.general.tooltipsEnabled
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.tooltipsEnabled = value
        end,
      },
      separator_1 = DP_CustomConfig:CreateSeparatorConfig(1.1),
      pressKeyDown = {
        type = "select",
        order = 2,
        width = "full",
        name = DisenchanterPlus:DP_i18n("Press key to show"),
        values = DP_CustomConfig:KeyDownDropdownConfig(),
        disabled = function() return not DisenchanterPlus.db.char.general.tooltipsEnabled end,
        get = function() return DisenchanterPlus.db.char.general.pressKeyDown end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.pressKeyDown = value
        end,
      },
      --separator_1 = DP_CustomConfig:CreateSeparatorConfig(2),
      showTitle = {
        type = "toggle",
        order = 3,
        name = DisenchanterPlus:DP_i18n("Show title"),
        desc = DisenchanterPlus:DP_i18n("Toggle showing title."),
        width = "full",
        disabled = function() return (not DisenchanterPlus.db.char.general.tooltipsEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.showTitle end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.showTitle = value
        end,
      },
      showItemID = {
        type = "toggle",
        order = 4,
        name = DisenchanterPlus:DP_i18n("Show ItemID"),
        desc = DisenchanterPlus:DP_i18n("Toggle showing item ids."),
        width = "full",
        disabled = function() return (not DisenchanterPlus.db.char.general.tooltipsEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.showItemID end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.showItemID = value
        end,
      },
      zeroValues = {
        type = "toggle",
        order = 5,
        name = DisenchanterPlus:DP_i18n("Show zero values"),
        desc = DisenchanterPlus:DP_i18n("Toggle showing zero values."),
        width = "full",
        disabled = function() return (not DisenchanterPlus.db.char.general.tooltipsEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.zeroValues end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.zeroValues = value
        end,
      },
      showExpectedEssences = {
        type = "toggle",
        order = 6,
        name = DisenchanterPlus:DP_i18n("Show expected materials"),
        desc = DisenchanterPlus:DP_i18n("Toggle showing of expected materials on items."),
        width = "full",
        disabled = function() return (not DisenchanterPlus.db.char.general.tooltipsEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.showExpectedEssences end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.showExpectedEssences = value
        end,
      },
      showAuctionPriceRange = {
        type = "toggle",
        order = 6.1,
        name = DisenchanterPlus:DP_i18n("Show auction price range"),
        desc = DisenchanterPlus:DP_i18n("Show the auction value for the minimum and maximum quantity of each material."),
        width = "full",
        disabled = function()
          return auctionOptionsDisabled() or not DisenchanterPlus.db.char.general.showExpectedEssences
        end,
        get = function() return DisenchanterPlus.db.char.general.showAuctionPriceRange end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.showAuctionPriceRange = value
        end,
      },
      showExpectedValue = {
        type = "toggle",
        order = 6.2,
        name = DisenchanterPlus:DP_i18n("Show expected material value"),
        desc = DisenchanterPlus:DP_i18n("Show the average auction value of materials from one disenchant."),
        width = "full",
        disabled = auctionOptionsDisabled,
        get = function() return DisenchanterPlus.db.char.general.showExpectedValue end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.showExpectedValue = value
        end,
      },
      showRealEssences = {
        type = "toggle",
        order = 7,
        name = DisenchanterPlus:DP_i18n("Show real materials obtained"),
        desc = DisenchanterPlus:DP_i18n("Toggle showing of real materials obtained from items."),
        width = "full",
        disabled = function() return (not DisenchanterPlus.db.char.general.tooltipsEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.showRealEssences end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.showRealEssences = value
        end,
      },
      showDistribution = {
        type = "toggle",
        order = 8,
        name = DisenchanterPlus:DP_i18n("Show distribution"),
        desc = DisenchanterPlus:DP_i18n("Toggle showing how often each quantity of a material was obtained (x1, x2, x3...)."),
        width = "full",
        disabled = function() return (not DisenchanterPlus.db.char.general.tooltipsEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.showDistribution end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.showDistribution = value
        end,
      },
      itemsToShow = {
        type = "range",
        order = 9,
        name = DisenchanterPlus:DP_i18n("Items to show"),
        desc = DisenchanterPlus:DP_i18n("Items to show in tooltip."),
        width = "full",
        min = 1,
        max = 20,
        step = 1,
        disabled = function() return (not DisenchanterPlus.db.char.general.tooltipsEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.itemsToShow end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.itemsToShow = value
        end,
      },
    }
  }
end
