---@class DP_SettingsDefaults
local DP_SettingsDefaults = DP_ModuleLoader:CreateModule("DP_SettingsDefaults");

function DP_SettingsDefaults:Load()
  return {
    global = {
      data = {
        items = {},
        dusts = {},
        essences = {},
        shards = {},
        crystals = {},
        unknown = {},
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
        disableAll = false,
        disenchanProcessEnabled = true,
        tooltipsEnabled = true,
        keybindingEnabled = false,
        acceptDisenchant = nil,
        pressKeyDown = "1_none",
        showTitle = true,
        showItemID = false,
        zeroValues = true,
        itemsToShow = 5,
        showExpectedEssences = true,
        showRealEssences = true,
        autoDisenchantEnabled = true,
        autoDisenchantDbTimeout = 10,
        itemQuality = {
          ["2"] = true,
          ["3"] = true,
          ["4"] = true,
        },
        disenchantFrameOffset = {
          xOffset = 0,
          yOffset = 200
        },
        permanentIgnoredItems = {
        },
        sessionIgnoredItems = {
        },
        onlySoulbound = false,
      },
    },
  }
end
