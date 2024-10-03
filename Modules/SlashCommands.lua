---@class DP_SlashCommands
local DP_SlashCommands = DP_ModuleLoader:CreateModule("DP_SlashCommands")

---@type DP_Settings
local DP_Settings = DP_ModuleLoader:ImportModule("DP_Settings")

---@type DP_WelcomeWindow
local DP_WelcomeWindow = DP_ModuleLoader:ImportModule("DP_WelcomeWindow")

function DP_SlashCommands.RegisterSlashCommands()
  DisenchanterPlus:RegisterChatCommand("disenchanterplus", DP_SlashCommands.HandleCommands)
  DisenchanterPlus:RegisterChatCommand("dplus", DP_SlashCommands.HandleCommands)
end

function DP_SlashCommands.HandleCommands(input)
  local command = string.lower(input) or "help"
  if command == "config" then
    DP_SlashCommands:OpenSettingsWindow()
  elseif command == "main" then
    DP_SlashCommands:OpenWelcomeWindow()
  else
    DisenchanterPlus:Print(format("|cffe1e1f1Disenchanter|r |cfff141bfPlus|r : %s", DisenchanterPlus:DP_i18n("Available commands")))
    DisenchanterPlus:Print(format("/dplus |cffc1c1c1config|r - %s", DisenchanterPlus:DP_i18n("Open settings window")))
    DisenchanterPlus:Print(format("/dplus |cffc1c1c1main|r - %s", DisenchanterPlus:DP_i18n("Open main window")))
  end
end

function DP_SlashCommands:CloseAllFrames()
  DP_Settings:HideSettingsFrame()
  DP_WelcomeWindow:HideDisenchanterPlusWindowFrame()
end

function DP_SlashCommands:OpenSettingsWindow()
  DP_SlashCommands:CloseAllFrames()
  C_Timer.After(0.2, function()
    DP_Settings:OpenSettingsFrame()
  end)
end

function DP_SlashCommands:OpenWelcomeWindow()
  DP_SlashCommands:CloseAllFrames()
  C_Timer.After(0.2, function()
    DP_WelcomeWindow:OpenDisenchanterPlusWindowFrame()
  end)
end
