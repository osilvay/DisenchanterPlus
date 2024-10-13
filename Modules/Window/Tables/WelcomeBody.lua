---@class DP_WelcomeBody
local DP_WelcomeBody = DP_ModuleLoader:CreateModule("DP_WelcomeBody")

local LibStub = LibStub
local AceGUI = LibStub("AceGUI-3.0")
local disenchanterPlusBodyContainer

---Redraw body container
---@param containerTable table
---@param parentFrame AceGUIFrame
function DP_WelcomeBody:RedrawWelcomeWindowBody(containerTable, parentFrame)
  disenchanterPlusBodyContainer:ReleaseChildren()
  DP_WelcomeBody:ContainerBodyFrame(containerTable, parentFrame)
end

---Create welcome container body frame
function DP_WelcomeBody:ContainerBodyFrame(containerTable, parentFrame)
  -- table
  if not disenchanterPlusBodyContainer then
    -- container
    ---@type AceGUIInlineGroup
    disenchanterPlusBodyContainer = AceGUI:Create("InlineGroup")
    disenchanterPlusBodyContainer:SetWidth(495)
    disenchanterPlusBodyContainer:SetHeight(220)
    disenchanterPlusBodyContainer:SetTitle(DisenchanterPlus:DP_i18n("Main plugins"))
    disenchanterPlusBodyContainer:SetLayout("Flow")
    disenchanterPlusBodyContainer:SetPoint("TOPLEFT", parentFrame.frame, "TOPLEFT", 10, -40)
    parentFrame:AddChild(disenchanterPlusBodyContainer)
  end
end

---H separator
---@param rowContainer any
---@param height number
function DP_WelcomeBody:horizontalSeparator(rowContainer, width, height)
  ---@type AceGUIWidget
  local separator = AceGUI:Create("SimpleGroup")
  separator:SetWidth(width)
  separator:SetHeight(height)
  rowContainer:AddChild(separator)
end

---V separator
---@param rowContainer any
---@param height number
function DP_WelcomeBody:verticalSeparator(rowContainer, height)
  ---@type AceGUIWidget
  local separator = AceGUI:Create("SimpleGroup")
  separator:SetFullWidth(true)
  separator:SetHeight(height)
  rowContainer:AddChild(separator)
end
