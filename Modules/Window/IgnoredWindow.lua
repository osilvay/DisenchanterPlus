---@class DP_IgnoredWindow
local DP_IgnoredWindow = DP_ModuleLoader:CreateModule("DP_IgnoredWindow")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

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

---@type DP_CustomFrames
local DP_CustomFrames = DP_ModuleLoader:ImportModule("DP_CustomFrames")

---@type DP_CustomSounds
local DP_CustomSounds = DP_ModuleLoader:ImportModule("DP_CustomSounds")

---@type DP_DisenchantGroup
local DP_DisenchantGroup = DP_ModuleLoader:ImportModule("DP_DisenchantGroup")

local LibStub = LibStub
local AceGUI = LibStub("AceGUI-3.0")

local DEFAULT_DIALOG_BACKDROP = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 16,
  edgeSize = 16,
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

local IgnoredWindowBaseFrame
local textFrameBgColorAlpha = 0.80
local windowOpened = false
local linesInScrollContainer = {}
local numLinesInScrollContainer = 0
local ignoreListType = {
  Permanent = "permanent",
  Session = "session",
}

---Initilize
function DP_IgnoredWindow:CreateIgnoredWindow()
  local xOffset = DisenchanterPlus.db.char.general.disenchantFrameOffset.xOffset
  local yOffset = DisenchanterPlus.db.char.general.disenchantFrameOffset.yOffset

  -- base frame ******************************************************************************************
  IgnoredWindowBaseFrame = CreateFrame("Frame", "DisenchanterPlus_Ignored", UIParent, BackdropTemplateMixin and "BackdropTemplate")
  IgnoredWindowBaseFrame:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset - 215)
  IgnoredWindowBaseFrame:SetFrameStrata("MEDIUM")
  IgnoredWindowBaseFrame:SetFrameLevel(0)
  IgnoredWindowBaseFrame:SetSize(424, 240)
  IgnoredWindowBaseFrame:SetMovable(true)
  IgnoredWindowBaseFrame:EnableMouse(true)
  --IgnoredWindowBaseFrame:SetScript("OnMouseDown", DP_IgnoredWindow.OnDragStart)
  --IgnoredWindowBaseFrame:SetScript("OnMouseUp", DP_IgnoredWindow.OnDragStop)
  IgnoredWindowBaseFrame:SetScript("OnEnter", function()
  end)
  IgnoredWindowBaseFrame:SetScript("OnLeave", function()
  end)

  IgnoredWindowBaseFrame:SetBackdrop(DEFAULT_DIALOG_BACKDROP)
  IgnoredWindowBaseFrame:SetBackdropColor(0, 0, 0, textFrameBgColorAlpha)

  -- texts
  local titleText = IgnoredWindowBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  titleText:SetTextColor(1, 1, 1)
  titleText:SetPoint("TOPLEFT", IgnoredWindowBaseFrame, 20, -20)
  titleText:SetText(DisenchanterPlus:DP_i18n("Items ignored"))
  IgnoredWindowBaseFrame.titleText = titleText

  local footText = IgnoredWindowBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  footText:SetTextColor(1, 1, 1)
  footText:SetPoint("TOPLEFT", IgnoredWindowBaseFrame, 20, -45)
  footText:SetText("")
  IgnoredWindowBaseFrame.footText = footText

  -- close button ******************************************************************************************
  local closeButton = CreateFrame("Button", "Ignored_SettingsButton", IgnoredWindowBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  closeButton:SetSize(32, 22)
  closeButton:SetPoint("TOPRIGHT", IgnoredWindowBaseFrame, -10, -10)
  closeButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Close window."), nil, nil, nil, nil, true)
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
    DP_IgnoredWindow:CloseWindow()
  end)

  local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local closeString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_a:14:14|t " -- .. DisenchanterPlus:DP_i18n("Settings")
  closeText:SetPoint("CENTER", closeButton, 2, 0)
  closeText:SetJustifyH("CENTER")
  closeText:SetText(closeString)
  closeText:SetTextColor(0.6, 0.6, 0.6)
  closeButton.text = closeText

  IgnoredWindowBaseFrame.closeButton = closeButton
  closeButton:Show()

  -- tab1 ******************************************************************************************
  local tab1Button = DP_CustomFrames:CreateTab(IgnoredWindowBaseFrame, "IgnoreWindow_Tab1", 1, DisenchanterPlus:DP_i18n("Session items"), true, (424 - 40) / 2, 24)
  tab1Button:SetPoint("TOPLEFT", IgnoredWindowBaseFrame, "TOPLEFT", 20, -45);

  IgnoredWindowBaseFrame.tab1Button = tab1Button
  tab1Button:Show()

  -- tab1 frame
  local tabScrollFrame = CreateFrame("ScrollFrame", "IgnoreWindow_TabScrollFrame1", IgnoredWindowBaseFrame, "UIPanelScrollFrameTemplate")
  tabScrollFrame:SetPoint("TOPLEFT", IgnoredWindowBaseFrame, "TOPLEFT", 16, -70)
  tabScrollFrame:SetPoint("BOTTOMRIGHT", IgnoredWindowBaseFrame, "BOTTOMRIGHT", -42, 10)
  --
  local tabScrollContentFrame = CreateFrame("Frame", "IgnoreWindow_ItemListFrame", IgnoredWindowBaseFrame)
  tabScrollContentFrame:SetPoint("CENTER", 0, 0)
  tabScrollContentFrame:SetSize(360, 150)
  tabScrollFrame:SetScrollChild(tabScrollContentFrame)
  IgnoredWindowBaseFrame.tabScrollContentFrame = tabScrollContentFrame
  tabScrollFrame:Show()

  -- tab2 ******************************************************************************************
  local tab2Button = DP_CustomFrames:CreateTab(IgnoredWindowBaseFrame, "IgnoreWindow_Tab2", 1, DisenchanterPlus:DP_i18n("Permanent items"), false, (424 - 40) / 2, 24)
  tab2Button:SetPoint("LEFT", tab1Button, "RIGHT", 0, 0);

  IgnoredWindowBaseFrame.tab2Button = tab2Button
  tab2Button:Show()

  -- tab click events
  tab1Button:SetScript("OnClick", function(current)
    tab1Button.active = true
    DP_CustomFrames:EnableTab(tab1Button)
    tab2Button.active = false
    DP_CustomFrames:DisableTab(tab2Button)
    IgnoredWindowBaseFrame.tabScrollContentFrame:Hide()
    DP_IgnoredWindow.PopulateIgnoreList(ignoreListType.Session, IgnoredWindowBaseFrame.tabScrollContentFrame)
    --IgnoredWindowBaseFrame.tabScrollContentFrame = tabFrame
  end)
  tab2Button:SetScript("OnClick", function(current)
    tab1Button.active = false
    DP_CustomFrames:DisableTab(tab1Button)
    tab2Button.active = true
    DP_CustomFrames:EnableTab(tab2Button)
    IgnoredWindowBaseFrame.tabScrollContentFrame:Hide()
    DP_IgnoredWindow.PopulateIgnoreList(ignoreListType.Permanent, IgnoredWindowBaseFrame.tabScrollContentFrame)
    --IgnoredWindowBaseFrame.tabScrollContentFrame = tabFrame
  end)

  DP_IgnoredWindow.PopulateIgnoreList(ignoreListType.Session, IgnoredWindowBaseFrame.tabScrollContentFrame)
  IgnoredWindowBaseFrame:Hide()
  return IgnoredWindowBaseFrame
