---@class DP_Database
local DP_Database = DP_ModuleLoader:CreateModule("DP_Database")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_CataclysmDisenchantTable
local DP_CataclysmDisenchantTable = DP_ModuleLoader:ImportModule("DP_CataclysmDisenchantTable")

---@type DP_ClassicDisenchantTable
local DP_ClassicDisenchantTable = DP_ModuleLoader:ImportModule("DP_ClassicDisenchantTable")

---@type DP_EnchantPatterns
local DP_EnchantPatterns = DP_ModuleLoader:ImportModule("DP_EnchantPatterns")

local dust = "dust"
local essence = "essence"
local shard = "shard"
local crystal = "crystal"

DisenchanterPlus.EnchantingItems = {
  -- vanilla
  strange_dust = 10940,
  soul_dust = 11083,
  vision_dust = 11137,
  dream_dust = 11176,
  illusion_dust = 16204,
  lesser_magic_essence = 10938,
  greater_magic_essence = 10939,
  lesser_astral_essence = 10998,
  greater_astral_essence = 11082,
  lesser_mystic_essence = 11134,
  greater_mystic_essence = 11135,
  lesser_nether_essence = 11174,
  greater_nether_essence = 11175,
  lesser_eternal_essence = 16202,
  greater_eternal_essence = 16203,
  small_glimmering_shard = 10978,
  large_glimmering_shard = 11084,
  small_glowing_shard = 11138,
  large_glowing_shard = 11139,
  small_radiant_shard = 11177,
  large_radiant_shard = 11178,
  small_brilliant_shard = 14343,
  large_brilliant_shard = 14344,
  nexus_crystal = 20725,
  -- outland
  arcane_dust = 22445,
  lesser_planar_essence = 22447,
  greater_planar_essence = 22446,
  small_prismatic_shard = 22448,
  large_prismatic_shard = 22449,
  void_crystal = 22450,
  -- northrend
  infinite_dust = 34054,
  lesser_cosmic_essence = 34056,
  greater_cosmic_essence = 34055,
  small_dream_shard = 34053,
  dream_shard = 34052,
  abyss_crystal = 34057,
  -- cataclysm
  hypnotic_dust = 52555,
  lesser_celestial_essence = 52718,
  greater_celestial_essence = 52719,
  small_heavenly_shard = 52720,
  heavenly_shard = 52721,
  maelstrom_crystal = 52722,
  -- pandaria
  spirit_dust = 0,
  mysterious_essence = 0,
  small_Ethereal_shard = 0,
  ethereal_shard = 0,
  sha_crystal = 0,
}

local enchantingItemType = {
  [DisenchanterPlus.EnchantingItems.strange_dust]              = dust,
  [DisenchanterPlus.EnchantingItems.soul_dust]                 = dust,
  [DisenchanterPlus.EnchantingItems.vision_dust]               = dust,
  [DisenchanterPlus.EnchantingItems.dream_dust]                = dust,
  [DisenchanterPlus.EnchantingItems.illusion_dust]             = dust,
  [DisenchanterPlus.EnchantingItems.arcane_dust]               = dust,
  [DisenchanterPlus.EnchantingItems.infinite_dust]             = dust,
  [DisenchanterPlus.EnchantingItems.hypnotic_dust]             = dust,
  [DisenchanterPlus.EnchantingItems.lesser_magic_essence]      = essence,
  [DisenchanterPlus.EnchantingItems.greater_magic_essence]     = essence,
  [DisenchanterPlus.EnchantingItems.lesser_astral_essence]     = essence,
  [DisenchanterPlus.EnchantingItems.greater_astral_essence]    = essence,
  [DisenchanterPlus.EnchantingItems.lesser_mystic_essence]     = essence,
  [DisenchanterPlus.EnchantingItems.greater_mystic_essence]    = essence,
  [DisenchanterPlus.EnchantingItems.lesser_nether_essence]     = essence,
  [DisenchanterPlus.EnchantingItems.greater_nether_essence]    = essence,
  [DisenchanterPlus.EnchantingItems.lesser_eternal_essence]    = essence,
  [DisenchanterPlus.EnchantingItems.greater_eternal_essence]   = essence,
  [DisenchanterPlus.EnchantingItems.lesser_planar_essence]     = essence,
  [DisenchanterPlus.EnchantingItems.greater_planar_essence]    = essence,
  [DisenchanterPlus.EnchantingItems.lesser_cosmic_essence]     = essence,
  [DisenchanterPlus.EnchantingItems.greater_cosmic_essence]    = essence,
  [DisenchanterPlus.EnchantingItems.lesser_celestial_essence]  = essence,
  [DisenchanterPlus.EnchantingItems.greater_celestial_essence] = essence,
  [DisenchanterPlus.EnchantingItems.small_glimmering_shard]    = shard,
  [DisenchanterPlus.EnchantingItems.large_glimmering_shard]    = shard,
  [DisenchanterPlus.EnchantingItems.small_glowing_shard]       = shard,
  [DisenchanterPlus.EnchantingItems.large_glowing_shard]       = shard,
  [DisenchanterPlus.EnchantingItems.small_radiant_shard]       = shard,
  [DisenchanterPlus.EnchantingItems.large_radiant_shard]       = shard,
  [DisenchanterPlus.EnchantingItems.small_brilliant_shard]     = shard,
  [DisenchanterPlus.EnchantingItems.large_brilliant_shard]     = shard,
  [DisenchanterPlus.EnchantingItems.small_prismatic_shard]     = shard,
  [DisenchanterPlus.EnchantingItems.large_prismatic_shard]     = shard,
  [DisenchanterPlus.EnchantingItems.small_dream_shard]         = shard,
  [DisenchanterPlus.EnchantingItems.dream_shard]               = shard,
  [DisenchanterPlus.EnchantingItems.small_heavenly_shard]      = shard,
  [DisenchanterPlus.EnchantingItems.heavenly_shard]            = shard,
  [DisenchanterPlus.EnchantingItems.nexus_crystal]             = crystal,
  [DisenchanterPlus.EnchantingItems.void_crystal]              = crystal,
  [DisenchanterPlus.EnchantingItems.abyss_crystal]             = crystal,
  [DisenchanterPlus.EnchantingItems.maelstrom_crystal]         = crystal,
  [DisenchanterPlus.EnchantingItems.spirit_dust]               = dust,
  [DisenchanterPlus.EnchantingItems.mysterious_essence]        = essence,
  [DisenchanterPlus.EnchantingItems.small_Ethereal_shard]      = shard,
  [DisenchanterPlus.EnchantingItems.ethereal_shard]            = shard,
  [DisenchanterPlus.EnchantingItems.sha_crystal]               = crystal
}

