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

---Initialize
function DP_EnchantProcess:Initialize()
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

---Craft show event
function DP_EnchantProcess:CraftShow()
  if not IsCorrectTradeSkill then
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
