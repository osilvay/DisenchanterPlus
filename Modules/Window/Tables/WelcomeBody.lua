---@class DP_WelcomeBody
local DP_WelcomeBody = DP_ModuleLoader:CreateModule("DP_WelcomeBody")

local LibStub = LibStub
local AceGUI = LibStub("AceGUI-3.0")
local playerCensusPlusBodyContainer

---Redraw body container
---@param containerTable table
---@param parentFrame AceGUIFrame
function DP_WelcomeBody:RedrawWelcomeWindowBody(containerTable, parentFrame)
  playerCensusPlusBodyContainer:ReleaseChildren()
  DP_WelcomeBody:ContainerBodyFrame(containerTable, parentFrame)
end

---Create welcome container body frame
function DP_WelcomeBody:ContainerBodyFrame(containerTable, parentFrame)
  -- table
  if not playerCensusPlusBodyContainer then
    -- container
    ---@type AceGUIInlineGroup
    playerCensusPlusBodyContainer = AceGUI:Create("InlineGroup")
    playerCensusPlusBodyContainer:SetWidth(495)
    playerCensusPlusBodyContainer:SetHeight(220)
    playerCensusPlusBodyContainer:SetTitle(DisenchanterPlus:DP_i18n("Main plugins"))
    playerCensusPlusBodyContainer:SetLayout("Flow")
    playerCensusPlusBodyContainer:SetPoint("TOPLEFT", parentFrame.frame, "TOPLEFT", 10, -40)
    parentFrame:AddChild(playerCensusPlusBodyContainer)
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
