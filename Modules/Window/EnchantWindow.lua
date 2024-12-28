---@class DP_EnchantWindow
local DP_EnchantWindow           = DP_ModuleLoader:CreateModule("DP_EnchantWindow")

---@type DP_CustomFunctions
local DP_CustomFunctions         = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_CustomSounds
local DP_CustomSounds            = DP_ModuleLoader:ImportModule("DP_CustomSounds")

---@type DP_EnchantPatterns
local DP_EnchantPatterns         = DP_ModuleLoader:ImportModule("DP_EnchantPatterns")

---@type DP_DisenchantProcess
local DP_DisenchantProcess       = DP_ModuleLoader:ImportModule("DP_DisenchantProcess")

---@type DP_SlashCommands
local DP_SlashCommands           = DP_ModuleLoader:ImportModule("DP_SlashCommands")

---@type DP_MinimapIcon
local DP_MinimapIcon             = DP_ModuleLoader:ImportModule("DP_MinimapIcon")

---@type DP_BagsCheck
local DP_BagsCheck               = DP_ModuleLoader:ImportModule("DP_BagsCheck")

---@type DP_EnchantProcess
local DP_EnchantProcess          = DP_ModuleLoader:ImportModule("DP_EnchantProcess")

---@type DP_CustomFrames
local DP_CustomFrames            = DP_ModuleLoader:ImportModule("DP_CustomFrames")

local DEFAULT_DIALOG_BACKDROP    = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 24,
  edgeSize = 24,
  insets = {
    left = 5,
    right = 5,
    top = 5,
    bottom = 5,
  },
}
local CUSTOM_DIALOG_BACKDROP     = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  tile = true,
  edgeSize = 1,
  insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local emptySlot                  = "Interface/AddOns/DisenchanterPlus/Images/Inventory/INVTYPE_SLOT"
local unknownSlot                = "Interface/AddOns/DisenchanterPlus/Images/Inventory/Unknown"

local uncommonIcon               = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\uncommon:16:16|t" --2
local rareIcon                   = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\rare:16:16|t"     --3
local epicIcon                   = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\epic:16:16|t"     --4
local uncommonIconFill           = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\uncommon_fill:16:16|t"
local rareIconFill               = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\rare_fill:16:16|t"
local epicIconFill               = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\epic_fill:16:16|t"

local optimal                    = "ffff8040"
local medium                     = "ffffff00"
local easy                       = "ff40c040"
local trivial                    = "ff808080"

local EnchanterPlusBaseFrame
local textFrameBgColorAlpha      = 0.85
local windowOpened               = false
local itemToDisenchant
local ignoreWindowOpened         = false
local enchantContainerLines      = {}
local itemContainerLines         = {}
local numLinesInEnchantContainer = 0
local numLinesInItemContainer    = 0
local enchantSelected            = nil
local lastEnchantCurrent         = nil
local itemSelected               = nil
local lastItemCurrent            = nil
local enchanting                 = false

