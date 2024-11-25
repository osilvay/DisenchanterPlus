---@class DP_DisenchantWindow
local DP_DisenchantWindow = DP_ModuleLoader:CreateModule("DP_DisenchantWindow")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_CustomSounds
local DP_CustomSounds = DP_ModuleLoader:ImportModule("DP_CustomSounds")

---@type DP_Database
local DP_Database = DP_ModuleLoader:ImportModule("DP_Database")

---@type DP_DisenchantProcess
local DP_DisenchantProcess = DP_ModuleLoader:ImportModule("DP_DisenchantProcess")

---@type DP_SlashCommands
local DP_SlashCommands = DP_ModuleLoader:ImportModule("DP_SlashCommands")

---@type DP_DisenchantGroup
local DP_DisenchantGroup = DP_ModuleLoader:ImportModule("DP_DisenchantGroup")

local LibStub = LibStub
--local AceGUI = LibStub("AceGUI-3.0")
--local fullBarWidth = 284
--local currentBarWidth = 0

local DEFAULT_DIALOG_BACKDROP = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 32,
  edgeSize = 32,
  insets = {
    left = 5,
    right = 5,
    top = 5,
    bottom = 5,
  },
}
local CUSTOM_DIALOG_BACKDROP = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  tile = true,
  edgeSize = 2,
  insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local DisenchanterPlusBaseFrame
local textFrameBgColorAlpha = 0.80
local windowOpened = false
local itemToDisenchant
local currentItemProcessed = 0

