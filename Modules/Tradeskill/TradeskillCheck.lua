---@class DP_TradeSkillCheck
local DP_TradeSkillCheck = DP_ModuleLoader:CreateModule("DP_TradeSkillCheck")

local L = LibStub("AceLocale-3.0"):GetLocale("DisenchanterPlus")

local tradeSkillList = {
  Enchanting = {
    SpellIDList = { 13262, 7411, 7412, 7413, 13920, 28029, 51313, 74258 },
    TradeSkillName = L["Enchanting"]
  },
}

local ENCHANTING_SKILL_LINE_ID = 333

---Is the profession info (C_TradeSkillUI.GetBaseProfessionInfo) Enchanting, matched by skill line ID or localized name
---@param professionInfo table|nil
---@return boolean
function DP_TradeSkillCheck:IsEnchantingProfessionInfo(professionInfo)
  if professionInfo == nil then
    return false
  end
  return professionInfo.professionID == ENCHANTING_SKILL_LINE_ID
    or professionInfo.professionName == DisenchanterPlus:DP_i18n("Enchanting")
end

function DP_TradeSkillCheck:IsOwnEnchantingOpen()
  if not (C_TradeSkillUI and C_TradeSkillUI.GetBaseProfessionInfo) then return false end
  return DP_TradeSkillCheck:IsEnchantingProfessionInfo(C_TradeSkillUI.GetBaseProfessionInfo())
      and not (C_TradeSkillUI.IsTradeSkillLinked and C_TradeSkillUI.IsTradeSkillLinked())
      and not (C_TradeSkillUI.IsTradeSkillGuild and C_TradeSkillUI.IsTradeSkillGuild())
end

local recipeFilterAPI = {
  filterSkillUp = { "GetOnlyShowSkillUpRecipes", "SetOnlyShowSkillUpRecipes" },
  filterWithoutMaterials = { "GetOnlyShowMakeableRecipes", "SetOnlyShowMakeableRecipes" },
}
local pendingRecipeFilters = {}

local function GetNativeRecipeFilter(key)
  if not DisenchanterPlus.IsForever or not DP_TradeSkillCheck:IsOwnEnchantingOpen() then return end
  local api = recipeFilterAPI[key]
  local getter, setter = C_TradeSkillUI[api[1]], C_TradeSkillUI[api[2]]
  if getter and setter then return getter, setter end
end

function DP_TradeSkillCheck:GetRecipeFilter(key)
  local getter = GetNativeRecipeFilter(key)
  if getter then return getter() == true end
  return DisenchanterPlus.db.char.general[key] == true
end

local function UpdateNativeFilterButton()
  local craftingPage = ProfessionsFrame and ProfessionsFrame.CraftingPage
  local recipeList = craftingPage and craftingPage.RecipeList
  local dropdown = recipeList and recipeList.FilterDropdown
  if dropdown and dropdown.ValidateResetState then dropdown:ValidateResetState() end
end

function DP_TradeSkillCheck:SetRecipeFilter(key, enabled)
  DisenchanterPlus.db.char.general[key] = enabled
  local getter, setter = GetNativeRecipeFilter(key)
  if not setter or InCombatLockdown() then
    if DisenchanterPlus.IsForever then pendingRecipeFilters[key] = enabled end
    return
  end

  pendingRecipeFilters[key] = nil
  if getter() == enabled then return end
  setter(enabled)
  UpdateNativeFilterButton()
end

function DP_TradeSkillCheck:ApplyPendingRecipeFilters()
  if not next(pendingRecipeFilters) or not self:IsOwnEnchantingOpen() or InCombatLockdown() then return end
  for key, enabled in pairs(pendingRecipeFilters) do
    self:SetRecipeFilter(key, enabled)
  end
end

---Get the active native slot filter by its localized menu labels.
function DP_TradeSkillCheck:GetEnchantSlotFilters(includeUnfiltered)
  if not DisenchanterPlus.IsForever or not self:IsOwnEnchantingOpen() then return end
  if not (C_TradeSkillUI.GetAllFilterableInventorySlotsCount and C_TradeSkillUI.GetFilterableInventorySlotName
      and C_TradeSkillUI.IsInventorySlotFiltered) then return end

  local slots = {}
  local indices = {}
  local anyFiltered = false
  for index = 1, C_TradeSkillUI.GetAllFilterableInventorySlotsCount() do
    local name = C_TradeSkillUI.GetFilterableInventorySlotName(index)
    if type(name) == "string" and name ~= "" then
      local filtered = C_TradeSkillUI.IsInventorySlotFiltered(index)
      local key = string.lower(name)
      if not indices[key] or not filtered then indices[key] = index end
      slots[key] = slots[key] or not filtered
      anyFiltered = anyFiltered or filtered
    end
  end
  if anyFiltered or includeUnfiltered then return slots, indices end
end