function DP_EnchantWindow:CreateEnchantWindow()
  local xOffset = DisenchanterPlus.db.char.general.enchantFrameOffset.xOffset
  local yOffset = DisenchanterPlus.db.char.general.enchantFrameOffset.yOffset

  -- base frame ******************************************************************************************
  EnchanterPlusBaseFrame = CreateFrame("Frame", "EnchantWindow_BaseFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
  EnchanterPlusBaseFrame:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset)
  EnchanterPlusBaseFrame:SetFrameStrata("DIALOG")
  EnchanterPlusBaseFrame:SetFrameLevel(0)
  EnchanterPlusBaseFrame:SetSize(624, 320)
  EnchanterPlusBaseFrame:SetMovable(true)
  EnchanterPlusBaseFrame:EnableMouse(true)
  EnchanterPlusBaseFrame:SetScript("OnMouseDown", DP_EnchantWindow.OnDragStart)
  EnchanterPlusBaseFrame:SetScript("OnMouseUp", DP_EnchantWindow.OnDragStop)

  EnchanterPlusBaseFrame:SetBackdrop(DEFAULT_DIALOG_BACKDROP)
  EnchanterPlusBaseFrame:SetBackdropColor(0, 0, 0, textFrameBgColorAlpha)

  -- title background
  --local titleBackground = CreateFrame("Frame", "EnchantWindow_BaseFrameTitleBackground", EnchanterPlusBaseFrame, BackdropTemplateMixin and "BackdropTemplate")
  --titleBackground:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, "TOPLEFT", 0, 0)
  --titleBackground:SetSize(624, 40)
  --titleBackground:SetBackdropColor(0.3, 0.5, 1, 1)
  --titleBackground:SetFrameStrata("LOW")

  local titleBar = CreateFrame("Button", "EnchantWindow_BaseFrameTitleBackground", EnchanterPlusBaseFrame)
  titleBar:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, "TOPLEFT", 0, 0)
  titleBar:SetSize(624, 36)
  titleBar:SetMovable(false)
  titleBar:SetFrameStrata("LOW")
  titleBar:SetFrameLevel(1)

  local titleBackground = titleBar:CreateTexture(nil, "OVERLAY")
  titleBackground:SetTexture("Interface\\Addons\\DisenchanterPlus\\Images\\Textures\\progressbar")
  titleBackground:SetDrawLayer("OVERLAY", 4)
  titleBackground:SetHeight(34)
  titleBackground:SetWidth(616)
  titleBackground:SetPoint("LEFT", titleBar, 4, -2)
  titleBackground:SetGradient("HORIZONTAL", CreateColor(0.82, 0.30, 0.91, 0.95), CreateColor(0.851, 0.565, 0.902, 0.95))
  titleBar.titleBackground = titleBackground

  local windowBackground = titleBar:CreateTexture(nil, "OVERLAY")
  windowBackground:SetTexture("Interface\\Addons\\DisenchanterPlus\\Images\\Textures\\progressbar")
  windowBackground:SetDrawLayer("OVERLAY", 4)
  windowBackground:SetHeight(278)
  windowBackground:SetWidth(616)
  windowBackground:SetPoint("TOPLEFT", titleBar, 4, -36)
  windowBackground:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0.5), CreateColor(0.6, 0.6, 0.6, 0.5))
  titleBar.windowBackground = windowBackground

  -- texts
  local titleText = EnchanterPlusBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  titleText:SetTextColor(1, 1, 1)
  titleText:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, 20, -12)
  --string.format("|T%s:%s:%s|t ", "Interface\\Addons\\DisenchanterPlus\\Images\\Menus\\disenchanterplus", 16, 16)
  titleText:SetText(DisenchanterPlus:DP_i18n("Item enchanter"))
  EnchanterPlusBaseFrame.titleText = titleText

  local footText = EnchanterPlusBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  footText:SetTextColor(0.6, 0.6, 0.6)
  footText:SetPoint("BOTTOMLEFT", EnchanterPlusBaseFrame, 20, 20)
  footText:SetText("")
  EnchanterPlusBaseFrame.footText = footText

  -- settings button ******************************************************************************************
  local settingsButton = CreateFrame("Button", "EnchantWindow_SettingsButton", EnchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  settingsButton:SetSize(32, 22)
  settingsButton:SetPoint("TOPRIGHT", EnchanterPlusBaseFrame, -45, -10)
  settingsButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Opens settings window."), nil, nil, nil, nil, true)
    settingsButton.text:SetTextColor(1, 1, 1)
    settingsButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\settings:14:14|t ") --.. DisenchanterPlus:DP_i18n("Settings")
  end)
  settingsButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    settingsButton.text:SetTextColor(0.6, 0.6, 0.6)
    settingsButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\settings_a:14:14|t ") -- .. DisenchanterPlus:DP_i18n("Settings"))
  end)
  settingsButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    DP_SlashCommands:OpenSettingsWindow()
    DP_EnchantWindow:CloseWindow()
  end)
  EnchanterPlusBaseFrame.settingsButton = settingsButton

  local settingsText = settingsButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local settingsString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\settings_a:14:14|t " -- .. DisenchanterPlus:DP_i18n("Settings")
  settingsText:SetPoint("CENTER", settingsButton, 2, 0)
  settingsText:SetJustifyH("CENTER")
  settingsText:SetText(settingsString)
  settingsText:SetTextColor(0.6, 0.6, 0.6)
  settingsButton.text = settingsText

  settingsButton:Hide()

  -- close button ******************************************************************************************
  local closeButton = CreateFrame("Button", "EnchantWindow_CloseButton", EnchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  closeButton:SetSize(32, 22)
  closeButton:SetPoint("TOPRIGHT", EnchanterPlusBaseFrame, -10, -10)
  closeButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Close window until next iteration."), nil, nil, nil, nil, true)
    closeButton.text:SetTextColor(1, 1, 1)
    closeButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close:14:14|t ") --.. DisenchanterPlus:DP_i18n("Settings")
  end)
  closeButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    closeButton.text:SetTextColor(0.6, 0.6, 0.6)
    closeButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_a:14:14|t ") -- .. DisenchanterPlus:DP_i18n("Settings"))
  end)
  closeButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    DP_EnchantWindow:CloseWindow()
  end)

  local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local closeString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_a:14:14|t " -- .. DisenchanterPlus:DP_i18n("Settings")
  closeText:SetPoint("CENTER", closeButton, 2, 0)
  closeText:SetJustifyH("CENTER")
  closeText:SetText(closeString)
  closeText:SetTextColor(0.6, 0.6, 0.6)
  closeButton.text = closeText

  EnchanterPlusBaseFrame.closeButton = closeButton
  closeButton:Show()

  -- yes button ******************************************************************************************
  local yesButton = CreateFrame("Button", "EnchantWindow_YesButton", EnchanterPlusBaseFrame, "SecureActionButtonTemplate")
  yesButton:SetEnabled(false)
  yesButton:SetSize(100, 22)
  yesButton:SetPoint("BOTTOMRIGHT", EnchanterPlusBaseFrame, -20, 20)

  local yesDummyButton = CreateFrame("Button", "EnchantWindow_YesDummyButton", EnchanterPlusBaseFrame, "UIPanelButtonTemplate")
  yesDummyButton:SetSize(100, 22)
  yesDummyButton:SetPoint("BOTTOMRIGHT", EnchanterPlusBaseFrame, -20, 20)
  yesDummyButton:Hide()

  local texture = yesButton:CreateTexture(nil, nil, "UIPanelButtonUpTexture")
  yesButton:SetNormalTexture(texture)
  yesButton:SetHighlightTexture(yesDummyButton:GetHighlightTexture())

  local disabledTexture = yesDummyButton:CreateTexture(nil, nil, "UIPanelButtonDisabledTexture")
  yesButton:SetDisabledTexture(disabledTexture)

  yesButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
  yesButton:SetAttribute("type", "macro")
  yesButton:SetAttribute("macrotext", "/cheer")

  DP_EnchantWindow:UpdateKeybindings()

  yesButton:SetScript("OnEnter", function(current)
    local keybind = ""
    if DisenchanterPlus.db.char.general.confirmEnchant ~= nil then
      keybind = " |cffeeeeff" .. DisenchanterPlus.db.char.general.confirmEnchant .. "|r"
    end
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Proceed with the enchantment.") .. keybind, nil, nil, nil, nil, true)
    yesButton.text:SetTextColor(1, 1, 1)
    yesButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\wand:14:14|t " .. DisenchanterPlus:DP_i18n("Enchant"))
  end)
  yesButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    yesButton.text:SetTextColor(0.6, 0.6, 0.6)
    yesButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\wand_a:14:14|t " .. DisenchanterPlus:DP_i18n("Enchant"))
  end)
  yesButton:SetScript("PreClick", function(current)
    if not enchanting then
      DP_EnchantWindow:DisableEnchantButton()
      C_Timer.After(5.5, function()
        local lastSelectedEnchant
        if lastEnchantCurrent and lastItemCurrent then
          lastSelectedEnchant = EnchanterPlusBaseFrame.tabScrollContentFrame1.line[lastEnchantCurrent.lineID].enchant
        end
        DP_EnchantWindow:EnableEnchantButton()
        DP_EnchantWindow:PopulateEnchantList(lastSelectedEnchant)
        enchanting = false
      end)
      enchanting = true
    end
  end)
  EnchanterPlusBaseFrame.yesButton = yesButton

  local yesText = yesButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local yesString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\wand_a:14:14|t " .. DisenchanterPlus:DP_i18n("Enchant")
  yesText:SetPoint("CENTER", yesButton, "CENTER")
  yesText:SetText(yesString)
  yesText:SetTextColor(0.6, 0.6, 0.6)
  yesButton.text = yesText

  -- craft buttons ******************************************************************************************
  DP_EnchantWindow:DrawCraftButton("EnchantWindow_CraftTrivialButton", "trivial", DisenchanterPlus:DP_i18n("Trivial"), "4", -80, -10)
  DP_EnchantWindow:DrawCraftButton("EnchantWindow_CraftTrivialButton", "easy", DisenchanterPlus:DP_i18n("Easy"), "3", -105, -10)
  DP_EnchantWindow:DrawCraftButton("EnchantWindow_CraftTrivialButton", "medium", DisenchanterPlus:DP_i18n("Medium"), "2", -130, -10)
  DP_EnchantWindow:DrawCraftButton("EnchantWindow_CraftTrivialButton", "optimal", DisenchanterPlus:DP_i18n("Optimal"), "1", -155, -10)

  -- custom buttons
  DP_CustomFrames:DrawCustomCleanButton("5", "EnchantWindow_ShowWithMatsButton", EnchanterPlusBaseFrame, "eye", "eye_off",
    DisenchanterPlus:DP_i18n("Filter without materials"), -180, -10,
    function()
      if DisenchanterPlus.db.char.general.filterWithoutMaterials == nil or DisenchanterPlus.db.char.general.filterWithoutMaterials == false then
        return false
      else
        return true
      end
    end,
    function(buttonIndex, name, parent, icon, iconDisabled, testFn)
      if DisenchanterPlus.db.char.general.filterWithoutMaterials == nil or DisenchanterPlus.db.char.general.filterWithoutMaterials == false then
        DisenchanterPlus.db.char.general.filterWithoutMaterials = true
      else
        DisenchanterPlus.db.char.general.filterWithoutMaterials = false
      end
      DP_CustomFrames:RedrawCustomCleanButton(buttonIndex, name, parent, icon, iconDisabled, testFn)
      enchantSelected = nil
      lastEnchantCurrent = nil
      itemSelected = nil
      lastItemCurrent = nil
      DP_EnchantWindow:DisableEnchantButton()
      DP_EnchantWindow:PopulateEnchantList()
      DP_EnchantWindow:PopulateItemList()
    end
  )

  DP_CustomFrames:DrawCustomCleanButton("6", "EnchantWindow_RefreshButton", EnchanterPlusBaseFrame, "refresh", "refresh_a",
    DisenchanterPlus:DP_i18n("Refresh enchants"), -205, -10,
    function()
    end,
    function()
      enchantSelected = nil
      lastEnchantCurrent = nil
      itemSelected = nil
      lastItemCurrent = nil
      DP_EnchantWindow:DisableEnchantButton()
      DP_EnchantWindow:PopulateEnchantList()
      DP_EnchantWindow:PopulateItemList()
    end
  )
  -- tab1 ******************************************************************************************
  local tab1Button = DP_CustomFrames:CreateTab(EnchanterPlusBaseFrame, "EnchantWindow_Tab1", 1, DisenchanterPlus:DP_i18n("Enchant list"), true, 302, 24)
  tab1Button:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, "TOPLEFT", 8, -38);

  EnchanterPlusBaseFrame.tab1Button = tab1Button
  tab1Button:Show()

  -- tab1 scroll frame
  local tabScrollFrame1 = CreateFrame("ScrollFrame", "EnchantWindow_TabScrollFrame1", EnchanterPlusBaseFrame, "UIPanelScrollFrameTemplate")
  tabScrollFrame1:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, "TOPLEFT", 10, -65)
  tabScrollFrame1:SetSize(275, 205)

  local tabScrollContentFrame1 = CreateFrame("Frame", "EnchantWindow_EnchantList", EnchanterPlusBaseFrame)
  tabScrollContentFrame1:SetPoint("CENTER", tabScrollFrame1, "CENTER", 0, 0)
  tabScrollContentFrame1:SetSize(275, 205)
  tabScrollFrame1:SetScrollChild(tabScrollContentFrame1)
  EnchanterPlusBaseFrame.tabScrollContentFrame1 = tabScrollContentFrame1
  tabScrollFrame1:Show()

  -- tab2 ******************************************************************************************
  local tab2Button = DP_CustomFrames:CreateTab(EnchanterPlusBaseFrame, "EnchantWindow_Tab2", 1, DisenchanterPlus:DP_i18n("Item list"), true, 302, 24)
  tab2Button:SetPoint("TOPRIGHT", EnchanterPlusBaseFrame, "TOPRIGHT", -8, -38);

  EnchanterPlusBaseFrame.tab2Button = tab2Button
  tab2Button:Show()

  -- tab1 scroll frame
  local tabScrollFrame2 = CreateFrame("ScrollFrame", "EnchantWindow_TabScrollFrame2", EnchanterPlusBaseFrame, "UIPanelScrollFrameTemplate")
  tabScrollFrame2:SetPoint("TOPRIGHT", EnchanterPlusBaseFrame, "TOPRIGHT", -30, -65)
  tabScrollFrame2:SetSize(275, 205)

  local tabScrollContentFrame2 = CreateFrame("Frame", "EnchantWindow_ItemList", EnchanterPlusBaseFrame)
  tabScrollContentFrame2:SetPoint("CENTER", tabScrollFrame2, "CENTER", 0, 0)
  tabScrollContentFrame2:SetSize(275, 205)
  tabScrollFrame2:SetScrollChild(tabScrollContentFrame2)
  EnchanterPlusBaseFrame.tabScrollContentFrame2 = tabScrollContentFrame2
  tabScrollFrame2:Show()

  EnchanterPlusBaseFrame:Hide()

  DP_EnchantWindow:PopulateEnchantList()

  return EnchanterPlusBaseFrame
