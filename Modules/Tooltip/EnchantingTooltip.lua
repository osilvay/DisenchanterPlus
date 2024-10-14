---@class DP_EnchantingTooltip
local DP_EnchantingTooltip = DP_ModuleLoader:CreateModule("DP_EnchantingTooltip")

---@type DP_Database
local DP_Database = DP_ModuleLoader:ImportModule("DP_Database")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

function DP_EnchantingTooltip:Initialize()
  PercentByQualityAndLevel = DP_Database:GetExpectedDisenchantData()
  hooksecurefunc(GameTooltip, "SetBagItem", DP_EnchantingTooltip.SetBagItem)
  hooksecurefunc(GameTooltip, "SetInventoryItem", DP_EnchantingTooltip.SetInventoryItem)
  hooksecurefunc(GameTooltip, "SetAuctionItem", DP_EnchantingTooltip.SetAuctionItem)
  if GameTooltip.SetItemKey then
    hooksecurefunc(GameTooltip, "SetItemKey", DP_EnchantingTooltip.SetItemKey)
  end
  hooksecurefunc(GameTooltip, "SetHyperlink", DP_EnchantingTooltip.SetHyperlink)
  --[[
  SetBuybackItem
  SetMerchantItem
  SetRecipeReagentItem
  SetTradeSkillItem
  SetCraftItem
  SetLootItem
  SetSendMailItem
  SetInboxItem
  SetTradePlayerItem
  SetTradeTargetItem
  ]]
end

---SetBagItem hook
---@param self DP_EnchantingTooltip
---@param bag number
---@param slot number
function DP_EnchantingTooltip.SetBagItem(self, bag, slot)
  if (not slot) then return end
  if not DP_CustomFunctions:IsKeyPressed(DisenchanterPlus.db.char.general.pressKeyDown) then return end
  if not DisenchanterPlus.db.char.general.tooltipsEnabled then return end

  local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
  if C_Item.DoesItemExist(itemLocation) then
    local item = {
      itemID = C_Item.GetItemID(itemLocation)
    }
    DP_EnchantingTooltip:ShowTooltip(item)
    GameTooltip:Show()
  end
end

---SetInventoryItem hook
---@param self DP_EnchantingTooltip
---@param unit string
---@param slot number
function DP_EnchantingTooltip.SetInventoryItem(self, unit, slot)
  if (not slot) then return end
  if not DP_CustomFunctions:IsKeyPressed(DisenchanterPlus.db.char.general.pressKeyDown) then return end
  if not DisenchanterPlus.db.char.general.tooltipsEnabled then return end
  local item = {
    itemID = GetInventoryItemID(unit, slot)
  }
  DP_EnchantingTooltip:ShowTooltip(item)
  GameTooltip:Show()
end

---SetAuctionItem hook
---@param self DP_EnchantingTooltip
---@param type string
---@param index number
function DP_EnchantingTooltip.SetAuctionItem(self, type, index)
  if (not index) then return end
  if not DP_CustomFunctions:IsKeyPressed(DisenchanterPlus.db.char.general.pressKeyDown) then return end
  if not DisenchanterPlus.db.char.general.tooltipsEnabled then return end
  local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, itemID, _ = GetAuctionItemInfo(type, index);
  local item = {
    itemID = itemID
  }
  DP_EnchantingTooltip:ShowTooltip(item)
  GameTooltip:Show()
end

---SetItemKey hook
---@param self DP_EnchantingTooltip
---@param itemID number
---@param itemLevel number
---@param itemSuffix number
function DP_EnchantingTooltip.SetItemKey(self, itemID, itemLevel, itemSuffix)
  if not DP_CustomFunctions:IsKeyPressed(DisenchanterPlus.db.char.general.pressKeyDown) then return end
  local info = C_TooltipInfo.GetItemKey(itemID, itemLevel, itemSuffix)
  if info == nil then return end
  local item = {
    itemID = itemID
  }
  DP_EnchantingTooltip:ShowTooltip(item)
  GameTooltip:Show()
end

---SetHyperlink hook
---@param self DP_EnchantingTooltip
---@param itemLink string
function DP_EnchantingTooltip.SetHyperlink(self, itemLink)
  if not DP_CustomFunctions:IsKeyPressed(DisenchanterPlus.db.char.general.pressKeyDown) then return end
  local itemID, strippedItemLink = GetItemInfoFromHyperlink(itemLink)

  if itemID == nil then return end
  local item = {
    itemID = itemID
  }
  DP_EnchantingTooltip:ShowTooltip(item)
  GameTooltip:Show()
end

-- #######################################################################################################################################

