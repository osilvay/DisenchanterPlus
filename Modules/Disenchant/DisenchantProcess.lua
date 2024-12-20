---@class DP_DisenchantProcess
local DP_DisenchantProcess = DP_ModuleLoader:CreateModule("DP_DisenchantProcess")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_DisenchantGroup
local DP_DisenchantGroup = DP_ModuleLoader:ImportModule("DP_DisenchantGroup")

---@type DP_DisenchantWindow
local DP_DisenchantWindow = DP_ModuleLoader:ImportModule("DP_DisenchantWindow")

local autoDisenchantDbTimeoutTicker = nil
local disenchantSpellID = 13262
local disenchanting = false
local itemToDisenchant = false
local totalItemsInBagsToDisenchant = 0
local autoDisenchantStatus = false

function DP_DisenchantProcess:Initialize()
  C_Timer.After(3, function()
    DP_DisenchantGroup:SaveSessionIgnoreList({})

    if DisenchanterPlus.db.char.general.autoDisenchantEnabled then
      DP_DisenchantProcess:SetAutoDisenchantStatus(true)
    end

    DP_DisenchantProcess:StartAutoDisenchant(false)
    DP_DisenchantGroup:CreatePermanentIgnoreListItems()
  end)
end

---Add item to ignored session list
---@param itemID number
function DP_DisenchantProcess:AddSessionIgnoredItem(itemID)
  --DisenchanterPlus:Dump(sessionIgnoredItems)
  local sessionIgnoredList = DP_DisenchantGroup:GetSessionIgnoreList() or {}
  if not DP_CustomFunctions:TableHasKey(sessionIgnoredList, tostring(itemID)) then
    sessionIgnoredList[tostring(itemID)] = ""
    DP_DisenchantGroup:CreateSessionIgnoreListItems(sessionIgnoredList)
    DP_DisenchantWindow:CloseWindow()
    itemToDisenchant = false
    disenchanting = false
    C_Timer.After(0.5, function()
      DP_DisenchantProcess:ScanForItems()
    end)
  end
end

---Checks if there are items in the session ignore list
function DP_DisenchantProcess:EmptySessionIgnoredItemsList()
  DP_DisenchantWindow:CloseWindow()
  local sessionIgnoredItems = {}
  DP_DisenchantGroup:CreateSessionIgnoreListItems(sessionIgnoredItems)
  itemToDisenchant = false
  disenchanting = false
  C_Timer.After(0.5, function()
    DP_DisenchantProcess:ScanForItems()
  end)
end

function DP_DisenchantProcess:EmptyPermanentIgnoredItemsList()
  DP_DisenchantWindow:CloseWindow()
  DP_DisenchantGroup:SavePermanentIgnoreList({})
  DP_DisenchantGroup:CreatePermanentIgnoreListItems()
  itemToDisenchant = false
  disenchanting = false
  C_Timer.After(0.5, function()
    DP_DisenchantProcess:ScanForItems()
  end)
end

---Add item to ignored session list
---@param itemID number
function DP_DisenchantProcess:AddPermanentIgnoredItem(itemID)
  --DisenchanterPlus:Debug("AddPermanentIgnoredItem : " .. tostring(itemID))
  local permanentIgnoreList = DP_DisenchantGroup:GetPermanentIgnoreList() or {}
  if not DP_CustomFunctions:TableHasKey(permanentIgnoreList, tostring(itemID)) then
    permanentIgnoreList[tostring(itemID)] = ""
    DP_DisenchantGroup:SavePermanentIgnoreList(permanentIgnoreList)
    DP_DisenchantGroup:CreatePermanentIgnoreListItems()
    DP_DisenchantWindow:CloseWindow()
    itemToDisenchant = false
    disenchanting = false
    C_Timer.After(0.5, function()
      DP_DisenchantProcess:ScanForItems()
    end)
  end
end

---Process spell cast sent
---@param unit string
---@param target string
---@param castGUID string
---@param spellID number
function DP_DisenchantProcess:UnitSpellCastSent(unit, target, castGUID, spellID)
  --DisenchanterPlus:Debug(string.format("UnitSpellCastStart : unitTarget = %s, castGUID = %s, spellID = %d", unitTarget, castGUID, spellID))
end