function DP_TradeSkillCheck:SelectEnchantSlot(index)
  if not index or InCombatLockdown() or not DisenchanterPlus.IsForever or not self:IsOwnEnchantingOpen()
      or not C_TradeSkillUI.SetInventorySlotFilter then return false end

  C_TradeSkillUI.SetInventorySlotFilter(index, true, true)
  UpdateNativeFilterButton()
  return true
end

function DP_TradeSkillCheck:ClearEnchantSlot(index)
  if not index or InCombatLockdown() or not DisenchanterPlus.IsForever or not self:IsOwnEnchantingOpen()
      or not C_TradeSkillUI.ClearInventorySlotFilter then return false end

  for slot = 1, C_TradeSkillUI.GetAllFilterableInventorySlotsCount() do
    if C_TradeSkillUI.IsInventorySlotFiltered(slot) ~= (slot ~= index) then return false end
  end

  C_TradeSkillUI.ClearInventorySlotFilter()
  UpdateNativeFilterButton()
  return true
end

---Get tradeSkill
---@return table|nil
function DP_TradeSkillCheck:GetTradeSkill()
  if DisenchanterPlus.IsForever then
    -- Forever / modern client: the old GetNumSkillLines/GetSkillLineInfo globals were removed.
    -- GetProfessions() returns up to 7 profession indices and GetProfessionInfo() accepts them.
    local enchantingName = DisenchanterPlus:DP_i18n("Enchanting")
    for i = 1, 7 do
      local tradeSkillIndex = select(i, GetProfessions())
      if tradeSkillIndex then
        local tradeSkillName, tradeSkillIcon, tradeSkillLevel, _, _, _, skillLineID = GetProfessionInfo(tradeSkillIndex)
        -- 333 is the Enchanting skill line ID; matching it avoids depending on the localized name.
        if tradeSkillName == enchantingName or skillLineID == ENCHANTING_SKILL_LINE_ID then
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
      or DisenchanterPlus.IsEraSeasonal or DisenchanterPlus.IsHardcore or DisenchanterPlus.IsTBC then
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
  end
  return nil
end

---Find proffesion by spellId
---@param spellID number
---@return string|nil tradeSkillName
function DP_TradeSkillCheck:FindTradeSkillBySpellID(spellID)
  -- Secret values cannot be compared while the addon is tainted.
  if issecretvalue and issecretvalue(spellID) then
    return nil
  end
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
  if issecretvalue and issecretvalue(spellID) then
    return false
  end
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
---@return boolean? nativeFiltersApplied
function DP_TradeSkillCheck:GetTradeSkillLines()
  if DisenchanterPlus.IsForever then
    -- Forever / modern client
    return DP_TradeSkillCheck:GetTradeSkillLinesForForever()
  elseif DisenchanterPlus.IsClassic or DisenchanterPlus.IsHardcore
      or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal or DisenchanterPlus.IsTBC then
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

local function CanCraftSkillUp(craftType)
  return craftType == "optimal" or craftType == "medium" or craftType == "easy"
end

---Get tradeskill lines for Forever / modern clients (C_TradeSkillUI)
---@return table
---@return boolean? nativeFiltersApplied
function DP_TradeSkillCheck:GetTradeSkillLinesForForever()
  local lines = {}
  if not (C_TradeSkillUI and C_TradeSkillUI.GetFilteredRecipeIDs) then
    return lines
  end

  if not self:IsOwnEnchantingOpen() then
    return lines
  end

  local recipeIDs = C_TradeSkillUI.GetFilteredRecipeIDs()
  if not recipeIDs then
    return lines
  end

  for _, recipeID in ipairs(recipeIDs) do
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    -- Skip unlearned / dummy recipes, matching the classic GetCraftInfo behavior.
    if recipeInfo and recipeInfo.learned and not recipeInfo.isDummyRecipe then
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

      local craftType = GetCraftTypeFromRelativeDifficulty(recipeInfo.relativeDifficulty)
      if recipeInfo.canSkillUp == false then
        craftType = "trivial"
      end
      table.insert(lines, {
        Index = recipeID,
        CraftName = recipeInfo.name,
        CraftDescription = craftDescription,
        CraftType = craftType,
        NumAvailable = C_TradeSkillUI.GetCraftableCount(recipeID) or 0,
        Reagents = reagents
      })
    end
  end
  return lines, true
end

---Get tradeskill lines for classic
---@return table
function DP_TradeSkillCheck:GetTradeSkillLinesForClassic()
  -- GetNumCrafts()/GetCraftInfo() read whichever craft window is open, so only read them when Enchanting is the open one.
  if GetCraftDisplaySkillLine and GetCraftDisplaySkillLine() ~= DisenchanterPlus:DP_i18n("Enchanting") then
    return {}
  end

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
      CanSkillUp = CanCraftSkillUp(craftType),
      NumAvailable = numAvailable,
      Reagents = reagents
    }
    --DisenchanterPlus:Dump(tradeSkillLine)
    table.insert(lines, tradeSkillLine)
  end
  return lines
end
