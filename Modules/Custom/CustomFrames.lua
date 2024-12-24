---@class DP_CustomFrames
local DP_CustomFrames = DP_ModuleLoader:CreateModule("DP_CustomFrames")

---@type DP_CustomSounds
local DP_CustomSounds = DP_ModuleLoader:ImportModule("DP_CustomSounds")

local tabInactivetexture = "Interface\\Addons\\DisenchanterPlus\\Images\\Textures\\inactiveTab"
local tabActivetexture = "Interface\\Addons\\DisenchanterPlus\\Images\\Textures\\activeTab"

function DP_CustomFrames:Initialize()
end

--- Creates a horizontal spacer with the given width.
---@param order number
---@param width number
function DP_CustomFrames:HorizontalSpacer(order, width)
  if not width then
    width = 0.5
  end
  return {
    type = "description",
    order = order,
    name = " ",
    width = width
  }
end

--- Creates a vertical spacer with the given height
---@param order number
---@param hidden boolean?
function DP_CustomFrames:Spacer(order, hidden)
  return {
    type = "description",
    order = order,
    hidden = hidden,
    name = " "
  }
end

function DP_CustomFrames:CreateTab(parentFrame, tabName, tabIndex, text, active, width, height)
  local tab1Button = CreateFrame("Button", tabName, parentFrame, BackdropTemplateMixin and "BackdropTemplate")
  tab1Button.active = active
  tab1Button:SetID(tabIndex)
  tab1Button:SetSize(width, height)

  local tab1ButtonText = tab1Button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local tab1ButtonString = text
  tab1ButtonText:SetPoint("CENTER", tab1Button, "CENTER")
  tab1ButtonText:SetText(tab1ButtonString)

  if active then
    tab1ButtonText:SetTextColor(0.8, 0.8, 0.8)
  else
    tab1ButtonText:SetTextColor(0.5, 0.5, 0.5)
  end
  tab1Button.text = tab1ButtonText

  local texture = tabInactivetexture
  if tab1Button.active then
    texture = tabActivetexture
  end

  local tabStatusTexture = tab1Button:CreateTexture(nil, "OVERLAY")
  tabStatusTexture:SetTexture(texture)
  tabStatusTexture:SetDrawLayer("OVERLAY", 5)
  tabStatusTexture:SetPoint("LEFT", tab1Button, 0, 0)
  tabStatusTexture:SetWidth(width)
  tabStatusTexture:SetHeight(height)
  tab1Button.tabStatusTexture = tabStatusTexture

  tab1Button:SetScript("OnEnter", function(current)
    if current.active then
      current.text:SetTextColor(1, 1, 1)
    else
      current.text:SetTextColor(0.8, 0.8, 0.8)
    end
  end)
  tab1Button:SetScript("OnLeave", function(current)
    if current.active then
      current.text:SetTextColor(0.8, 0.8, 0.8)
    else
      current.text:SetTextColor(0.5, 0.5, 0.5)
    end
  end)
  return tab1Button
end

function DP_CustomFrames:EnableTab(tabObject)
  DP_CustomSounds:PlayCustomSound("TabChange")
  tabObject.text:SetTextColor(0.8, 0.8, 0.8)
  tabObject.tabStatusTexture:SetTexture(tabActivetexture)
end

function DP_CustomFrames:DisableTab(tabObject)
  tabObject.text:SetTextColor(0.5, 0.5, 0.5)
  tabObject.tabStatusTexture:SetTexture(tabInactivetexture)
end

---Draw custom button
---@param buttonIndex string
---@param name string
---@param parent table
---@param icon string
---@param tooltipText string
---@param x number
---@param y number
---@param testFn function
---@param onClickFn function
function DP_CustomFrames:DrawCustomCleanButton(buttonIndex, name, parent, icon, iconDisabled, tooltipText, x, y, testFn, onClickFn)
  if not parent then return end
  if not parent.customButtons then
    parent.customButtons = {}
  end

  local customButton = CreateFrame("Button", name, parent, BackdropTemplateMixin and "BackdropTemplate")
  customButton.buttonIndex = buttonIndex
  customButton:SetSize(32, 22)
  customButton:SetPoint("TOPRIGHT", parent, x, y)
  customButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
    local textString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\" .. iconDisabled .. ":16:16|t "
    if testFn() then
      textString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\" .. icon .. ":16:16|t "
    end
    current.text:SetText(textString)
    current:SetAlpha(0.8)
  end)
  customButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    local textString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\" .. iconDisabled .. ":16:16|t "
    if testFn() then
      textString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\" .. icon .. ":16:16|t "
    end
    current.text:SetText(textString)
    current:SetAlpha(0.6)
  end)
  customButton:SetScript("OnClick", function(current)
    onClickFn(buttonIndex, name, parent, icon, iconDisabled, testFn)
  end)
  customButton:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    edgeSize = 2,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  customButton:SetBackdropColor(0, 0, 0, 0)
  customButton:SetAlpha(0.6)

  local buttonText = customButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local buttonString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\" .. iconDisabled .. ":16:16|t "
  if testFn() then
    buttonString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\" .. icon .. ":16:16|t "
  end

  buttonText:SetPoint("CENTER", customButton, 2, 0)
  buttonText:SetJustifyH("CENTER")
  buttonText:SetText(buttonString)
  customButton.text = buttonText

  parent.customButtons[name] = customButton
  customButton:Show()
end

---Redraw craft button
---@param buttonIndex string
---@param name string
---@param parent table
---@param icon string
---@param iconDisabled string
---@param testFn function
function DP_CustomFrames:RedrawCustomCleanButton(buttonIndex, name, parent, icon, iconDisabled, testFn)
  if not parent then return end
  local customButton = parent.customButtons[name]
  if customButton then
    local buttonString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\" .. iconDisabled .. ":16:16|t "
    if testFn() then
      buttonString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\" .. icon .. ":16:16|t "
    end
    customButton.text:SetText(buttonString)
    C_Timer.After(0.1, function()
    end)
  end
end
