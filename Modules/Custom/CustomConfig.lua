---@class DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:CreateModule("DP_CustomConfig")
local _DP_CustomConfig = {}

---@type DP_CustomFrames
local DP_CustomFrames = DP_ModuleLoader:ImportModule("DP_CustomFrames");

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions");

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors");

---@type DP_CustomPopup
local DP_CustomPopup = DP_ModuleLoader:ImportModule("DP_CustomPopup")

---Generate delete character dropdown config
---@param characterList table
---@param deleteCharacterFn function
---@param currentCharacterList table
---@return table config
function DP_CustomConfig:CreateDeleteCharacterConfig(characterList, deleteCharacterFn, currentCharacterList, order)
  return {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      deleteCharacterData = {
        type = "select",
        order = 1,
        width = "full",
        name = DisenchanterPlus:DP_i18n("Delete character data"),
        values = function(info, value)
          return characterList
        end,
        disabled = false,
        confirm = function(info, value)
          return DisenchanterPlus:DP_i18n("Are you sure you want to delete this character?") .. "\n\n" .. currentCharacterList[value] ..
              "\n\n|cffff3300" .. DisenchanterPlus:DP_i18n("This operation can not be undone...") .. "|r"
        end,
        get = function() return {} end,
        set = function(info, value)
          deleteCharacterFn(value)
        end,
      }
    }
  }
end

---Generate memory config
---@param addonToCheck string
---@param numEntries table
---@return table config
function DP_CustomConfig:CreateMemoryConfig(addonToCheck, numEntries, order)
  local addonStats = DP_CustomFunctions:UpdateMemoryUsageForAddon(addonToCheck)
  return {
    type = "group",
    order = order,
    inline = true,
    name = DisenchanterPlus:DP_i18n("Memory usage"),
    args = {
      addonName = {
        type = "description",
        order = 1,
        width = 0.8,
        hidden = false,
        name = DisenchanterPlus:DP_i18n("Addon")
      },
      addonNameValue = {
        type = "description",
        order = 1.1,
        width = 1,
        hidden = false,
        name = function()
          if addonStats == nil or addonStats["disabled"] then
            return DP_CustomColors:Colorize(DP_CustomColors:CustomColors("DISABLED"), DisenchanterPlus:DP_i18n("Disabled"))
          else
            return DP_CustomColors:Colorize(DP_CustomColors:CustomColors("ENABLED"), DisenchanterPlus:DP_i18n("Enabled"))
          end
        end
      },
      entriesInDb = DP_CustomConfig:CreateEntriesConfig(DisenchanterPlus:DP_i18n("Entries"), 2, numEntries),
      memoryUsageKb = {
        type = "description",
        order = 3,
        width = 0.8,
        hidden = false,
        name = DisenchanterPlus:DP_i18n("Use in KB")
      },
      memoryUsageKbValue = {
        type = "description",
        order = 3.1,
        width = 1,
        hidden = false,
        name = function()
          return DP_CustomColors:ColorizeByValue(tostring(addonStats["totalMemInKb"]), addonStats["totalMemInKb"], 4096) .. " KB"
        end
      },
      memoryUsageMb = {
        type = "description",
        order = 4,
        width = 0.8,
        hidden = false,
        name = DisenchanterPlus:DP_i18n("Use in MB")
      },
      memoryUsageMbValue = {
        type = "description",
        order = 4.1,
        width = 1,
        hidden = false,
        name = function()
          return DP_CustomColors:ColorizeByValue(tostring(addonStats["totalMemInMb"]), addonStats["totalMemInMb"], 4) .. " MB"
        end
      }
    }
  }
end

---Generate delete character dropdown config
---@param addonToCheck string
---@param numEntries table
---@return table config
function DP_CustomConfig:CreateStatsConfig(addonToCheck, numEntries, order)
  return {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      addonMemoryUsage = DP_CustomConfig:CreateMemoryConfig(addonToCheck, numEntries, 1),
    },
  }
end

---Generate header config
---@param header string
---@param order number
---@param color? string
---@return table config
function DP_CustomConfig:CreateHeaderConfig(header, order, color)
  return
  {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      spacer_1 = DP_CustomFrames:Spacer(1, false),
      header = {
        type = "header",
        order = 2,
        name = string.format("|cff999999#######|r" .. " " .. "|c%s%s|r" .. " " .. "|cff999999######|r", color or "fff1c100", header),
      }
    }
  }
end

---Generate separator config
---@param order number
---@return table config
function DP_CustomConfig:CreateSeparatorConfig(order)
  return
  {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      --spacer_1 = DP_CustomFrames:Spacer(1, false),
      separator = {
        type = "description",
        order = 1,
        name = "",
      }
    }
  }
end

function DP_CustomConfig:CreateEntriesConfig(header, order, entries)
  local argEntries = {}
  local entryIndex = 1
  for title, value in pairs(entries) do
    argEntries["entryIndex" .. entryIndex] = {
      type = "description",
      order = entryIndex,
      width = 0.8,
      hidden = false,
      name = title
    }
    argEntries["entryValue" .. entryIndex] = {
      type = "description",
      order = entryIndex + 0.1,
      width = 1,
      hidden = false,
      name = function()
        return DP_CustomColors:Colorize(DP_CustomColors:CustomColors("NAME"), tostring(value))
      end
    }
    entryIndex = entryIndex + 1
  end

  return {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = argEntries
  }
end

---Create key dropdown config
function DP_CustomConfig:KeyDownDropdownConfig()
  return {
    ["1_none"] = DisenchanterPlus:DP_i18n("None"),
    ["2_alt"] = DisenchanterPlus:DP_i18n("Alt"),
    ["3_shift"] = DisenchanterPlus:DP_i18n("Shift"),
    ["4_control"] = DisenchanterPlus:DP_i18n("Control"),
    ["5_altShift"] = DisenchanterPlus:DP_i18n("Alt + Shift"),
    ["6_altControl"] = DisenchanterPlus:DP_i18n("Alt + Control"),
    ["7_altShiftControl"] = DisenchanterPlus:DP_i18n("Alt + Shift + Control"),
    ["8_shiftControl"] = DisenchanterPlus:DP_i18n("Shift + Control"),
  }
end
