---@class DP_WelcomeWindow
local DP_WelcomeWindow = DP_ModuleLoader:CreateModule("DP_WelcomeWindow")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_CustomFrames
local DP_CustomFrames = DP_ModuleLoader:ImportModule("DP_CustomFrames")

---@type DP_WelcomeBody
local DP_WelcomeBody = DP_ModuleLoader:ImportModule("DP_WelcomeBody")

---@type DP_WelcomeHeader
local DP_WelcomeHeader = DP_ModuleLoader:ImportModule("DP_WelcomeHeader")

-- Forward declaration
DisenchanterPlusWindowFrame = nil

local LibStub = LibStub
local AceGUI = LibStub("AceGUI-3.0")

local tableData = {}

---Initilize
function DP_WelcomeWindow:Initialize()
  if not DisenchanterPlusWindowFrame then
    DP_WelcomeWindow:CreateWelcomeWindowTable()

    ---@type AceGUIFrame, AceGUIFrame
    local playerCensusPlusWindowFrame = AceGUI:Create("Frame");
    playerCensusPlusWindowFrame:SetWidth(515)
    playerCensusPlusWindowFrame:SetHeight(535)
    playerCensusPlusWindowFrame:SetPoint("CENTER", 0, 0)
    playerCensusPlusWindowFrame:SetLayout("Fill")
    playerCensusPlusWindowFrame:SetTitle("DisenchanterPlus")
    playerCensusPlusWindowFrame:SetStatusText(string.format("%s %s", DisenchanterPlus:GetAddonColoredName(), DisenchanterPlus:GetAddonColoredVersion()))
    playerCensusPlusWindowFrame:EnableResize(false)
    --playerCensusPlusWindowFrame:Hide()
    playerCensusPlusWindowFrame:SetCallback("OnClose", function(widget)
      PlaySound(840)
    end)

    -- header
    DP_WelcomeHeader:ContainerHeaderFrame(tableData, playerCensusPlusWindowFrame)

    -- table
    DP_WelcomeBody:ContainerBodyFrame(tableData, playerCensusPlusWindowFrame)

    playerCensusPlusWindowFrame:Hide()
    DisenchanterPlusWindowFrame = playerCensusPlusWindowFrame;

    _G["DisenchanterPlusWindowFrame"] = DisenchanterPlusWindowFrame.frame
    table.insert(UISpecialFrames, "DisenchanterPlusWindowFrame")
  end
end

---Create welcome window table data
function DP_WelcomeWindow:CreateWelcomeWindowTable()
  tableData = {
    table = {
      header = {
      },
      data = {
      }
    },
  }
end

---Hide window frame
function DP_WelcomeWindow:HideDisenchanterPlusWindowFrame()
  if DisenchanterPlusWindowFrame and DisenchanterPlusWindowFrame:IsShown() then
    DisenchanterPlusWindowFrame:Hide();
  end
end

---Open window
function DP_WelcomeWindow:OpenDisenchanterPlusWindowFrame()
  if not DisenchanterPlusWindowFrame then return end
  if not DisenchanterPlusWindowFrame:IsShown() then
    PlaySound(882)
    --DisenchanterPlus:Debug("Show WelcomeWindow frame")
    DisenchanterPlusWindowFrame:Show()
    DP_WelcomeWindow:RedrawDisenchanterPlusWindowFrame()
  else
    --DisenchanterPlus:Debug("Hide WelcomeWindow frame")
    DisenchanterPlusWindowFrame:Hide()
  end
end

---Redraw welcome window frame
function DP_WelcomeWindow:RedrawDisenchanterPlusWindowFrame()
  if not DisenchanterPlusWindowFrame then return end
  --DisenchanterPlus:Debug("Redraw DisenchanterPlusWindowFrame frame")
  if DisenchanterPlusWindowFrame:IsShown() then
    DP_WelcomeBody:RedrawWelcomeWindowBody(tableData, DisenchanterPlusWindowFrame)
  end
end
