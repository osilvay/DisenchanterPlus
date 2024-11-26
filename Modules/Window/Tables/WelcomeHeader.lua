---@class DP_WelcomeHeader
local DP_WelcomeHeader = DP_ModuleLoader:CreateModule("DP_WelcomeHeader")

---@type DP_SlashCommands
local DP_SlashCommands = DP_ModuleLoader:ImportModule("DP_SlashCommands")

---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_CustomFrames
local DP_CustomFrames = DP_ModuleLoader:ImportModule("DP_CustomFrames")

---@type DP_CustomMedias
local DP_CustomMedias = DP_ModuleLoader:ImportModule("DP_CustomMedias")

local LibStub = LibStub
local AceGUI = LibStub("AceGUI-3.0")

---Create loot fiter frame
---@param containerTable table
---@param parentFrame AceGUIFrame
function DP_WelcomeHeader:ContainerHeaderFrame(containerTable, parentFrame)
  -- container
  ---@type AceGUIInlineGroup
  local headerContainer = AceGUI:Create("SimpleGroup")
  headerContainer:SetFullWidth(true)
  headerContainer:SetWidth(500)
  headerContainer:SetHeight(40)
  headerContainer:SetLayout("Flow")
  headerContainer:SetPoint("TOPLEFT", parentFrame.frame, "TOPLEFT", 20, 0)
  parentFrame:AddChild(headerContainer)

  --Options button
  ---@type AceGUIButton
  local settingsButton = AceGUI:Create("Button")
  local settingsIcon = DP_CustomMedias:GetIconFileAsLink("settings_a", 16, 16)
  settingsButton:SetWidth(150)
  settingsButton:SetPoint("TOPRIGHT", parentFrame.frame, "TOPRIGHT", -20, -15)
  settingsButton:SetText(settingsIcon .. " " .. DisenchanterPlus:DP_i18n('Settings'))
  settingsButton:SetCallback("OnClick", function()
    DP_SlashCommands:OpenSettingsWindow()
  end)
  parentFrame:AddChild(settingsButton)
end
