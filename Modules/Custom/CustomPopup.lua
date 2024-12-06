---@class DP_CustomPopup
local DP_CustomPopup = DP_ModuleLoader:CreateModule("DP_CustomPopup")

local _DP_CustomPopup = DP_CustomPopup.private
_DP_CustomPopup.popup = nil

local LibStub = LibStub
local AceGUI = LibStub("AceGUI-3.0")
local isOpened = false
local _DP_CreateContainer, _DP_CreateDescription, _DP_CreateButtonContainer, _DP_CreateSeparator, _DP_CreateAcceptButton, _DP_CreateCancelButton
local title, description, _acceptFn
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

function DP_CustomPopup:CreatePopup(customTitle, customDescription, customAcceptFn)
  if customTitle == nil or customDescription == nil or customAcceptFn == nil then return end
  title = customTitle
  description = customDescription
  _acceptFn = customAcceptFn
  if not _DP_CustomPopup.popup then
    _DP_CustomPopup.popup = _DP_CreatePopupWindow()
    _DP_CustomPopup.popup:Hide()
  else
    _DP_CustomPopup.popup:ReleaseChildren()
    _DP_CustomPopup.popup:SetTitle(customTitle)
    DP_CustomPopup:CreateWindowContent(_DP_CustomPopup.popup)
  end
  C_Timer.After(0.1, function()
    DP_CustomPopup:ShowPopup()
  end)
end

function DP_CustomPopup:ShowPopup()
  if not _DP_CustomPopup.popup:IsShown() then
    _DP_CustomPopup.popup:Show()
    isOpened = true
    --DisenchanterPlus:Debug("ShowPopup " .. tostring(isOpened))
  else
    _DP_CustomPopup.popup:Hide()
    isOpened = false
    --DisenchanterPlus:Debug("ShowPopup " .. tostring(isOpened))
  end
end

function DP_CustomPopup:CancelPopup()
  --DisenchanterPlus:Debug("Cancel popup")
  if _DP_CustomPopup.popup then
    _DP_CustomPopup.popup:Hide()
    isOpened = false
  end
end

function DP_CustomPopup:IsOpened()
  --DisenchanterPlus:Debug("IsOpened " .. tostring(isOpened))
  return isOpened
end

_DP_CreatePopupWindow = function()
  ---@type AceGUIWindow
  local popup = AceGUI:Create("Frame")
  popup:Show()
  popup:SetTitle(title)
  popup:SetWidth(410)
  popup:SetHeight(140)
  popup:EnableResize(false)
  popup.frame:Raise()
  popup:SetCallback("OnClose", function()
    popup:Hide()
  end)
  DP_CustomPopup:CreateWindowContent(popup)
  --popup.frame:SetBackdrop(DEFAULT_DIALOG_BACKDROP)
  --popup.frame:SetBackdropColor(0, 0, 0, 1)
  return popup
end

function DP_CustomPopup:CreateWindowContent(popup)
  local container = _DP_CreateContainer()
  popup:AddChild(container)

  local desc = _DP_CreateDescription()
  container:AddChild(desc)

  local buttonContainer = _DP_CreateButtonContainer()
  container:AddChild(buttonContainer)
end

---Create container
---@return AceGUIWidget
_DP_CreateContainer       = function()
  ---@type AceGUISimpleGroup
  local container = AceGUI:Create("SimpleGroup")
  container:SetWidth(400)
  container:SetHeight(140)
  container:SetLayout('Flow')
  container:SetAutoAdjustHeight(false)
  return container
end

---Create label
---@return AceGUIWidget
_DP_CreateDescription     = function()
  ---@type AceGUISimpleGroup
  local descContainer = AceGUI:Create("SimpleGroup")
  descContainer:SetWidth(400)
  descContainer:SetHeight(60)
  descContainer:SetLayout('Flow')
  descContainer:SetAutoAdjustHeight(false)

  -- Separator <-
  descContainer:AddChild(_DP_CreateSeparator(10, 60))

  ---@type AceGUILabel
  local desc = AceGUI:Create("Label")
  desc:SetText(description)
  desc:SetWidth(380)
  desc:SetFullHeight(true)
  descContainer:AddChild(desc)

  -- Separator ->
  descContainer:AddChild(_DP_CreateSeparator(10, 60))

  return descContainer
end

---Create container
---@return AceGUIWidget
_DP_CreateButtonContainer = function()
  ---@type AceGUISimpleGroup
  local btnContainer = AceGUI:Create("SimpleGroup")
  btnContainer:SetWidth(400)
  btnContainer:SetHeight(40)
  btnContainer:SetLayout('Flow')

  -- Separator
  btnContainer:AddChild(_DP_CreateSeparator(10, 40))

  local addAcceptBtn = _DP_CreateAcceptButton()
  btnContainer:AddChild(addAcceptBtn)

  -- Separator
  btnContainer:AddChild(_DP_CreateSeparator(120, 40))

  local addCancelBtn = _DP_CreateCancelButton()
  btnContainer:AddChild(addCancelBtn)

  -- Separator
  btnContainer:AddChild(_DP_CreateSeparator(10, 40))

  return btnContainer
end

---Create accept button
---@return AceGUIWidget
_DP_CreateAcceptButton    = function()
  ---@type AceGUIButton
  local addAcceptBtn = AceGUI:Create("Button")
  addAcceptBtn:SetText(DisenchanterPlus:DP_i18n('Accept'))
  addAcceptBtn:SetWidth(120)
  addAcceptBtn:SetCallback("OnClick", _DP_HandleAcceptBtn)
  return addAcceptBtn
end

---Create cancel button
---@return AceGUIWidget
_DP_CreateCancelButton    = function()
  ---@type AceGUIButton
  local addCancelBtn = AceGUI:Create("Button")
  addCancelBtn:SetText(DisenchanterPlus:DP_i18n('Cancel'))
  addCancelBtn:SetWidth(120)
  addCancelBtn:SetCallback("OnClick", _DP_HandleCancelBtn)
  return addCancelBtn
end


---Create accept button
---@return AceGUIWidget
_DP_CreateSeparator = function(width, height)
  ---@type AceGUILabel
  local separator = AceGUI:Create("Label")
  separator:SetText('')
  separator:SetWidth(width)
  separator:SetHeight(height)
  return separator
end

---Handle entry note
_DP_HandleAcceptBtn = function()
  _acceptFn()
  _DP_CustomPopup.popup:Hide()
end

---Handle entry note
_DP_HandleCancelBtn = function()
  _DP_CustomPopup.popup:Hide()
end
