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
        --print(string.format("Skill: %s - %s", skillName, skillRank))
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
  local lines = {}
  for index = 1, GetNumCrafts(), 1 do
    local reagents = {}
    local numReagents = GetCraftNumReagents(index);
    local totalReagents = 0;
    for i = 1, numReagents, 1 do
      local name, texturePath, numRequired, numHave = GetCraftReagentInfo(index, i);
      totalReagents = totalReagents + numRequired;
      table.insert(reagents, {
        Name = name,
        Texture = texturePath,
        Count = numRequired,
        PlayerCount = numHave,
      })
    end;

    local craftName, craftSubSpellName, craftType, numAvailable, isExpanded, trainingPointCost, requiredLevel = GetCraftInfo(index)
    local tradeSkillLine = {
      CraftName = craftName,
      CraftSubSpellName = craftSubSpellName,
      CraftType = craftType,
      RequiredLevel = requiredLevel,
      NumAvailable = numAvailable,
      Reagents = reagents
    }
    table.insert(lines, tradeSkillLine)
  end
  return lines
end
