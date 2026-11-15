---@class DP_EnchantProcess
local DP_EnchantProcess = DP_ModuleLoader:CreateModule("DP_EnchantProcess")

---@type DP_EnchantWindow
local DP_EnchantWindow = DP_ModuleLoader:ImportModule("DP_EnchantWindow")

---@type DP_TradeSkillCheck
local DP_TradeSkillCheck = DP_ModuleLoader:ImportModule("DP_TradeSkillCheck")

---@type DP_BagsCheck
local DP_BagsCheck = DP_ModuleLoader:ImportModule("DP_BagsCheck")

local IsTradeSkillKnown = false
local IsCorrectTradeSkill = false
local IsCraftingWindowOpen = false
local TradeSkillInfo
local popupsHooked = false

---Static popups shown by the game when an enchant replaces an existing one,
---with the API the popup's accept button calls.
local replaceEnchantActions = {
  REPLACE_ENCHANT = "ReplaceEnchant",
  TRADE_REPLACE_ENCHANT = "ReplaceTradeEnchant",
  REPLACE_TRADESKILL_ENCHANT = "ReplaceTradeskillEnchant",
}

---Set when a replacement was already confirmed, to avoid confirming twice
---when both the event and the popup hook see the same replacement.
local lastReplaceConfirm = 0

---Is the addon enchant window open or was an enchant cast from it?
---@return boolean
local function IsEnchantFlowActive()
  return DP_EnchantWindow:IsWindowOpened() or DP_EnchantWindow:IsEnchanting()
end

---Return the canonical token for a REPLACE_ENCHANT style dialog/event name.
---@param which string
---@return string|nil
local function GetReplaceEnchantToken(which)
  if type(which) ~= "string" then return nil end
  if replaceEnchantActions[which] then return which end
  for token in pairs(replaceEnchantActions) do
    if string.find(which, token, 1, true) then
      return token
    end
  end
  return nil
end

---Find a visible static popup frame by dialog token
---@param which string
---@return Frame|nil
local function GetVisibleStaticPopup(which)
  if type(StaticPopup_Visible) == "function" then
    local popupName, popupFrame = StaticPopup_Visible(which)
    -- New clients return (name, frame); old ones returned only the frame.
    local dialog = popupFrame or (type(popupName) == "table" and popupName) or nil
    if dialog then return dialog end
    if type(popupName) == "string" and _G[popupName] then return _G[popupName] end
  end

  for index = 1, 4 do
    local dialog = _G["StaticPopup" .. index]
    if dialog and dialog:IsShown() and dialog.which == which then
      return dialog
    end
  end
  return nil
end

---Confirm the "replace enchant" prompt for a dialog token.
---If the popup already exists it is accepted through the same handler its button uses;
---otherwise the API the popup's accept button calls is invoked directly.
---@param which string
---@return boolean handled
local function ConfirmReplaceEnchant(which)
  local token = GetReplaceEnchantToken(which)
  if not token then return false end

  DisenchanterPlus:Debug("Replace enchant detectado: " .. token)

  if GetTime() - lastReplaceConfirm < 0.5 then
    -- Ya confirmado por la otra via: solo cerrar el popup si llego a mostrarse.
    if type(StaticPopup_Hide) == "function" then
      StaticPopup_Hide(token)
    end
    return true
  end

  local dialog = GetVisibleStaticPopup(token)
  if dialog and type(StaticPopup_OnClick) == "function" then
    lastReplaceConfirm = GetTime()
    if pcall(StaticPopup_OnClick, dialog, 1) then
      return true
    end
    lastReplaceConfirm = 0
  end

  local api = replaceEnchantActions[token]
  if type(C_Item) == "table" and api and type(C_Item[api]) == "function" then
    lastReplaceConfirm = GetTime()
    if not pcall(C_Item[api]) then
      lastReplaceConfirm = 0
      return false
    end
    C_Timer.After(0, function()
      if type(StaticPopup_Hide) == "function" then
        StaticPopup_Hide(token)
      end
    end)
    return true
  end
  return false
end

---Create the frame that listens for the replace-enchant game events.
function DP_EnchantProcess:InitializeAutoConfirmPopups()
  if popupsHooked or type(hooksecurefunc) ~= "function" or type(StaticPopup_Show) ~= "function" then
    return
  end
  popupsHooked = true

  -- The game fires REPLACE_ENCHANT when the item is used; this is the most reliable
  -- signal because it does not depend on the popup frame being visible.
  local eventFrame = CreateFrame("Frame", "EnchantWindow_ReplaceEnchantEventFrame", UIParent)
  DP_EnchantProcess.replaceEnchantEventFrame = eventFrame
  for event in pairs(replaceEnchantActions) do
    -- pcall: some client builds may not know every token.
    pcall(eventFrame.RegisterEvent, eventFrame, event)
  end
  eventFrame:SetScript("OnEvent", function(_, event)
    if IsEnchantFlowActive() then
      ConfirmReplaceEnchant(event)
    end
  end)

  -- The game can hide REPLACE_ENCHANT as soon as the spell cast state changes, so the
  -- popup has to be accepted in the same frame it is shown; a delayed accept can arrive
  -- after the dialog is already hidden and the enchant is never applied.
  hooksecurefunc("StaticPopup_Show", function(which)
    if not GetReplaceEnchantToken(which) then return end
    -- Solo se responde por el flujo del addon: ventana de encantamiento abierta o
    -- encantamiento lanzado desde ella. Nunca se toca un popup ajeno al addon.
    if not IsEnchantFlowActive() then return end

    if ConfirmReplaceEnchant(which) then return end

    -- Reintento por si el popup se muestra en otro frame/slot.
    C_Timer.After(0, function()
      if IsEnchantFlowActive() then
        ConfirmReplaceEnchant(which)
      end
    end)
  end)