---Initilize
function DP_DisenchantWindow:CreateAutoDisenchantWindow()
  local xOffset = DisenchanterPlus.db.char.general.disenchantFrameOffset.xOffset
  local yOffset = DisenchanterPlus.db.char.general.disenchantFrameOffset.yOffset

  -- base frame ******************************************************************************************
  DisenchanterPlusBaseFrame = CreateFrame("Frame", "DisenchanterPlus_AutoDisenchant", UIParent, BackdropTemplateMixin and "BackdropTemplate")
  DisenchanterPlusBaseFrame:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset)
  DisenchanterPlusBaseFrame:SetFrameStrata("MEDIUM")
  DisenchanterPlusBaseFrame:SetFrameLevel(0)
  DisenchanterPlusBaseFrame:SetSize(424, 190)
  DisenchanterPlusBaseFrame:SetMovable(true)
  DisenchanterPlusBaseFrame:EnableMouse(true)
  DisenchanterPlusBaseFrame:SetScript("OnMouseDown", DP_DisenchantWindow.OnDragStart)
  DisenchanterPlusBaseFrame:SetScript("OnMouseUp", DP_DisenchantWindow.OnDragStop)
  DisenchanterPlusBaseFrame:SetScript("OnEnter", function()
  end)
  DisenchanterPlusBaseFrame:SetScript("OnLeave", function()
  end)

  DisenchanterPlusBaseFrame:SetBackdrop(DEFAULT_DIALOG_BACKDROP)
  DisenchanterPlusBaseFrame:SetBackdropColor(0, 0, 0, textFrameBgColorAlpha)

  -- text
  local titleText = DisenchanterPlusBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  titleText:SetTextColor(1, 1, 1)
  titleText:SetPoint("TOPLEFT", DisenchanterPlusBaseFrame, 20, -20)
  titleText:SetText(DisenchanterPlus:DP_i18n("Auto disenchanting") .. " :")

  local itemLeftText = DisenchanterPlusBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  itemLeftText:SetTextColor(0.6, 0.6, 0.6)
  itemLeftText:SetPoint("BOTTOMLEFT", DisenchanterPlusBaseFrame, 20, 50)
  itemLeftText:SetText(string.format("%s : |cffffcc00%d|r", DisenchanterPlus:DP_i18n("Items left"), 0))
  DisenchanterPlusBaseFrame.itemLeftText = itemLeftText

  local footText = DisenchanterPlusBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  footText:SetTextColor(1, 1, 1)
  footText:SetPoint("TOPLEFT", DisenchanterPlusBaseFrame, 20, -45)
  footText:SetText("")
  DisenchanterPlusBaseFrame.footText = footText

  -- item ******************************************************************************************
  local itemButton = CreateFrame("Button", "AutoDisenchant_ItemFrame", DisenchanterPlusBaseFrame)
  itemButton:SetPoint("TOPLEFT", DisenchanterPlusBaseFrame, "TOPLEFT", 20, -70)
  itemButton:SetHeight(48)
  itemButton:SetWidth(48)
  itemButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    local bagIndex = tonumber(DisenchanterPlusBaseFrame.yesButton:GetAttribute("target-bag")) or nil
    local slot = tonumber(DisenchanterPlusBaseFrame.yesButton:GetAttribute("target-slot")) or nil
    if bagIndex ~= nil and slot ~= nil and tonumber(bagIndex) and tonumber(slot) then
      local iBagIndex = math.floor(bagIndex)
      local iSlot = math.floor(slot)
      local itemID = C_Container.GetContainerItemID(iBagIndex, iSlot);
      GameTooltip:SetItemByID(itemID)
    end
    GameTooltip:Show()
  end)
  itemButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
  end)
  DisenchanterPlusBaseFrame.item = itemButton

  local itemText = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  itemText:SetTextColor(1, 1, 1)
  itemText:SetPoint("LEFT", itemButton, 56, 0)
  itemText:SetText("")
  itemButton.text = itemText

  -- settings button ******************************************************************************************
  local settingsButton = CreateFrame("Button", "AutoDisenchant_SettingsButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  settingsButton:SetSize(130, 22)
  settingsButton:SetPoint("TOPRIGHT", DisenchanterPlusBaseFrame, -20, -20)
  settingsButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Opens settings window."), nil, nil, nil, nil, true)
    settingsButton.text:SetTextColor(1, 1, 1)
    settingsButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\settings:14:14|t " .. DisenchanterPlus:DP_i18n("Settings"))
  end)
  settingsButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    settingsButton.text:SetTextColor(0.6, 0.6, 0.6)
    settingsButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\settings_a:14:14|t " .. DisenchanterPlus:DP_i18n("Settings"))
  end)
  settingsButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    DP_SlashCommands:OpenSettingsWindow()
    DP_DisenchantWindow:CloseWindow()
  end)
  DisenchanterPlusBaseFrame.settingsButton = settingsButton

  local settingsText = settingsButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local settingsString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\settings_a:14:14|t " .. DisenchanterPlus:DP_i18n("Settings")
  settingsText:SetPoint("CENTER", settingsButton, "CENTER")
  settingsText:SetJustifyH("CENTER")
  settingsText:SetText(settingsString)
  settingsText:SetTextColor(0.6, 0.6, 0.6)
  settingsButton.text = settingsText

  settingsButton:Hide()

  -- no button ******************************************************************************************
  local noButton = CreateFrame("Button", "AutoDisenchant_NoButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  noButton:SetSize(90, 22)
  noButton:SetPoint("BOTTOMRIGHT", DisenchanterPlusBaseFrame, -120, 20)
  noButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Do not disenchant this item during this game session."), nil, nil, nil, nil, true)
    noButton.text:SetTextColor(1, 1, 1)
    noButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close:14:14|t " .. DisenchanterPlus:DP_i18n("No"))
  end)
  noButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    noButton.text:SetTextColor(0.6, 0.6, 0.6)
    noButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_a:14:14|t " .. DisenchanterPlus:DP_i18n("No"))
  end)
  noButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    if itemToDisenchant ~= nil then
      DP_DisenchantProcess:AddSessionIgnoredItem(itemToDisenchant)
    end
  end)
  DisenchanterPlusBaseFrame.noButton = noButton

  local noText = noButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local noString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_a:14:14|t " .. DisenchanterPlus:DP_i18n("No")
  noText:SetPoint("CENTER", noButton, "CENTER")
  noText:SetText(noString)
  noText:SetTextColor(0.6, 0.6, 0.6)
  noButton.text = noText

  noButton:Hide()

  -- clear session button ******************************************************************************************
  local clearSessionButton = CreateFrame("Button", "AutoDisenchant_ClearSessionButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "BackdropTemplate")
  clearSessionButton:SetSize(22, 22)
  clearSessionButton:SetPoint("BOTTOMRIGHT", DisenchanterPlusBaseFrame, -210, 20)
  clearSessionButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Clear the ignore list of this session."), nil, nil, nil, nil, true)
    clearSessionButton.text:SetTextColor(1, 1, 1)
    clearSessionButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\clean_list1:16:16|t")
  end)
  clearSessionButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    clearSessionButton.text:SetTextColor(0.6, 0.6, 0.6)
    clearSessionButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\clean_list1_a:16:16|t")
  end)
  clearSessionButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    if itemToDisenchant ~= nil then
      DP_DisenchantProcess:EmptySessionIgnoredItemsList()
      DisenchanterPlusBaseFrame.clearSessionButton:Hide()
      DisenchanterPlus:Info(DisenchanterPlus:DP_i18n("Session ignore list cleared"))
    end
  end)
  clearSessionButton:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    edgeSize = 2,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  clearSessionButton:SetBackdropColor(0, 0, 0, 0)
  DisenchanterPlusBaseFrame.clearSessionButton = clearSessionButton

  local clearSessionText = clearSessionButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local clearSessionString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\clean_list1_a:16:16|t"
  clearSessionText:SetPoint("CENTER", clearSessionButton, "CENTER")
  clearSessionText:SetText(clearSessionString)
  clearSessionText:SetTextColor(0.6, 0.6, 0.6)
  clearSessionButton.text = clearSessionText

  clearSessionButton:Hide()

  -- yes button ******************************************************************************************
  local yesButton = CreateFrame("Button", "AutoDisenchant_YesButton", DisenchanterPlusBaseFrame, "SecureActionButtonTemplate")
  yesButton:SetSize(90, 22)
  yesButton:SetPoint("BOTTOMRIGHT", DisenchanterPlusBaseFrame, -20, 20)

  local yesDummyButton = CreateFrame("Button", "AutoDisenchant_YesDummyButton", DisenchanterPlusBaseFrame, "UIPanelButtonTemplate")
  yesDummyButton:SetSize(90, 22)
  yesDummyButton:SetPoint("BOTTOMRIGHT", DisenchanterPlusBaseFrame, -20, 20)
  yesDummyButton:Hide()

  local texture = yesButton:CreateTexture(nil, nil, "UIPanelButtonUpTexture")
  yesButton:SetNormalTexture(texture)
  yesButton:SetHighlightTexture(yesDummyButton:GetHighlightTexture())

  yesButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
  yesButton:SetAttribute("unit", "none")
  yesButton:SetAttribute("type", "spell")
  yesButton:SetAttribute("target-item", nil)
  yesButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Proceed with disenchantment."), nil, nil, nil, nil, true)
    yesButton.text:SetTextColor(1, 1, 1)
    yesButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:14:14|t " .. DisenchanterPlus:DP_i18n("Yes"))
  end)
  yesButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    yesButton.text:SetTextColor(0.6, 0.6, 0.6)
    yesButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:14:14|t " .. DisenchanterPlus:DP_i18n("Yes"))
  end)
  DisenchanterPlusBaseFrame.yesButton = yesButton

  local yesText = yesButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local yesString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:14:14|t " .. DisenchanterPlus:DP_i18n("Yes")
  yesText:SetPoint("CENTER", yesButton, "CENTER")
  yesText:SetText(yesString)
  yesText:SetTextColor(0.6, 0.6, 0.6)
  yesButton.text = yesText
  yesButton:Hide()

  -- ignore button ******************************************************************************************
  local ignoreButton = CreateFrame("Button", "AutoDisenchant_IgnoreButton", DisenchanterPlusBaseFrame, "UIPanelButtonTemplate")
  ignoreButton:SetSize(90, 22)
  ignoreButton:SetPoint("BOTTOMLEFT", DisenchanterPlusBaseFrame, 20, 20)
  ignoreButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Add this item to the permanent ignore list."), nil, nil, nil, nil, true)
    ignoreButton.text:SetTextColor(1, 1, 1)
    ignoreButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\cancel1:14:14|t " .. DisenchanterPlus:DP_i18n("Ignore"))
  end)
  ignoreButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    ignoreButton.text:SetTextColor(0.6, 0.6, 0.6)
    ignoreButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\cancel1_a:14:14|t " .. DisenchanterPlus:DP_i18n("Ignore"))
  end)
  ignoreButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    if itemToDisenchant ~= nil then
      DP_DisenchantProcess:AddPermanentIgnoredItem(itemToDisenchant)
    end
  end)
  DisenchanterPlusBaseFrame.ignoreButton = ignoreButton

  local ignoreText = ignoreButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local ignoreString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\cancel1_a:14:14|t " .. DisenchanterPlus:DP_i18n("Ignore")
  ignoreText:SetPoint("CENTER", ignoreButton, "CENTER")
  ignoreText:SetText(ignoreString)
  ignoreText:SetTextColor(0.6, 0.6, 0.6)
  ignoreButton.text = ignoreText
  ignoreButton:Hide()

  -- clear permanent button ******************************************************************************************
  local clearPermanentButton = CreateFrame("Button", "AutoDisenchant_ClearPermanentButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "BackdropTemplate")
  clearPermanentButton:SetSize(22, 22)
  clearPermanentButton:SetPoint("BOTTOMLEFT", DisenchanterPlusBaseFrame, 110, 20)
  clearPermanentButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Clear the permanent ignore list."), nil, nil, nil, nil, true)
    clearPermanentButton.text:SetTextColor(1, 1, 1)
    clearPermanentButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\clean_list2:16:16|t")
  end)
  clearPermanentButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    clearPermanentButton.text:SetTextColor(0.6, 0.6, 0.6)
    clearPermanentButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\clean_list2_a:16:16|t")
  end)
  clearPermanentButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    if itemToDisenchant ~= nil then
      DP_DisenchantProcess:EmptyPermanentIgnoredItemsList()
      DisenchanterPlusBaseFrame.clearPermanentButton:Hide()
      DisenchanterPlus:Info(DisenchanterPlus:DP_i18n("Permanent ignore list cleared"))
    end
  end)
  clearPermanentButton:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    edgeSize = 2,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  clearPermanentButton:SetBackdropColor(0, 0, 0, 0)
  DisenchanterPlusBaseFrame.clearPermanentButton = clearPermanentButton

  local clearPermanentText = clearPermanentButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local clearPermanentString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\clean_list2_a:16:16|t"
  clearPermanentText:SetPoint("CENTER", clearPermanentButton, "CENTER")
  clearPermanentText:SetText(clearPermanentString)
  clearPermanentText:SetTextColor(0.6, 0.6, 0.6)
  clearPermanentButton.text = clearPermanentText

  clearPermanentButton:Hide()
  --[[
  -- progress bar ******************************************************************************************
  local progressBar = CreateFrame("Button", "AutoDisenchant_ProgressBar", DisenchanterPlusBaseFrame)
  progressBar:SetPoint("BOTTOMLEFT", DisenchanterPlusBaseFrame, 75, 50)
  progressBar:SetSize(353044, 16)
  progressBar:SetMovable(false)
  progressBar:SetFrameStrata("MEDIUM")
  progressBar:SetFrameLevel(1)

  local percentProgressBarText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  percentProgressBarText:SetTextColor(1, 1, 1)
  percentProgressBarText:SetPoint("LEFT", progressBar, (fullBarWidth / 2) - 15, 0)
  percentProgressBarText:SetText(tostring(0) .. " %")
  percentProgressBarText:SetDrawLayer("OVERLAY", 6)
  percentProgressBarText:SetShadowColor(0, 0, 0, 1)
  percentProgressBarText:SetJustifyH("CENTER")
  percentProgressBarText:SetWidth(48)
  progressBar.percentProgressBarText = percentProgressBarText

  local progressBarTextureEmpty = progressBar:CreateTexture(nil, "OVERLAY")
  progressBarTextureEmpty:SetTexture("Interface\\Addons\\DisenchanterPlus\\Images\\Textures\\progressbar")
  progressBarTextureEmpty:SetDrawLayer("OVERLAY", 4)
  progressBarTextureEmpty:SetHeight(14)
  progressBarTextureEmpty:SetWidth(fullBarWidth)
  progressBarTextureEmpty:SetPoint("LEFT", progressBar, 0, 0)
  progressBarTextureEmpty:SetColorTexture(0.1, 0.3, 0.1, 0.6)
  progressBar.textureEmpty = progressBarTextureEmpty

  local progressBarTextureFill = progressBar:CreateTexture(nil, "OVERLAY")
  progressBarTextureFill:SetTexture("Interface\\Addons\\DisenchanterPlus\\Images\\Textures\\progressbar")
  progressBarTextureFill:SetDrawLayer("OVERLAY", 5)
  progressBarTextureFill:SetPoint("LEFT", progressBar, 0, 0)
  progressBarTextureFill:SetHeight(14)
  progressBarTextureFill:SetWidth(currentBarWidth)
  progressBarTextureFill:SetColorTexture(0.3, 0.9, 0.2, 0.7)
  progressBar.textureFill = progressBarTextureFill

  local minProgressBarText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  minProgressBarText:SetTextColor(1, 0.8, 0.3)
  minProgressBarText:SetPoint("LEFT", progressBar, -35, 0)
  minProgressBarText:SetText(tostring(0))
  minProgressBarText:SetJustifyH("RIGHT")
  progressBar.minProgressBarText = minProgressBarText

  local maxProgressBarText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  maxProgressBarText:SetTextColor(1, 0.8, 0.3)
  maxProgressBarText:SetPoint("LEFT", progressBar, fullBarWidth + 15, 0)
  maxProgressBarText:SetText(tostring(0))
  minProgressBarText:SetJustifyH("LEFT")
  progressBar.maxProgressBarText = maxProgressBarText
  DisenchanterPlusBaseFrame.progressBar = progressBar
  ]]

  DisenchanterPlusBaseFrame:Hide()
  return DisenchanterPlusBaseFrame
