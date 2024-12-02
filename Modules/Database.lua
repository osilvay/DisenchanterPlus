---@class DP_Database
local DP_Database = DP_ModuleLoader:CreateModule("DP_Database")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

local dusts = {}
local essences = {}
local shards = {}
local crystals = {}
local items = {}

local armor, weapon, all
local dust = "dust"
local essence = "essence"
local shard = "shard"
local crystal = "crystal"
local unkonwun = string.lower(UNKNOWN)

local strange_dust = 10940
local soul_dust = 11083
local vision_dust = 11137
local dream_dust = 11176
local illusion_dust = 16204
local arcane_dust = 22445
local infinite_dust = 34054
local hypnotic_dust = 52555
local lesser_magic_essence = 10938
local greater_magic_essence = 10939
local lesser_astral_essence = 10998
local greater_astral_essence = 11082
local lesser_mystic_essence = 11134
local greater_mystic_essence = 11135
local lesser_nether_essence = 11174
local greater_nether_essence = 11175
local lesser_eternal_essence = 16202
local greater_eternal_essence = 16203
local lesser_planar_essence = 22447
local greater_planar_essence = 22446
local lesser_cosmic_essence = 34056
local greater_cosmic_essence = 34055
local lesser_celestial_essence = 52718
local greater_celestial_essence = 52719
local small_glimmering_shard = 10978
local large_glimmering_shard = 11084
local small_glowing_shard = 11138
local large_glowing_shard = 11139
local small_radiant_shard = 11177
local large_radiant_shard = 11178
local small_brilliant_shard = 14343
local large_brilliant_shard = 14344
local small_prismatic_shard = 22448
local large_prismatic_shard = 22449
local small_dream_shard = 34053
local dream_shard = 34052
local small_heavenly_shard = 52720
local heavenly_shard = 52721
local nexus_crystal = 20725
local void_crystal = 22450
local abyss_crystal = 34057
local maelstrom_crystal = 52722

local disenchantData = {
  { 1,   5,   10,  "1-2x", strange_dust,  "1-2x", lesser_magic_essence,      nil,  nil,                    nil,  nil },
  { 1,   11,  15,  "2-3x", strange_dust,  "1-2x", greater_magic_essence,     "1x", small_glimmering_shard, "1x", nil },
  { 25,  16,  20,  "4-6x", strange_dust,  "1-2x", lesser_astral_essence,     "1x", small_glimmering_shard, "1x", nil },
  { 50,  21,  25,  "1-2x", soul_dust,     "1-2x", greater_astral_essence,    "1x", large_glimmering_shard, "1x", nil },
  { 75,  26,  30,  "2-5x", soul_dust,     "1-2x", lesser_mystic_essence,     "1x", small_glowing_shard,    "1x", nil },
  { 100, 31,  35,  "1-2x", vision_dust,   "1-2x", greater_mystic_essence,    "1x", large_glowing_shard,    "1x", nil },
  { 125, 36,  40,  "2-5x", vision_dust,   "1-2x", lesser_nether_essence,     "1x", small_radiant_shard,    "1x", nil },
  { 150, 41,  45,  "1-2x", dream_dust,    "1-2x", greater_nether_essence,    "1x", large_radiant_shard,    "1x", nil },
  { 175, 46,  50,  "2-5x", dream_dust,    "1-2x", lesser_eternal_essence,    "1x", small_brilliant_shard,  "1x", nil },
  { 200, 51,  55,  "1-2x", illusion_dust, "1-2x", greater_eternal_essence,   "1x", large_brilliant_shard,  "1x", nil },
  { 225, 55,  60,  "2-5x", illusion_dust, "1-3x", greater_eternal_essence,   "1x", large_brilliant_shard,  "1x", nexus_crystal },
  { 225, 57,  63,  "1-3x", arcane_dust,   "1-3x", lesser_planar_essence,     "1x", small_prismatic_shard,  "1x", nil },
  { 275, 64,  70,  "2-5x", arcane_dust,   "1-2x", greater_planar_essence,    "1x", large_prismatic_shard,  "1x", void_crystal },
  { 325, 67,  72,  "2-3x", infinite_dust, "1-2x", lesser_cosmic_essence,     "1x", small_dream_shard,      "1x", nil },
  { 350, 73,  80,  "4-7x", infinite_dust, "1-2x", greater_cosmic_essence,    "1x", dream_shard,            "1x", abyss_crystal },
  { 425, 272, 305, "2-3x", hypnotic_dust, "1-2x", lesser_celestial_essence,  "1x", small_heavenly_shard,   "1x", nil },
  { 450, 305, 999, "2-5x", hypnotic_dust, "1-2x", greater_celestial_essence, "1x", heavenly_shard,         "1x", maelstrom_crystal },
}