---Process spell cast succeded
---@param unitTarget string
---@param castGUID string
---@param spellID number
function DP_DisenchantProcess:UnitSpellCastStart(unitTarget, castGUID, spellID)
  --DisenchanterPlus:Debug(string.format("UnitSpellCastStart : unitTarget = %s, castGUID = %s, spellID = %d", unitTarget, castGUID, spellID))
  if unitTarget == "player" and spellID == disenchantSpellID then
    if not disenchanting then disenchanting = true end
    local _, itemLink, itemIcon, itemID = DP_DisenchantWindow:GetItemToDisenchant()
    if itemLink ~= nil and itemIcon ~= nil then
      DisenchanterPlus:Info(string.format("%s |T%d:0|t %s", DisenchanterPlus:DP_i18n("Disenchanting"), itemIcon, itemLink))
    end
    DP_DisenchantWindow:CloseWindow()
    DP_DisenchantProcess:CancelAutoDisenchant(true)
  end
end

---Starts autoDisenchant
---@param silent boolean
function DP_DisenchantProcess:StartAutoDisenchant(silent)
  --if not DisenchanterPlus.db.char.general.autoDisenchantEnabled then return end
  --DisenchanterPlus:Debug("Start auto disenchant : " .. tostring(silent))
  local autoDisenchantDbTimeout = DisenchanterPlus.db.char.general.autoDisenchantDbTimeout
  if autoDisenchantDbTimeoutTicker == nil and DisenchanterPlus.db.char.general.autoDisenchantEnabled then
    if not silent then
      DisenchanterPlus:Print(string.format(DisenchanterPlus:DP_i18n("Starting auto disenchant")))
    end
    autoDisenchantDbTimeoutTicker = C_Timer.NewTicker(autoDisenchantDbTimeout, function()
      --DisenchanterPlus:Debug("Starting Ticker " .. tostring(autoDisenchantDbTimeout))
      DP_DisenchantProcess:ScanForItems()
    end)
    DP_DisenchantProcess:ScanForItems() -- primera ejecución
  end
end

---Starts autoDisenchant
---@param silent? boolean
function DP_DisenchantProcess:CancelAutoDisenchant(silent)
  --DisenchanterPlus:Debug("Cancel auto disenchant : " .. tostring(silent))
  if autoDisenchantDbTimeoutTicker ~= nil then
    if silent == nil then silent = false end
    if not silent then
      DisenchanterPlus:Print(string.format(DisenchanterPlus:DP_i18n("Cancelling auto disenchant"), DisenchanterPlus:MessageWithAddonColor(DisenchanterPlus:DP_i18n("Enchanting"))))
    end
    autoDisenchantDbTimeoutTicker:Cancel()
    autoDisenchantDbTimeoutTicker = nil
    disenchanting = false
    itemToDisenchant = false
  end
end

---Pause disenchant process
function DP_DisenchantProcess:PauseDisenchantProcess()
  DP_DisenchantProcess:SetAutoDisenchantStatus(false)
  DP_DisenchantProcess:CancelAutoDisenchant(false)
end

function DP_DisenchantProcess:CloseDisenchantProcess()
  --DP_DisenchantProcess:CancelAutoDisenchant(true)
  DP_DisenchantWindow:CloseWindow()
  itemToDisenchant = false
  disenchanting = false
end

---Starts disenchant process
function DP_DisenchantProcess:StartsDisenchantProcess()
  disenchanting = false
  itemToDisenchant = false
  DP_DisenchantProcess:SetAutoDisenchantStatus(true)
  DP_DisenchantProcess:StartAutoDisenchant(false)
end

---Process spell cast stop
---@param unitTarget string
---@param castGUID string
---@param spellID number
function DP_DisenchantProcess:UnitSpellCastStop(unitTarget, castGUID, spellID)
end

---Process spell cast failed
---@param unitTarget string
---@param castGUID string
---@param spellID number
function DP_DisenchantProcess:UnitSpellCastFailed(unitTarget, castGUID, spellID)
  if unitTarget == "player" and spellID == disenchantSpellID then
    if not disenchanting then disenchanting = true end
    local _, itemLink, itemIcon, itemID = DP_DisenchantWindow:GetItemToDisenchant()
    if itemLink ~= nil and itemIcon ~= nil then
      DisenchanterPlus:Print(string.format(DisenchanterPlus:DP_i18n("|cfffc8686Error!|r |T%d:0|t%s Can not be disenchanted. Added to ignored list."), itemIcon, itemLink))
    end
    disenchanting = false
    itemToDisenchant = false
    DP_DisenchantWindow:CloseWindow()

    if itemID then
      DP_DisenchantProcess:AddPermanentIgnoredItem(itemID)
    end

    C_Timer.After(1, function()
      --print("UnitSpellCastFailed")
      if DP_DisenchantProcess:GetAutoDisenchantStatus() then
        DP_DisenchantProcess:StartAutoDisenchant(true)
      end
    end)
  end
