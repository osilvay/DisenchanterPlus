---@class DP_LootProcess
local DP_LootProcess = DP_ModuleLoader:CreateModule("DP_LootProcess")

---@type DP_Database
local DP_Database = DP_ModuleLoader:ImportModule("DP_Database")

---@type DP_TradeSkillCheck
local DP_TradeSkillCheck = DP_ModuleLoader:ImportModule("DP_TradeSkillCheck")

local MaxLootReadyCount = 0
local LootingInProgress = false
local IsTradeSkill = false
local TradeSkillInfo = {}
local ItemLockedInfo = {}
local IsItemLocked = false

function DP_LootProcess:Initialize()
end

---loot ready with error protection
function DP_LootProcess:LootReady()
  --DisenchanterPlus:Debug("LootingInProgress : " .. tostring(LootingInProgress))
  if LootingInProgress then
    return
  else
    LootingInProgress = true
  end

  local numLootItems = GetNumLootItems()
  MaxLootReadyCount = math.max(MaxLootReadyCount, numLootItems)
  --DisenchanterPlus:Debug("MaxLootReadyCount : " .. tostring(MaxLootReadyCount))

  -- Security: limit max loot items to prevent infinite loops
  local maxLootLimit = 1000
  if numLootItems > maxLootLimit then
    DisenchanterPlus:Warning("Loot items exceed safe limit (" .. tostring(numLootItems) .. ">" .. tostring(maxLootLimit) .. "). Capping at limit.")
    numLootItems = maxLootLimit
  end

  for slotIndex = 1, numLootItems do
    local success, lootLink = pcall(function() return GetLootSlotLink(slotIndex) end)
    if not success or lootLink == nil then
      DisenchanterPlus:Debug("Failed to get loot link for slot " .. tostring(slotIndex))
      break
    end

    local slotType = GetLootSlotType(slotIndex)
    if lootLink ~= nil and slotType ~= nil then
      local itemID, _, _, _, _, _, _ = C_Item.GetItemInfoInstant(lootLink)
      if itemID == nil then
        DisenchanterPlus:Debug("ItemID is nil for loot link at slot " .. tostring(slotIndex))
        break
      end

      local lootIcon, lootName, lootQuantity, currencyID, lootQuality, _, _, _, _ = GetLootSlotInfo(slotIndex)
      if lootIcon == nil or lootName == nil then
        DisenchanterPlus:Debug("Loot info missing for slot " .. tostring(slotIndex))
        break
      end

      --DisenchanterPlus:Debug("itemID : " .. tostring(itemID))
      local enchantingItemType = DP_LootProcess:CheckEnchantingItemType(itemID)
      if enchantingItemType == nil then
        DisenchanterPlus:Debug("Not an enchanting item: " .. tostring(itemID))
        break
      end

      if itemID ~= -1 then
        local sources = { GetLootSourceInfo(slotIndex) }
        --DisenchanterPlus:Debug(string.format(" %d > quality = %d, name =  %s [%d mobs] - item_id = %d - quantity = %d", i, lootQuantity, lootName, #sources / 2, itemID, lootQuantity))
        --DisenchanterPlus:Dump(sources)

        -- Security: limit source iterations to prevent infinite loops
        local maxSourceIterations = 100
        for sourceIndex = 1, math.min(#sources, maxSourceIterations), 2 do
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
    local tradeSkillName = DP_TradeSkillCheck:FindTradeSkillBySpellID(spellID)
    --DisenchanterPlus:Debug(proffesionName .. " : " .. spellID)
    if tradeSkillName then
      IsTradeSkill = true
      TradeSkillInfo = {
        Name = tradeSkillName,
        SpellID = spellID
      }
      --DisenchanterPlus:Dump(TradeSkillInfo)
    end
  end
end

---Save enchanting item details with error protection
---@param lootInfo table
function DP_LootProcess:SaveEnchantingItemDetails(lootInfo)
  if lootInfo == nil or lootInfo.ItemID == nil then
    DisenchanterPlus:Warning("SaveEnchantingItemDetails: Invalid lootInfo or missing ItemID")
    return
  end

  local success, result = pcall(function()
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
  end)

  if not success then
    DisenchanterPlus:Error("Failed to save enchanting item details: " .. tostring(result))
  end
end

---Save source item details with error protection
---@param itemID number
---@param essenceInfo table
function DP_LootProcess:SaveSourceItemDetails(itemID, essenceInfo)
  if itemID == nil or essenceInfo == nil or essenceInfo.ItemID == nil then
    DisenchanterPlus:Warning("SaveSourceItemDetails: Invalid parameters")
    return
  end

  local success, result = pcall(function()
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
  end)

  if not success then
    DisenchanterPlus:Error("Failed to save source item details: " .. tostring(result))
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

    --DisenchanterPlus:Dump(containerInfo)
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
