---@class DP_EnchantProcess
local DP_EnchantProcess = DP_ModuleLoader:CreateModule("DP_EnchantProcess")

---@type DP_EnchantWindow
local DP_EnchantWindow = DP_ModuleLoader:ImportModule("DP_EnchantWindow")

---@type DP_TradeskillCheck
local DP_TradeskillCheck = DP_ModuleLoader:ImportModule("DP_TradeskillCheck")

---@type DP_BagsCheck
local DP_BagsCheck = DP_ModuleLoader:ImportModule("DP_BagsCheck")

local IsTradeSkillKnown = false
local IsCraftingWindowOpen = false
local TradeSkillInfo
local TradeSkillLines = {}
local ItemsInBags = {}

---Initialize
function DP_EnchantProcess:Initialize()
  C_Timer.After(1, function()
    TradeSkillInfo = DP_TradeskillCheck:GetTradeSkill()
    if TradeSkillInfo then
      IsTradeSkillKnown = true
    end
  end)
end

---Unit spell cast succeeded event
---@param unitTarget string
---@param castGUID string
---@param spellID number
function DP_EnchantProcess:UnitSpellCastSucceeded(unitTarget, castGUID, spellID)
  local tradeSkillName = DP_TradeskillCheck:FindTradeSkillBySpellID(spellID)
  if tradeSkillName then
    IsTradeSkillKnown = true
  else
    IsTradeSkillKnown = false
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

---Craft show event
function DP_EnchantProcess:CraftShow()
  if IsTradeSkillKnown and TradeSkillInfo and not IsCraftingWindowOpen then
    --DisenchanterPlus:Info("Opening |cffffcc00" .. TradeSkillInfo.Name .. "|r")
    IsCraftingWindowOpen = true
    DP_EnchantProcess:PopulateTradeSkillLines()
    --DP_EnchantProcess:PopulateItemsInBags()
    C_Timer.After(0.1, function()
      DP_EnchantProcess:OpenEnchantWindow()
      DP_EnchantWindow:PopulateEnchantList()
      --DP_EnchantWindow:PopulateItemList()
    end)
  end
end

---Craft close event
function DP_EnchantProcess:CraftClose()
  if IsTradeSkillKnown and TradeSkillInfo and IsCraftingWindowOpen then
    --DisenchanterPlus:Info("Closing |cffffcc00" .. TradeSkillInfo.Name .. "|r")
    IsCraftingWindowOpen = false
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
  DP_EnchantWindow.PopulateEnchantList()
end

---Close enchant window
function DP_EnchantProcess:CloseEnchantWindow()
  if InCombatLockdown() or UnitAffectingCombat("player") then return end
  if DP_EnchantWindow:IsWindowOpened() then
    DP_EnchantWindow:CloseWindow()
  end
end

---Populate tradeSkill lines
function DP_EnchantProcess:PopulateTradeSkillLines()
  if IsCraftingWindowOpen then
    TradeSkillLines = DP_TradeskillCheck:GetTradeSkillLines()
  end
end

---Get tradeSkill lines
---@return table
function DP_EnchantProcess:GetTradeSkillLines()
  DP_EnchantProcess:PopulateTradeSkillLines()
  return TradeSkillLines
end
