---@class DP_TradeSkillCheck
local DP_TradeSkillCheck = DP_ModuleLoader:CreateModule("DP_TradeSkillCheck")

local L = LibStub("AceLocale-3.0"):GetLocale("DisenchanterPlus")

local tradeSkillList = {
  Enchanting = {
    SpellIDList = { 13262, 7411, 7412, 7413, 13920, 28029, 51313, 74258 },
    TradeSkillName = L["Enchanting"]
  },
}

---Get tradeSkill
---@return table|nil
function DP_TradeSkillCheck:GetTradeSkill()
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
function DP_TradeSkillCheck:FindTradeSkillBySpellID(spellID)
  for tradeSkillName, tradeSkillInfo in pairs(tradeSkillList) do
    for _, currentSpellID in pairs(tradeSkillInfo.SpellIDList) do
      if spellID == currentSpellID then
        return tradeSkillName
      end
    end
  end
  return nil
end

---Is enchanting tradeskill
---@param spellID number
---@return boolean
function DP_TradeSkillCheck:IsEnchantingTradeSkill(spellID)
  for tradeSkillName, tradeSkillInfo in pairs(tradeSkillList) do
    for _, currentSpellID in pairs(tradeSkillInfo.SpellIDList) do
      if spellID == currentSpellID then
        return true
      end
    end
  end
  return false
end

---Populate tradeSkill lines
---@return table
function DP_TradeSkillCheck:GetTradeSkillLines()
  if DisenchanterPlus.IsClassic or DisenchanterPlus.IsHardcore or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal then
    -- classic_era
    return DP_TradeSkillCheck:GetTradeSkillLinesForClassic()
  elseif DisenchanterPlus.IsCataclysm then
    -- cataclysm
    return DP_TradeSkillCheck:GetTradeSkillLinesForCata()
  end
  return {}
end

---Get tradeskill lines for classic
---@return table
function DP_TradeSkillCheck:GetTradeSkillLinesForClassic()
  DP_TradeSkillCheck.NumTradeSkills = function()
    return GetNumCrafts()
  end
  DP_TradeSkillCheck.TradeSkillNumReagents = function(index)
    return GetCraftNumReagents(index)
  end
  DP_TradeSkillCheck.TradeSkillReagentInfo = function(index, i)
    return GetCraftReagentInfo(index, i)
  end
  DP_TradeSkillCheck.TradeSkillInfo = function(index)
    return GetCraftInfo(index)
  end
  DP_TradeSkillCheck.TradeSkillDescription = function(index)
    return GetCraftDescription(index)
  end
  local lines = {}
  for index = 1, DP_TradeSkillCheck.NumTradeSkills(), 1 do
    local reagents = {}
    local numReagents = DP_TradeSkillCheck.TradeSkillNumReagents(index)
    local totalReagents = 0;
    for i = 1, numReagents, 1 do
      local name, texturePath, numRequired, numHave = DP_TradeSkillCheck.TradeSkillReagentInfo(index, i)
      totalReagents = totalReagents + numRequired;
      table.insert(reagents, {
        Name = name,
        Texture = texturePath,
        Count = numRequired,
        PlayerCount = numHave,
      })
    end;
    local craftName, _, craftType, numAvailable, _, _, _ = DP_TradeSkillCheck.TradeSkillInfo(index)
    local craftDescription = DP_TradeSkillCheck.TradeSkillDescription(index)

    local tradeSkillLine = {
      CraftName = craftName,
      CraftDescription = craftDescription,
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
function DP_TradeSkillCheck:GetTradeSkillLinesForCata()
  DP_TradeSkillCheck.NumTradeSkills = function(index)
    return GetNumTradeSkills()
  end
  DP_TradeSkillCheck.TradeSkillNumReagents = function(index)
    return GetTradeSkillNumReagents(index)
  end
  DP_TradeSkillCheck.TradeSkillReagentInfo = function(index, i)
    return GetTradeSkillReagentInfo(index, i)
  end
  DP_TradeSkillCheck.TradeSkillInfo = function(index)
    return GetTradeSkillInfo(index)
  end
  DP_TradeSkillCheck.TradeSkillDescription = function(index)
    return GetTradeSkillDescription(index)
  end
  local lines = {}
  for index = 1, DP_TradeSkillCheck.NumTradeSkills(), 1 do
    local reagents = {}
    local numReagents = DP_TradeSkillCheck.TradeSkillNumReagents(index)
    local totalReagents = 0;
    for i = 1, numReagents, 1 do
      local name, texturePath, numRequired, numHave = DP_TradeSkillCheck.TradeSkillReagentInfo(index, i)
      totalReagents = totalReagents + numRequired;
      table.insert(reagents, {
        Name = name,
        Texture = texturePath,
        Count = numRequired,
        PlayerCount = numHave,
      })
    end;

    local craftName, craftType, numAvailable, _, _, _ = DP_TradeSkillCheck.TradeSkillInfo(index)
    local craftDescription = DP_TradeSkillCheck.TradeSkillDescription(index)
    local tradeSkillLine = {
      CraftName = craftName,
      CraftDescription = craftDescription,
      CraftType = craftType,
      NumAvailable = numAvailable,
      Reagents = reagents
    }
    --DisenchanterPlus:Dump(tradeSkillLine)
    table.insert(lines, tradeSkillLine)
  end
  return lines
end