end

---Open auto enchant window
function DP_EnchantWindow:OpenWindow()
  if not EnchanterPlusBaseFrame then
    EnchanterPlusBaseFrame = DP_EnchantWindow:CreateEnchantWindow()
  end

  --DisenchanterPlus:Debug(tostring(windowOpened))
  if not windowOpened then
    C_Timer.After(0.2, function()
      EnchanterPlusBaseFrame:SetBackdropColor(0, 0, 0, textFrameBgColorAlpha)
      EnchanterPlusBaseFrame:Show()
      EnchanterPlusBaseFrame.settingsButton:Show()
      windowOpened = true
    end)
  end
end

function DP_EnchantWindow:IsWindowOpened()
  return windowOpened
end

---Close window
function DP_EnchantWindow:CloseWindow()
  if InCombatLockdown() or UnitAffectingCombat("player") or EnchanterPlusBaseFrame == nil then return end
  if EnchanterPlusBaseFrame == nil then return end

  if lastEnchantCurrent then
    lastEnchantCurrent.text:SetTextColor(1, 1, 1, 0.1)
    lastEnchantCurrent.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
    EnchanterPlusBaseFrame.tabScrollContentFrame1.line[lastEnchantCurrent.lineID]:SetBackdropColor(1, 1, 1, 0)
    enchantSelected = nil
    lastEnchantCurrent = nil
    itemSelected = nil
    lastItemCurrent = nil
    DP_EnchantWindow:PopulateItemList()
  end
  DP_EnchantProcess:SetCraftingWindowOpen(false)
  DP_EnchantWindow:DisableEnchantButton()
  EnchanterPlusBaseFrame:Hide()
  windowOpened = false
