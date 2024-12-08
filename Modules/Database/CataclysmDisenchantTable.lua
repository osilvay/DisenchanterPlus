---@class DP_CataclysmDisenchantTable
local DP_CataclysmDisenchantTable = DP_ModuleLoader:CreateModule("DP_CataclysmDisenchantTable")

local L = LibStub("AceLocale-3.0"):GetLocale("DisenchanterPlus")

local armor = L["Armor"]
local weapon = L["Weapon"]
local all = L["All"]

local cataclysmDisenchantData = {}
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
    { 225, 61,  99 },
    { 275, 102, 120 },
    { 325, 130, 150 },
    { 350, 154, 182 },
    { 425, 232, 318 },
    { 475, 372, 437 }
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
    { 225, 61,  97 },
    { 275, 100, 115 },
    { 325, 130, 200 },
    { 450, 288, 346 },
    { 525, 417, 424 },
    { 550, 425, 463 }
  },
  EPIC = {
    { 225, 61,  95 },
    { 300, 100, 164 },
    { 375, 200, 277 },
    { 475, 300, 416 },
    { 575, 420, 575 },
  }
}

function DP_CataclysmDisenchantTable:Initialize()
  cataclysmDisenchantData = {
    UNCOMMON = {
      [armor] = {
        { 5,   15,  "1-2x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.lesser_magic_essence,      nil,  nil,                                                     nil, nil },
        { 16,  20,  "2-3x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.greater_magic_essence,     "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, nil, nil },
        { 21,  25,  "4-6x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.lesser_astral_essence,     "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, nil, nil },
        { 26,  30,  "1-2x", DisenchanterPlus.EnchantingItems.soul_dust,     "1-2x", DisenchanterPlus.EnchantingItems.greater_astral_essence,    "1x", DisenchanterPlus.EnchantingItems.large_glimmering_shard, nil, nil },
        { 31,  35,  "2-5x", DisenchanterPlus.EnchantingItems.soul_dust,     "1-2x", DisenchanterPlus.EnchantingItems.lesser_mystic_essence,     "1x", DisenchanterPlus.EnchantingItems.small_glowing_shard,    nil, nil },
        { 36,  40,  "1-2x", DisenchanterPlus.EnchantingItems.vision_dust,   "1-2x", DisenchanterPlus.EnchantingItems.greater_mystic_essence,    "1x", DisenchanterPlus.EnchantingItems.large_glowing_shard,    nil, nil },
        { 41,  45,  "2-5x", DisenchanterPlus.EnchantingItems.vision_dust,   "1-2x", DisenchanterPlus.EnchantingItems.lesser_nether_essence,     "1x", DisenchanterPlus.EnchantingItems.small_radiant_shard,    nil, nil },
        { 46,  50,  "1-2x", DisenchanterPlus.EnchantingItems.dream_dust,    "1-2x", DisenchanterPlus.EnchantingItems.greater_nether_essence,    "1x", DisenchanterPlus.EnchantingItems.large_radiant_shard,    nil, nil },
        { 51,  55,  "2-5x", DisenchanterPlus.EnchantingItems.dream_dust,    "1-2x", DisenchanterPlus.EnchantingItems.lesser_eternal_essence,    "1x", DisenchanterPlus.EnchantingItems.small_brilliant_shard,  nil, nil },
        { 56,  60,  "1-2x", DisenchanterPlus.EnchantingItems.illusion_dust, "1-2x", DisenchanterPlus.EnchantingItems.greater_eternal_essence,   "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  nil, nil },
        { 61,  65,  "2-5x", DisenchanterPlus.EnchantingItems.illusion_dust, "2-3x", DisenchanterPlus.EnchantingItems.greater_eternal_essence,   "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  nil, nil },
        { 79,  79,  "1-2x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-2x", DisenchanterPlus.EnchantingItems.lesser_planar_essence,     "1x", DisenchanterPlus.EnchantingItems.small_prismatic_shard,  nil, nil },
        { 80,  99,  "2-3x", DisenchanterPlus.EnchantingItems.arcane_dust,   "2-3x", DisenchanterPlus.EnchantingItems.lesser_planar_essence,     "1x", DisenchanterPlus.EnchantingItems.small_prismatic_shard,  nil, nil },
        { 100, 120, "2-5x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-2x", DisenchanterPlus.EnchantingItems.greater_planar_essence,    "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  nil, nil },
        { 130, 151, "2-3x", DisenchanterPlus.EnchantingItems.infinite_dust, "1-2x", DisenchanterPlus.EnchantingItems.lesser_cosmic_essence,     "1x", DisenchanterPlus.EnchantingItems.small_dream_shard,      nil, nil },
        { 152, 200, "4-7x", DisenchanterPlus.EnchantingItems.infinite_dust, "1-2x", DisenchanterPlus.EnchantingItems.greater_cosmic_essence,    "1x", DisenchanterPlus.EnchantingItems.dream_shard,            nil, nil },
        { 272, 305, "2-3x", DisenchanterPlus.EnchantingItems.hypnotic_dust, "1-3x", DisenchanterPlus.EnchantingItems.lesser_celestial_essence,  "1x", DisenchanterPlus.EnchantingItems.small_heavenly_shard,   nil, nil },
        { 305, 333, "2-5x", DisenchanterPlus.EnchantingItems.hypnotic_dust, "1-2x", DisenchanterPlus.EnchantingItems.greater_celestial_essence, "1x", DisenchanterPlus.EnchantingItems.heavenly_shard,         nil, nil },
      },
      [weapon] = {
        { 6,   15,  "1-2x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.lesser_magic_essence,      nil,  nil,                                                     nil, nil },
        { 16,  20,  "2-3x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.greater_magic_essence,     "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, nil, nil },
        { 21,  25,  "4-6x", DisenchanterPlus.EnchantingItems.strange_dust,  "1-2x", DisenchanterPlus.EnchantingItems.lesser_astral_essence,     "1x", DisenchanterPlus.EnchantingItems.small_glimmering_shard, nil, nil },
        { 26,  30,  "1-2x", DisenchanterPlus.EnchantingItems.soul_dust,     "1-2x", DisenchanterPlus.EnchantingItems.greater_astral_essence,    "1x", DisenchanterPlus.EnchantingItems.large_glimmering_shard, nil, nil },
        { 31,  35,  "2-5x", DisenchanterPlus.EnchantingItems.soul_dust,     "1-2x", DisenchanterPlus.EnchantingItems.lesser_mystic_essence,     "1x", DisenchanterPlus.EnchantingItems.small_glowing_shard,    nil, nil },
        { 36,  40,  "1-2x", DisenchanterPlus.EnchantingItems.vision_dust,   "1-2x", DisenchanterPlus.EnchantingItems.greater_mystic_essence,    "1x", DisenchanterPlus.EnchantingItems.large_glowing_shard,    nil, nil },
        { 41,  45,  "2-5x", DisenchanterPlus.EnchantingItems.vision_dust,   "1-2x", DisenchanterPlus.EnchantingItems.lesser_nether_essence,     "1x", DisenchanterPlus.EnchantingItems.small_radiant_shard,    nil, nil },
        { 46,  50,  "1-2x", DisenchanterPlus.EnchantingItems.dream_dust,    "1-2x", DisenchanterPlus.EnchantingItems.greater_nether_essence,    "1x", DisenchanterPlus.EnchantingItems.large_radiant_shard,    nil, nil },
        { 51,  55,  "2-5x", DisenchanterPlus.EnchantingItems.dream_dust,    "1-2x", DisenchanterPlus.EnchantingItems.lesser_eternal_essence,    "1x", DisenchanterPlus.EnchantingItems.small_brilliant_shard,  nil, nil },
        { 56,  60,  "1-2x", DisenchanterPlus.EnchantingItems.illusion_dust, "1-2x", DisenchanterPlus.EnchantingItems.greater_eternal_essence,   "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  nil, nil },
        { 61,  65,  "2-5x", DisenchanterPlus.EnchantingItems.illusion_dust, "2-3x", DisenchanterPlus.EnchantingItems.greater_eternal_essence,   "1x", DisenchanterPlus.EnchantingItems.large_brilliant_shard,  nil, nil },
        { 80,  99,  "2-3x", DisenchanterPlus.EnchantingItems.arcane_dust,   "2-3x", DisenchanterPlus.EnchantingItems.lesser_planar_essence,     "1x", DisenchanterPlus.EnchantingItems.small_prismatic_shard,  nil, nil },
        { 100, 120, "2-5x", DisenchanterPlus.EnchantingItems.arcane_dust,   "1-2x", DisenchanterPlus.EnchantingItems.greater_planar_essence,    "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  nil, nil },
        { 130, 151, "2-3x", DisenchanterPlus.EnchantingItems.infinite_dust, "1-2x", DisenchanterPlus.EnchantingItems.lesser_cosmic_essence,     "1x", DisenchanterPlus.EnchantingItems.small_dream_shard,      nil, nil },
        { 152, 200, "4-7x", DisenchanterPlus.EnchantingItems.infinite_dust, "1-2x", DisenchanterPlus.EnchantingItems.greater_cosmic_essence,    "1x", DisenchanterPlus.EnchantingItems.dream_shard,            nil, nil },
        { 306, 306, "1-4x", DisenchanterPlus.EnchantingItems.hypnotic_dust, "1-4x", DisenchanterPlus.EnchantingItems.lesser_celestial_essence,  "1x", DisenchanterPlus.EnchantingItems.small_heavenly_shard,   nil, nil },
        { 307, 333, "2-5x", DisenchanterPlus.EnchantingItems.hypnotic_dust, "1-4x", DisenchanterPlus.EnchantingItems.greater_celestial_essence, "1x", DisenchanterPlus.EnchantingItems.heavenly_shard,         nil, nil },
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
        { 66,  99,  nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.small_prismatic_shard,  "1x", DisenchanterPlus.EnchantingItems.nexus_crystal },
        { 100, 115, nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.large_prismatic_shard,  "1x", DisenchanterPlus.EnchantingItems.void_crystal },
        { 130, 166, nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.small_dream_shard,      nil,  nil },
        { 167, 200, nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.dream_shard,            nil,  nil },
        { 279, 316, nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.small_heavenly_shard,   nil,  nil },
        { 318, 352, nil, nil, nil, nil, "1x", DisenchanterPlus.EnchantingItems.heavenly_shard,         nil,  nil },
      }
    },
    EPIC = {
      [all] = {
        { 40,  45,  nil, nil, nil, nil, "2-4x", DisenchanterPlus.EnchantingItems.small_radiant_shard,   nil,    nil },
        { 46,  50,  nil, nil, nil, nil, "2-4x", DisenchanterPlus.EnchantingItems.large_radiant_shard,   nil,    nil },
        { 51,  55,  nil, nil, nil, nil, "2-4x", DisenchanterPlus.EnchantingItems.small_brilliant_shard, nil,    nil },
        { 56,  60,  nil, nil, nil, nil, nil,    nil,                                                    "1x",   DisenchanterPlus.EnchantingItems.nexus_crystal },
        { 61,  88,  nil, nil, nil, nil, nil,    nil,                                                    "1-2x", DisenchanterPlus.EnchantingItems.nexus_crystal },
        { 90,  100, nil, nil, nil, nil, nil,    nil,                                                    "1-2x", DisenchanterPlus.EnchantingItems.void_crystal },
        { 105, 164, nil, nil, nil, nil, nil,    nil,                                                    "1-2x", DisenchanterPlus.EnchantingItems.void_crystal },
        { 185, 199, nil, nil, nil, nil, nil,    nil,                                                    "1-2x", DisenchanterPlus.EnchantingItems.abyss_crystal },
        { 200, 284, nil, nil, nil, nil, nil,    nil,                                                    "1x",   DisenchanterPlus.EnchantingItems.abyss_crystal },
        { 285, 359, nil, nil, nil, nil, nil,    nil,                                                    "1x",   DisenchanterPlus.EnchantingItems.maelstrom_crystal },
        { 360, 999, nil, nil, nil, nil, nil,    nil,                                                    "1-2x", DisenchanterPlus.EnchantingItems.maelstrom_crystal },
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

---Check kill level for item
---@param skillLevel number
---@param itemLevel number
---@param itemMinLevel number
---@param itemQuality number
---@return boolean
function DP_CataclysmDisenchantTable:CheckSkillLevelForItem(skillLevel, itemLevel, itemMinLevel, itemQuality)
  --DisenchanterPlus:Debug(tostring(skillLevel))
  --DisenchanterPlus:Debug(tostring(itemLevel))
  --DisenchanterPlus:Debug(tostring(itemMinLevel))
  --DisenchanterPlus:Debug(tostring(itemQuality))
  local result = false

  if skillLevel and itemLevel and itemQuality then
    local subTable
    if itemQuality == 2 then
      --DisenchanterPlus:Debug(tostring("Uncommon"))
      subTable = skillLevelData.UNCOMMON
    elseif itemQuality == 3 then
      --DisenchanterPlus:Debug(tostring("Rare"))
      subTable = skillLevelData.RARE
    elseif itemQuality == 4 then
      --DisenchanterPlus:Debug(tostring("Epic"))
      subTable = skillLevelData.EPIC
    else
      --DisenchanterPlus:Debug(tostring("Unknown"))
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
  --DisenchanterPlus:Debug(tostring(result))
  return result
end

---Get disenchant table
---@return table
function DP_CataclysmDisenchantTable:GetDisenchantTable()
  return cataclysmDisenchantData
end

---Get expected percents
---@return table
function DP_CataclysmDisenchantTable:GetExpectedPercents()
  return expectedPercents
end

---Generate disenchant table
---@return table
function DP_CataclysmDisenchantTable:GenerateDisenchantTable()
  local uncommonArmors = {}
  local uncommonWeapons = {}
  local rareEquipment = {}
  local epicEquipment = {}

  -- process uncommon **********************************************************************

  -- armors
  local armorData = cataclysmDisenchantData.UNCOMMON[armor] or {}
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
  local weaponData = cataclysmDisenchantData.UNCOMMON[weapon] or {}
  local index = 0
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
    --DisenchanterPlus:Debug(tostring(minItemLevel) .. " - " .. tostring(maxItemLevel))
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
    --DisenchanterPlus:Dump(weaponEntry)
    table.insert(uncommonWeapons, weaponEntry)
  end

  -- process rare **************************************************************************
  local rareData = cataclysmDisenchantData.RARE[all] or {}
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
  local epicData = cataclysmDisenchantData.EPIC[all] or {}
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