end

---Process spell cast failed
---@param unitTarget string
---@param castGUID string
---@param spellID number
function DP_DisenchantProcess:UnitSpellCastInterrupted(unitTarget, castGUID, spellID)
  disenchanting = false
  itemToDisenchant = false

  C_Timer.After(1, function()
    --print("UnitSpellCastInterrupted")
    if DP_DisenchantProcess:GetAutoDisenchantStatus() then
      DP_DisenchantProcess:StartAutoDisenchant(true)
    end
  end)
end

---Process loot closed
function DP_DisenchantProcess:LootClosed()
  --DisenchanterPlus:Debug("Process running : " .. tostring(DP_DisenchantProcess:IsProcessRunning()))
  C_Timer.After(1, function()
    --print("LootClosed")
    if DP_DisenchantProcess:GetAutoDisenchantStatus() then
      DP_DisenchantProcess:StartAutoDisenchant(true)
    end
  end)
end

---Process bag update
function DP_DisenchantProcess:BagUpdate(bagIndex)
  if bagIndex < 0 or bagIndex > 4 then return end
  if DP_DisenchantWindow:IsWindowOpened() then
    local numItemsLeft = DP_DisenchantProcess:ItemsInBags()
    DP_DisenchantWindow:UpdateItemsLeft(numItemsLeft)
  end
end

---Checks if there are items in the session ignore list
---@return boolean
function DP_DisenchantProcess:SessionIgnoredItemsHasElements()
  local sessionIgnoreList = DP_DisenchantGroup:GetSessionIgnoreList() or {}
  if not DP_CustomFunctions:TableIsEmpty(sessionIgnoreList) then
    return true
  end
  return false
end

---Checks if there are items in the permanent ignore list
---@return boolean
function DP_DisenchantProcess:PermanentIgnoredItemsHasElements()
  local permanentIgnoreList = DP_DisenchantGroup:GetPermanentIgnoreList() or {}
  if not DP_CustomFunctions:TableIsEmpty(permanentIgnoreList) then
    return true
  end
  return false
end

function DP_DisenchantProcess:PlayerRegenDisabled()
  DP_DisenchantWindow:DisableButtons()
end

function DP_DisenchantProcess:PlayerRegenEnabled()
  DP_DisenchantWindow:EnableButtons()
end

---Open disenchant window
function DP_DisenchantProcess:OpenDisenchantWindow()
  if InCombatLockdown() or UnitAffectingCombat("player") or disenchanting or itemToDisenchant then return end

  --local disenchantIsKnown = IsSpellKnown(disenchantSpellID)
  --if not disenchantIsKnown then return end

  --local tradeskill = DP_DisenchantProcess:CheckTradeskill()
  --if tradeskill == nil then return end
  local tradeskill = DP_DisenchantProcess:CheckTradeskill() or {}
  DP_DisenchantWindow:OpenWindow({}, tradeskill)
  DP_DisenchantWindow:UpdateItemsLeft(totalItemsInBagsToDisenchant)
end

---Scan for items
function DP_DisenchantProcess:ScanForItems()
  if not DisenchanterPlus.db.char.general.autoDisenchantEnabled then
    DP_DisenchantProcess:CancelAutoDisenchant(true)
    DP_DisenchantWindow:CloseWindow()
  end
  --DisenchanterPlus:Debug("Search items...")
  --DisenchanterPlus:Debug("Is disenchanting ? " .. tostring(disenchanting))
  --DisenchanterPlus:Debug("Has itemToDisenchant ? " .. tostring(itemToDisenchant))
  if InCombatLockdown() or UnitAffectingCombat("player") or disenchanting or itemToDisenchant then return end

  local disenchantIsKnown = IsSpellKnown(disenchantSpellID)
  --DisenchanterPlus:Debug("Has tradeskill ?" .. tostring(disenchantIsKnown))
  if not disenchantIsKnown then return end

  local tradeskill = DP_DisenchantProcess:CheckTradeskill()
  --DisenchanterPlus:Debug("Has tradeskill : " .. tostring(tradeskill))

  if tradeskill == nil then return end

  local itemInfoFromBag = DP_DisenchantProcess:GetItemFromBag()

  --DisenchanterPlus:Debug(DP_DisenchantWindow:ItemToDisenchant())
  --DisenchanterPlus:Dump(itemInfoFromBag)

  if itemInfoFromBag ~= nil and DP_DisenchantWindow:ItemToDisenchant() == nil then
    itemToDisenchant = true
    DP_DisenchantWindow:OpenWindow(itemInfoFromBag, tradeskill)
    DP_DisenchantWindow:UpdateItemsLeft(totalItemsInBagsToDisenchant)
  end