local enchantingItemType = {
  [strange_dust]              = dust,
  [soul_dust]                 = dust,
  [vision_dust]               = dust,
  [dream_dust]                = dust,
  [illusion_dust]             = dust,
  [arcane_dust]               = dust,
  [infinite_dust]             = dust,
  [hypnotic_dust]             = dust,
  [lesser_magic_essence]      = essence,
  [greater_magic_essence]     = essence,
  [lesser_astral_essence]     = essence,
  [greater_astral_essence]    = essence,
  [lesser_mystic_essence]     = essence,
  [greater_mystic_essence]    = essence,
  [lesser_nether_essence]     = essence,
  [greater_nether_essence]    = essence,
  [lesser_eternal_essence]    = essence,
  [greater_eternal_essence]   = essence,
  [lesser_planar_essence]     = essence,
  [greater_planar_essence]    = essence,
  [lesser_cosmic_essence]     = essence,
  [greater_cosmic_essence]    = essence,
  [lesser_celestial_essence]  = essence,
  [greater_celestial_essence] = essence,
  [small_glimmering_shard]    = shard,
  [large_glimmering_shard]    = shard,
  [small_glowing_shard]       = shard,
  [large_glowing_shard]       = shard,
  [small_radiant_shard]       = shard,
  [large_radiant_shard]       = shard,
  [small_brilliant_shard]     = shard,
  [large_brilliant_shard]     = shard,
  [small_prismatic_shard]     = shard,
  [large_prismatic_shard]     = shard,
  [small_dream_shard]         = shard,
  [dream_shard]               = shard,
  [small_heavenly_shard]      = shard,
  [heavenly_shard]            = shard,
  [nexus_crystal]             = crystal,
  [void_crystal]              = crystal,
  [abyss_crystal]             = crystal,
  [maelstrom_crystal]         = crystal
}

function DP_Database:Initialize()
  armor = DisenchanterPlus:DP_i18n("Armor")
  weapon = DisenchanterPlus:DP_i18n("Weapon")
  all = DisenchanterPlus:DP_i18n("All")
end

---Check skill level for item
---@param skillLevel number
---@param itemLevel number
---@param itemMinLevel number
---@return boolean
function DP_Database:CheckSkillLevelForItem(skillLevel, itemLevel, itemMinLevel)
  --DisenchanterPlus:Debug("skillLevel " .. tostring(skillLevel))
  --DisenchanterPlus:Debug("itemLevel " .. tostring(itemLevel))
  --DisenchanterPlus:Debug("itemMinLevel " .. tostring(itemMinLevel))
  if DisenchanterPlus.IsClassic or DisenchanterPlus.IsHardcore or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal then return true end

  local levelToCheck = 0
  for _, currentData in pairs(disenchantData) do
    local currentSkillLevel = currentData[1]
    local currentMinItemLevel = currentData[2]
    local currentMaxItemLevel = currentData[3]
    if itemLevel >= 272 then
      levelToCheck = itemLevel
    else
      levelToCheck = itemMinLevel
    end
    if levelToCheck >= currentMinItemLevel and levelToCheck <= currentMaxItemLevel and skillLevel >= currentSkillLevel then
      return true
    end
  end
  return false
end