---Show tooltip
---@param itemInfo table
function DP_EnchantingTooltip:ShowTooltip(itemInfo)
  local itemID = itemInfo.itemID
  local showTooltip = false
  local isEnchantingItem = false
  local isItem = false

  if DP_Database:GetEnchantingItemType(itemID) ~= nil then
    isEnchantingItem = true
  end

  if itemID == nil then return end
  --DisenchanterPlus:Debug("ShowTooltip [" .. tostring(itemID) .. "]")

  local _, _, itemQuality, _, _, itemType, _, _, _, _, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
  --LogBook:Debug(string.format("itemQuality = %s - itemType = %s", tostring(itemQuality), tostring(itemType)))
  --if itemQuality == nil or itemType == nil or itemQuality < 2 then return end

  if itemType == DisenchanterPlus:DP_i18n("Armor") or itemType == DisenchanterPlus:DP_i18n("Weapon") then
    isItem = true
  end

  if isEnchantingItem or isItem then
    showTooltip = true
  end
  if not showTooltip then return end

  local isShowItemID = DisenchanterPlus.db.char.general.showItemID
  local isShowTitle = DisenchanterPlus.db.char.general.showTitle
  local itemIDText = DP_CustomColors:Colorize(DP_CustomColors:CustomColors("ROWID"), tostring(itemID))
  if not isShowItemID then
    itemIDText = ""
  end
  local titleText = DisenchanterPlus:MessageWithAddonColor(DisenchanterPlus:DP_i18n("Enchanting"))

  if isItem then
    titleText = string.format("%s", titleText)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(titleText, itemIDText)
    DP_EnchantingTooltip:ProcessItem(itemID)
  elseif isEnchantingItem then
    local numItems = 0
    titleText = string.format("%s |cff999999(%d %s)|r", titleText, numItems, DisenchanterPlus:DP_i18n("items"))
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(titleText, itemIDText)
    DP_EnchantingTooltip:ProcessEnchantingItem(itemID)
  end
end

---Process item
---@param itemID number
function DP_EnchantingTooltip:ProcessItem(itemID)
  if itemID == nil then return end

  -- esperados
  if DisenchanterPlus.db.char.general.showExpectedEssences then
    DP_EnchantingTooltip:GetExpectedItemData(itemID)
  end

  local enchantingItemsInfo = DisenchanterPlus.db.global.data.items[itemID] or {}
  local enchantingItems = enchantingItemsInfo.EnchantingItems or {}

  -- reales
  if DisenchanterPlus.db.char.general.showRealEssences then
    local itemRealData = {}
    local totalEnchantingItems = 0
    local totalQuantity = 0

    for enchantingItemID, enchantingItemInfo in pairs(enchantingItems) do
      local currentItemInfo = DP_Database:GetEnchantingItemData(enchantingItemID)
      if currentItemInfo ~= nil then
        currentItemInfo.Source = nil
        currentItemInfo.Quantity = enchantingItemInfo.Quantity
        currentItemInfo.Items = enchantingItemInfo.Items

        totalEnchantingItems = totalEnchantingItems + 1
        totalQuantity = totalQuantity + (enchantingItemInfo.Quantity or 0)
        --DisenchanterPlus:Dump(currentItemInfo)
        table.insert(itemRealData, currentItemInfo)
      end
    end
    table.sort(itemRealData, function(a, b) return a.Quality ~= nil and b.Quality ~= nil and a.Quality < b.Quality end)

    GameTooltip:AddLine(string.format("|cff999999%s|r", DisenchanterPlus:DP_i18n("Real")))
    local noData = true
    for _, currentRealItem in pairs(itemRealData) do
      if currentRealItem.Quantity > 0 then noData = false end
    end

    --DisenchanterPlus:Dump(itemRealData)
    if DP_CustomFunctions:TableLength(itemRealData) == 0 or noData then
      GameTooltip:AddLine(string.format(" |cffff3300%s|r", DisenchanterPlus:DP_i18n("No data")))
    else
      local realIndex = 1
      for _, currentRealItem in pairs(itemRealData) do
        --DisenchanterPlus:Dump(itemRealData)
        local quantity = currentRealItem.Quantity or 0
        local itemLink = currentRealItem.ItemLink
        local itemIcon = currentRealItem.ItemIcon
        local percentage = string.format("%.2f", (quantity * 100) / totalQuantity)
        --DisenchanterPlus:Debug(itemLink .. " = " .. quantity .. " / " .. percentage)

        if itemLink == nil or itemIcon == nil then
          local _, cachedItemLink, _, _, _, _, _, _, _, cachedItemIcon, _, _, _, _, _, _, _ = C_Item.GetItemInfo(currentRealItem.ItemID)
          if itemLink == nil then itemLink = cachedItemLink end
          if itemIcon == nil then itemIcon = cachedItemIcon end
        end

        if quantity ~= nil and ((tonumber(quantity) == 0 and DisenchanterPlus.db.char.general.zeroValues) or tonumber(quantity) > 0) then
          local percentageText = string.format("|cfff1f1f1%s|r", percentage or "0")
          local leftTextLine = string.format(" + |T%d:0|t %s |cff6191f1%d|r", itemIcon or 134400, itemLink or "NOT_CACHED", quantity)
          local rightTextLine = string.format("%s", percentageText) .. " |cfff1b131%|r"
          GameTooltip:AddDoubleLine(leftTextLine, rightTextLine)
          realIndex = realIndex + 1
        end
      end
    end
  end
