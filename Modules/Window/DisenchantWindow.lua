---@class DP_DisenchantWindow
local DP_DisenchantWindow = DP_ModuleLoader:CreateModule("DP_DisenchantWindow")

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

---@type DP_MinimapIcon
local DP_MinimapIcon = DP_ModuleLoader:ImportModule("DP_MinimapIcon")

---@type DP_CustomMedias
local DP_CustomMedias = DP_ModuleLoader:ImportModule("DP_CustomMedias")

---@type DP_IgnoredWindow
local DP_IgnoredWindow = DP_ModuleLoader:ImportModule("DP_IgnoredWindow")

local LibStub = LibStub
--local AceGUI = LibStub("AceGUI-3.0")

local DEFAULT_DIALOG_BACKDROP = {
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
local CUSTOM_DIALOG_BACKDROP = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  tile = true,
  edgeSize = 1,
  insets = { left = 4, right = 4, top = 4, bottom = 4 },
}
local emptySlot = "Interface/AddOns/DisenchanterPlus/Images/Inventory/INVTYPE_SLOT"
local unknownSlot = "Interface/AddOns/DisenchanterPlus/Images/Inventory/Unknown"

local uncommonIcon = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\uncommon:16:16|t" --2
local rareIcon = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\rare:16:16|t"         --3
local epicIcon = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\epic:16:16|t"         --4
local uncommonIconFill = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\uncommon_fill:16:16|t"
local rareIconFill = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\rare_fill:16:16|t"
local epicIconFill = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\epic_fill:16:16|t"

local DisenchanterPlusBaseFrame
local textFrameBgColorAlpha = 0.75
local windowOpened = false
local itemToDisenchant
local ignoreWindowOpened = false