end

---Drag start
function DP_EnchantWindow.OnDragStart()
  EnchanterPlusBaseFrame:StartMoving()
end

---Drag stop
function DP_EnchantWindow.OnDragStop()
  local frameX = EnchanterPlusBaseFrame:GetCenter()
  local xLeft, yTop, xRight, yBottom = EnchanterPlusBaseFrame:GetLeft(), EnchanterPlusBaseFrame:GetTop(), EnchanterPlusBaseFrame:GetRight(), EnchanterPlusBaseFrame:GetBottom()
  local xSize, ySize = EnchanterPlusBaseFrame:GetSize()
  local screenWidth = GetScreenWidth()
  local xcreenHeight = GetScreenHeight()
  local xPositionFromCenter = -((screenWidth / 2) - xLeft) + (xSize / 2)
  local yPositionFromCenter = -((xcreenHeight / 2) - yTop) - (ySize / 2)
  DisenchanterPlus.db.char.general.enchantFrameOffset.xOffset = tonumber(string.format("%.1f", xPositionFromCenter))
  DisenchanterPlus.db.char.general.enchantFrameOffset.yOffset = tonumber(string.format("%.1f", yPositionFromCenter))
  EnchanterPlusBaseFrame:StopMovingOrSizing()
end

function DP_EnchantWindow:DisableButtons()
  if not EnchanterPlusBaseFrame then return end
end

function DP_EnchantWindow:EnableButtons()
  if not EnchanterPlusBaseFrame then return end
end

