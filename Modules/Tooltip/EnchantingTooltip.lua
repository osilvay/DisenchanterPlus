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

  if DisenchanterPlus.IsMainline then
  else
    GameTooltip:HookScript("OnTooltipSetItem", DP_EnchantingTooltip.OnGameTooltipSetItem)
  end
end

-- #######################################################################################################################################

---Show tooltip
---@param itemInfo table
function DP_EnchantingTooltip:ShowTooltip(itemInfo)
  local itemID = itemInfo.ItemID
  local isEnchantingItem = false
  local isItem = false

  local showTooltip = DP_CustomFunctions:IsKeyPressed(DisenchanterPlus.db.char.general.pressKeyDown)
  if not showTooltip then return end

  if DP_Database:GetEnchantingItemType(itemID) ~= nil then
    isEnchantingItem = true
  end

  if itemID == nil then return end
  --DisenchanterPlus:Debug("ShowTooltip [" .. tostring(itemID) .. "]")

  local _, itemType, _, _, _, _, _ = C_Item.GetItemInfoInstant(itemID)
  --DisenchanterPlus:Debug(string.format("itemQuality = %s - itemType = %s", tostring(itemQuality), tostring(itemType)))

  if itemType == DisenchanterPlus:DP_i18n("Armor") or itemType == DisenchanterPlus:DP_i18n("Weapon") then
    isItem = true
  end

  showTooltip = (isItem or isEnchantingItem)

  if not showTooltip then return end

  -- draw title
  local isShowItemID = DisenchanterPlus.db.char.general.showItemID
  local isShowTitle = DisenchanterPlus.db.char.general.showTitle
  local itemIDText = DP_CustomColors:Colorize(DP_CustomColors:CustomColors("ROWID"), tostring(itemID))
  if not isShowItemID then
    itemIDText = ""
  end

  if isShowTitle then
    local titleText = string.format("%s", DisenchanterPlus:MessageWithAddonColor(DisenchanterPlus:DP_i18n("Enchanting")))
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(titleText, itemIDText)
  end
  if isItem then
    DP_EnchantingTooltip:ProcessItem(itemID)
  elseif isEnchantingItem then
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
        currentItemInfo.Quantity = enchantingItemInfo.Quantity or 0
        currentItemInfo.Items = enchantingItemInfo.Items or 0

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

  if DisenchanterPlus.db.char.general.showExpectedEssences or DisenchanterPlus.db.char.general.showRealEssences then
    GameTooltip:AddLine(" ")
  end
end

---Get expected item data
---@param itemID number
function DP_EnchantingTooltip:GetExpectedItemData(itemID)
  local itemExpectedData = DP_EnchantingTooltip.ProcessIsItemExpectedData(itemID) or {}
  --DisenchanterPlus:Dump(itemExpectedData)
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
        if DisenchanterPlus.db.char.general.auctionatorIntegration and currentExpecteItem.AuctionatorString ~= nil then
          GameTooltip:AddDoubleLine("       |cffa19171" .. DisenchanterPlus:DP_i18n("Auction") .. "|r", "|cffaaaaaa" .. currentExpecteItem.AuctionatorString .. "|r")
        end
        expectedIndex = expectedIndex + 1
      end
    end
  end
end