---Initilize
function DP_DisenchantWindow:CreateAutoDisenchantWindow()
  local xOffset = DisenchanterPlus.db.char.general.disenchantFrameOffset.xOffset
  local yOffset = DisenchanterPlus.db.char.general.disenchantFrameOffset.yOffset

  -- base frame ******************************************************************************************
  DisenchanterPlusBaseFrame = CreateFrame("Frame", "DisenchanterPlus_AutoDisenchant", UIParent, BackdropTemplateMixin and "BackdropTemplate")
  DisenchanterPlusBaseFrame:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset)
  DisenchanterPlusBaseFrame:SetFrameStrata("HIGH")
  DisenchanterPlusBaseFrame:SetFrameLevel(0)
  DisenchanterPlusBaseFrame:SetSize(424, 190)
  DisenchanterPlusBaseFrame:SetMovable(true)
  DisenchanterPlusBaseFrame:EnableMouse(true)
  DisenchanterPlusBaseFrame:SetScript("OnMouseDown", DP_DisenchantWindow.OnDragStart)
  DisenchanterPlusBaseFrame:SetScript("OnMouseUp", DP_DisenchantWindow.OnDragStop)

  DisenchanterPlusBaseFrame:SetBackdrop(DEFAULT_DIALOG_BACKDROP)
  DisenchanterPlusBaseFrame:SetBackdropColor(0, 0, 0, 0)

  local titleBar = CreateFrame("Frame", "EnchantWindow_BaseFrameTitleBackground", DisenchanterPlusBaseFrame)
  titleBar:SetPoint("TOPLEFT", DisenchanterPlusBaseFrame, "TOPLEFT", 0, 0)
  titleBar:SetSize(424, 36)
  titleBar:SetMovable(false)
  titleBar:SetFrameStrata("BACKGROUND")
  titleBar:SetFrameLevel(1)
  DisenchanterPlusBaseFrame.titleBar = titleBar

  local titleBackground = titleBar:CreateTexture(nil, "OVERLAY")
  titleBackground:SetTexture("Interface\\Addons\\DisenchanterPlus\\Images\\Textures\\progressbar")
  titleBackground:SetDrawLayer("OVERLAY", 4)
  titleBackground:SetHeight(34)
  titleBackground:SetWidth(416)
  titleBackground:SetPoint("LEFT", titleBar, 4, -2)
  titleBackground:SetGradient("HORIZONTAL", CreateColor(0.8, 0.30, 0.9, 0.8), CreateColor(0.8, 0.5, 0.9, 0.8))
  titleBar.titleBackground = titleBackground

  local windowBackground = titleBar:CreateTexture(nil, "OVERLAY")
  windowBackground:SetTexture("Interface\\Addons\\DisenchanterPlus\\Images\\Textures\\progressbar")
  windowBackground:SetDrawLayer("OVERLAY", 4)
  windowBackground:SetHeight(150)
  windowBackground:SetWidth(416)
  windowBackground:SetPoint("TOPLEFT", titleBar, 4, -36)
  windowBackground:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0.4), CreateColor(0.6, 0.6, 0.6, 0.4))
  titleBar.windowBackground = windowBackground

  -- texts
  local titleText = DisenchanterPlusBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  titleText:SetTextColor(0.8, 0.8, 0.8)
  titleText:SetPoint("LEFT", titleBar, 20, -2)
  titleText:SetText(DisenchanterPlus:DP_i18n("Auto disenchant"))
  DisenchanterPlusBaseFrame.titleText = titleText

  local itemLeftText = DisenchanterPlusBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  itemLeftText:SetTextColor(0.6, 0.6, 0.6)
  itemLeftText:SetPoint("BOTTOMLEFT", DisenchanterPlusBaseFrame, 20, 50)
  itemLeftText:SetText(string.format("%s : |cffffcc00%d|r", DisenchanterPlus:DP_i18n("Items left"), 0))
  DisenchanterPlusBaseFrame.itemLeftText = itemLeftText

  local footText = DisenchanterPlusBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  footText:SetTextColor(1, 1, 1)
  footText:SetPoint("TOPLEFT", DisenchanterPlusBaseFrame, 20, -103)
  footText:SetText("")
  DisenchanterPlusBaseFrame.footText = footText

  -- qualities
  DP_DisenchantWindow:DrawQualityButton("DienchantWindow_UncommonButton", "uncommon", DisenchanterPlus:DP_i18n("Uncommon"), "2", -115, -10)
  DP_DisenchantWindow:DrawQualityButton("DienchantWindow_RareButton", "rare", DisenchanterPlus:DP_i18n("Rare"), "3", -140, -10)
  DP_DisenchantWindow:DrawQualityButton("DienchantWindow_EpicButton", "epic", DisenchanterPlus:DP_i18n("Epic"), "4", -165, -10)

  -- item ******************************************************************************************
  local itemButton = CreateFrame("Button", "AutoDisenchant_ItemFrame", DisenchanterPlusBaseFrame)
  itemButton:SetPoint("TOPLEFT", DisenchanterPlusBaseFrame, "TOPLEFT", 20, -50)
  itemButton:SetNormalTexture(unknownSlot)
  itemButton:SetText(string.format("|T%s:%s:%s|t", unknownSlot, "48", "48"))
  itemButton:SetHeight(48)
  itemButton:SetWidth(48)
  itemButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    local bagIndex = tonumber(DisenchanterPlusBaseFrame.yesButton:GetAttribute("target-bag"))
    local slot = tonumber(DisenchanterPlusBaseFrame.yesButton:GetAttribute("target-slot"))
    if (bagIndex and slot) then
      local containerInfo = C_Container.GetContainerItemInfo(bagIndex, slot)
      if containerInfo and containerInfo.hyperlink then
        GameTooltip:SetHyperlink(containerInfo.hyperlink)
      end
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
  itemText:SetJustifyH("LEFT")
  itemText:SetJustifyV("MIDDLE")
  itemText:SetSize(330, 48)
  itemText:SetText("")
  itemButton.text = itemText

  -- settings button ******************************************************************************************
  local settingsButton = CreateFrame("Button", "AutoDisenchant_SettingsButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  settingsButton:SetSize(32, 22)
  settingsButton:SetPoint("TOPRIGHT", DisenchanterPlusBaseFrame, -45, -10)
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
    DP_DisenchantWindow:CloseWindow()
  end)
  DisenchanterPlusBaseFrame.settingsButton = settingsButton

  local settingsText = settingsButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local settingsString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\settings_a:14:14|t " -- .. DisenchanterPlus:DP_i18n("Settings")
  settingsText:SetPoint("CENTER", settingsButton, 2, 0)
  settingsText:SetJustifyH("CENTER")
  settingsText:SetText(settingsString)
  settingsText:SetTextColor(0.6, 0.6, 0.6)
  settingsButton.text = settingsText

  settingsButton:Hide()

  -- close button ******************************************************************************************
  local closeButton = CreateFrame("Button", "AutoDisenchant_CloseButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  closeButton:SetSize(32, 22)
  closeButton:SetPoint("TOPRIGHT", DisenchanterPlusBaseFrame, -10, -10)
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
    --DP_DisenchantWindow:CloseWindow()
    DP_DisenchantProcess:CloseDisenchantProcess()
    --DP_MinimapIcon:UpdateIcon(DP_CustomMedias:GetMediaFile("disenchanterplus_paused"))
  end)

  local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local closeString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_a:14:14|t " -- .. DisenchanterPlus:DP_i18n("Settings")
  closeText:SetPoint("CENTER", closeButton, 2, 0)
  closeText:SetJustifyH("CENTER")
  closeText:SetText(closeString)
  closeText:SetTextColor(0.6, 0.6, 0.6)
  closeButton.text = closeText

  DisenchanterPlusBaseFrame.closeButton = closeButton
  closeButton:Show()

  -- pause button ******************************************************************************************
  local pauseButton = CreateFrame("Button", "AutoDisenchant_PauseButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  pauseButton:SetSize(32, 22)
  pauseButton:SetPoint("TOPRIGHT", DisenchanterPlusBaseFrame, -80, -10)
  pauseButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Pause the disenchantment process."), nil, nil, nil, nil, true)
    pauseButton.text:SetTextColor(1, 1, 1)
    pauseButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\pause:14:14|t ") --.. DisenchanterPlus:DP_i18n("Settings"))
  end)
  pauseButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    pauseButton.text:SetTextColor(0.6, 0.6, 0.6)
    pauseButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\pause_a:14:14|t ") -- .. DisenchanterPlus:DP_i18n("Settings"))
  end)
  pauseButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("ChatScrollButton")
    if InCombatLockdown() or UnitAffectingCombat("player") then return end
    DP_DisenchantWindow:CloseWindow()
    DisenchanterPlusBaseFrame.pauseButton:Hide()
    DisenchanterPlusBaseFrame.playButton:Show()
    DP_DisenchantProcess:PauseDisenchantProcess()
    DP_MinimapIcon:UpdateIcon(DP_CustomMedias:GetMediaFile("disenchanterplus_paused"))
  end)
  DisenchanterPlusBaseFrame.pauseButton = pauseButton

  local pauseText = pauseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local pauseString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\pause_a:14:14|t " -- .. DisenchanterPlus:DP_i18n("Settings")
  pauseText:SetPoint("CENTER", pauseButton, 2, 0)
  pauseText:SetJustifyH("CENTER")
  pauseText:SetText(pauseString)
  pauseText:SetTextColor(0.6, 0.6, 0.6)
  pauseButton.text = pauseText

  pauseButton:Hide()

  -- play button ******************************************************************************************
  local playButton = CreateFrame("Button", "AutoDisenchant_PlayButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  playButton:SetSize(32, 22)
  playButton:SetPoint("TOPRIGHT", DisenchanterPlusBaseFrame, -80, -10)
  playButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Starts the disenchantment process."), nil, nil, nil, nil, true)
    playButton.text:SetTextColor(1, 1, 1)
    playButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\play:14:14|t ") --.. DisenchanterPlus:DP_i18n("Settings"))
  end)
  playButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    playButton.text:SetTextColor(0.6, 0.6, 0.6)
    playButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\play_a:14:14|t ") -- .. DisenchanterPlus:DP_i18n("Settings"))
  end)
  playButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("ChatScrollButton")
    if InCombatLockdown() or UnitAffectingCombat("player") then return end
    DP_DisenchantWindow:CloseWindow()
    DisenchanterPlusBaseFrame.pauseButton:Show()
    DisenchanterPlusBaseFrame.playButton:Hide()
    DisenchanterPlus.db.char.general.autoDisenchantEnabled = true
    DP_DisenchantProcess:StartsDisenchantProcess()
    DP_MinimapIcon:UpdateIcon(DP_CustomMedias:GetMediaFile("disenchanterplus_running"))
  end)
  DisenchanterPlusBaseFrame.playButton = playButton

  local playText = playButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local playString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\play_a:14:14|t " -- .. DisenchanterPlus:DP_i18n("Settings")
  playText:SetPoint("CENTER", playButton, 2, 0)
  playText:SetJustifyH("CENTER")
  playText:SetText(playString)
  playText:SetTextColor(0.6, 0.6, 0.6)
  playButton.text = playText

  playButton:Hide()

  -- no button ******************************************************************************************
  local noButton = CreateFrame("Button", "AutoDisenchant_NoButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  noButton:SetEnabled(false)
  noButton:SetSize(95, 22)
  noButton:SetPoint("BOTTOMRIGHT", DisenchanterPlusBaseFrame, -130, 20)
  noButton:SetScript("OnEnter", function(current)
    local keybind = ""
    if DisenchanterPlus.db.char.general.cancelDisenchant ~= nil then
      keybind = " |cffeeeeff" .. DisenchanterPlus.db.char.general.cancelDisenchant .. "|r"
    end
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Do not disenchant this item during this game session.") .. keybind, nil, nil, nil, nil, true)
    noButton.text:SetTextColor(1, 1, 1)
    noButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close:14:14|t " .. DisenchanterPlus:DP_i18n("Cancel"))
  end)
  noButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    noButton.text:SetTextColor(0.6, 0.6, 0.6)
    noButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_a:14:14|t " .. DisenchanterPlus:DP_i18n("Cancel"))
  end)
  noButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    if itemToDisenchant ~= nil then
      DP_DisenchantProcess:AddSessionIgnoredItem(itemToDisenchant)
    end
  end)
  DisenchanterPlusBaseFrame.noButton = noButton

  local noText = noButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local noString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_a:14:14|t " .. DisenchanterPlus:DP_i18n("Cancel")
  noText:SetPoint("CENTER", noButton, "CENTER")
  noText:SetText(noString)
  noText:SetTextColor(0.6, 0.6, 0.6)
  noButton.text = noText

  noButton:Hide()

  -- yes button ******************************************************************************************
  local yesButton = CreateFrame("Button", "AutoDisenchant_YesButton", DisenchanterPlusBaseFrame, "SecureActionButtonTemplate")
  yesButton:SetEnabled(false)
  yesButton:SetSize(100, 22)
  yesButton:SetPoint("BOTTOMRIGHT", DisenchanterPlusBaseFrame, -20, 20)

  local yesDummyButton = CreateFrame("Button", "AutoDisenchant_YesDummyButton", DisenchanterPlusBaseFrame, "UIPanelButtonTemplate")
  yesDummyButton:SetSize(90, 22)
  yesDummyButton:SetPoint("BOTTOMRIGHT", DisenchanterPlusBaseFrame, -20, 20)
  yesDummyButton:Hide()

  local texture = yesButton:CreateTexture(nil, nil, "UIPanelButtonUpTexture")
  yesButton:SetNormalTexture(texture)
  yesButton:SetHighlightTexture(yesDummyButton:GetHighlightTexture())

  local disabledTexture = yesDummyButton:CreateTexture(nil, nil, "UIPanelButtonDisabledTexture")
  yesButton:SetDisabledTexture(disabledTexture)

  yesButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
  yesButton:SetAttribute("unit", "none")
  yesButton:SetAttribute("type", "spell")
  yesButton:SetAttribute("target-item", nil)

  DP_DisenchantWindow:UpdateKeybindings()

  yesButton:SetScript("OnEnter", function(current)
    local keybind = ""
    if DisenchanterPlus.db.char.general.acceptDisenchant ~= nil then
      keybind = " |cffeeeeff" .. DisenchanterPlus.db.char.general.acceptDisenchant .. "|r"
    end
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Proceed with the enchantment.") .. keybind, nil, nil, nil, nil, true)
    yesButton.text:SetTextColor(1, 1, 1)
    yesButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:14:14|t " .. DisenchanterPlus:DP_i18n("Proceed"))
  end)
  yesButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    yesButton.text:SetTextColor(0.6, 0.6, 0.6)
    yesButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:14:14|t " .. DisenchanterPlus:DP_i18n("Proceed"))
  end)
  DisenchanterPlusBaseFrame.yesButton = yesButton

  local yesText = yesButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local yesString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:14:14|t " .. DisenchanterPlus:DP_i18n("Proceed")
  yesText:SetPoint("CENTER", yesButton, "CENTER")
  yesText:SetText(yesString)
  yesText:SetTextColor(0.6, 0.6, 0.6)
  yesButton.text = yesText
  yesButton:Hide()

  -- ignore button ******************************************************************************************
  local ignoreButton = CreateFrame("Button", "AutoDisenchant_IgnoreButton", DisenchanterPlusBaseFrame, "UIPanelButtonTemplate")
  ignoreButton:SetEnabled(false)
  ignoreButton:SetSize(90, 22)
  ignoreButton:SetPoint("BOTTOMLEFT", DisenchanterPlusBaseFrame, 20, 20)
  ignoreButton:SetScript("OnEnter", function(current)
    local keybind = ""
    if DisenchanterPlus.db.char.general.ignoreDisenchant ~= nil then
      keybind = " |cffeeeeff" .. DisenchanterPlus.db.char.general.ignoreDisenchant .. "|r"
    end
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Add this item to the permanent ignore list.") .. keybind, nil, nil, nil, nil, true)
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
  --local clearPermanentButton = CreateFrame("Button", "AutoDisenchant_ClearIgnoredButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "BackdropTemplate")
  local clearPermanentButton = CreateFrame("Button", "AutoDisenchant_ClearIgnoredButton", DisenchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  clearPermanentButton:SetSize(32, 22)
  clearPermanentButton:SetPoint("BOTTOMLEFT", DisenchanterPlusBaseFrame, 120, 20)
  clearPermanentButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Open ignored items list."), nil, nil, nil, nil, true)
    clearPermanentButton.text:SetTextColor(1, 1, 1)
    clearPermanentButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\clean_list2:16:16|t")
  end)
  clearPermanentButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    clearPermanentButton.text:SetTextColor(0.6, 0.6, 0.6)
    clearPermanentButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\clean_list2_a:16:16|t")
  end)
  clearPermanentButton:SetScript("OnClick", function(current)
    DP_DisenchantWindow:OpenIgnoreWindow()
  end)
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
  local fullBarWidth = 284
  local currentBarWidth = 50

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

  --DisenchanterPlus:Debug(tostring(windowOpened))
  if not windowOpened then
    C_Timer.After(0.2, function()
      DisenchanterPlusBaseFrame:SetBackdropColor(0, 0, 0, textFrameBgColorAlpha)
      DisenchanterPlusBaseFrame:Show()
      DisenchanterPlusBaseFrame.settingsButton:Show()

      if DP_DisenchantProcess:IsProcessRunning() then
        DisenchanterPlusBaseFrame.pauseButton:Show()
        DisenchanterPlusBaseFrame.playButton:Hide()
      else
        DisenchanterPlusBaseFrame.pauseButton:Hide()
        DisenchanterPlusBaseFrame.playButton:Show()
      end

      DisenchanterPlusBaseFrame.yesButton:Show()
      DisenchanterPlusBaseFrame.noButton:Show()

      if DP_DisenchantProcess:PermanentIgnoredItemsHasElements() or DP_DisenchantProcess:SessionIgnoredItemsHasElements() then
        DisenchanterPlusBaseFrame.clearPermanentButton:Show()
      else
        DisenchanterPlusBaseFrame.clearPermanentButton:Hide()
      end

      DisenchanterPlusBaseFrame.ignoreButton:Show()
      windowOpened = true
      --DP_DisenchantWindow:RedrawQualities()
    end)
  end

  if ignoreWindowOpened then
    DP_DisenchantWindow:OpenIgnoreWindow()
  end
end

function DP_DisenchantWindow:IsWindowOpened()
  return windowOpened
end

---Close window
function DP_DisenchantWindow:CloseWindow()
  if InCombatLockdown() or UnitAffectingCombat("player") then return end
  if DisenchanterPlusBaseFrame == nil then return end

  if DP_IgnoredWindow:IsWindowOpened() then
    ignoreWindowOpened = true
    DP_IgnoredWindow:CloseWindow()
  else
    ignoreWindowOpened = false
  end

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
  DP_IgnoredWindow.OnDragStart()
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
  C_Timer.After(0.1, function()
    DP_IgnoredWindow.OnDragStop()
  end)
end

---Populate items to disenchant
---@param itemInfo table
---@param tradeskill table
function DP_DisenchantWindow:PopulateItem(itemInfo, tradeskill)
  --DisenchanterPlus:Dump(itemInfo)
  if itemInfo ~= nil and not DP_CustomFunctions:TableIsEmpty(itemInfo) and not DP_CustomFunctions:TableIsEmpty(tradeskill) then
    local canDisenchant = DP_Database:CheckSkillLevelForItem(tradeskill.Level, itemInfo.ItemLevel, itemInfo.ItemMinLevel, itemInfo.ItemQuality)
    DisenchanterPlusBaseFrame.item:SetNormalTexture(itemInfo.ItemIcon or unknownSlot)
    DisenchanterPlusBaseFrame.item.text:SetText(itemInfo.ItemLink)
    DisenchanterPlusBaseFrame.yesButton:SetAttribute("target-bag", itemInfo.BagIndex)
    DisenchanterPlusBaseFrame.yesButton:SetAttribute("target-slot", itemInfo.Slot)
    DisenchanterPlusBaseFrame.yesButton:SetAttribute("spell", itemInfo.SpellID)
    itemToDisenchant = itemInfo.ItemID

    if not canDisenchant then
      local disabledTexture = DisenchanterPlusBaseFrame.yesButton:CreateTexture(nil, nil, "UIPanelButtonDisabledTexture")
      DisenchanterPlusBaseFrame.yesButton:SetDisabledTexture(disabledTexture)
      DisenchanterPlusBaseFrame.yesButton:SetEnabled(false)
      local footText = "|cffff033d" .. DisenchanterPlus:DP_i18n("You don't have enough skill level.") .. "|r"
      DisenchanterPlusBaseFrame.footText:SetText(footText)
    else
      local enabledTexture = DisenchanterPlusBaseFrame.yesButton:CreateTexture(nil, nil, "UIPanelButtonUpTexture")
      DisenchanterPlusBaseFrame.yesButton:SetNormalTexture(enabledTexture)
      DisenchanterPlusBaseFrame.yesButton:SetEnabled(true)
      local footText = "|cff1cff00" .. DisenchanterPlus:DP_i18n("You have enough skill level.") .. "|r"
      DisenchanterPlusBaseFrame.footText:SetText(footText)
    end
    DisenchanterPlusBaseFrame.noButton:SetEnabled(true)
    DisenchanterPlusBaseFrame.ignoreButton:SetEnabled(true)
  else
    DisenchanterPlusBaseFrame.item:SetNormalTexture(unknownSlot)
    DisenchanterPlusBaseFrame.item.text:SetText("")

    local footText = "|cffffc700" .. DisenchanterPlus:DP_i18n("No item found to disenchant.") .. "|r"
    local autoDisenchantEnabled = DP_DisenchantProcess:IsProcessRunning()
    if not autoDisenchantEnabled then
      footText = "|cffffc700" .. DisenchanterPlus:DP_i18n("Auto disenchant process paused.") .. "|r"
    end
    if DP_CustomFunctions:TableIsEmpty(tradeskill) then
      footText = "|cffff033d" .. DisenchanterPlus:DP_i18n("You don't have the enchanting skill.") .. "|r"
    end

    DisenchanterPlusBaseFrame.footText:SetText(footText)
    DisenchanterPlusBaseFrame.yesButton:SetAttribute("target-bag", nil)
    DisenchanterPlusBaseFrame.yesButton:SetAttribute("target-slot", nil)
    DisenchanterPlusBaseFrame.yesButton:SetAttribute("spell", nil)
    itemToDisenchant = nil

    local disabledTexture = DisenchanterPlusBaseFrame.yesButton:CreateTexture(nil, nil, "UIPanelButtonDisabledTexture")
    DisenchanterPlusBaseFrame.yesButton:SetDisabledTexture(disabledTexture)
    DisenchanterPlusBaseFrame.yesButton:SetEnabled(false)
    DisenchanterPlusBaseFrame.noButton:SetEnabled(false)
    DisenchanterPlusBaseFrame.ignoreButton:SetEnabled(false)
  end
end

function DP_DisenchantWindow:DisableButtons()
  if not DisenchanterPlusBaseFrame then return end
  DisenchanterPlusBaseFrame.yesButton:SetEnabled(false)
  DisenchanterPlusBaseFrame.noButton:SetEnabled(false)
  DisenchanterPlusBaseFrame.ignoreButton:SetEnabled(false)
end

function DP_DisenchantWindow:EnableButtons()
  if not DisenchanterPlusBaseFrame then return end
  DisenchanterPlusBaseFrame.yesButton:SetEnabled(true)
  DisenchanterPlusBaseFrame.noButton:SetEnabled(true)
  DisenchanterPlusBaseFrame.ignoreButton:SetEnabled(true)
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
---@return integer|nil
function DP_DisenchantWindow:GetItemToDisenchant()
  local itemName, itemLink, itemIcon, itemID
  if DisenchanterPlusBaseFrame ~= nil then
    local bagIndex = tonumber(DisenchanterPlusBaseFrame.yesButton:GetAttribute("target-bag")) or nil
    local slot = tonumber(DisenchanterPlusBaseFrame.yesButton:GetAttribute("target-slot")) or nil
    if bagIndex ~= nil and slot ~= nil then
      itemID = C_Container.GetContainerItemID(bagIndex, slot);
      itemName, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
    end
  end
  return itemName, itemLink, itemIcon, itemID
end

function DP_DisenchantWindow:RunKeybindAcceptDisenchant()
end

function DP_DisenchantWindow:RunKeybindCancelDisenchant()
  DP_CustomSounds:PlayCustomSound("WindowClose")
  if itemToDisenchant ~= nil then
    DP_DisenchantProcess:AddSessionIgnoredItem(itemToDisenchant)
  end
end

function DP_DisenchantWindow:RunKeybindIgnoreDisenchant()
  DP_CustomSounds:PlayCustomSound("WindowClose")
  if itemToDisenchant ~= nil then
    DP_DisenchantProcess:AddPermanentIgnoredItem(itemToDisenchant)
  end
end

--[[
function DP_DisenchantWindow:RedrawQualities()
  if DisenchanterPlus.db.char.general.showItemQuality then
    local qualities = DisenchanterPlus.db.char.general.itemQuality
    local uncommonIconString = uncommonIcon
    if qualities["2"] == nil or qualities["2"] then uncommonIconString = uncommonIconFill end

    local rareIconString = rareIcon
    if qualities["3"] == nil or qualities["3"] then rareIconString = rareIconFill end

    local epicIconString = epicIcon
    if qualities["4"] == nil or qualities["4"] then epicIconString = epicIconFill end
    DisenchanterPlusBaseFrame.qualitiesText:SetText(uncommonIconString .. " " .. rareIconString .. " " .. epicIconString)
  else
    DisenchanterPlusBaseFrame.qualitiesText:SetText("")
  end
end

function DP_DisenchantWindow:RedrawQualitiesTooltip()
  local qualities = DisenchanterPlus.db.char.general.itemQuality
  local tooltipString = DisenchanterPlus:DP_i18n("Qualities") .. " :"
  if qualities["2"] == nil or qualities["2"] then tooltipString = tooltipString .. " |cff1eff00" .. string.lower(DisenchanterPlus:DP_i18n("Uncommon")) .. "|r" end
  if qualities["3"] == nil or qualities["3"] then tooltipString = tooltipString .. " |cff0070dd" .. string.lower(DisenchanterPlus:DP_i18n("Rare")) .. "|r" end
  if qualities["4"] == nil or qualities["4"] then tooltipString = tooltipString .. " |cffa335ee" .. string.lower(DisenchanterPlus:DP_i18n("Epic")) .. "|r" end
  return tooltipString
end
]]

---Update keybindings
function DP_DisenchantWindow:UpdateKeybindings()
  if DisenchanterPlus.db.char.general.acceptDisenchant ~= nil then
    SetBindingClick(DisenchanterPlus.db.char.general.acceptDisenchant, "AutoDisenchant_YesButton", "LeftButton")
  end
end

---Close ignore window
function DP_DisenchantWindow:CloseIgnoreWindow()
  local normalTexture = DisenchanterPlusBaseFrame.clearPermanentButton:CreateTexture(nil, nil, "UIPanelButtonUpTexture")
  DisenchanterPlusBaseFrame.clearPermanentButton:SetNormalTexture(normalTexture)
end

---Open ignore window
function DP_DisenchantWindow:OpenIgnoreWindow()
  if DP_IgnoredWindow:IsWindowOpened() then
    DP_CustomSounds:PlayCustomSound("WindowClose")
    DP_IgnoredWindow:CloseWindow()
  else
    DP_CustomSounds:PlayCustomSound("WindowOpen")
    local highlightTexture = DisenchanterPlusBaseFrame.clearPermanentButton:CreateTexture(nil, nil, "UIPanelButtonHighlightTexture")
    DisenchanterPlusBaseFrame.clearPermanentButton:SetNormalTexture(highlightTexture)
    DP_IgnoredWindow:OpenWindow()
  end
end

---Draw craft button
---@param name string
---@param icon string
---@param tooltipText string
---@param qualityIndex string
---@param x number
---@param y number
function DP_DisenchantWindow:DrawQualityButton(name, icon, tooltipText, qualityIndex, x, y)
  if not DisenchanterPlusBaseFrame.qualityButtons then
    DisenchanterPlusBaseFrame.qualityButtons = {}
  end

  local qualityButton = CreateFrame("Button", name, DisenchanterPlusBaseFrame, BackdropTemplateMixin and "BackdropTemplate")
  qualityButton.qualityIndex = qualityIndex
  qualityButton:SetSize(32, 22)
  qualityButton:SetPoint("TOPRIGHT", DisenchanterPlusBaseFrame, x, y)
  qualityButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
    current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\" .. icon .. "_fill:16:16|t ") --.. DisenchanterPlus:DP_i18n("Settings")
    current:SetAlpha(0.8)
  end)
  qualityButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    local qualityString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\" .. icon .. ":16:16|t "
    if DP_DisenchantWindow:CheckQualityButtonStatus(current.qualityIndex) then
      qualityString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\" .. icon .. "_fill:16:16|t "
    end
    current.text:SetText(qualityString)
    current:SetAlpha(0.6)
  end)
  qualityButton:SetScript("OnClick", function(current)
    DP_DisenchantWindow:ClickQualityButton(qualityIndex, icon)
  end)
  qualityButton:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    edgeSize = 2,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  qualityButton:SetBackdropColor(0, 0, 0, 0)
  qualityButton:SetAlpha(0.6)

  local craftText = qualityButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local qualityString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\" .. icon .. ":16:16|t "
  if DP_DisenchantWindow:CheckQualityButtonStatus(qualityIndex) then
    qualityString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\" .. icon .. "_fill:16:16|t "
  end

  craftText:SetPoint("CENTER", qualityButton, 2, 0)
  craftText:SetJustifyH("CENTER")
  craftText:SetText(qualityString)
  qualityButton.text = craftText

  DisenchanterPlusBaseFrame.qualityButtons[qualityIndex] = qualityButton
  qualityButton:Show()
