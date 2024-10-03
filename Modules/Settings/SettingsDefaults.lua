---@class DP_SettingsDefaults
local DP_SettingsDefaults = DP_ModuleLoader:CreateModule("DP_SettingsDefaults");

function DP_SettingsDefaults:Load()
  return {
    global = {
      data = {
        characters = {
        },
        players = {
        },
        realms = {
        },
      },
      characters = {
        char = {
          info = {
          },
        },
      },
    },
    char = {
      advanced = {
        debug = false,
      },
      general = {
        disenchanProcessEnabled = true,
        tooltipsEnabled = true,
        autoDisenchantEnabled = true,
        autoDisenchantDbTimeout = 10,
        itemQuality = {
          ["2"] = true,
          ["3"] = true,
          ["4"] = false,
        },
        disenchantFrameOffset = {
          xOffset = 0,
          yOffset = 200
        },
        permanentIgnoredItems = {
        },
        onlySoulbound = false
      },
    },
  }
end
