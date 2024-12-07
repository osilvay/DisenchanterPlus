---@class DP_ClassicDisenchantTable
local DP_ClassicDisenchantTable = DP_ModuleLoader:CreateModule("DP_ClassicDisenchantTable")

local L = LibStub("AceLocale-3.0"):GetLocale("DisenchanterPlus")

local armor = L["Armor"]
local weapon = L["Weapon"]
local all = L["All"]

local classicDisenchantData = {}
local expectedPercents = {}

function DP_ClassicDisenchantTable:Initialize()
  classicDisenchantData = {
    { 5,  10, "1-2x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.lesser_magic_essence,    nil,  nil,                                                     nil,  nil },
    { 11, 15, "2-3x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.greater_magic_essence,   "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, "1x", nil },
    { 16, 20, "4-6x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.lesser_astral_essence,   "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, "1x", nil },
    { 21, 25, "1-2x", DisenchanterPlus.EnchantingItems.soul_dust,     "1-2x", DisenchanterPlus.EnchantingItems.greater_astral_essence,  "1x", DisenchanterPlus.EnchantingItems.large_glimmering_shard, "1x", nil },
    { 26, 30, "2-5x", DisenchanterPlus.EnchantingItems.soul_dust,     "1-2x", DisenchanterPlus.EnchantingItems.lesser_mystic_essence,   "1x", DisenchanterPlus.EnchantingItems.small_glowing_shard,    "1x", nil },
    { 31, 35, "1-2x", DisenchanterPlus.EnchantingItems.vision_dust,   "1-2x", DisenchanterPlus.EnchantingItems.greater_mystic_essence,  "1x", DisenchanterPlus.EnchantingItems.large_glowing_shard,    "1x", nil },
    { 36, 40, "2-5x", DisenchanterPlus.EnchantingItems.vision_dust,   "1-2x", DisenchanterPlus.EnchantingItems.lesser_nether_essence,   "1x", DisenchanterPlus.EnchantingItems.small_radiant_shard,    "1x", nil },
    { 41, 45, "1-2x", DisenchanterPlus.EnchantingItems.dream_dust,    "1-2x", DisenchanterPlus.EnchantingItems.greater_nether_essence,  "1x", DisenchanterPlus.EnchantingItems.large_radiant_shard,    "1x", nil },
    { 46, 50, "2-5x", DisenchanterPlus.EnchantingItems.dream_dust,    "1-2x", DisenchanterPlus.EnchantingItems.lesser_eternal_essence,  "1x", DisenchanterPlus.EnchantingItems.small_brilliant_shard,  "1x", nil },
    { 51, 55, "1-2x", DisenchanterPlus.EnchantingItems.illusion_dust, "1-2x", DisenchanterPlus.EnchantingItems.greater_eternal_essence, "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  "1x", nil },
    { 55, 60, "2-5x", DisenchanterPlus.EnchantingItems.illusion_dust, "1-3x", DisenchanterPlus.EnchantingItems.greater_eternal_essence, "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  "1x", DisenchanterPlus.EnchantingItems.nexus_crystal }
  }
  expectedPercents = {
    UNCOMMON = {
      Dust = {
        [armor] = 75,
        [weapon] = 20
      },
      Essence = {
        [armor] = 20,
        [weapon] = 75
      },
      Shard = {
        [armor] = 5,
        [weapon] = 5
      },
      Crystal = {
        [armor] = 0,
        [weapon] = 0
      },
    },
    RARE = {
      Dust = {
        [all] = 0,
      },
      Essence = {
        [all] = 0,
      },
      Shard = {
        [all] = 99.5,
      },
      Crystal = {
        [all] = 0.5,
      },
    },
    EPIC = {
      Dust = {
        [all] = 0,
      },
      Essence = {
        [all] = 0,
      },
      Shard = {
        [all] = 0,
      },
      Crystal = {
        [all] = 100,
      },
    }
  }
end

---Check kill level for item
---@return boolean
function DP_ClassicDisenchantTable:CheckSkillLevelForItem()
  return true
end

---Get disenchant table
---@return table
function DP_ClassicDisenchantTable:GetDisenchantTable()
  return classicDisenchantData
end

---Get expected percents
---@return table
function DP_ClassicDisenchantTable:GetExpectedPercents()
  return expectedPercents
end

---Generate disenchant table
---@return table
function DP_ClassicDisenchantTable:GenerateDisenchantTable()
  local uncommonArmors = {}
  local uncommonWeapons = {}
  local rareEquipment = {}
  local epicEquipment = {}

  for _, currentData in pairs(classicDisenchantData) do
    local tradeskillLevel = 0
    local minItemLevel = currentData[1]
    local maxItemLevel = currentData[2]
    local dustText = currentData[3]
    local dustData = currentData[4]
    local essenceText = currentData[5]
    local essenceData = currentData[6]
    local shardText = currentData[7]
    local shardData = currentData[8]
    local crystalText = currentData[9]
    local crystalData = currentData[10]

    -- process uncommon **********************************************************************
    local armorEntry = {
      TradeskillLevel = tradeskillLevel,
      MinILevel = minItemLevel,
      MaxILevel = maxItemLevel,
      ItemIDs = {}
    }
    local weaponEntry = {
      TradeskillLevel = tradeskillLevel,
      MinILevel = minItemLevel,
      MaxILevel = maxItemLevel,
      ItemIDs = {}
    }

    if dustData ~= nil then
      armorEntry.ItemIDs[dustData] = {
        Percent = expectedPercents.UNCOMMON.Dust[armor],
        QuantityText = dustText
      }
      weaponEntry.ItemIDs[dustData] = {
        Percent = expectedPercents.UNCOMMON.Dust[weapon],
        QuantityText = dustText
      }
    end
    if essenceData ~= nil then
      armorEntry.ItemIDs[essenceData] = {
        Percent = expectedPercents.UNCOMMON.Essence[armor],
        QuantityText = essenceText
      }
      weaponEntry.ItemIDs[essenceData] = {
        Percent = expectedPercents.UNCOMMON.Essence[weapon],
        QuantityText = essenceText
      }
    end
    if shardData ~= nil then
      armorEntry.ItemIDs[shardData] = {
        Percent = expectedPercents.UNCOMMON.Shard[armor],
        QuantityText = shardText
      }
      weaponEntry.ItemIDs[shardData] = {
        Percent = expectedPercents.UNCOMMON.Shard[weapon],
        QuantityText = shardText
      }
    end
    if crystalData ~= nil then
      armorEntry.ItemIDs[crystalData] = {
        Percent = expectedPercents.UNCOMMON.Crystal[armor],
        QuantityText = crystalText
      }
      weaponEntry.ItemIDs[crystalData] = {
        Percent = expectedPercents.UNCOMMON.Crystal[weapon],
        QuantityText = crystalText
      }
    end
    table.insert(uncommonArmors, armorEntry)
    table.insert(uncommonWeapons, weaponEntry)

    -- process rare **********************************************************************
    local rareEntry = {
      TradeskillLevel = tradeskillLevel,
      MinILevel = minItemLevel,
      MaxILevel = maxItemLevel,
      ItemIDs = {}
    }
    if shardData ~= nil then
      rareEntry.ItemIDs[shardData] = {
        Percent = expectedPercents.RARE.Shard[all],
        QuantityText = shardText
      }
    end
    if crystalData ~= nil then
      rareEntry.ItemIDs[crystalData] = {
        Percent = expectedPercents.RARE.Crystal[all],
        QuantityText = crystalText
      }
    end
    table.insert(rareEquipment, rareEntry)

    -- process epic **********************************************************************
    local epicEntry = {
      TradeskillLevel = tradeskillLevel,
      MinILevel = minItemLevel,
      MaxILevel = maxItemLevel,
      ItemIDs = {}
    }
    if shardData ~= nil then
      epicEntry.ItemIDs[shardData] = {
        Percent = expectedPercents.EPIC.Shard[all],
        QuantityText = shardText
      }
    end
    if crystalData ~= nil then
      epicEntry.ItemIDs[crystalData] = {
        Percent = expectedPercents.EPIC.Crystal[all],
        QuantityText = crystalText
      }
    end
    table.insert(epicEquipment, epicEntry)
  end

  return {
    UNCOMMON = {
      [armor] = uncommonArmors,
      [weapon] = uncommonWeapons
    },
    RARE = {
      [all] = rareEquipment
    },
    EPIC = {
      [all] = epicEquipment
    }
  }
end
