---@class DP_TBCDisenchantTable
local DP_TBCDisenchantTable = DP_ModuleLoader:CreateModule("DP_TBCDisenchantTable")

local L = LibStub("AceLocale-3.0"):GetLocale("DisenchanterPlus")

local armor = L["Armor"]
local weapon = L["Weapon"]
local all = L["All"]

local tbcDisenchantData = {}
local expectedPercents = {}

local skillLevelData = {
  UNCOMMON = {
    { 1,   1,   20 },
    { 25,  21,  25 },
    { 50,  26,  30 },
    { 75,  31,  35 },
    { 100, 36,  40 },
    { 125, 41,  45 },
    { 150, 46,  50 },
    { 175, 51,  55 },
    { 200, 56,  60 },
    { 225, 61,  70 },
    { 275, 71,  80 },
    { 325, 81,  90 },
    { 350, 91,  100 },
    { 375, 101, 125 }
  },
  RARE = {
    { 25,  10,  25 },
    { 50,  26,  30 },
    { 75,  31,  35 },
    { 100, 36,  40 },
    { 125, 41,  45 },
    { 150, 46,  50 },
    { 175, 51,  55 },
    { 200, 56,  60 },
    { 225, 61,  70 },
    { 275, 71,  80 },
    { 325, 81,  90 },
    { 350, 91,  100 },
    { 375, 101, 125 }
  },
  EPIC = {
    { 225, 61,  70 },
    { 275, 71,  80 },
    { 325, 81,  90 },
    { 350, 91,  100 },
    { 375, 101, 125 }
  }
}

