---@class DP_LootProcess
local DP_LootProcess = DP_ModuleLoader:CreateModule("DP_LootProcess")

---@type DP_Database
local DP_Database = DP_ModuleLoader:ImportModule("DP_Database")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

local MaxLootReadyCount = 0
local LootingInProgress = false
local allProfessionID = {}
local IsTradeSkill = false
local TradeSkillInfo = {}
local ItemLockedInfo = {}
local IsItemLocked = false
local CopperPerSilver = 100
local SilverPerGold = 100
local dust = "dust"
local essence = "essence"
local shard = "shard"
local crystal = "crystal"
local unkonwun = string.lower(UNKNOWN)

function DP_LootProcess:Initialize()
  allProfessionID = {
    Enchanting = {
      spellID = { 13262, 7411, 7412, 7413, 13920, 28029, 51313, 74258 },
      professionName = DisenchanterPlus:DP_i18n("Enchanting")
    },
  }
end

---loot ready
function DP_LootProcess:LootReady()
  --DisenchanterPlus:Debug("LootingInProgress : " .. tostring(LootingInProgress))
  if LootingInProgress then
    return
  else
    LootingInProgress = true
  end

  MaxLootReadyCount = math.max(MaxLootReadyCount, GetNumLootItems())
  --DisenchanterPlus:Debug("MaxLootReadyCount : " .. tostring(MaxLootReadyCount))
  for slotIndex = 1, GetNumLootItems() do
    local lootLink = GetLootSlotLink(slotIndex)
    local slotType = GetLootSlotType(slotIndex)
    local itemID = GetItemInfoFromHyperlink(lootLink)
    if itemID == nil then return end

    local lootIcon, lootName, lootQuantity, currencyID, lootQuality, _, _, _, _ = GetLootSlotInfo(slotIndex)
    --local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = C_Item.GetItemInfo(lootLink)

    --DisenchanterPlus:Debug("itemID : " .. tostring(itemID))
    local enchantingItemType = DP_LootProcess:CheckEnchantingItemType(itemID)
    if enchantingItemType == nil then return end

    if itemID ~= -1 then
      local sources = { GetLootSourceInfo(slotIndex) }
      --DisenchanterPlus:Debug(string.format(" %d > quality = %d, name =  %s [%d mobs] - item_id = %d - quantity = %d", i, lootQuantity, lootName, #sources / 2, itemID, lootQuantity))
      --DisenchanterPlus:Dump(sources)
      for sourceIndex = 1, #sources, 2 do
        local guidType = select(1, strsplit("-", sources[sourceIndex]))
        --DisenchanterPlus:Debug("guidType = " .. tostring(guidType))
        --if guidType ~= "Item" then

        local lootInfo = {
          ItemName = lootName,
          Quality = lootQuality,
          Quantity = tonumber(lootQuantity),
          Type = slotType,
          ItemLink = lootLink,
          ItemIcon = lootIcon,
          ItemID = itemID,
          CurrencyID = currencyID,
          Time = GetTime(),
          IsTradeSkill = IsTradeSkill,
          Source = {},
          EnchantingItemType = enchantingItemType
        }
        if lootLink then
          _, _, lootInfo.Tier = string.find(lootLink, "|A:Professions%-ChatIcon%-Quality%-Tier(%d):")
        end
        local lootGUID = sources[sourceIndex]
        --DisenchanterPlus:Debug("Quantity = " .. tostring(lootQuantity))
        --DisenchanterPlus:Debug(tostring(IsTradeSkill))

        if IsTradeSkill then
          --DisenchanterPlus:Debug(TradeSkillInfo.Name)
          if TradeSkillInfo.Name == "Enchanting" and IsItemLocked then
            ItemLockedInfo.Quantity = tonumber(lootInfo.Quantity)
            ItemLockedInfo.Quality = lootInfo.Quality
            ItemLockedInfo.Items = 1
            TradeSkillInfo.From[ItemLockedInfo.ItemID] = ItemLockedInfo
            lootInfo.Source = TradeSkillInfo
          end
        end

        -- stores item
        C_Timer.After(0.1, function()
          DP_LootProcess:StoreItemDetails(lootInfo)
        end)
      end
    end
  end
end

---Loot closed
function DP_LootProcess:LootClosed()
  LootingInProgress = false
  MaxLootReadyCount = 0
  IsTradeSkill = false
  TradeSkillInfo = {}
  IsItemLocked = false
  ItemLockedInfo = {}
end

---Process spell cast succeded
---@param unitTarget string
---@param castGUID string
---@param spellID number
function DP_LootProcess:UnitSpellCastSucceeded(unitTarget, castGUID, spellID)
  if unitTarget == "player" then
    local proffesionName = DP_LootProcess:FindProfessionBySpellId(spellID)
    --DisenchanterPlus:Debug(proffesionName .. " : " .. spellID)
    if proffesionName ~= "" then
      IsTradeSkill = true
      TradeSkillInfo = {
        Name = proffesionName,
        SpellID = spellID,
        From = {}
      }
      --DisenchanterPlus:Dump(TradeSkillInfo)
    end
  end
end

---Find proffesion by spellId
---@param spellID number
---@return string profession
function DP_LootProcess:FindProfessionBySpellId(spellID)
  for profession, professionInfo in pairs(allProfessionID) do
    for _, professionID in pairs(professionInfo.spellID) do
      if spellID == professionID then
        return profession
      end
    end
  end
  --DisenchanterPlus:Debug("Profession with spellID = " .. spellID .. " not found.")
  return ""
end

---Store item details
---@param lootInfo table
function DP_LootProcess:StoreItemDetails(lootInfo)
  if lootInfo ~= nil then
    local itemID = lootInfo.ItemID
    local savedLootInfo
    if lootInfo.EnchantingItemType == dust then
      savedLootInfo = DisenchanterPlus.db.global.data.dusts[itemID] or {}
    elseif lootInfo.EnchantingItemType == essence then
      savedLootInfo = DisenchanterPlus.db.global.data.essences[itemID] or {}
    elseif lootInfo.EnchantingItemType == shard then
      savedLootInfo = DisenchanterPlus.db.global.data.shards[itemID] or {}
    elseif lootInfo.EnchantingItemType == crystal then
      savedLootInfo = DisenchanterPlus.db.global.data.crystals[itemID] or {}
    else
      savedLootInfo = DisenchanterPlus.db.global.data.unknown[itemID] or {}
    end
    local essenceInfo = {
      ItemID = lootInfo.ItemID,
      ItemName = lootInfo.ItemName,
      Quantity = lootInfo.Quantity,
      Quality = lootInfo.Quality,
      Items = 1
    }
    if DP_CustomFunctions:TableIsEmpty(savedLootInfo) then
      --DisenchanterPlus:Debug("Loot is new : " .. tostring(itemID))
      savedLootInfo = {
        ItemName = lootInfo.ItemName,
        IsTradeSkill = lootInfo.IsTradeSkill,
        Quantity = lootInfo.Quantity,
        Time = lootInfo.Time,
        ItemID = lootInfo.ItemID,
        EnchantingItemType = lootInfo.EnchantingItemType,
        Type = lootInfo.Type,
        ItemLink = lootInfo.ItemLink,
        ItemIcon = lootInfo.ItemIcon,
        Quality = lootInfo.Quality,
        Source = {
        },
      }
    else
      if savedLootInfo.ItemIcon == nil then savedLootInfo.ItemIcon = lootInfo.ItemIcon end
    end
    --DisenchanterPlus:Dump(lootInfo)
    --DisenchanterPlus:Dump(savedLootInfo)

    -- process source item
    local lootInfoSource = lootInfo.Source or {}
    local lootInfoSourceFrom = lootInfoSource.From or {}
    local savedLootInfoSource = savedLootInfo.Source or {}
    local savedLootInfoSourceFrom = savedLootInfoSource.From or {}

    for fromItemID, fromItemInfo in pairs(lootInfoSourceFrom) do
      local savedItemInfo = savedLootInfoSourceFrom[fromItemID]
      if savedItemInfo == nil then
        savedItemInfo = fromItemInfo
      else
        local savedItems = tonumber(savedItemInfo.Items) or 0
        local savedQuantity = tonumber(savedItemInfo.Quantity) or 0
        local currentItems = tonumber(fromItemInfo.Items) or 0
        local currentQuantity = tonumber(fromItemInfo.Quantity) or 0
        savedItemInfo.Items = currentItems + savedItems
        savedItemInfo.Quantity = currentQuantity + savedQuantity
      end
      savedLootInfoSourceFrom[fromItemID] = savedItemInfo
      DP_LootProcess:SaveSourceItemID(fromItemID, essenceInfo)
    end
    savedLootInfoSource.From = savedLootInfoSourceFrom
    savedLootInfo.Source = savedLootInfoSource

    -- total items and quantity
    local totalItems = 0
    local totalQuantity = 0
    for _, fromItemInfo in pairs(savedLootInfoSourceFrom) do
      totalItems = totalItems + 1
      totalQuantity = totalQuantity + (fromItemInfo.Quantity or 0)
    end
    savedLootInfo.Items = totalItems
    savedLootInfo.Quantity = totalQuantity

    -- save enchanting item
    if lootInfo.EnchantingItemType == dust then
      DisenchanterPlus.db.global.data.dusts[itemID] = savedLootInfo
    elseif lootInfo.EnchantingItemType == essence then
      DisenchanterPlus.db.global.data.essences[itemID] = savedLootInfo
    elseif lootInfo.EnchantingItemType == shard then
      DisenchanterPlus.db.global.data.shards[itemID] = savedLootInfo
    elseif lootInfo.EnchantingItemType == crystal then
      DisenchanterPlus.db.global.data.crystals[itemID] = savedLootInfo
    else
      DisenchanterPlus.db.global.data.unknown[itemID] = savedLootInfo
    end
  end
end

---Process item locked
---@param bagOrSlotIndex number
---@param slotIndex number
function DP_LootProcess:ItemLocked(bagOrSlotIndex, slotIndex)
  --DisenchanterPlus:Debug("Locked item : " .. tostring(bagOrSlotIndex) .. " - " .. tostring(slotIndex))
  if bagOrSlotIndex == nil or slotIndex == nil then
    IsItemLocked = true
    ItemLockedInfo = {
    }
  else
    local containerInfo = C_Container.GetContainerItemInfo(bagOrSlotIndex, slotIndex)
    if containerInfo == nil then return end

    --LogBook:Dump(containerInfo)
    IsItemLocked = true
    ItemLockedInfo = {
      Name = containerInfo.itemName,
      ItemID = containerInfo.itemID,
      Quality = containerInfo.quality,
    }
  end
end

---Check enchanting item yype
---@param itemID number
function DP_LootProcess:CheckEnchantingItemType(itemID)
  return DP_Database:GetEnchantingItemType(itemID)
end

---Save source UtemID
---@param itemID number
---@param essenceInfo table
function DP_LootProcess:SaveSourceItemID(itemID, essenceInfo)
  --DisenchanterPlus:Debug("Saving source itemID " .. tostring(itemID))
  --DisenchanterPlus:Debug("Essence itemID " .. tostring(essenceInfo.ItemID))
  --DisenchanterPlus:Dump(essenceInfo)

  local savedItemInfo = DisenchanterPlus.db.global.data.items[itemID] or {}
  local savedEnchantingItems = savedItemInfo.EnchantingItems or {}

  local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, _, _, itemTexture, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
  if savedItemInfo.ItemName == nil then savedItemInfo.ItemName = itemName end
  if savedItemInfo.Quality == nil then savedItemInfo.Quality = itemQuality end
  if savedItemInfo.ItemLink == nil then savedItemInfo.ItemLink = itemLink end
  if savedItemInfo.ItemLevel == nil then savedItemInfo.ItemLevel = itemLevel end
  if savedItemInfo.ItemMinLevel == nil then savedItemInfo.ItemMinLevel = itemMinLevel end
  if savedItemInfo.ItemType == nil then savedItemInfo.ItemType = itemType end
  if savedItemInfo.ItemSubType == nil then savedItemInfo.ItemSubType = itemSubType end
  if savedItemInfo.ItemTexture == nil then savedItemInfo.ItemTexture = itemTexture end
  if savedItemInfo.EnchantingItems == nil then savedItemInfo.EnchantingItems = {} end

  local essenceItemID = essenceInfo.ItemID
  local essenceItemInfo = savedEnchantingItems[essenceItemID] or {}

  if essenceItemInfo == nil then
    essenceItemInfo = essenceInfo
  else
    local savedItems = tonumber(essenceItemInfo.Items) or 0
    local savedQuantity = tonumber(essenceItemInfo.Quantity) or 0
    local currentItems = tonumber(essenceInfo.Items) or 0
    local currentQuantity = tonumber(essenceInfo.Quantity) or 0
    essenceItemInfo.Items = currentItems + savedItems
    essenceItemInfo.Quantity = currentQuantity + savedQuantity
  end
  essenceItemInfo.ItemName = essenceInfo.ItemName

  savedItemInfo.EnchantingItems[essenceItemID] = essenceItemInfo
  DisenchanterPlus.db.global.data.items[itemID] = savedItemInfo
end
