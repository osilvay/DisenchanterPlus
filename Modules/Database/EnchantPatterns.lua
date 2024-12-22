---@class DP_EnchantPatterns
local DP_EnchantPatterns = DP_ModuleLoader:CreateModule("DP_EnchantPatterns")

local L = LibStub("AceLocale-3.0"):GetLocale("DisenchanterPlus")

local EquipLocationsForEnchantTypes = {}
local EnchantTypeExclusions = {}

function DP_EnchantPatterns:Initialize()
  EquipLocationsForEnchantTypes[DisenchanterPlus:DP_i18n("enchant bracer")] = {
    "INVTYPE_WRIST"
  }
  EquipLocationsForEnchantTypes[DisenchanterPlus:DP_i18n("enchant cloak")] = {
    "INVTYPE_CLOAK"
  }
  EquipLocationsForEnchantTypes[DisenchanterPlus:DP_i18n("enchant weapon")] = {
    "INVTYPE_WEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPONOFFHAND"
  }
  EquipLocationsForEnchantTypes[DisenchanterPlus:DP_i18n("enchant 2h weapon")] = {
    "INVTYPE_2HWEAPON"
  }
  EquipLocationsForEnchantTypes[DisenchanterPlus:DP_i18n("enchant chest")] = {
    "INVTYPE_CHEST"
  }
  EquipLocationsForEnchantTypes[DisenchanterPlus:DP_i18n("enchant boots")] = {
    "INVTYPE_FEET"
  }
  EquipLocationsForEnchantTypes[DisenchanterPlus:DP_i18n("enchant gloves")] = {
    "INVTYPE_HAND"
  }
  EquipLocationsForEnchantTypes[DisenchanterPlus:DP_i18n("enchant shield")] = {
    "INVTYPE_SHIELD"
  }

  EnchantTypeExclusions = {
    DisenchanterPlus:DP_i18n("runed copper rod"),
    DisenchanterPlus:DP_i18n("runed silver Rod"),
    DisenchanterPlus:DP_i18n("runed golden Rod"),
    DisenchanterPlus:DP_i18n("runed truesilver rod"),
    DisenchanterPlus:DP_i18n("runed arcanite rod"),
    DisenchanterPlus:DP_i18n("minor wizard oil"),
    DisenchanterPlus:DP_i18n("minor mana oil"),
    DisenchanterPlus:DP_i18n("lesser wizard oil"),
    DisenchanterPlus:DP_i18n("lesser mana oil"),
    DisenchanterPlus:DP_i18n("wizard oil"),
    DisenchanterPlus:DP_i18n("brilliant mana oil"),
    DisenchanterPlus:DP_i18n("brilliant wizard oil"),
  }
end

function DP_EnchantPatterns:GetEnchantTypeExclusions()
  return EnchantTypeExclusions
end

function DP_EnchantPatterns:GetEquipLocationsForEnchantTypes()
  return EquipLocationsForEnchantTypes
end