function DP_TBCDisenchantTable:Initialize()
  tbcDisenchantData = {
    UNCOMMON = {
      [armor] = {
        { 5,   15,  "1-2x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.lesser_magic_essence,    nil,  nil,                                                     nil, nil },
        { 16,  20,  "2-3x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.greater_magic_essence,   "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, nil, nil },
        { 21,  25,  "4-6x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.lesser_astral_essence,   "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, nil, nil },
        { 26,  30,  "1-2x", DisenchanterPlus.EnchantingItems.soul_dust,     "1-2x", DisenchanterPlus.EnchantingItems.greater_astral_essence,  "1x", DisenchanterPlus.EnchantingItems.large_glimmering_shard, nil, nil },
        { 31,  35,  "2-5x", DisenchanterPlus.EnchantingItems.soul_dust,     "1-2x", DisenchanterPlus.EnchantingItems.lesser_mystic_essence,   "1x", DisenchanterPlus.EnchantingItems.small_glowing_shard,    nil, nil },
        { 36,  40,  "1-2x", DisenchanterPlus.EnchantingItems.vision_dust,   "1-2x", DisenchanterPlus.EnchantingItems.greater_mystic_essence,  "1x", DisenchanterPlus.EnchantingItems.large_glowing_shard,    nil, nil },
        { 41,  45,  "2-5x", DisenchanterPlus.EnchantingItems.vision_dust,   "1-2x", DisenchanterPlus.EnchantingItems.lesser_nether_essence,   "1x", DisenchanterPlus.EnchantingItems.small_radiant_shard,    nil, nil },
        { 46,  50,  "1-2x", DisenchanterPlus.EnchantingItems.dream_dust,    "1-2x", DisenchanterPlus.EnchantingItems.greater_nether_essence,  "1x", DisenchanterPlus.EnchantingItems.large_radiant_shard,    nil, nil },
        { 51,  55,  "2-5x", DisenchanterPlus.EnchantingItems.dream_dust,    "1-2x", DisenchanterPlus.EnchantingItems.lesser_eternal_essence,  "1x", DisenchanterPlus.EnchantingItems.small_brilliant_shard,  nil, nil },
        { 56,  60,  "1-2x", DisenchanterPlus.EnchantingItems.illusion_dust, "1-2x", DisenchanterPlus.EnchantingItems.greater_eternal_essence, "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  nil, nil },
        { 61,  65,  "2-5x", DisenchanterPlus.EnchantingItems.illusion_dust, "2-3x", DisenchanterPlus.EnchantingItems.greater_eternal_essence, "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  nil, nil },
        { 66,  70,  "2-5x", DisenchanterPlus.EnchantingItems.illusion_dust, "2-3x", DisenchanterPlus.EnchantingItems.greater_eternal_essence, "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  nil, nil },
        { 71,  75,  "1-2x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-2x", DisenchanterPlus.EnchantingItems.lesser_planar_essence,   "1x", DisenchanterPlus.EnchantingItems.small_prismatic_shard,  nil, nil },
        { 76,  80,  "2-3x", DisenchanterPlus.EnchantingItems.arcane_dust,   "2-3x", DisenchanterPlus.EnchantingItems.lesser_planar_essence,   "1x", DisenchanterPlus.EnchantingItems.small_prismatic_shard,  nil, nil },
        { 81,  85,  "2-5x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-2x", DisenchanterPlus.EnchantingItems.greater_planar_essence,  "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  nil, nil },
        { 86,  90,  "2-5x", DisenchanterPlus.EnchantingItems.arcane_dust,   "2-3x", DisenchanterPlus.EnchantingItems.greater_planar_essence,  "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  nil, nil },
        { 91,  100, "2-5x", DisenchanterPlus.EnchantingItems.arcane_dust,   "2-3x", DisenchanterPlus.EnchantingItems.greater_planar_essence,  "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  nil, nil },
        { 101, 125, "3-6x", DisenchanterPlus.EnchantingItems.arcane_dust,   "2-3x", DisenchanterPlus.EnchantingItems.greater_planar_essence,  "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  nil, nil }
      },
      [weapon] = {
        { 6,   15,  "1-2x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.lesser_magic_essence,    nil,  nil,                                                     nil, nil },
        { 16,  20,  "2-3x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.greater_magic_essence,   "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, nil, nil },
        { 21,  25,  "4-6x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.lesser_astral_essence,   "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, nil, nil },
        { 26,  30,  "1-2x", DisenchanterPlus.EnchantingItems.soul_dust,     "1-2x", DisenchanterPlus.EnchantingItems.greater_astral_essence,  "1x", DisenchanterPlus.EnchantingItems.large_glimmering_shard, nil, nil },
        { 31,  35,  "2-5x", DisenchanterPlus.EnchantingItems.soul_dust,     "1-2x", DisenchanterPlus.EnchantingItems.lesser_mystic_essence,   "1x", DisenchanterPlus.EnchantingItems.small_glowing_shard,    nil, nil },
        { 36,  40,  "1-2x", DisenchanterPlus.EnchantingItems.vision_dust,   "1-2x", DisenchanterPlus.EnchantingItems.greater_mystic_essence,  "1x", DisenchanterPlus.EnchantingItems.large_glowing_shard,    nil, nil },
        { 41,  45,  "2-5x", DisenchanterPlus.EnchantingItems.vision_dust,   "1-2x", DisenchanterPlus.EnchantingItems.lesser_nether_essence,   "1x", DisenchanterPlus.EnchantingItems.small_radiant_shard,    nil, nil },
        { 46,  50,  "1-2x", DisenchanterPlus.EnchantingItems.dream_dust,    "1-2x", DisenchanterPlus.EnchantingItems.greater_nether_essence,  "1x", DisenchanterPlus.EnchantingItems.large_radiant_shard,    nil, nil },
        { 51,  55,  "2-5x", DisenchanterPlus.EnchantingItems.dream_dust,    "1-2x", DisenchanterPlus.EnchantingItems.lesser_eternal_essence,  "1x", DisenchanterPlus.EnchantingItems.small_brilliant_shard,  nil, nil },
        { 56,  60,  "1-2x", DisenchanterPlus.EnchantingItems.illusion_dust, "1-2x", DisenchanterPlus.EnchantingItems.greater_eternal_essence, "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  nil, nil },
        { 61,  65,  "2-5x", DisenchanterPlus.EnchantingItems.illusion_dust, "2-3x", DisenchanterPlus.EnchantingItems.greater_eternal_essence, "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  nil, nil },
        { 66,  70,  "2-5x", DisenchanterPlus.EnchantingItems.illusion_dust, "2-3x", DisenchanterPlus.EnchantingItems.greater_eternal_essence, "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  nil, nil },
        { 71,  75,  "1-4x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-4x", DisenchanterPlus.EnchantingItems.lesser_planar_essence,   "1x", DisenchanterPlus.EnchantingItems.small_prismatic_shard,  nil, nil },
        { 76,  80,  "1-4x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-4x", DisenchanterPlus.EnchantingItems.lesser_planar_essence,   "1x", DisenchanterPlus.EnchantingItems.small_prismatic_shard,  nil, nil },
        { 81,  85,  "1-4x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-4x", DisenchanterPlus.EnchantingItems.greater_planar_essence,  "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  nil, nil },
        { 86,  90,  "1-4x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-4x", DisenchanterPlus.EnchantingItems.greater_planar_essence,  "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  nil, nil },
        { 91,  100, "1-4x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-4x", DisenchanterPlus.EnchantingItems.greater_planar_essence,  "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  nil, nil },
        { 101, 125, "1-4x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-4x", DisenchanterPlus.EnchantingItems.greater_planar_essence,  "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  nil, nil }
      }
    },
    RARE = {
      [all] = {
        { 1,   25,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, nil,  nil },
        { 26,  30,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.large_glimmering_shard, nil,  nil },
        { 31,  35,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.small_glowing_shard,    nil,  nil },
        { 36,  40,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.large_glowing_shard,    nil,  nil },
        { 41,  45,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.small_radiant_shard,    nil,  nil },
        { 46,  50,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.large_radiant_shard,    nil,  nil },
        { 51,  55,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.small_brilliant_shard,  nil,  nil },
        { 56,  65,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  "1x", DisenchanterPlus.EnchantingItems.nexus_crystal },
        { 66,  70,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  "1x", DisenchanterPlus.EnchantingItems.nexus_crystal },
        { 71,  80,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.small_prismatic_shard,  "1x", DisenchanterPlus.EnchantingItems.void_crystal },
        { 81,  90,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  "1x", DisenchanterPlus.EnchantingItems.void_crystal },
        { 91,  100, nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  "1x", DisenchanterPlus.EnchantingItems.void_crystal },
        { 101, 125, nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  "1x", DisenchanterPlus.EnchantingItems.void_crystal }
      }
    },
    EPIC = {
      [all] = {
        { 40,  45,  nil, nil, nil, nil, "2-4x", DisenchanterPlus.EnchantingItems.small_radiant_shard,   nil,    nil },
        { 46,  50,  nil, nil, nil, nil, "2-4x", DisenchanterPlus.EnchantingItems.large_radiant_shard,   nil,    nil },
        { 51,  55,  nil, nil, nil, nil, "2-4x", DisenchanterPlus.EnchantingItems.small_brilliant_shard, nil,    nil },
        { 56,  60,  nil, nil, nil, nil, nil,    nil,                                                    "1x",   DisenchanterPlus.EnchantingItems.nexus_crystal },
        { 61,  70,  nil, nil, nil, nil, nil,    nil,                                                    "1-2x", DisenchanterPlus.EnchantingItems.nexus_crystal },
        { 71,  80,  nil, nil, nil, nil, nil,    nil,                                                    "1-2x", DisenchanterPlus.EnchantingItems.void_crystal },
        { 81,  90,  nil, nil, nil, nil, nil,    nil,                                                    "1-2x", DisenchanterPlus.EnchantingItems.void_crystal },
        { 91,  100, nil, nil, nil, nil, nil,    nil,                                                    "1-2x", DisenchanterPlus.EnchantingItems.void_crystal },
        { 101, 125, nil, nil, nil, nil, nil,    nil,                                                    "1-2x", DisenchanterPlus.EnchantingItems.void_crystal }
      }
    }
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

---Check skill level for item
---@param skillLevel number
---@param itemLevel number
---@param itemMinLevel number
---@param itemQuality number
---@return boolean
function DP_TBCDisenchantTable:CheckSkillLevelForItem(skillLevel, itemLevel, itemMinLevel, itemQuality)
  local result = false

  if skillLevel and itemLevel and itemQuality then
    local subTable
    if itemQuality == 2 then
      subTable = skillLevelData.UNCOMMON
    elseif itemQuality == 3 then
      subTable = skillLevelData.RARE
    elseif itemQuality == 4 then
      subTable = skillLevelData.EPIC
    else
      subTable = {}
    end

    if subTable then
      for i = #subTable, 1, -1 do
        local minSkillLevel, minItemLevel, maxItemLevel = subTable[i][1], subTable[i][2], subTable[i][3]
        if itemLevel >= minItemLevel and itemLevel <= maxItemLevel and skillLevel >= minSkillLevel then
          result = true
          break
        end
      end
    end
  end

  return result
end

---Get disenchant table
---@return table
function DP_TBCDisenchantTable:GetDisenchantTable()
  return tbcDisenchantData
end

---Get expected percents
---@return table
function DP_TBCDisenchantTable:GetExpectedPercents()
  return expectedPercents
end

---Generate disenchant table
---@return table
function DP_TBCDisenchantTable:GenerateDisenchantTable()
  local uncommonArmors = {}
  local uncommonWeapons = {}
  local rareEquipment = {}
  local epicEquipment = {}

  -- process uncommon **********************************************************************

  -- armors
  local armorData = tbcDisenchantData.UNCOMMON[armor] or {}
  for _, currentArmorData in pairs(armorData) do
    local minItemLevel = currentArmorData[1]
    local maxItemLevel = currentArmorData[2]
    local dustText = currentArmorData[3]
    local dustData = currentArmorData[4]
    local essenceText = currentArmorData[5]
    local essenceData = currentArmorData[6]
    local shardText = currentArmorData[7]
    local shardData = currentArmorData[8]
    local crystalText = currentArmorData[9]
    local crystalData = currentArmorData[10]

    local armorEntry = {
      MinILevel = minItemLevel,
      MaxILevel = maxItemLevel,
      ItemIDs = {}
    }
    if dustData ~= nil then
      armorEntry.ItemIDs[dustData] = {
        Percent = expectedPercents.UNCOMMON.Dust[armor] + (shardData == nil and 5 or 0),
        QuantityText = dustText
      }
    end
    if essenceData ~= nil then
      armorEntry.ItemIDs[essenceData] = {
        Percent = expectedPercents.UNCOMMON.Essence[armor],
        QuantityText = essenceText
      }
    end
    if shardData ~= nil then
      armorEntry.ItemIDs[shardData] = {
        Percent = expectedPercents.UNCOMMON.Shard[armor],
        QuantityText = shardText
      }
    end
    if crystalData ~= nil then
      armorEntry.ItemIDs[crystalData] = {
        Percent = expectedPercents.UNCOMMON.Crystal[armor],
        QuantityText = crystalText
      }
    end
    table.insert(uncommonArmors, armorEntry)
  end

  -- weapons
  local weaponData = tbcDisenchantData.UNCOMMON[weapon] or {}
  for _, currentWeaponData in pairs(weaponData) do
    local minItemLevel = currentWeaponData[1]
    local maxItemLevel = currentWeaponData[2]
    local dustText = currentWeaponData[3]
    local dustData = currentWeaponData[4]
    local essenceText = currentWeaponData[5]
    local essenceData = currentWeaponData[6]
    local shardText = currentWeaponData[7]
    local shardData = currentWeaponData[8]
    local crystalText = currentWeaponData[9]
    local crystalData = currentWeaponData[10]

    local weaponEntry = {
      MinILevel = minItemLevel,
      MaxILevel = maxItemLevel,
      ItemIDs = {}
    }
    if dustData ~= nil then
      weaponEntry.ItemIDs[dustData] = {
        Percent = expectedPercents.UNCOMMON.Dust[weapon] + (shardData == nil and 5 or 0),
        QuantityText = dustText
      }
    end
    if essenceData ~= nil then
      weaponEntry.ItemIDs[essenceData] = {
        Percent = expectedPercents.UNCOMMON.Essence[weapon],
        QuantityText = essenceText
      }
    end
    if shardData ~= nil then
      weaponEntry.ItemIDs[shardData] = {
        Percent = expectedPercents.UNCOMMON.Shard[weapon],
        QuantityText = shardText
      }
    end
    if crystalData ~= nil then
      weaponEntry.ItemIDs[crystalData] = {
        Percent = expectedPercents.UNCOMMON.Crystal[weapon],
        QuantityText = crystalText
      }
    end
    table.insert(uncommonWeapons, weaponEntry)
  end

  -- process rare **************************************************************************
  local rareData = tbcDisenchantData.RARE[all] or {}
  for _, currentWeaponData in pairs(rareData) do
    local minItemLevel = currentWeaponData[1]
    local maxItemLevel = currentWeaponData[2]
    local shardText = currentWeaponData[7]
    local shardData = currentWeaponData[8]
    local crystalText = currentWeaponData[9]
    local crystalData = currentWeaponData[10]

    local rareEntry = {
      MinILevel = minItemLevel,
      MaxILevel = maxItemLevel,
      ItemIDs = {}
    }
    if shardData ~= nil then
      rareEntry.ItemIDs[shardData] = {
        Percent = expectedPercents.RARE.Shard[all] + (crystalData == nil and 0.5 or 0),
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
  end

  -- process epic **************************************************************************
  local epicData = tbcDisenchantData.EPIC[all] or {}
  for _, currentWeaponData in pairs(epicData) do
    local minItemLevel = currentWeaponData[1]
    local maxItemLevel = currentWeaponData[2]
    local shardText = currentWeaponData[7]
    local shardData = currentWeaponData[8]
    local crystalText = currentWeaponData[9]
    local crystalData = currentWeaponData[10]

    local epicEntry = {
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
