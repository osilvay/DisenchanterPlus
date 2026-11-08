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
  if DisenchanterPlus.IsForever then
    -- Forever / modern client: the old GetNumSkillLines/GetSkillLineInfo globals were removed.
    -- GetProfessions() returns up to 7 profession indices and GetProfessionInfo() accepts them.
    local enchantingName = DisenchanterPlus:DP_i18n("Enchanting")
    for i = 1, 7 do
      local tradeSkillIndex = select(i, GetProfessions())
      if tradeSkillIndex then
        local tradeSkillName, tradeSkillIcon, tradeSkillLevel = GetProfessionInfo(tradeSkillIndex)
        if tradeSkillName == enchantingName then
          return {
            TradeSkillIndex = tradeSkillIndex,
            Name = tradeSkillName,
            Icon = tradeSkillIcon,
            Level = tradeSkillLevel
          }
        end
      end
    end
  elseif DisenchanterPlus.IsClassic or DisenchanterPlus.IsEra
      or DisenchanterPlus.IsEraSeasonal or DisenchanterPlus.IsHardcore
      or DisenchanterPlus.IsTBC then
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
  if DisenchanterPlus.IsForever then
    -- Forever / modern client
    return DP_TradeSkillCheck:GetTradeSkillLinesForForever()
  elseif DisenchanterPlus.IsClassic or DisenchanterPlus.IsTBC or DisenchanterPlus.IsHardcore
      or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal then
    -- classic_era
    return DP_TradeSkillCheck:GetTradeSkillLinesForClassic()
  end
  return {}
end

---Map the modern relative difficulty enum to the addon craft type strings
---@param relativeDifficulty number|nil
---@return string
local function GetCraftTypeFromRelativeDifficulty(relativeDifficulty)
  local difficultyEnum = Enum and Enum.TradeskillRelativeDifficulty
  if not difficultyEnum then
    return "optimal"
  end
  local difficultyMap = {
    [difficultyEnum.Optimal] = "optimal",
    [difficultyEnum.Medium] = "medium",
    [difficultyEnum.Easy] = "easy",
    [difficultyEnum.Trivial] = "trivial",
  }
  return difficultyMap[relativeDifficulty] or "optimal"
end

---Get tradeskill lines for Forever / modern clients (C_TradeSkillUI)
---@return table
function DP_TradeSkillCheck:GetTradeSkillLinesForForever()
  local lines = {}
  if not (C_TradeSkillUI and C_TradeSkillUI.GetFilteredRecipeIDs) then
    return lines
  end

  local recipeIDs = C_TradeSkillUI.GetFilteredRecipeIDs()
  if not recipeIDs then
    return lines
  end

  for _, recipeID in ipairs(recipeIDs) do
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    -- Skip unlearned / dummy recipes, matching the classic GetCraftInfo behavior.
    if recipeInfo and recipeInfo.learned ~= false and not recipeInfo.isDummyRecipe then
      local reagents = {}
      local schematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false)
      if schematic and schematic.reagentSlotSchematics then
        for slotIndex, reagentSlotSchematic in ipairs(schematic.reagentSlotSchematics) do
          local reagent = reagentSlotSchematic.reagents and reagentSlotSchematic.reagents[1]
          if reagent and reagent.itemID then
            local reagentName, _, _, _, _, _, _, _, _, reagentTexture = C_Item.GetItemInfo(reagent.itemID)
            if not reagentName and C_Item.GetItemNameByID then
              reagentName = C_Item.GetItemNameByID(reagent.itemID)
            end
            table.insert(reagents, {
              Index = slotIndex,
              Name = reagentName or ("item:" .. tostring(reagent.itemID)),
              Texture = reagentTexture,
              Count = reagentSlotSchematic.quantityRequired or 1,
              PlayerCount = C_Item.GetItemCount(reagent.itemID),
            })
          end
        end
      end

      local craftDescription = ""
      if C_TradeSkillUI.GetRecipeDescription then
        -- Optional reagent data is empty for enchanting recipes, but the API is guarded
        -- because it can reject invalid arguments on some client builds.
        local ok, description = pcall(C_TradeSkillUI.GetRecipeDescription, recipeID, {}, nil)
        if ok and type(description) == "string" then
          craftDescription = description
        end
      end

      table.insert(lines, {
        Index = recipeID,
        CraftName = recipeInfo.name,
        CraftDescription = craftDescription,
        CraftType = GetCraftTypeFromRelativeDifficulty(recipeInfo.relativeDifficulty),
        NumAvailable = C_TradeSkillUI.GetCraftableCount(recipeID) or 0,
        Reagents = reagents
      })
    end
  end
  return lines
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
        Index = i,
        Name = name,
        Texture = texturePath,
        Count = numRequired,
        PlayerCount = numHave,
      })
    end;
    local craftName, _, craftType, numAvailable, _, _, _ = DP_TradeSkillCheck.TradeSkillInfo(index)
    local craftDescription = DP_TradeSkillCheck.TradeSkillDescription(index)

    local tradeSkillLine = {
      Index = index,
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