---Populate enchant list
---@param lastSelectedEnchant? string
function DP_EnchantWindow:PopulateEnchantList(lastSelectedEnchant)
  local lastSelectedEnchantFound = nil
  if lastSelectedEnchant ~= nil then lastSelectedEnchantFound = false end

  local itemNum = 1
  local offsetV = 24
  local tradeSkillLines = DP_EnchantProcess:GetTradeSkillLines()
  EnchanterPlusBaseFrame.tabScrollContentFrame1.line = {}

  -- filter craft types
  local craftTypesIndex = {}
  craftTypesIndex["1"] = "optimal"
  craftTypesIndex["2"] = "medium"
  craftTypesIndex["3"] = "easy"
  craftTypesIndex["4"] = "trivial"

  local craftTypes = DisenchanterPlus.db.char.general.enchantCraftType or {}
  local craftTypesList = {}

  for k, craftTypesValue in pairs(craftTypes) do
    if craftTypesValue then
      table.insert(craftTypesList, craftTypesIndex[k])
    end
  end

  -- filter exclusions
  local enchantExclusions = DP_EnchantPatterns:GetEnchantExclusions()

  -- draw
  if numLinesInEnchantContainer > 0 then
    for i = 1, numLinesInEnchantContainer, 1 do
      enchantContainerLines[tostring(i)]:Hide()
      enchantContainerLines[tostring(i)].acceptEnchantButton.text:SetTextColor(1, 1, 1, 0.1)
      enchantContainerLines[tostring(i)].acceptEnchantButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t")
    end
  end

  for _, lineInfo in pairs(tradeSkillLines) do
    local filterByCraftType = DP_CustomFunctions:TableHasValue(craftTypesList, lineInfo.CraftType)
    local filtarByExclusion = not DP_CustomFunctions:TableHasValue(enchantExclusions, string.lower(lineInfo.CraftName))
    local filterByNumAvailable = (not DisenchanterPlus.db.char.general.filterWithoutMaterials or
      (DisenchanterPlus.db.char.general.filterWithoutMaterials and (lineInfo.NumAvailable and lineInfo.NumAvailable > 0))) and true or false

    if filterByCraftType and filtarByExclusion and filterByNumAvailable then
      if enchantContainerLines[tostring(itemNum)] == nil then
        local enchantLineFrame = CreateFrame("Frame", "EnchantWindow_EnchantLine" .. itemNum, EnchanterPlusBaseFrame.tabScrollContentFrame1, BackdropTemplateMixin and "BackdropTemplate")
        enchantLineFrame.enchantCorrect = false
        enchantLineFrame.enchant = lineInfo.CraftName

        enchantLineFrame:SetPoint("TOPLEFT", EnchanterPlusBaseFrame.tabScrollContentFrame1, "TOPLEFT", 0, -(offsetV * (itemNum - 1)))
        enchantLineFrame:SetSize(310, 32)
        enchantLineFrame:SetBackdrop(CUSTOM_DIALOG_BACKDROP)
        enchantLineFrame:SetBackdropColor(1, 1, 1, 0)

        -- select button
        local acceptEnchantButton = CreateFrame("Button", "EnchantWindow_SelectButton" .. itemNum, enchantLineFrame, BackdropTemplateMixin and "BackdropTemplate")
        acceptEnchantButton.lineID = itemNum
        acceptEnchantButton.numAvailable = lineInfo.NumAvailable or 0
        acceptEnchantButton.reagents = lineInfo.Reagents

        acceptEnchantButton:SetSize(32, 32)
        acceptEnchantButton:SetPoint("RIGHT", enchantLineFrame, -40, 0)
        acceptEnchantButton:SetScript("OnEnter", function(current)
          GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
          --local tooltipString = "|cffffffff" .. DisenchanterPlus:DP_i18n("Reagents") .. "|r\n\n"
          GameTooltip:AddLine(DisenchanterPlus:DP_i18n("Reagents"))
          local reagents = current.reagents or {}
          for _, reagent in pairs(reagents) do
            local reagentLeftLine = string.format(" + |T%d:0|t |cffe1e1e1%s|r", reagent.Texture or 134400, reagent.Name)
            local reagentRightLine = string.format("|cff91c1f1x|r |cff6191f1%d|r", reagent.Count)
            GameTooltip:AddLine(reagentLeftLine .. " " .. reagentRightLine)
            --tooltipString = tooltipString .. reagentLine
          end
          --GameTooltip:SetText(tooltipString, nil, nil, nil, nil, false)
          --GameTooltip:AddDoubleLine()
          GameTooltip:Show()
          if enchantSelected ~= current.lineID then
            current.text:SetTextColor(1, 1, 1, 0.6)
            current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
            EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]:SetBackdropColor(1, 1, 1, 0.3)
          end
        end)
        acceptEnchantButton:SetScript("OnLeave", function(current)
          GameTooltip:Hide()
          if enchantSelected ~= current.lineID then
            current.text:SetTextColor(1, 1, 1, 0.1)
            current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t")
            EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]:SetBackdropColor(1, 1, 1, 0)
          end
        end)
        acceptEnchantButton:SetScript("OnClick", function(current)
          if enchantSelected ~= current.lineID then
            if lastEnchantCurrent then
              lastEnchantCurrent.text:SetTextColor(1, 1, 1, 0.1)
              lastEnchantCurrent.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
              EnchanterPlusBaseFrame.tabScrollContentFrame1.line[lastEnchantCurrent.lineID]:SetBackdropColor(1, 1, 1, 0)
            end
            current.text:SetTextColor(1, 1, 1, 1)
            EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]:SetBackdropColor(1, 1, 1, 0.6)
            enchantSelected = current.lineID
            lastEnchantCurrent = current
            if current.numAvailable and current.numAvailable > 0 then
              current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_c:24:24|t")
              itemSelected    = nil
              lastItemCurrent = nil
              DP_EnchantWindow:PopulateItemList(EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID].enchant)
            else
              current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_c:24:24|t")
              EnchanterPlusBaseFrame.footText:SetText("|cffff0a30" .. DisenchanterPlus:DP_i18n("You don't have any materials for that enchantment.") .. "|r")
              DP_EnchantWindow:PopulateItemList()
            end
          else
            current.text:SetTextColor(1, 1, 1, 0.1)
            current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
            EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]:SetBackdropColor(1, 1, 1, 0)
            EnchanterPlusBaseFrame.footText:SetText("|cffffc700" .. DisenchanterPlus:DP_i18n("Select an enchantment from the left list.") .. "|r")
            enchantSelected = nil
            lastEnchantCurrent = nil
            itemSelected = nil
            lastItemCurrent = nil
            DP_EnchantWindow:PopulateItemList()
            DP_EnchantWindow:DisableEnchantButton()
          end
        end)
        acceptEnchantButton:SetBackdrop({
          bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
          tile = true,
          edgeSize = 2,
          insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        acceptEnchantButton:SetBackdropColor(0, 0, 0, 0)
        enchantLineFrame.acceptEnchantButton = acceptEnchantButton

        local acceptEnchantText = acceptEnchantButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        local acceptEnchantString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t"
        acceptEnchantText:SetPoint("CENTER", acceptEnchantButton, "CENTER")
        acceptEnchantText:SetTextColor(1, 1, 1, 0.1)
        if lastSelectedEnchant == lineInfo.CraftName then
          acceptEnchantString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_c:24:24|t"
          acceptEnchantText:SetTextColor(1, 1, 1, 1)
          lastSelectedEnchantFound = true
        end
        acceptEnchantText:SetText(acceptEnchantString)
        acceptEnchantButton.text = acceptEnchantText

        -- enchant text
        local enchantLineText = enchantLineFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        enchantLineText.lineID = itemNum
        enchantLineText.numAvailable = lineInfo.NumAvailable or 0

        enchantLineText:SetSize(240, 32)
        enchantLineText:SetPoint("LEFT", enchantLineFrame, 10, 0)
        enchantLineText:SetText(string.format("|c%s%s %s|r",
          DP_EnchantWindow:GetColorByCraftType(lineInfo.CraftType),
          (lineInfo.NumAvailable and lineInfo.NumAvailable > 0) and "[" .. lineInfo.NumAvailable .. "]" or "-",
          lineInfo.CraftName))
        enchantLineText:SetJustifyH("LEFT")
        enchantLineText:SetMaxLines(1)
        enchantLineText:SetScript("OnEnter", function(current)
          if enchantSelected ~= current.lineID then
            local tabFrame = EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]
            tabFrame.acceptEnchantButton.text:SetTextColor(1, 1, 1, 0.6)
            tabFrame.acceptEnchantButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
            tabFrame:SetBackdropColor(1, 1, 1, 0.3)
          end
        end)
        enchantLineText:SetScript("OnLeave", function(current)
          if enchantSelected ~= current.lineID then
            local tabFrame = EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]
            tabFrame.acceptEnchantButton.text:SetTextColor(1, 1, 1, 0.1)
            tabFrame.acceptEnchantButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
            tabFrame:SetBackdropColor(1, 1, 1, 0.0)
          end
        end)
        enchantLineFrame.enchantLineText = enchantLineText
        EnchanterPlusBaseFrame.tabScrollContentFrame1.line[itemNum] = enchantLineFrame
        enchantContainerLines[tostring(itemNum)] = enchantLineFrame
      else
        local enchantLineFrame = enchantContainerLines[tostring(itemNum)]
        enchantLineFrame.enchantCorrect = false
        enchantLineFrame.enchant = lineInfo.CraftName

        local acceptEnchantButton = enchantLineFrame.acceptEnchantButton
        acceptEnchantButton.lineID = itemNum
        acceptEnchantButton.numAvailable = lineInfo.NumAvailable or 0
        acceptEnchantButton.reagents = lineInfo.Reagents

        if lastSelectedEnchant == lineInfo.CraftName then
          local acceptEnchantString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_c:24:24|t"
          acceptEnchantButton.text:SetTextColor(1, 1, 1, 1)
          acceptEnchantButton.text:SetText(acceptEnchantString)
          lastSelectedEnchantFound = true
        end

        local enchantLineText = enchantLineFrame.enchantLineText
        enchantLineText.lineID = itemNum
        enchantLineText.numAvailable = lineInfo.NumAvailable or 0

        enchantLineText:SetText(string.format("|c%s%s %s|r",
          DP_EnchantWindow:GetColorByCraftType(lineInfo.CraftType),
          (lineInfo.NumAvailable and lineInfo.NumAvailable > 0) and "[" .. lineInfo.NumAvailable .. "]" or "-",
          lineInfo.CraftName))

        EnchanterPlusBaseFrame.tabScrollContentFrame1.line[itemNum] = enchantLineFrame
        enchantContainerLines[tostring(itemNum)] = enchantLineFrame
        enchantLineFrame:Show()
      end
      itemNum = itemNum + 1
    end
  end
  EnchanterPlusBaseFrame.tabScrollContentFrame1:Show()
  numLinesInEnchantContainer = DP_CustomFunctions:TableLength(EnchanterPlusBaseFrame.tabScrollContentFrame1.line)

  if lastSelectedEnchant ~= nil and not lastSelectedEnchantFound then
    enchantSelected = nil
    lastEnchantCurrent = nil
    itemSelected = nil
    lastItemCurrent = nil
    DP_EnchantWindow:DisableEnchantButton()
    DP_EnchantWindow:PopulateItemList()
  end

  EnchanterPlusBaseFrame.footText:SetText("|cffffc700" .. DisenchanterPlus:DP_i18n("Select an enchantment from the left list.") .. "|r")