end

function DP_DisenchantWindow:UpdateItemsLeft(itemsLeft)
  --DisenchanterPlus:Debug("Items left : " .. tostring(itemsLeft))
  DisenchanterPlusBaseFrame.itemLeftText:SetText(string.format("%s : |cffffcc00%d|r", DisenchanterPlus:DP_i18n("Items left"), itemsLeft))
end

---Open auto disenchant window
---@param bagItems table
---@param tradeskill table
function DP_DisenchantWindow:OpenWindow(bagItems, tradeskill)
  if not DisenchanterPlusBaseFrame then
    DisenchanterPlusBaseFrame = DP_DisenchantWindow:CreateAutoDisenchantWindow()
  end

  if bagItems ~= nil then
    DP_DisenchantWindow:PopulateItem(bagItems, tradeskill)
  end

  if not windowOpened then
    C_Timer.After(0.2, function()
      DisenchanterPlusBaseFrame:SetBackdropColor(0, 0, 0, textFrameBgColorAlpha)
      DisenchanterPlusBaseFrame:Show()
      DisenchanterPlusBaseFrame.settingsButton:Show()
      DisenchanterPlusBaseFrame.yesButton:Show()
      DisenchanterPlusBaseFrame.noButton:Show()

      if DP_DisenchantProcess:SessionIgnoredItemsHasElements() then
        DisenchanterPlusBaseFrame.clearSessionButton:Show()
      else
        DisenchanterPlusBaseFrame.clearSessionButton:Hide()
      end

      if DP_DisenchantProcess:PermanentIgnoredItemsHasElements() then
        DisenchanterPlusBaseFrame.clearPermanentButton:Show()
      else
        DisenchanterPlusBaseFrame.clearPermanentButton:Hide()
      end

      DisenchanterPlusBaseFrame.ignoreButton:Show()
      windowOpened = true
    end)
  end