end

---Open auto disenchant window
function DP_IgnoredWindow:OpenWindow()
  if not IgnoredWindowBaseFrame then
    IgnoredWindowBaseFrame = DP_IgnoredWindow:CreateIgnoredWindow()
  end

  if not windowOpened then
    C_Timer.After(0.2, function()
      IgnoredWindowBaseFrame:SetBackdropColor(0, 0, 0, textFrameBgColorAlpha)
      IgnoredWindowBaseFrame:Show()
      windowOpened = true
      DP_IgnoredWindow.UpdatePosition()
      DP_IgnoredWindow.PopulateIgnoreList(ignoreListType.Session, IgnoredWindowBaseFrame.tabScrollContentFrame)
      DP_IgnoredWindow:UpdateTabQuantities()
    end)
  end
end

function DP_IgnoredWindow:UpdateTabQuantities()
  if not DP_IgnoredWindow:IsWindowOpened() then return end
  -- tab 1
  local sessionQuantity = DP_CustomFunctions:TableLength(DP_DisenchantGroup:GetSessionIgnoreList())
  local sessionQuantityString = string.format("|cff666666%d|r", sessionQuantity)
  if sessionQuantity > 0 then
    sessionQuantityString = string.format("|cffffcc66%d|r", sessionQuantity)
  end
  local permanentQuantity = DP_CustomFunctions:TableLength(DP_DisenchantGroup:GetPermanentIgnoreList())
  local permanentQuantityString = string.format("|cff666666%d|r", permanentQuantity)
  if permanentQuantity > 0 then
    permanentQuantityString = string.format("|cffffcc66%d|r", permanentQuantity)
  end

  IgnoredWindowBaseFrame.tab1Button.text:SetText(DisenchanterPlus:DP_i18n("Session items") .. " " .. sessionQuantityString)
  IgnoredWindowBaseFrame.tab2Button.text:SetText(DisenchanterPlus:DP_i18n("Permanent items") .. " " .. permanentQuantityString)