end

---Get color by craft type
---@param craftType string
---@return string
function DP_EnchantWindow:GetColorByCraftType(craftType)
  if not craftType == nil or craftType == "trivial" then
    return trivial
  elseif craftType == "easy" then
    return easy
  elseif craftType == "medium" then
    return medium
  elseif craftType == "optimal" then
    return optimal
  else
    return trivial
  end
end

---Get equip location from enchant
---@param enchant string
---@return table|nil
function DP_EnchantWindow:GetEquipLocationFromEnchant(enchant)
  local equipoLocations = DP_EnchantPatterns:GetEquipLocationsForEnchantTypes()
  for pattern, equipLocation in pairs(equipoLocations) do
    local search = string.find(string.lower(enchant), pattern)
    if search then
      --DisenchanterPlus:Dump(equipLocation)
      return equipLocation
    end
  end
  return nil
end

---Populate item list
---@param enchant? string
function DP_EnchantWindow:PopulateItemList(enchant)
  local itemNum = 1
  local offsetV = 24
  local totalItemsInBags = {}
  EnchanterPlusBaseFrame.tabScrollContentFrame2.line = {}

  if numLinesInItemContainer > 0 then
    for i = 1, numLinesInItemContainer, 1 do
      itemContainerLines[tostring(i)]:Hide()
    end
  end
  if not enchant then return end

  local equipLocations = DP_EnchantWindow:GetEquipLocationFromEnchant(enchant)
  if equipLocations then
    for _, equipLocation in pairs(equipLocations) do
      local itemsInBags = DP_BagsCheck:GetItemsInBags(equipLocation)
      for k, v in pairs(itemsInBags) do totalItemsInBags[k] = v end
    end
  end

  if DP_CustomFunctions:TableIsEmpty(totalItemsInBags) then
    EnchanterPlusBaseFrame.footText:SetText("|cffff650a" .. DisenchanterPlus:DP_i18n("There are no items for this enchantment.") .. "|r")
    return
  end

  for _, lineInfo in pairs(totalItemsInBags) do
    if itemContainerLines[tostring(itemNum)] == nil then
      local itemLineFrame = CreateFrame("Frame", "EnchantWindow_ItemLine" .. itemNum, EnchanterPlusBaseFrame.tabScrollContentFrame2, BackdropTemplateMixin and "BackdropTemplate")
      itemLineFrame.itemCorrect = false
      itemLineFrame.itemID = lineInfo.ItemID
      itemLineFrame.itemName = lineInfo.ItemName

      itemLineFrame:SetPoint("TOPLEFT", EnchanterPlusBaseFrame.tabScrollContentFrame2, "TOPLEFT", 0, -(offsetV * (itemNum - 1)))
      itemLineFrame:SetSize(310, 32)
      itemLineFrame:SetBackdrop(CUSTOM_DIALOG_BACKDROP)
      itemLineFrame:SetBackdropColor(1, 1, 1, 0)

      -- select button ***************************************************************************************************************************************
      local acceptItemButton = CreateFrame("Button", "EnchantWindow_SelectItemButton" .. itemNum, itemLineFrame, BackdropTemplateMixin and "BackdropTemplate")
      acceptItemButton.lineID = itemNum

      acceptItemButton:SetSize(32, 32)
      acceptItemButton:SetPoint("RIGHT", itemLineFrame, -40, 0)
      acceptItemButton:SetScript("OnEnter", function(current)
        GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
        GameTooltip:SetText(DisenchanterPlus:DP_i18n("Select"), nil, nil, nil, nil, true)
        if itemSelected ~= current.lineID then
          current.text:SetTextColor(1, 1, 1, 0.6)
          current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
          EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]:SetBackdropColor(1, 1, 1, 0.3)
        end
      end)
      acceptItemButton:SetScript("OnLeave", function(current)
        GameTooltip:Hide()
        if itemSelected ~= current.lineID then
          current.text:SetTextColor(1, 1, 1, 0.1)
          current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t")
          EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]:SetBackdropColor(1, 1, 1, 0)
        end
      end)
      acceptItemButton:SetScript("OnClick", function(current)
        if itemSelected ~= current.lineID then
          if lastItemCurrent then
            lastItemCurrent.text:SetTextColor(1, 1, 1, 0.1)
            lastItemCurrent.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
            EnchanterPlusBaseFrame.tabScrollContentFrame2.line[lastItemCurrent.lineID]:SetBackdropColor(1, 1, 1, 0)
          end
          current.text:SetTextColor(1, 1, 1, 1)
          current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_c:24:24|t")
          EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]:SetBackdropColor(1, 1, 1, 0.6)
          itemSelected = current.lineID
          lastItemCurrent = current
          DP_EnchantWindow:CheckReadyToEnchant()
        else
          current.text:SetTextColor(1, 1, 1, 0.1)
          current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
          EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]:SetBackdropColor(1, 1, 1, 0)
          EnchanterPlusBaseFrame.footText:SetText("|cffffc700" .. DisenchanterPlus:DP_i18n("Select an item from the right list.") .. "|r")
          itemSelected = nil
          lastItemCurrent = nil
          DP_EnchantWindow:DisableEnchantButton()
        end
      end)
      acceptItemButton:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        edgeSize = 2,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
      })
      acceptItemButton:SetBackdropColor(0, 0, 0, 0)
      itemLineFrame.acceptItemButton = acceptItemButton

      -- button text ***************************************************************************************************************************************
      local acceptItemText = acceptItemButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      local acceptItemString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t"
      acceptItemText:SetPoint("CENTER", acceptItemButton, "CENTER")
      acceptItemText:SetText(acceptItemString)
      acceptItemText:SetTextColor(1, 1, 1, 0.1)
      acceptItemButton.text = acceptItemText

      -- item text ***************************************************************************************************************************************
      local itemLineText = itemLineFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      itemLineText.lineID = itemNum

      itemLineText:SetSize(240, 32)
      itemLineText:SetPoint("LEFT", itemLineFrame, 10, 0)
      itemLineText:SetText(string.format("%s", lineInfo.ItemLink))
      itemLineText:SetJustifyH("LEFT")
      itemLineText:SetMaxLines(1)
      itemLineText:SetScript("OnEnter", function(current)
        if itemSelected ~= current.lineID then
          local tabFrame = EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]
          tabFrame.acceptItemButton.text:SetTextColor(1, 1, 1, 0.6)
          tabFrame.acceptItemButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
          tabFrame:SetBackdropColor(1, 1, 1, 0.3)
        end
      end)
      itemLineText:SetScript("OnLeave", function(current)
        if itemSelected ~= current.lineID then
          local tabFrame = EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]
          tabFrame.acceptItemButton.text:SetTextColor(1, 1, 1, 0.1)
          tabFrame.acceptItemButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
          tabFrame:SetBackdropColor(1, 1, 1, 0.0)
        end
      end)
      itemLineFrame.itemLineText = itemLineText
      EnchanterPlusBaseFrame.tabScrollContentFrame2.line[itemNum] = itemLineFrame
      itemContainerLines[tostring(itemNum)] = itemLineFrame
    else
      local itemLineFrame = itemContainerLines[tostring(itemNum)]
      itemLineFrame:SetBackdropColor(1, 1, 1, 0)
      itemLineFrame.itemCorrect = false
      itemLineFrame.itemID = lineInfo.ItemID
      itemLineFrame.itemName = lineInfo.ItemName

      local acceptItemButton = itemLineFrame.acceptItemButton
      acceptItemButton.text:SetTextColor(1, 1, 1, 0.1)
      acceptItemButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t")
      acceptItemButton.lineID = itemNum
      acceptItemButton.numAvailable = lineInfo.NumAvailable or 0

      local itemLineText = itemLineFrame.itemLineText
      itemLineText.lineID = itemNum
      itemLineText:SetText(string.format("%s", lineInfo.ItemLink))

      EnchanterPlusBaseFrame.tabScrollContentFrame2.line[itemNum] = itemLineFrame
      itemContainerLines[tostring(itemNum)] = itemLineFrame

      itemLineFrame:Show()
    end
    itemNum = itemNum + 1
  end

  EnchanterPlusBaseFrame.tabScrollContentFrame2:Show()
  numLinesInItemContainer = DP_CustomFunctions:TableLength(EnchanterPlusBaseFrame.tabScrollContentFrame2.line)

  EnchanterPlusBaseFrame.footText:SetText("|cffffc700" .. DisenchanterPlus:DP_i18n("Select an item from the right list.") .. "|r")
