---@class DP_MinimapIcon
local DP_MinimapIcon = DP_ModuleLoader:CreateModule("DP_MinimapIcon");
local _DP_MinimapIcon = {}

---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings")

---@type DP_SlashCommands
local DP_SlashCommands = DP_ModuleLoader:ImportModule("DP_SlashCommands")

---@type DP_WelcomeWindow
local DP_WelcomeWindow = DP_ModuleLoader:ImportModule("DP_WelcomeWindow")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

---@type DP_CustomMedias
local DP_CustomMedias = DP_ModuleLoader:ImportModule("DP_CustomMedias")

local _LibDBIcon = LibStub("LibDBIcon-1.0");

function DP_MinimapIcon:Initialize()
  _LibDBIcon:Register("DisenchanterPlus", _DP_MinimapIcon:CreateDataBrokerObject(), DisenchanterPlus.db.profile.minimap);
  DisenchanterPlus.minimapConfigIcon = _LibDBIcon
end

function _DP_MinimapIcon:CreateDataBrokerObject()
  local LDBDataObject = LibStub("LibDataBroker-1.1"):NewDataObject("DisenchanterPlus", {
    type = "data source",
    text = string.format("|cffe1e1f1DisenchanterPlus|r |c%sPlus|r", DisenchanterPlus:GetAddonColor()),
    icon = DP_CustomMedias:GetMediaFile("disenchanterplus"),
    OnClick = function(_, button)
      if button == "LeftButton" then
        DP_SlashCommands:CloseAllFrames()
        DP_WelcomeWindow:OpenDisenchanterPlusWindowFrame()
      elseif button == "RightButton" then
        DP_SlashCommands:CloseAllFrames()
        DP_Settings:OpenSettingsFrame()
      end
    end,
    OnTooltipShow = function(tooltip)
      tooltip:AddLine(DisenchanterPlus:GetAddonColoredName())
      tooltip:AddLine(DP_CustomColors:Colorize(DP_CustomColors:CustomColors("HIGHLIGHTED"), DisenchanterPlus:DP_i18n("Left Click")) .. ": " .. DP_CustomColors:Colorize(DP_CustomColors:CustomColors("TEXT_VALUE"), DisenchanterPlus:DP_i18n("Open main window")));
      tooltip:AddLine(DP_CustomColors:Colorize(DP_CustomColors:CustomColors("HIGHLIGHTED"), DisenchanterPlus:DP_i18n("Right Click")) .. ": " .. DP_CustomColors:Colorize(DP_CustomColors:CustomColors("TEXT_VALUE"), DisenchanterPlus:DP_i18n("Open settings window")));
    end,
  });

  self.LDBDataObject = LDBDataObject
  return LDBDataObject
end

--- Update the LibDataBroker text
function DP_MinimapIcon:UpdateText(text, value)
  _DP_MinimapIcon.LDBDataObject.text = text
end