function DP_Database:Initialize()
  if DisenchanterPlus.IsClassic or DisenchanterPlus.IsHardcore or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal then
    -- classic_era
    DP_ClassicDisenchantTable:Initialize()
  elseif DisenchanterPlus.IsCataclysm then
    -- cataclysm
    DP_CataclysmDisenchantTable:Initialize()
  end
  DP_EnchantPatterns:Initialize()
end

---Check skill level for item
---@param skillLevel number
---@param itemLevel number
---@param itemMinLevel number
---@param itemQuality number
---@return boolean
function DP_Database:CheckSkillLevelForItem(skillLevel, itemLevel, itemMinLevel, itemQuality)
  --DisenchanterPlus:Debug("skillLevel " .. tostring(skillLevel))
  --DisenchanterPlus:Debug("itemLevel " .. tostring(itemLevel))
  --DisenchanterPlus:Debug("itemMinLevel " .. tostring(itemMinLevel))
  --DisenchanterPlus:Debug("itemQuality " .. tostring(itemQuality))

  if DisenchanterPlus.IsClassic or DisenchanterPlus.IsHardcore or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal then
    -- classic_era
    return DP_ClassicDisenchantTable:CheckSkillLevelForItem() -- always true
  elseif DisenchanterPlus.IsCataclysm then
    -- cataclysm
    return DP_CataclysmDisenchantTable:CheckSkillLevelForItem(skillLevel, itemLevel, itemMinLevel, itemQuality)
  end
  return false
end

---Get expected disenchant data
---@return table
function DP_Database:GetExpectedDisenchantData()
  if DisenchanterPlus.IsClassic or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal or DisenchanterPlus.IsHardcore then
    return DP_ClassicDisenchantTable:GenerateDisenchantTable()
  elseif DisenchanterPlus.IsCataclysm then
    return DP_CataclysmDisenchantTable:GenerateDisenchantTable()
  end
  return {}
end

---Get num entries for stats
---@return table
function DP_Database:GetNumEntries()
  local itemList = DisenchanterPlus.db.global.data.items or {}
  local dustList = DisenchanterPlus.db.global.data.dusts or {}
  local essenceList = DisenchanterPlus.db.global.data.essences or {}
  local shardList = DisenchanterPlus.db.global.data.shards or {}
  local crystalList = DisenchanterPlus.db.global.data.crystals or {}
  --local unknownList = DisenchanterPlus.db.global.data.unknown or {}

  local result = {
    ["1 - " .. DisenchanterPlus:DP_i18n("Items")] = DP_CustomFunctions:TableLength(itemList),
    ["2 - " .. DisenchanterPlus:DP_i18n("Dusts")] = DP_CustomFunctions:TableLength(dustList),
    ["3 - " .. DisenchanterPlus:DP_i18n("Essences")] = DP_CustomFunctions:TableLength(essenceList),
    ["4 - " .. DisenchanterPlus:DP_i18n("Shards")] = DP_CustomFunctions:TableLength(shardList),
    ["5 - " .. DisenchanterPlus:DP_i18n("Crystals")] = DP_CustomFunctions:TableLength(crystalList),
    --[UNKNOWN] = DP_CustomFunctions:TableLength(unknownList),
  }
  --result = DP_CustomFunctions:SortComplexTableByKey(result)
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
---@param itemID number
---@return string
function DP_Database:GetEnchantingItemType(itemID)
  local result = enchantingItemType[itemID] or nil
  --DisenchanterPlus:Debug(string.format("Enchanting itemID type %s = %s", tostring(itemID), result))
  return result
end

---Get item data
---@param itemID number
---@return table|nil
function DP_Database:GetItemData(itemID)
  return DisenchanterPlus.db.global.data.items[itemID] or nil
end

---Set item data
---@param itemID number
---@param itemInfo table
function DP_Database:SetItemData(itemID, itemInfo)
  --DisenchanterPlus:Debug(string.format("Saving enchanting itemID type %s", tostring(itemID)))
  if itemID == nil then return end
  DisenchanterPlus.db.global.data.items[itemID] = itemInfo
end

---Get enchanting item data
---@param itemID number
---@return table|nil
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

---Set enchanting item data
---@param itemID number
---@param lootInfo table
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