end

---Initialize
function DP_EnchantProcess:Initialize()
  DP_EnchantProcess:InitializeAutoConfirmPopups()
  C_Timer.After(1, function()
    DP_EnchantProcess:CheckTradeskill()
  end)
end

---Check tradeskill
function DP_EnchantProcess:CheckTradeskill()
  TradeSkillInfo = DP_TradeSkillCheck:GetTradeSkill()
  if TradeSkillInfo then
    IsTradeSkillKnown = true
  end
end

---Unit spell cast succeeded event
---@param unitTarget string
---@param castGUID string
---@param spellID number
function DP_EnchantProcess:UnitSpellCastSucceeded(unitTarget, castGUID, spellID)
  IsCorrectTradeSkill = false
  if not InCombatLockdown() and not UnitAffectingCombat("player") then
    local tradeSkillName = DP_TradeSkillCheck:FindTradeSkillBySpellID(spellID)
    --DisenchanterPlus:Debug(tradeSkillName or "nil")
    if tradeSkillName then
      IsCorrectTradeSkill = true
    end
  end
end

---Is tradeSkill known
---@return boolean
function DP_EnchantProcess:IsTradeSkillKnown()
  return IsTradeSkillKnown
end

---Is craft window open
---@return boolean
function DP_EnchantProcess:IsCraftingWindowOpen()
  return IsCraftingWindowOpen
end

---Set crafting window open
---@param status boolean
function DP_EnchantProcess:SetCraftingWindowOpen(status)
  IsCraftingWindowOpen = status
end

---Is the currently open profession Enchanting (Forever / modern clients)
---@return boolean
function DP_EnchantProcess:IsEnchantingProfessionOpen()
  if not (C_TradeSkillUI and C_TradeSkillUI.GetBaseProfessionInfo) then
    return false
  end
  local professionInfo = C_TradeSkillUI.GetBaseProfessionInfo()
  if professionInfo == nil then
    return false
  end
  return professionInfo.professionName == DisenchanterPlus:DP_i18n("Enchanting")
end

---Craft show event
function DP_EnchantProcess:CraftShow()
  if not DisenchanterPlus.db.char.general.enchantEnabled then return end

  local isCorrectTradeSkill = IsCorrectTradeSkill
  if DisenchanterPlus.IsForever then
    -- Forever opens professions through C_TradeSkillUI.OpenTradeSkill() instead of
    -- casting the profession spell, so detect the open profession directly.
    isCorrectTradeSkill = DP_EnchantProcess:IsEnchantingProfessionOpen()
  end

  if not isCorrectTradeSkill then
    if DP_EnchantProcess:IsCraftingWindowOpen() then
      DP_EnchantProcess:CraftClose()
    end
    return
  end

  DP_EnchantProcess:CheckTradeskill()
  --DisenchanterPlus:Debug("|cffffcc00" .. TradeSkillInfo.Name .. "|r = " .. tostring(IsTradeSkillKnown))
  --DisenchanterPlus:Dump(TradeSkillInfo)

  if IsTradeSkillKnown and TradeSkillInfo
      --and TradeSkillInfo.Name ~= DisenchanterPlus:DP_i18n("Enchanting")
      and not IsCraftingWindowOpen then
    --DisenchanterPlus:Debug("Opening |cffffcc00" .. TradeSkillInfo.Name .. "|r")
    local tradeSkillLines = DP_EnchantProcess:GetTradeSkillLines()
    --DisenchanterPlus:Dump(tradeSkillLines)

    DP_EnchantProcess:SetCraftingWindowOpen(true)
    C_Timer.After(0.1, function()
      DP_EnchantProcess:OpenEnchantWindow()
    end)
  end
end

---Craft close event
function DP_EnchantProcess:CraftClose()
  if not DisenchanterPlus.db.char.general.enchantEnabled then return end
  if IsTradeSkillKnown and TradeSkillInfo and IsCraftingWindowOpen then
    --DisenchanterPlus:Info("Closing |cffffcc00" .. TradeSkillInfo.Name .. "|r")
    DP_EnchantProcess:SetCraftingWindowOpen(false)
    C_Timer.After(0.1, function()
      DP_EnchantProcess:CloseEnchantWindow()
    end)
  end
end

---Open enchant window
function DP_EnchantProcess:OpenEnchantWindow()
  if InCombatLockdown() or UnitAffectingCombat("player") then return end
  if not DP_EnchantWindow:IsWindowOpened() then
    DP_EnchantWindow:OpenWindow()
  end
  DP_EnchantWindow:PopulateEnchantList()
end

---Close enchant window
function DP_EnchantProcess:CloseEnchantWindow()
  if InCombatLockdown() or UnitAffectingCombat("player") then return end
  if DP_EnchantWindow:IsWindowOpened() then
    DP_EnchantWindow:CloseWindow()
  end
end

---Get tradeSkill lines
---@return table
function DP_EnchantProcess:GetTradeSkillLines()
  return DP_TradeSkillCheck:GetTradeSkillLines()
end
