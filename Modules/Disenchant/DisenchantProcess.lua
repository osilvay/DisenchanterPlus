---@class DP_DisenchantProcess
local DP_DisenchantProcess = DP_ModuleLoader:CreateModule("DP_DisenchantProcess")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_DisenchantGroup
local DP_DisenchantGroup = DP_ModuleLoader:ImportModule("DP_DisenchantGroup")

---@type DP_DisenchantWindow
local DP_DisenchantWindow = DP_ModuleLoader:ImportModule("DP_DisenchantWindow")

---@type DP_TradeSkillCheck
local DP_TradeSkillCheck = DP_ModuleLoader:ImportModule("DP_TradeSkillCheck")

---@type DP_BagsCheck
local DP_BagsCheck = DP_ModuleLoader:ImportModule("DP_BagsCheck")

local autoDisenchantDbTimeoutTicker = nil
local disenchantSpellID = 13262
local disenchanting = false
local itemToDisenchant = false
local autoDisenchantStatus = false
local disenchantCastGUID = nil

function DP_DisenchantProcess:Initialize()
  C_Timer.After(1, function()
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
  if unit == "player" and spellID == disenchantSpellID then
    disenchantCastGUID = castGUID
  end
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
    if castGUID and (castGUID ~= disenchantCastGUID) then return end -- < this is the addition
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
    local numItemsLeft = DP_BagsCheck:ItemsInBags()
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
  local tradeskill = DP_TradeSkillCheck:GetTradeSkill() or {}
  DP_DisenchantWindow:OpenWindow({}, tradeskill)
  DP_DisenchantWindow:UpdateItemsLeft(DP_BagsCheck:GetTotalItemsInBagsToDisenchant())
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

  local tradeskill = DP_TradeSkillCheck:GetTradeSkill() or {}
  --DisenchanterPlus:Debug("Has tradeskill : " .. tostring(tradeskill))

  if tradeskill == nil then return end

  local itemInfoFromBag = DP_BagsCheck:GetItemFromBag()
  --DisenchanterPlus:Debug(DP_DisenchantWindow:ItemToDisenchant())
  --DisenchanterPlus:Dump(itemInfoFromBag)

  if itemInfoFromBag ~= nil and DP_DisenchantWindow:ItemToDisenchant() == nil then
    itemToDisenchant = true
    DP_DisenchantWindow:OpenWindow(itemInfoFromBag, tradeskill)
    DP_DisenchantWindow:UpdateItemsLeft(DP_BagsCheck:GetTotalItemsInBagsToDisenchant())
  end
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