end

---Items in bags
---@param itemLink? string
---@return table|nil items
function DP_DisenchantProcess:GetItemFromBag(itemLink)
  local result
  local itemsInBagsToDisenchant = 0
  local sessionIgnoredList = DP_DisenchantGroup:GetSessionIgnoreList() or {}
  local permanentIgnoredList = DP_DisenchantGroup:GetPermanentIgnoreList() or {}

  for bagIndex = 0, 4 do
    --DisenchanterPlus:Debug("Bag : " .. tostring(bagIndex))
    local itemInBag, numItemsInBag = DP_DisenchantProcess:ItemInBag(bagIndex, itemLink, sessionIgnoredList, permanentIgnoredList)
    if itemInBag ~= nil then
      --DisenchanterPlus:Debug(itemInBag.ItemName)
      if result == nil then result = itemInBag end
    end
    itemsInBagsToDisenchant = itemsInBagsToDisenchant + numItemsInBag
  end
  totalItemsInBagsToDisenchant = itemsInBagsToDisenchant
  return result
end

function DP_DisenchantProcess:ItemsInBags()
  local itemsInBagsToDisenchant = 0
  local sessionIgnoredList = DP_DisenchantGroup:GetSessionIgnoreList() or {}
  local permanentIgnoredList = DP_DisenchantGroup:GetPermanentIgnoreList() or {}
  for bagIndex = 0, 4 do
    --DisenchanterPlus:Debug("Bag : " .. tostring(bagIndex))
    local _, numItemsInBag = DP_DisenchantProcess:ItemInBag(bagIndex, nil, sessionIgnoredList, permanentIgnoredList)
    itemsInBagsToDisenchant = itemsInBagsToDisenchant + numItemsInBag
  end
  return itemsInBagsToDisenchant
end

---Items in bag index
---@param bagIndex number
---@param itemLinkToSearch? string
---@param sessionIgnoredList table
---@param permanentIgnoredList table
---@return table|nil
---@return number
function DP_DisenchantProcess:ItemInBag(bagIndex, itemLinkToSearch, sessionIgnoredList, permanentIgnoredList)
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

---Check for emchanting tradeskill
---@return table|nil
function DP_DisenchantProcess:CheckTradeskill()
  if DisenchanterPlus.IsClassic or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal or DisenchanterPlus.IsHardcore then
    for skillIndex = 1, GetNumSkillLines() do
      local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier,
      skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType,
      skillDescription = GetSkillLineInfo(skillIndex)
      if not isHeader then
        --print(string.format("Skill: %s - %s", skillName, skillRank))
        if skillName == DisenchanterPlus:DP_i18n("Enchanting") then
          return {
            Name = skillName,
            Icon = 136244,
            Level = skillRank
          }
        end
      end
    end
  else
    local profList = {}
    local prof1, prof2, _, _, _, _ = GetProfessions();
    table.insert(profList, prof1)
    table.insert(profList, prof2)
    --DisenchanterPlus:Dump(profList)

    for _, prof in pairs(profList) do
      local tradeskillName, tradeskillIcon, tradeskillLevel, _, _, _, _, _, _, _ = GetProfessionInfo(prof)
      if tradeskillName == DisenchanterPlus:DP_i18n("Enchanting") then
        return {
          Name = tradeskillName,
          Icon = tradeskillIcon,
          Level = tradeskillLevel
        }
      end
    end
  end
  return nil
end

---Is process running
---@return boolean
function DP_DisenchantProcess:IsProcessRunning()
  if autoDisenchantDbTimeoutTicker ~= nil then
    return true
  end
  return false
end

---Set auto disenchant paused
---@param status boolean
function DP_DisenchantProcess:SetAutoDisenchantStatus(status)
  autoDisenchantStatus = status
end

---Get auto disenchant paused
---@return boolean
function DP_DisenchantProcess:GetAutoDisenchantStatus()
  return autoDisenchantStatus
end
