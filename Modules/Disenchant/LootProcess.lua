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
    if lootLink ~= nil and slotType ~= nil then
      local itemID, _, _, _, _, _, _ = C_Item.GetItemInfoInstant(lootLink)
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
            Time = GetServerTime(),
            IsTradeSkill = IsTradeSkill,
            EnchantingItemType = enchantingItemType,
            Source = {},
          }
          if lootLink then
            _, _, lootInfo.Tier = string.find(lootLink, "|A:Professions%-ChatIcon%-Quality%-Tier(%d):")
          end

          if IsTradeSkill then
            --DisenchanterPlus:Debug(TradeSkillInfo.Name)
            if TradeSkillInfo.Name == "Enchanting" and IsItemLocked then
              lootInfo.Source[ItemLockedInfo.ItemID] = {
                Items = 1,
                Quality = ItemLockedInfo.Quality,
                ItemName = ItemLockedInfo.ItemName,
                Quantity = tonumber(lootQuantity)
              }
            end
          end

          -- stores item
          DP_LootProcess:SaveEnchantingItemDetails(lootInfo)
        end
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
        SpellID = spellID
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

---Save enchanting item details
---@param lootInfo table
function DP_LootProcess:SaveEnchantingItemDetails(lootInfo)
  if lootInfo ~= nil then
    local itemID = lootInfo.ItemID
    --DisenchanterPlus:Dump(enchantingItemInfo)

    local savedItemInfo = DP_Database:GetEnchantingItemData(itemID) or {}
    local savedSource = savedItemInfo.Source or {}
    local lootSource = lootInfo.Source or {}
    local sourceItemsToSave = {}

    for sourceItemID, sourceItemInfo in pairs(lootSource) do
      local savedSourceItemInfo = savedSource[sourceItemID]
      --DisenchanterPlus:Dump(savedSourceItemInfo)
      if savedSourceItemInfo == nil then
        savedSourceItemInfo = sourceItemInfo
      else
        local savedItems = tonumber(savedSourceItemInfo.Items) or 0
        local savedQuantity = tonumber(savedSourceItemInfo.Quantity) or 0
        local currentItems = tonumber(sourceItemInfo.Items) or 0
        local currentQuantity = tonumber(sourceItemInfo.Quantity) or 0
        savedSourceItemInfo.ItemName = sourceItemInfo.ItemName
        savedSourceItemInfo.Items = currentItems + savedItems
        savedSourceItemInfo.Quantity = currentQuantity + savedQuantity
      end
      savedSource[sourceItemID] = savedSourceItemInfo
      table.insert(sourceItemsToSave, sourceItemID)
    end
    lootInfo.Source = savedSource
    --DisenchanterPlus:Dump(lootInfo)

    DP_Database:SetEnchantingItemData(itemID, lootInfo)

    -- actualizo source items
    local enchantingItemInfo = {
      ItemID = lootInfo.ItemID,
      ItemName = lootInfo.ItemName,
      Quantity = lootInfo.Quantity,
      Quality = lootInfo.Quality,
      Items = 1
    }
    for _, sourceItemID in pairs(sourceItemsToSave) do
      DP_LootProcess:SaveSourceItemDetails(sourceItemID, enchantingItemInfo)
    end
  end
end

---Save source item details
---@param itemID number
---@param essenceInfo table
function DP_LootProcess:SaveSourceItemDetails(itemID, essenceInfo)
  --DisenchanterPlus:Debug("Saving source itemID " .. tostring(itemID))
  --DisenchanterPlus:Debug("Essence itemID " .. tostring(essenceInfo.ItemID))
  --DisenchanterPlus:Dump(essenceInfo)
  local sourceItemInfo = DP_Database:GetItemData(itemID)
  if sourceItemInfo == nil then
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, _, _, itemTexture, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
    sourceItemInfo = {
      ItemName = itemName,
      Quality = itemQuality,
      ItemLink = itemLink,
      ItemLevel = itemLevel,
      ItemMinLevel = itemMinLevel,
      ItemType = itemType,
      ItemSubType = itemSubType,
      ItemTexture = itemTexture,
      EnchantingItems = {},
    }
  end

  local savedEnchantingItems = sourceItemInfo.EnchantingItems or {}
  local essenceItemID = essenceInfo.ItemID
  local essenceItemInfo = savedEnchantingItems[essenceItemID]

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
  essenceItemInfo.Quality = essenceInfo.Quality

  sourceItemInfo.EnchantingItems[essenceItemID] = essenceItemInfo
  --DisenchanterPlus:Dump(sourceItemInfo)

  DP_Database:SetItemData(itemID, sourceItemInfo)
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
      ItemName = containerInfo.itemName,
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
