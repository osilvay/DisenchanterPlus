---@class DP_WelcomeWindow
local DP_WelcomeWindow = DP_ModuleLoader:CreateModule("DP_WelcomeWindow")

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
    local disenchanterPlusWindowFrame = AceGUI:Create("Frame");
    disenchanterPlusWindowFrame:SetWidth(515)
    disenchanterPlusWindowFrame:SetHeight(535)
    disenchanterPlusWindowFrame:SetPoint("CENTER", 0, 0)
    disenchanterPlusWindowFrame:SetLayout("Fill")
    disenchanterPlusWindowFrame:SetTitle("DisenchanterPlus")
    disenchanterPlusWindowFrame:SetStatusText(string.format("%s %s", DisenchanterPlus:GetAddonColoredName(), DisenchanterPlus:GetAddonColoredVersion()))
    disenchanterPlusWindowFrame:EnableResize(false)
    --disenchanterPlusWindowFrame:Hide()
    disenchanterPlusWindowFrame:SetCallback("OnClose", function(widget)
      --DP_CustomSounds:PlayCustomSound("WindowClose")
    end)

    -- header
    DP_WelcomeHeader:ContainerHeaderFrame(tableData, disenchanterPlusWindowFrame)

    -- table
    DP_WelcomeBody:ContainerBodyFrame(tableData, disenchanterPlusWindowFrame)

    disenchanterPlusWindowFrame:Hide()
    DisenchanterPlusWindowFrame = disenchanterPlusWindowFrame;

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
    --DP_CustomSounds:PlayCustomSound("WindowOpen")
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