end

---Get expected item data
---@param itemID number
function DP_EnchantingTooltip:GetExpectedItemData(itemID)
  local itemExpectedData = DP_EnchantingTooltip.ProcessIsItemExpectedData(itemID) or {}
  --LogBook:Dump(itemExpectedData)
  if DP_CustomFunctions:TableLength(itemExpectedData) > 0 then
    table.sort(itemExpectedData, function(a, b) return a.ItemQuality ~= nil and b.ItemQuality ~= nil and a.ItemQuality < b.ItemQuality end)
  end

  GameTooltip:AddLine(string.format("|cff999999%s|r", DisenchanterPlus:DP_i18n("Expected")))
  if DP_CustomFunctions:TableLength(itemExpectedData) == 0 then
    GameTooltip:AddLine(string.format(" |cffff3300%s|r", DisenchanterPlus:DP_i18n("No data")))
  else
    local expectedIndex = 1
    for _, currentExpecteItem in pairs(itemExpectedData) do
      local quantity = currentExpecteItem.QuantityText
      local percentage = string.format("%.2f", currentExpecteItem.Percent)
      local _, itemLink, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ = C_Item.GetItemInfo(currentExpecteItem.ItemID)
      local itemIcon = C_Item.GetItemIconByID(currentExpecteItem.ItemID)
      local percentageText = string.format("|cfff1f1f1%s|r", percentage or "0")
      if itemIcon ~= nil and itemLink ~= nil then
        local leftTextLine = string.format(" + |T%d:0|t %s |cff6191f1%s|r", itemIcon, itemLink, quantity or 0)
        local rightTextLine = string.format("%s", percentageText) .. " |cfff1b131%|r"
        GameTooltip:AddDoubleLine(leftTextLine, rightTextLine)
        expectedIndex = expectedIndex + 1
      end
    end
  end
end

---Process is item expected data
---@param itemID number
---@return table
function DP_EnchantingTooltip.ProcessIsItemExpectedData(itemID)
  local _, _, itemQuality, itemLevel, itemMinLevel, itemType, _, _, _, _, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
  local essencesData = {}
  if itemQuality == 2 then
    essencesData = PercentByQualityAndLevel["UNCOMMON"][itemType]
  elseif itemQuality == 3 then
    essencesData = PercentByQualityAndLevel["RARE"][DisenchanterPlus:DP_i18n("All")]
  elseif itemQuality == 4 then
    essencesData = PercentByQualityAndLevel["EPIC"][DisenchanterPlus:DP_i18n("All")]
  end
  if essencesData == nil then return {} end

  local result = {}
  --LogBook:Debug(string.format("%s, %s", tostring(itemLevel), tostring(itemMinLevel)))
  for _, currentData in pairs(essencesData) do
    --LogBook:Debug(string.format("%s, %s = %s - %s", tostring(itemLevel), tostring(itemMinLevel), tostring(currentData.MinILevel), tostring(currentData.MaxILevel)))
    if itemMinLevel == 0 then itemMinLevel = itemLevel end
    local levelToCheck = 0

    -- for cata
    if itemLevel >= 272 then
      levelToCheck = itemLevel
    else
      levelToCheck = itemMinLevel
    end

    if levelToCheck >= currentData.MinILevel and levelToCheck <= currentData.MaxILevel then
      for essenceItemID, currentEssenceData in pairs(currentData.ItemIDs) do
        local essenceItemName, essenceItemLink, essenceItemQuality, _, _, _, _, _, _, _, _, _, _, _, _, _, _ = C_Item.GetItemInfo(essenceItemID)
        --LogBook:Debug(string.format("%s = %s", essenceItemID, essenceItemLink))
        local essenceToAdd = {
          ItemID = essenceItemID,
          ItemName = essenceItemName,
          ItemLink = essenceItemLink,
          ItemQuality = essenceItemQuality,
          Percent = currentEssenceData.Percent,
          QuantityText = currentEssenceData.QuantityText,
        }
        table.insert(result, essenceToAdd)
      end
      break
    end
  end
  return result
end

---Process enchanting item
function DP_EnchantingTooltip:ProcessEnchantingItem(itemID)
  if itemID == nil then return end
  if DisenchanterPlus.db.char.general.showRealEssences then
    local itemRealData = {}
  end
end
