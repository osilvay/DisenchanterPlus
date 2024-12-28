---@class DP_TradeskillCheck
local DP_TradeskillCheck = DP_ModuleLoader:CreateModule("DP_TradeskillCheck")

local L = LibStub("AceLocale-3.0"):GetLocale("DisenchanterPlus")

local tradeSkillList = {
  Enchanting = {
    SpellIDList = { 13262, 7411, 7412, 7413, 13920, 28029, 51313, 74258 },
    TradeSkillName = L["Enchanting"]
  },
}

---Get tradeSkill
---@return table|nil
function DP_TradeskillCheck:GetTradeSkill()
  local result
  if DisenchanterPlus.IsClassic or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal or DisenchanterPlus.IsHardcore then
    for tradeSkillIndex = 1, GetNumSkillLines() do
      local tradeSkillName, isHeader, _, tradeSkillRank, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(tradeSkillIndex)
      if not isHeader then
        if tradeSkillName == DisenchanterPlus:DP_i18n("Enchanting") then
          return {
            TradeSkillIndex = tradeSkillIndex,
            Name = tradeSkillName,
            Icon = 136244,
            Level = tradeSkillRank
          }
        end
      end
    end
  elseif DisenchanterPlus.IsCataclysm then
    local profList = {}
    local prof1, prof2, _, _, _, _ = GetProfessions();
    table.insert(profList, prof1)
    table.insert(profList, prof2)

    for _, tradeSkillIndex in pairs(profList) do
      local tradeSkillName, tradeSkillIcon, tradeSkillLevel, _, _, _, _, _, _, _ = GetProfessionInfo(tradeSkillIndex)
      if tradeSkillName == DisenchanterPlus:DP_i18n("Enchanting") then
        result = {
          TradeSkillIndex = tradeSkillIndex,
          Name = tradeSkillName,
          Icon = tradeSkillIcon,
          Level = tradeSkillLevel
        }
        break
      end
    end
  end
  return result
end

---Find proffesion by spellId
---@param spellID number
---@return string|nil tradeSkillName
function DP_TradeskillCheck:FindTradeSkillBySpellID(spellID)
  for tradeSkillName, tradeSkillInfo in pairs(tradeSkillList) do
    for _, currentSpellID in pairs(tradeSkillInfo.SpellIDList) do
      if spellID == currentSpellID then
        return tradeSkillName
      end
    end
  end
  return nil
end

---Populate tradeSkill lines
---@return table
function DP_TradeskillCheck:GetTradeSkillLines()
  if DisenchanterPlus.IsClassic or DisenchanterPlus.IsHardcore or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal then
    -- classic_era
    return DP_TradeskillCheck:GetTradeSkillLinesForClassic()
  elseif DisenchanterPlus.IsCataclysm then
    -- cataclysm
    return DP_TradeskillCheck:GetTradeSkillLinesForCata()
  end
  return {}
end

---Get tradeskill lines for classic
---@return table
function DP_TradeskillCheck:GetTradeSkillLinesForClassic()
  DP_TradeskillCheck.NumTradeSkills = function()
    return GetNumCrafts()
  end
  DP_TradeskillCheck.TradeSkillNumReagents = function(index)
    return GetCraftNumReagents(index)
  end
  DP_TradeskillCheck.TradeSkillReagentInfo = function(index, i)
    return GetCraftReagentInfo(index, i)
  end
  DP_TradeskillCheck.TradeSkillInfo = function(index)
    return GetCraftInfo(index)
  end
  local lines = {}
  for index = 1, DP_TradeskillCheck.NumTradeSkills(), 1 do
    local reagents = {}
    local numReagents = DP_TradeskillCheck.TradeSkillNumReagents(index)
    local totalReagents = 0;
    for i = 1, numReagents, 1 do
      local name, texturePath, numRequired, numHave = DP_TradeskillCheck.TradeSkillReagentInfo(index, i)
      totalReagents = totalReagents + numRequired;
      table.insert(reagents, {
        Name = name,
        Texture = texturePath,
        Count = numRequired,
        PlayerCount = numHave,
      })
    end;
    local craftName, _, craftType, numAvailable, _, _, _ = DP_TradeskillCheck.TradeSkillInfo(index)
    local tradeSkillLine = {
      CraftName = craftName,
      CraftType = craftType,
      NumAvailable = numAvailable,
      Reagents = reagents
    }
    --DisenchanterPlus:Dump(tradeSkillLine)
    table.insert(lines, tradeSkillLine)
  end
  return lines
end

---Get tradeskill lines for cata
---@return table
function DP_TradeskillCheck:GetTradeSkillLinesForCata()
  DP_TradeskillCheck.NumTradeSkills = function(index)
    return GetNumTradeSkills()
  end
  DP_TradeskillCheck.TradeSkillNumReagents = function(index)
    return GetTradeSkillNumReagents(index)
  end
  DP_TradeskillCheck.TradeSkillReagentInfo = function(index, i)
    return GetTradeSkillReagentInfo(index, i)
  end
  DP_TradeskillCheck.TradeSkillInfo = function(index)
    return GetTradeSkillInfo(index)
  end
  local lines = {}
  for index = 1, DP_TradeskillCheck.NumTradeSkills(), 1 do
    local reagents = {}
    local numReagents = DP_TradeskillCheck.TradeSkillNumReagents(index)
    local totalReagents = 0;
    for i = 1, numReagents, 1 do
      local name, texturePath, numRequired, numHave = DP_TradeskillCheck.TradeSkillReagentInfo(index, i)
      totalReagents = totalReagents + numRequired;
      table.insert(reagents, {
        Name = name,
        Texture = texturePath,
        Count = numRequired,
        PlayerCount = numHave,
      })
    end;

    local craftName, craftType, numAvailable, _, _, _ = GetTradeSkillInfo(index)
    local tradeSkillLine = {
      CraftName = craftName,
      CraftType = craftType,
      NumAvailable = numAvailable,
      Reagents = reagents
    }
    --DisenchanterPlus:Dump(tradeSkillLine)
    table.insert(lines, tradeSkillLine)
  end
  return lines
end
