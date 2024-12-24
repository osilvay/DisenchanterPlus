---@class DP_BagsCheck
local DP_BagsCheck = DP_ModuleLoader:CreateModule("DP_BagsCheck")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_DisenchantGroup
local DP_DisenchantGroup = DP_ModuleLoader:ImportModule("DP_DisenchantGroup")

local L = LibStub("AceLocale-3.0"):GetLocale("DisenchanterPlus")

local disenchantSpellID = 13262
local totalItemsInBagsToDisenchant = 0

---Items in bags
---@return table|nil
function DP_BagsCheck:GetItemFromBag()
  local result
  local itemsInBagsToDisenchant = 0
  local sessionIgnoredList = DP_DisenchantGroup:GetSessionIgnoreList() or {}
  local permanentIgnoredList = DP_DisenchantGroup:GetPermanentIgnoreList() or {}

  for bagIndex = 0, 4 do
    --DisenchanterPlus:Debug("Bag : " .. tostring(bagIndex))
    local itemInBag, numItemsInBag = DP_BagsCheck:ItemInBag(bagIndex, sessionIgnoredList, permanentIgnoredList)
    if itemInBag ~= nil then
      --DisenchanterPlus:Debug(itemInBag.ItemName)
      if result == nil then result = itemInBag end
    end
    itemsInBagsToDisenchant = itemsInBagsToDisenchant + numItemsInBag
  end
  totalItemsInBagsToDisenchant = itemsInBagsToDisenchant
  return result
end

---Items in bags
---@return unknown
function DP_BagsCheck:ItemsInBags()
  local itemsInBagsToDisenchant = 0
  local sessionIgnoredList = DP_DisenchantGroup:GetSessionIgnoreList() or {}
  local permanentIgnoredList = DP_DisenchantGroup:GetPermanentIgnoreList() or {}
  for bagIndex = 0, 4 do
    --DisenchanterPlus:Debug("Bag : " .. tostring(bagIndex))
    local _, numItemsInBag = DP_BagsCheck:ItemInBag(bagIndex, sessionIgnoredList, permanentIgnoredList)
    itemsInBagsToDisenchant = itemsInBagsToDisenchant + numItemsInBag
  end
  return itemsInBagsToDisenchant
end

---Items in bag index
---@param bagIndex number
---@param sessionIgnoredList table
---@param permanentIgnoredList table
---@return table|nil
---@return number
function DP_BagsCheck:ItemInBag(bagIndex, sessionIgnoredList, permanentIgnoredList)
  local numSlots = C_Container.GetContainerNumSlots(bagIndex)
  local numItemsInBag = 0
  local result

  --DisenchanterPlus:Debug(string.format("Slot %d = %d slots", bagIndex or "nil", numSlots or "nil"))
  local itemQualities = DisenchanterPlus.db.char.general.itemQuality or {}
  local itemQualityList = {}

  for k, itemQualityValue in pairs(itemQualities) do
    if itemQualityValue then
      table.insert(itemQualityList, k)
    end
  end

  for slot = 1, numSlots do
    local containerInfo = C_Container.GetContainerItemInfo(bagIndex, slot)

    if containerInfo ~= nil and containerInfo.itemID ~= nil then
      local itemName, _, itemQuality, itemLevel, itemMinLevel, itemType, _, _, _, itemTexture, _, _, _, _, _, _, _ = C_Item.GetItemInfo(containerInfo.itemID)
      local isBound = containerInfo.isBound

      if (itemType == DisenchanterPlus:DP_i18n("Armor") or itemType == DisenchanterPlus:DP_i18n("Weapon")) and
          not DP_CustomFunctions:TableHasKey(sessionIgnoredList, tostring(containerInfo.itemID)) and
          not DP_CustomFunctions:TableHasKey(permanentIgnoredList, tostring(containerInfo.itemID)) and
          DP_CustomFunctions:TableHasValue(itemQualityList, tostring(itemQuality)) and
          ((DisenchanterPlus.db.char.general.onlySoulbound and isBound) or not DisenchanterPlus.db.char.general.onlySoulbound) then
        --DisenchanterPlus:Dump(sessionIgnoredItems)
        --DisenchanterPlus:Debug(containerInfo.hyperlink)
        --DisenchanterPlus:Debug(itemLink)
        --DisenchanterPlus:Debug("itemQuality = " .. tostring(itemQuality) .. ", itemID = " .. tostring(containerInfo.itemID) .. ", texture = " .. itemTexture)
        numItemsInBag = numItemsInBag + 1
        if result == nil then
          result = {
            ItemID = tostring(containerInfo.itemID),
            ItemName = itemName,
            ItemIcon = itemTexture,
            ItemLink = containerInfo.hyperlink,
            ItemQuality = itemQuality,
            ItemLevel = itemLevel,
            ItemMinLevel = itemMinLevel,
            Slot = slot,
            BagIndex = bagIndex,
            SpellID = disenchantSpellID
          }
        end
      end
    end
  end
  return result, numItemsInBag
end

---Get total items in bags to disenchant
---@return integer
function DP_BagsCheck:GetTotalItemsInBagsToDisenchant()
  return totalItemsInBagsToDisenchant
end

---Get items in bags
---@param equipLocation? string
---@return table
function DP_BagsCheck:GetItemsInBags(equipLocation)
  local itemsInBags = {}
  local numItemsInBag = 0
  local itemQualities = DisenchanterPlus.db.char.general.enchantItemQuality or {}
  local itemQualityList = {}

  for k, itemQualityValue in pairs(itemQualities) do
    if itemQualityValue then
      table.insert(itemQualityList, k)
    end
  end

  for bagIndex = 0, 4 do
    local numSlots = C_Container.GetContainerNumSlots(bagIndex)
    for slot = 1, numSlots do
      local containerInfo = C_Container.GetContainerItemInfo(bagIndex, slot)

      if containerInfo ~= nil and containerInfo.itemID ~= nil then
        local itemName, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, _, itemEquipLoc, itemTexture, _, _, _, _, _, _, _ = C_Item.GetItemInfo(containerInfo.itemID)
        if (itemType == DisenchanterPlus:DP_i18n("Armor") or itemType == DisenchanterPlus:DP_i18n("Weapon")) and
            DP_CustomFunctions:TableHasValue(itemQualityList, tostring(itemQuality)) then
          --DisenchanterPlus:Debug(equipLocation .. " = " .. itemEquipLoc)
          local itemString, realItemName = containerInfo.hyperlink:match("|H(.*)|h%[(.*)%]|h")
          if not equipLocation or equipLocation == itemEquipLoc then
            numItemsInBag = numItemsInBag + 1
            itemsInBags[tostring(containerInfo.itemID)] = {
              ItemName = realItemName,
              ItemIcon = itemTexture,
              ItemLink = containerInfo.hyperlink,
              ItemQuality = itemQuality,
              ItemLevel = itemLevel,
              ItemMinLevel = itemMinLevel,
              ItemType = itemType,
              ItemSubType = itemSubType,
              ItemEquipLoc = itemEquipLoc,
              Slot = slot,
              BagIndex = bagIndex,
              SpellID = disenchantSpellID
            }
          end
        end
      end
    end
  end
  return itemsInBags
end