end

---Close window
function DP_DisenchantWindow:CloseWindow()
  if DisenchanterPlusBaseFrame == nil then return end
  DisenchanterPlusBaseFrame:Hide()
  windowOpened = false
  itemToDisenchant = nil
  DisenchanterPlusBaseFrame.yesButton:SetAttribute("target-bag", nil)
  DisenchanterPlusBaseFrame.yesButton:SetAttribute("target-slot", nil)
  DisenchanterPlusBaseFrame.yesButton:SetAttribute("spell", nil)
end

---Drag start
function DP_DisenchantWindow.OnDragStart()
  DisenchanterPlusBaseFrame:StartMoving()
end

---Drag stop
function DP_DisenchantWindow.OnDragStop()
  local frameX = DisenchanterPlusBaseFrame:GetCenter()
  local xLeft, yTop, xRight, yBottom = DisenchanterPlusBaseFrame:GetLeft(), DisenchanterPlusBaseFrame:GetTop(), DisenchanterPlusBaseFrame:GetRight(), DisenchanterPlusBaseFrame:GetBottom()
  local xSize, ySize = DisenchanterPlusBaseFrame:GetSize()
  local screenWidth = GetScreenWidth()
  local xcreenHeight = GetScreenHeight()
  local xPositionFromCenter = -((screenWidth / 2) - xLeft) + (xSize / 2)
  local yPositionFromCenter = -((xcreenHeight / 2) - yTop) - (ySize / 2)
  DisenchanterPlus.db.char.general.disenchantFrameOffset.xOffset = tonumber(string.format("%.1f", xPositionFromCenter))
  DisenchanterPlus.db.char.general.disenchantFrameOffset.yOffset = tonumber(string.format("%.1f", yPositionFromCenter))
  DisenchanterPlusBaseFrame:StopMovingOrSizing()
