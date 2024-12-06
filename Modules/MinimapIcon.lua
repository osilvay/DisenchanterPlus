---@class DP_MinimapIcon
local DP_MinimapIcon = DP_ModuleLoader:CreateModule("DP_MinimapIcon");
local _DP_MinimapIcon = {}

---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings")

---@type DP_SlashCommands
local DP_SlashCommands = DP_ModuleLoader:ImportModule("DP_SlashCommands")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

---@type DP_CustomMedias
local DP_CustomMedias = DP_ModuleLoader:ImportModule("DP_CustomMedias")

---@type DP_DisenchantProcess
local DP_DisenchantProcess = DP_ModuleLoader:ImportModule("DP_DisenchantProcess")

---@type DP_DisenchantWindow
local DP_DisenchantWindow = DP_ModuleLoader:ImportModule("DP_DisenchantWindow")

local _LibDBIcon = LibStub("LibDBIcon-1.0");

function DP_MinimapIcon:Initialize()
  _LibDBIcon:Register("DisenchanterPlus", _DP_MinimapIcon:CreateDataBrokerObject(), DisenchanterPlus.db.profile.minimap);
  DisenchanterPlus.minimapConfigIcon = _LibDBIcon
end

---Create data object
---@return LibDataBroker.DataDisplay|LibDataBroker.QuickLauncher
function _DP_MinimapIcon:CreateDataBrokerObject()
  local autoDisenchantEnabled = DisenchanterPlus.db.char.general.autoDisenchantEnabled
  local icon = DP_CustomMedias:GetMediaFile("disenchanterplus_paused")
  if autoDisenchantEnabled then
    icon = DP_CustomMedias:GetMediaFile("disenchanterplus_running")
  end

  local dataObject = {
    type = "data source",
    text = string.format("|cffe1e1f1DisenchanterPlus|r |c%sPlus|r", DisenchanterPlus:GetAddonColor()),
    icon = icon,
    OnClick = function(_, button)
      if button == "LeftButton" then
        if IsShiftKeyDown() then
          if DP_DisenchantProcess:ProcessRunning() then
            DP_SlashCommands:CloseAllFrames()
            DP_DisenchantProcess:PauseDisenchantProcess()
            DP_MinimapIcon:UpdateIcon(DP_CustomMedias:GetMediaFile("disenchanterplus_paused"))
          end
        else
          if not DP_DisenchantWindow:IsWindowOpened() then
            DP_SlashCommands:CloseAllFrames()
            DP_DisenchantProcess:OpenDisenchantWindow()
          end
        end
      elseif button == "RightButton" then
        if IsShiftKeyDown() then
          if not DP_DisenchantProcess:ProcessRunning() then
            DP_SlashCommands:CloseAllFrames()
            DP_DisenchantProcess:StartsDisenchantProcess()
            DP_MinimapIcon:UpdateIcon(DP_CustomMedias:GetMediaFile("disenchanterplus_running"))
          end
        else
          DP_SlashCommands:CloseAllFrames()
          DP_Settings:OpenSettingsFrame()
        end
      end
    end,
    OnTooltipShow = function(tooltip)
      tooltip:AddLine(DisenchanterPlus:GetAddonColoredName())
      tooltip:AddLine(DP_CustomColors:Colorize(DP_CustomColors:CustomColors("HIGHLIGHTED"), DisenchanterPlus:DP_i18n("Left Click")) .. ": " .. DP_CustomColors:Colorize(DP_CustomColors:CustomColors("TEXT_VALUE"), DisenchanterPlus:DP_i18n("Open main window")));
      tooltip:AddLine(DP_CustomColors:Colorize(DP_CustomColors:CustomColors("HIGHLIGHTED"), DisenchanterPlus:DP_i18n("Right Click")) .. ": " .. DP_CustomColors:Colorize(DP_CustomColors:CustomColors("TEXT_VALUE"), DisenchanterPlus:DP_i18n("Open settings window")));
      tooltip:AddLine(DP_CustomColors:Colorize(DP_CustomColors:CustomColors("HIGHLIGHTED"), DisenchanterPlus:DP_i18n("Shift + Left Click")) .. ": " .. DP_CustomColors:Colorize(DP_CustomColors:CustomColors("TEXT_VALUE"), DisenchanterPlus:DP_i18n("Pause auto disenchant")));
      tooltip:AddLine(DP_CustomColors:Colorize(DP_CustomColors:CustomColors("HIGHLIGHTED"), DisenchanterPlus:DP_i18n("Shift + Right Click")) .. ": " .. DP_CustomColors:Colorize(DP_CustomColors:CustomColors("TEXT_VALUE"), DisenchanterPlus:DP_i18n("Starts auto disenchant")));
    end,
  }

  local LDBDataObject = LibStub("LibDataBroker-1.1"):NewDataObject("DisenchanterPlus", dataObject);
  self.LDBDataObject = LDBDataObject
  return LDBDataObject
end

--- Update the LibDataBroker text
function DP_MinimapIcon:UpdateText(value)
  _DP_MinimapIcon.LDBDataObject.text = value
end

function DP_MinimapIcon:UpdateIcon(value)
  _DP_MinimapIcon.LDBDataObject.icon = value
end