end

---Get enchant and item selected
---@return string|nil
---@return string|nil
function DP_EnchantWindow:CheckReadyToEnchant()
  if not lastEnchantCurrent or not lastItemCurrent then
    DP_EnchantWindow:DisableEnchantButton()
    return
  end

  local enchant = EnchanterPlusBaseFrame.tabScrollContentFrame1.line[lastEnchantCurrent.lineID].enchant
  local itemName = EnchanterPlusBaseFrame.tabScrollContentFrame2.line[lastItemCurrent.lineID].itemName

  local macro = string.format("/cast %s\n/use %s\n/click StaticPopup1Button1\n", enchant, itemName)
  EnchanterPlusBaseFrame.yesButton:SetAttribute("macrotext", macro)

  C_Timer.After(0.2, function()
    DP_EnchantWindow:EnableEnchantButton()
    local footText = "|cff1cee1c" .. DisenchanterPlus:DP_i18n("You can start to enchant.") .. "|r"
    EnchanterPlusBaseFrame.footText:SetText(footText)
  end)
end

---Enable enchant button
function DP_EnchantWindow:EnableEnchantButton()
  local enabledTexture = EnchanterPlusBaseFrame.yesButton:CreateTexture(nil, nil, "UIPanelButtonUpTexture")
  EnchanterPlusBaseFrame.yesButton:SetNormalTexture(enabledTexture)
  EnchanterPlusBaseFrame.yesButton:SetEnabled(true)