---Get expected disenchant data
---@return table
function DP_Database:GetExpectedDisenchantData()
  local expectedPercents = {
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

  local uncommonArmors = {}
  local uncommonWeapons = {}
  local rareEquipment = {}
  local epicEquipment = {}

  for _, currentData in pairs(disenchantData) do
    local tradeskillLevel = currentData[1]
    local minItemLevel = currentData[2]
    local maxItemLevel = currentData[3]
    local dustText = currentData[4]
    local dustData = currentData[5]
    local essenceText = currentData[6]
    local essenceData = currentData[7]
    local shardText = currentData[8]
    local shardData = currentData[9]
    local crystalText = currentData[10]
    local crystalData = currentData[11]

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

---Get num entries
---@return table
function DP_Database:GetNumEntries()
  local itemList = DisenchanterPlus.db.global.data.items or {}
  local dustList = DisenchanterPlus.db.global.data.dusts or {}
  local essenceList = DisenchanterPlus.db.global.data.essences or {}
  local shardList = DisenchanterPlus.db.global.data.shards or {}
  local crystalList = DisenchanterPlus.db.global.data.crystals or {}
  --local unknownList = DisenchanterPlus.db.global.data.unknown or {}

  local result = {
    [DisenchanterPlus:DP_i18n("Items")] = DP_CustomFunctions:TableLength(itemList),
    [DisenchanterPlus:DP_i18n("Dusts")] = DP_CustomFunctions:TableLength(dustList),
    [DisenchanterPlus:DP_i18n("Essences")] = DP_CustomFunctions:TableLength(essenceList),
    [DisenchanterPlus:DP_i18n("Shards")] = DP_CustomFunctions:TableLength(shardList),
    [DisenchanterPlus:DP_i18n("Crystals")] = DP_CustomFunctions:TableLength(crystalList),
    --[UNKNOWN] = DP_CustomFunctions:TableLength(unknownList),
  }
  result = DP_CustomFunctions:SortComplexTableByKey(result)
  return result
end

---Update database
function DP_Database:UpdateDatabase()
  DisenchanterPlus:Info(DisenchanterPlus:DP_i18n("Update database"))
end

---Consolidate database
function DP_Database:ConsolidateDatabase()
  DisenchanterPlus:Info(DisenchanterPlus:DP_i18n("Consolidate database"))
end

---Clean database
function DP_Database:CleanDatabase()
  DisenchanterPlus:Info(DisenchanterPlus:DP_i18n("Clean database"))
end

---Purge database
function DP_Database:PurgeDatabase()
  DisenchanterPlus:Info(DisenchanterPlus:DP_i18n("Purge database"))
  DisenchanterPlus.db.global.data.items = {}
  DisenchanterPlus.db.global.data.dusts = {}
  DisenchanterPlus.db.global.data.essences = {}
  DisenchanterPlus.db.global.data.shards = {}
  DisenchanterPlus.db.global.data.crystals = {}
end

---Get enchanting item type
function DP_Database:GetEnchantingItemType(itemID)
  local result = enchantingItemType[itemID] or nil
  --DisenchanterPlus:Debug(string.format("Enchanting itemID type %s = %s", tostring(itemID), result))
  return result
end

function DP_Database:GetItemData(itemID)
  return DisenchanterPlus.db.global.data.items[itemID] or nil
end

function DP_Database:SetItemData(itemID, itemInfo)
  --DisenchanterPlus:Debug(string.format("Saving enchanting itemID type %s", tostring(itemID)))
  if itemID == nil then return end
  DisenchanterPlus.db.global.data.items[itemID] = itemInfo
end

function DP_Database:GetEnchantingItemData(itemID)
  local type = DP_Database:GetEnchantingItemType(itemID)
  if type == nil then return end
  local result = {}
  if type == dust then
    result = DisenchanterPlus.db.global.data.dusts[itemID] or {}
  elseif type == essence then
    result = DisenchanterPlus.db.global.data.essences[itemID] or {}
  elseif type == shard then
    result = DisenchanterPlus.db.global.data.shards[itemID] or {}
  elseif type == crystal then
    result = DisenchanterPlus.db.global.data.crystals[itemID] or {}
  end
  return result
end

function DP_Database:SetEnchantingItemData(itemID, lootInfo)
  local type = DP_Database:GetEnchantingItemType(itemID)
  if type == nil then return end
  if type == dust then
    DisenchanterPlus.db.global.data.dusts[itemID] = lootInfo
  elseif type == essence then
    DisenchanterPlus.db.global.data.essences[itemID] = lootInfo
  elseif type == shard then
    DisenchanterPlus.db.global.data.shards[itemID] = lootInfo
  elseif type == crystal then
    DisenchanterPlus.db.global.data.crystals[itemID] = lootInfo
  end
end