end

---Chceck craft type
---@param qualityIndex string
---@return boolean
function DP_DisenchantWindow:CheckQualityButtonStatus(qualityIndex)
  if DisenchanterPlus.db.char.general.itemQuality[qualityIndex] == nil or DisenchanterPlus.db.char.general.itemQuality[qualityIndex] == true then
    return true
  else
    return false
  end
end

---Click craft button
---@param qualityIndex string
---@param icon string
function DP_DisenchantWindow:ClickQualityButton(qualityIndex, icon)
  if DP_DisenchantWindow:CheckQualityButtonStatus(qualityIndex) then
    DisenchanterPlus.db.char.general.itemQuality[qualityIndex] = false
  else
    DisenchanterPlus.db.char.general.itemQuality[qualityIndex] = true
  end
  DP_CustomSounds:PlayCustomSound("ChatScrollButton")
  DP_DisenchantWindow:RedrawQualityButton(qualityIndex, icon)
end

---Redraw craft button
---@param qualityIndex string
---@param icon string
function DP_DisenchantWindow:RedrawQualityButton(qualityIndex, icon)
  local craftButton = DisenchanterPlusBaseFrame.qualityButtons[qualityIndex]
  if craftButton then
    local qualityString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\" .. icon .. ":16:16|t "
    if DP_DisenchantWindow:CheckQualityButtonStatus(qualityIndex) then
      qualityString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\" .. icon .. "_fill:16:16|t "
    end
    craftButton.text:SetText(qualityString)
    C_Timer.After(0.1, function()
    end)
  end
end