end

---Populate items to disenchant
---@param itemInfo table
---@param tradeskill table
function DP_DisenchantWindow:PopulateItem(itemInfo, tradeskill)
  if itemInfo ~= nil then
    local canDisenchant = DP_Database:CheckSkillLevelForItem(tradeskill.Level, itemInfo.ItemLevel, itemInfo.ItemMinLevel)
    DisenchanterPlusBaseFrame.item:SetNormalTexture(itemInfo.ItemIcon or "Interface\\Buttons\\UI-Slot-Background")
    DisenchanterPlusBaseFrame.item.text:SetText(itemInfo.ItemLink)
    DisenchanterPlusBaseFrame.yesButton:SetAttribute("target-bag", itemInfo.BagIndex)
    DisenchanterPlusBaseFrame.yesButton:SetAttribute("target-slot", itemInfo.Slot)
    DisenchanterPlusBaseFrame.yesButton:SetAttribute("spell", itemInfo.SpellID)
    itemToDisenchant = itemInfo.ItemID
    if not canDisenchant then
      local disabledTexture = DisenchanterPlusBaseFrame.yesButton:CreateTexture(nil, nil, "UIPanelButtonDisabledTexture")
      DisenchanterPlusBaseFrame.yesButton:SetNormalTexture(disabledTexture)
      DisenchanterPlusBaseFrame.yesButton:SetEnabled(false)
      local footText = "|cffff3300" .. DisenchanterPlus:DP_i18n("You don't have enough skill level.") .. "|r"
      DisenchanterPlusBaseFrame.footText:SetText(footText)
    else
      local enabledTexture = DisenchanterPlusBaseFrame.yesButton:CreateTexture(nil, nil, "UIPanelButtonUpTexture")
      DisenchanterPlusBaseFrame.yesButton:SetNormalTexture(enabledTexture)
      DisenchanterPlusBaseFrame.yesButton:SetEnabled(true)
      local footText = "|cffccff33" .. DisenchanterPlus:DP_i18n("You have enough skill level.") .. "|r"
      DisenchanterPlusBaseFrame.footText:SetText(footText)
    end
  end
end

---Item to disenchant
---@return boolean
function DP_DisenchantWindow:ItemToDisenchant()
  return itemToDisenchant
end

---Get item to disenchant
---@return string|nil
---@return string|nil
---@return integer|nil
function DP_DisenchantWindow:GetItemToDisenchant()
  local itemName, itemLink, itemIcon
  local bagIndex = tonumber(DisenchanterPlusBaseFrame.yesButton:GetAttribute("target-bag")) or nil
  local slot = tonumber(DisenchanterPlusBaseFrame.yesButton:GetAttribute("target-slot")) or nil
  if bagIndex ~= nil and slot ~= nil and tonumber(bagIndex) and tonumber(slot) then
    local iBagIndex = math.floor(bagIndex)
    local iSlot = math.floor(slot)
    local itemID = C_Container.GetContainerItemID(iBagIndex, iSlot);
    itemName, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
  end
  return itemName, itemLink, itemIcon
end