end

function DP_IgnoredWindow:IsWindowOpened()
  return windowOpened
end

---close window
function DP_IgnoredWindow:CloseWindow()
  if IgnoredWindowBaseFrame == nil then return end
  IgnoredWindowBaseFrame:Hide()
  windowOpened = false
end

---Drag start
function DP_IgnoredWindow.OnDragStart()
  if IgnoredWindowBaseFrame == nil then return end
  IgnoredWindowBaseFrame:Hide()
end

---Drag stop
function DP_IgnoredWindow.OnDragStop()
  if IgnoredWindowBaseFrame == nil then return end
  if not DP_IgnoredWindow:IsWindowOpened() then return end
  DP_IgnoredWindow.UpdatePosition()
  IgnoredWindowBaseFrame:Show()
end

function DP_IgnoredWindow.UpdatePosition()
  local xOffset = DisenchanterPlus.db.char.general.disenchantFrameOffset.xOffset
  local yOffset = DisenchanterPlus.db.char.general.disenchantFrameOffset.yOffset
  IgnoredWindowBaseFrame:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset - 215)
end

function DP_IgnoredWindow.PopulateIgnoreList(listType, tabFrame)
  DP_IgnoredWindow:UpdateTabQuantities()

  local itemNum = 1
  local offsetV = 24
  tabFrame.line = {}

  local ignoreList

  if listType == ignoreListType.Permanent then
    ignoreList = DP_DisenchantGroup:GetPermanentIgnoreList()
  else
    ignoreList = DP_DisenchantGroup:GetSessionIgnoreList()
  end

  if numLinesInScrollContainer > 0 then
    for i = 1, numLinesInScrollContainer, 1 do
      linesInScrollContainer[tostring(i)]:Hide()
    end
  end

  for itemID, itemLink in pairs(ignoreList) do
    if linesInScrollContainer[tostring(itemNum)] == nil then
      local itemLineFrame = CreateFrame("Frame", "IgnoreWindow_ItemFrame" .. itemNum, tabFrame, BackdropTemplateMixin and "BackdropTemplate")
      itemLineFrame:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -(offsetV * (itemNum - 1)))
      itemLineFrame:SetSize((424 - 40) + 8, 32)
      itemLineFrame:SetBackdrop(CUSTOM_DIALOG_BACKDROP)
      itemLineFrame:SetBackdropColor(1, 1, 1, 0)

      local deleteButton = CreateFrame("Button", "AutoDisenchant_DeleteButton" .. itemNum, itemLineFrame, BackdropTemplateMixin and "BackdropTemplate")
      deleteButton.lineID = itemNum
      deleteButton.itemID = itemID
      deleteButton.listType = listType

      deleteButton:SetSize(32, 32)
      deleteButton:SetPoint("RIGHT", itemLineFrame, -28, 0)
      deleteButton:SetScript("OnEnter", function(current)
        GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
        GameTooltip:SetText(DisenchanterPlus:DP_i18n("Remove."), nil, nil, nil, nil, true)
        deleteButton.text:SetTextColor(1, 1, 1)
        deleteButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\delete:20:20|t")
        if tabFrame.line[current.lineID] ~= nil then
          tabFrame.line[current.lineID]:SetBackdropColor(1, 1, 1, 0.3)
        end
      end)
      deleteButton:SetScript("OnLeave", function(current)
        GameTooltip:Hide()
        if tabFrame.line[current.lineID] ~= nil then
          deleteButton.text:SetTextColor(0.6, 0.6, 0.6)
          deleteButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\delete_a:20:20|t")
          tabFrame.line[current.lineID]:SetBackdropColor(1, 1, 1, 0)
        end
      end)
      deleteButton:SetScript("OnClick", function(current)
        if current.listType == ignoreListType.Permanent then
          DP_DisenchantGroup:RemovePermanentIgnoreListItem(current.itemID)
        else
          DP_DisenchantGroup:RemoveSessionIgnoreListItem(current.itemID)
        end
        --DisenchanterPlus:Debug("Removed " .. current.listType .. " : " .. current.itemID)
        DP_IgnoredWindow.PopulateIgnoreList(current.listType, tabFrame)
      end)
      deleteButton:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        edgeSize = 2,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
      })
      deleteButton:SetBackdropColor(0, 0, 0, 0)
      itemLineFrame.deleteButton = deleteButton

      local deleteText = deleteButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      local deleteString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\delete_a:20:20|t"
      deleteText:SetPoint("CENTER", deleteButton, "CENTER")
      deleteText:SetText(deleteString)
      deleteText:SetTextColor(0.6, 0.6, 0.6)
      deleteButton.text = deleteText

      local itemText = itemLineFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
      itemText.lineID = itemNum
      itemText:SetSize((424 - 40) + 8 - 32, 32)
      itemText:SetPoint("LEFT", itemLineFrame, 10, 0)
      itemText:SetText(itemLink)
      itemText:SetJustifyH("LEFT")
      itemText:SetScript("OnEnter", function(current)
        GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(itemID)
        GameTooltip:Show()
        --DisenchanterPlus:Debug("itemText = " .. tostring(current.lineID))
        tabFrame.line[current.lineID]:SetBackdropColor(1, 1, 1, 0.3)
      end)
      itemText:SetScript("OnLeave", function(current)
        GameTooltip:Hide()
        tabFrame.line[current.lineID]:SetBackdropColor(1, 1, 1, 0)
      end)
      itemLineFrame.itemText = itemText
      tabFrame.line[itemNum] = itemLineFrame
      linesInScrollContainer[tostring(itemNum)] = itemLineFrame
    else
      local itemLineFrame = linesInScrollContainer[tostring(itemNum)]
      local deleteButton = itemLineFrame.deleteButton
      deleteButton.itemID = itemID
      deleteButton.listType = listType

      local itemText = itemLineFrame.itemText
      itemText:SetText(itemLink)

      tabFrame.line[itemNum] = itemLineFrame
      linesInScrollContainer[tostring(itemNum)] = itemLineFrame
      itemLineFrame:Show()
    end
    itemNum = itemNum + 1
  end
  tabFrame:Show()
  numLinesInScrollContainer = DP_CustomFunctions:TableLength(tabFrame.line)
  --DisenchanterPlus:Debug(tostring(DP_CustomFunctions:TableLength(tabFrame.line)))
end