end

---Disable enchant button
function DP_EnchantWindow:DisableEnchantButton()
  local disabledTexture = EnchanterPlusBaseFrame.yesButton:CreateTexture(nil, nil, "UIPanelButtonDisabledTexture")
  EnchanterPlusBaseFrame.yesButton:SetDisabledTexture(disabledTexture)
  EnchanterPlusBaseFrame.yesButton:SetEnabled(false)
end

---Update key bindings
function DP_EnchantWindow:UpdateKeybindings()
  if DisenchanterPlus.db.char.general.confirmEnchant ~= nil then
    SetBindingClick(DisenchanterPlus.db.char.general.confirmEnchant, "EnchantWindow_YesButton", "LeftButton")
  end
end

---Draw craft button
---@param name string
---@param icon string
---@param tooltipText string
---@param craftIndex string
---@param x number
---@param y number
function DP_EnchantWindow:DrawCraftButton(name, icon, tooltipText, craftIndex, x, y)
  if not EnchanterPlusBaseFrame.craftButton then
    EnchanterPlusBaseFrame.craftButton = {}
  end

  local craftButton = CreateFrame("Button", name, EnchanterPlusBaseFrame, BackdropTemplateMixin and "BackdropTemplate")
  craftButton.craftIndex = craftIndex
  craftButton:SetSize(32, 22)
  craftButton:SetPoint("TOPRIGHT", EnchanterPlusBaseFrame, x, y)
  craftButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
    current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. "_fill:16:16|t ") --.. DisenchanterPlus:DP_i18n("Settings")
    current:SetAlpha(0.8)
  end)
  craftButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    local craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. ":16:16|t "
    if DP_EnchantWindow:CheckCraftTypeStatus(current.craftIndex) then
      craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. "_fill:16:16|t "
    end
    current.text:SetText(craftString)
    current:SetAlpha(0.6)
  end)
  craftButton:SetScript("OnClick", function(current)
    DP_EnchantWindow:ClickCraftTypeButton(craftIndex, icon)
  end)
  craftButton:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    edgeSize = 2,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  craftButton:SetBackdropColor(0, 0, 0, 0)
  craftButton:SetAlpha(0.6)

  local craftText = craftButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. ":16:16|t "
  if DP_EnchantWindow:CheckCraftTypeStatus(craftIndex) then
    craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. "_fill:16:16|t "
  end

  craftText:SetPoint("CENTER", craftButton, 2, 0)
  craftText:SetJustifyH("CENTER")
  craftText:SetText(craftString)
  craftButton.text = craftText

  EnchanterPlusBaseFrame.craftButton[craftIndex] = craftButton
  craftButton:Show()
end

---Chceck craft type
---@param craftIndex string
---@return boolean
function DP_EnchantWindow:CheckCraftTypeStatus(craftIndex)
  if DisenchanterPlus.db.char.general.enchantCraftType[craftIndex] == nil or DisenchanterPlus.db.char.general.enchantCraftType[craftIndex] == true then
    return true
  else
    return false
  end
end

---Click craft button
---@param craftIndex string
---@param icon string
function DP_EnchantWindow:ClickCraftTypeButton(craftIndex, icon)
  if DP_EnchantWindow:CheckCraftTypeStatus(craftIndex) then
    DisenchanterPlus.db.char.general.enchantCraftType[craftIndex] = false
  else
    DisenchanterPlus.db.char.general.enchantCraftType[craftIndex] = true
  end
  DP_CustomSounds:PlayCustomSound("ChatScrollButton")
  DP_EnchantWindow:RedrawCraftButton(craftIndex, icon)
end

---Redraw craft button
---@param craftIndex string
---@param icon string
function DP_EnchantWindow:RedrawCraftButton(craftIndex, icon)
  local craftButton = EnchanterPlusBaseFrame.craftButton[craftIndex]
  if craftButton then
    local craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. ":16:16|t "
    if DP_EnchantWindow:CheckCraftTypeStatus(craftIndex) then
      craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. "_fill:16:16|t "
    end
    craftButton.text:SetText(craftString)
    C_Timer.After(0.1, function()
      enchantSelected = nil
      lastEnchantCurrent = nil
      itemSelected = nil
      lastItemCurrent = nil
      DP_EnchantWindow:DisableEnchantButton()
      DP_EnchantWindow:PopulateEnchantList()
    end)
  end
end
