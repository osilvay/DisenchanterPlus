---@class DP_EnchantGroup
local DP_EnchantGroup = DP_ModuleLoader:CreateModule("DP_EnchantGroup");

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

---Header
---@param order? number
---@return table
function DP_EnchantGroup:Header(order)
  return DP_CustomConfig:CreateHeaderConfig(DisenchanterPlus:DP_i18n("Enchant"), order or 1, DisenchanterPlus:GetAddonColor())
end

---Config
---@param order? number
---@return table
function DP_EnchantGroup:Config(order)
  return {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      enchantEnabled = {
        type = "toggle",
        order = 1,
        name = DisenchanterPlus:DP_i18n("Enable"),
        desc = DisenchanterPlus:DP_i18n("Enable enchant items."),
        width = "full",
        disabled = function() return DisenchanterPlus.db.char.general.disableAll end,
        get = function()
          return DisenchanterPlus.db.char.general.enchantEnabled
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.enchantEnabled = value
          if value then
            C_Timer.After(0.1, function()
            end)
          else
            C_Timer.After(0.1, function()
            end)
          end
        end,
      },
      separator_1 = DP_CustomConfig:CreateSeparatorConfig(1.1),
      filterWithoutMaterials = {
        type = "toggle",
        order = 2,
        name = DisenchanterPlus:DP_i18n("Filter without materials"),
        desc = DisenchanterPlus:DP_i18n("Filter enchants without materials."),
        width = "full",
        disabled = function() return (not DisenchanterPlus.db.char.general.enchantEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.filterWithoutMaterials end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.filterWithoutMaterials = value
        end,
      },
      enchantCraftType = {
        type = "multiselect",
        order = 3,
        width = "full",
        name = DisenchanterPlus:DP_i18n("Craft types"),
        desc = DisenchanterPlus:DP_i18n("Only these types of crafting."),
        values = DP_EnchantGroup:CraftTypeDropdownConfig(),
        disabled = function() return (not DisenchanterPlus.db.char.general.enchantEnabled); end,
        get = function(info, entry)
          return DisenchanterPlus.db.char.general[info[#info]][entry]
        end,
        set = function(info, entry, value)
          DisenchanterPlus.db.char.general[info[#info]][entry] = value
        end,
      },
      enchantItemQuality = {
        type = "multiselect",
        order = 4,
        width = "full",
        name = DisenchanterPlus:DP_i18n("Item qualities"),
        desc = DisenchanterPlus:DP_i18n("Only enchant these item qualities."),
        values = DP_EnchantGroup:ItemQualityDropdownConfig(),
        disabled = function() return (not DisenchanterPlus.db.char.general.enchantEnabled); end,
        get = function(info, entry)
          return DisenchanterPlus.db.char.general[info[#info]][entry]
        end,
        set = function(info, entry, value)
          DisenchanterPlus.db.char.general[info[#info]][entry] = value
        end,
      },
    }
  }
end

function DP_EnchantGroup:ItemQualityDropdownConfig()
  return {
    ["1"] = "|c" .. DP_CustomColors:CustomQualityColors(1) .. DisenchanterPlus:DP_i18n("Common") .. "|r",
    ["2"] = "|c" .. DP_CustomColors:CustomQualityColors(2) .. DisenchanterPlus:DP_i18n("Uncommon") .. "|r",
    ["3"] = "|c" .. DP_CustomColors:CustomQualityColors(3) .. DisenchanterPlus:DP_i18n("Rare") .. "|r",
    ["4"] = "|c" .. DP_CustomColors:CustomQualityColors(4) .. DisenchanterPlus:DP_i18n("Epic") .. "|r",
  }
end

function DP_EnchantGroup:CraftTypeDropdownConfig()
  return {
    ["1"] = "|c" .. DP_CustomColors:CraftTypeColors("optimal") .. DisenchanterPlus:DP_i18n("Optimal") .. "|r",
    ["2"] = "|c" .. DP_CustomColors:CraftTypeColors("medium") .. DisenchanterPlus:DP_i18n("Medium") .. "|r",
    ["3"] = "|c" .. DP_CustomColors:CraftTypeColors("easy") .. DisenchanterPlus:DP_i18n("Easy") .. "|r",
    ["4"] = "|c" .. DP_CustomColors:CraftTypeColors("trivial") .. DisenchanterPlus:DP_i18n("Trivial") .. "|r",
  }
end