---Process is item expected data
---@param itemID number
---@return table
function DP_EnchantingTooltip.ProcessIsItemExpectedData(itemID)
  local _, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, _, _, _, _, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
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
  --DisenchanterPlus:Debug(string.format("itemLevel = %s, itemMinLevel = %s", tostring(itemLevel), tostring(itemMinLevel)))
  --DisenchanterPlus:Debug(string.format("itemLevel = %s", tostring(itemLevel)))
  for _, currentData in pairs(essencesData) do
    --DisenchanterPlus:Debug(string.format("MinILevel = %s, MaxILevel = %s", tostring(currentData.MinILevel), tostring(currentData.MaxILevel)))

    local levelToCheck
    if DisenchanterPlus.IsClassic or DisenchanterPlus.IsHardcore or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal then
      -- classic_era
      levelToCheck = (itemMinLevel > 0) and itemMinLevel or itemLevel
    elseif DisenchanterPlus.IsCataclysm then
      -- cataclysm
      levelToCheck = itemLevel
    end

    if levelToCheck >= currentData.MinILevel and levelToCheck <= currentData.MaxILevel then
      --DisenchanterPlus:Dump(currentData.ItemIDs)
      for essenceItemID, currentEssenceData in pairs(currentData.ItemIDs) do
        local essenceItemName, essenceItemLink, essenceItemQuality, _, _, _, _, _, _, _, _, _, _, _, _, _, _ = C_Item.GetItemInfo(essenceItemID)
        --DisenchanterPlus:Debug(string.format("essenceItemID = %s = essenceItemLink = %s", essenceItemID, essenceItemLink))

        local auctionatorPrice
        local auctionatorString = "|cffcc1100" .. DisenchanterPlus:DP_i18n("No data") .. "|r"
        if DisenchanterPlus.db.char.general.auctionatorIntegration and Auctionator and essenceItemLink ~= nil then
          local dbKey = Auctionator.Utilities.BasicDBKeyFromLink(essenceItemLink)
          if dbKey ~= nil then
            auctionatorPrice = Auctionator.Database:GetFirstPrice({ dbKey })
            if auctionatorPrice then
              auctionatorString = Auctionator.Utilities.CreatePaddedMoneyString(auctionatorPrice)
            end
          end
        end

        local essenceToAdd = {
          ItemID = essenceItemID,
          ItemName = essenceItemName,
          ItemLink = essenceItemLink,
          ItemQuality = essenceItemQuality,
          Percent = currentEssenceData.Percent,
          QuantityText = currentEssenceData.QuantityText,
          AuctionatorPrice = auctionatorPrice,
          AuctionatorString = auctionatorString
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
    local enchantingItemInfo = DP_Database:GetEnchantingItemData(itemID)
    if enchantingItemInfo == nil then return end
    local sourceItems = enchantingItemInfo.Source or {}
    local essenceRealData = {}
    local differentItems = 0
    local totalItems = 0
    local totalQuantity = 0

    for sourceItemID, sourceItemInfo in pairs(sourceItems) do
      local savedItemInfo = DP_Database:GetItemData(sourceItemID)
      --DisenchanterPlus:Dump(savedItemInfo)

      if savedItemInfo ~= nil then
        savedItemInfo.Quantity = sourceItemInfo.Quantity
        savedItemInfo.Items = sourceItemInfo.Items
        savedItemInfo.ItemID = sourceItemID

        differentItems = differentItems + 1
        totalItems = totalItems + (sourceItemInfo.Items or 0)
        totalQuantity = totalQuantity + (sourceItemInfo.Quantity or 0)
        --DisenchanterPlus:Dump(currentItemInfo)
        table.insert(essenceRealData, savedItemInfo)
      end
      --savedItemInfo.EnchantingItems = nil
    end
    table.sort(essenceRealData, function(a, b) return a.Items ~= nil and b.Items ~= nil and a.Items < b.Items end)
    --DisenchanterPlus:Dump(essenceRealData)

    -- draw title
    local isShowTitle = DisenchanterPlus.db.char.general.showTitle
    if isShowTitle then
      local titleText = string.format("|cff999999(%d %s)|r", differentItems, DisenchanterPlus:DP_i18n("items"))
      GameTooltip:AddLine(titleText)
    end

    local index = 1
    local currentPercent = 0
    for _, currentItemInfo in pairs(essenceRealData) do
      local quantity = currentItemInfo.Quantity or 0
      local items = currentItemInfo.Items or 0
      if (items == 0 and DisenchanterPlus.db.char.general.zeroValues) or items > 0 then
        if index > DisenchanterPlus.db.char.general.itemsToShow then
          if totalItems > DisenchanterPlus.db.char.general.itemsToShow then
            local remainingPercent = "0"
            if currentPercent > 100 then currentPercent = 100 end
            if currentPercent > 0 then
              remainingPercent = string.format("%.2f", 100 - currentPercent)
            end
            local remaining = string.format("%.2f", (totalItems - DisenchanterPlus.db.char.general.itemsToShow))
            local leftTotal = string.format("   %d |cffc1c1c1%s...|r", remaining, DisenchanterPlus:DP_i18n("more"))
            local rightTotal = string.format("|cff919191%s|r", remainingPercent) .. " |cfff1b131%|r"
            GameTooltip:AddDoubleLine(leftTotal, rightTotal)
          end
          break
        end

        -- draw item
        local percentage = string.format("%.2f", 0)
        local itemLink = currentItemInfo.ItemLink
        local itemIcon = currentItemInfo.ItemIcon

        if itemLink == nil or itemIcon == nil then
          local _, cachedItemLink, _, _, _, _, _, _, _, cachedItemIcon, _, _, _, _, _, _, _ = C_Item.GetItemInfo(currentItemInfo.ItemID)
          if itemLink == nil then itemLink = cachedItemLink end
          if itemIcon == nil then itemIcon = cachedItemIcon end
        end

        if totalItems >= 1 then
          percentage = string.format("%.2f", (items * 100) / totalItems)
        end
        currentPercent = currentPercent + tonumber(percentage)

        local percentageText = string.format("|cfff1f1f1%s|r", percentage or "0")
        local leftTextLine = string.format(" + |T%d:0|t %s |cff91c1f1x|r|cff6191f1%d|r", itemIcon or "", itemLink or "", items or 0)
        local rightTextLine = string.format("%s", percentageText) .. " |cfff1b131%|r"
        GameTooltip:AddDoubleLine(leftTextLine, rightTextLine)
        index = index + 1
      end
    end
  end
end

function DP_EnchantingTooltip.OnGameTooltipShow(tooltip, ...)
end

function DP_EnchantingTooltip.OnGameTooltipSetItem(tooltip, ...)
  local _, itemLink = tooltip:GetItem()
  if itemLink == nil then return end
  local itemID = C_Item.GetItemIDForItemInfo(itemLink)

  if not itemID or itemID == 0 then
    DisenchanterPlus:Warning("Not an item")
  else
    --DisenchanterPlus:Info("Item : " .. itemName .. " - " .. itemLink)
    local itemInfo = {
      ItemID = itemID
    }
    DP_EnchantingTooltip:ShowTooltip(itemInfo)
  end
end
