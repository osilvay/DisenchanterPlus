---@class DP_GeneralGroup
local DP_GeneralGroup = DP_ModuleLoader:CreateModule("DP_GeneralGroup");

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---@type DP_CustomMedias
local DP_CustomMedias = DP_ModuleLoader:ImportModule("DP_CustomMedias")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

---@type DP_DisenchantProcess
local DP_DisenchantProcess = DP_ModuleLoader:ImportModule("DP_DisenchantProcess")

---Header
---@param order? number
---@return table
function DP_GeneralGroup:Header(order)
  return DP_CustomConfig:CreateHeaderConfig(DisenchanterPlus:DP_i18n("General"), order or 1, DisenchanterPlus:GetAddonColor())
end

---Config
---@param order? number
---@return table
function DP_GeneralGroup:Config(order)
  -- Import the Minimap module so we can call the toggle function
  local DP_MinimapIcon = DP_ModuleLoader:ImportModule("DP_MinimapIcon")

  return {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      disableAll = {
        type = "toggle",
        order = 1,
        name = DisenchanterPlus:DP_i18n("Disable all"),
        desc = DisenchanterPlus:DP_i18n("Disable all settings."),
        width = "full",
        disabled = false,
        get = function()
          return DisenchanterPlus.db.char.general.disableAll
        end,
        set = function(info, value)
          DP_GeneralGroup:CheckStatus(value)
          DisenchanterPlus.db.char.general.disableAll = value
        end,
      },
      -- NEW: Hide Minimap Icon Toggle
      hideMinimap = {
        type = "toggle",
        order = 2, -- Appears below "Disable all"
        name = "Hide Minimap Icon", -- You can wrap this in DP_i18n if you have translations
        desc = "Hide the DisenchanterPlus button from the minimap.",
        width = "full",
        get = function()
          return DisenchanterPlus.db.profile.minimap.hide
        end,
        set = function(info, value)
          DisenchanterPlus.db.profile.minimap.hide = value
          -- Call the visibility function to apply the change immediately
          if DP_MinimapIcon and DP_MinimapIcon.ToggleVisibility then
            DP_MinimapIcon:ToggleVisibility()
          end
        end,
      },
    },
  }
end

function DP_GeneralGroup:CheckStatus(status)
  if status then
    DisenchanterPlus.db.char.general.tooltipsEnabled = false
    DisenchanterPlus.db.char.general.autoDisenchantEnabled = false
    DisenchanterPlus.db.char.general.enchantEnabled = false
  else
    DisenchanterPlus.db.char.general.tooltipsEnabled = true
    DisenchanterPlus.db.char.general.autoDisenchantEnabled = true
    DisenchanterPlus.db.char.general.enchantEnabled = true
  end
end
