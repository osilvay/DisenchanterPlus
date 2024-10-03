---@class DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:CreateModule("DP_CustomColors")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---Custom class colors
---@param color_index string
---@return string colorized_string
function DP_CustomColors:CustomClassColors(color_index)
  local customClassColors = {
    UNKNOWN = "FF919191",
    DRUID = "FFFF7C0A",
    HUNTER = "FFAAD372",
    MAGE = "FF3FC7EB",
    PALADIN = "FFF48CBA",
    PRIEST = "FFFFFFFF",
    ROGUE = "FFFFF468",
    SHAMAN = "FF0070DD",
    WARLOCK = "FF8788EE",
    WARRIOR = "FFC69B6D",
    DEATHKNIGHT = "FFC41E3A",
    EVOKER = "FF33937F",
    MONK = "ff00FF96",
    DEMONHUNTER = "FFA330C9"
  };
  return customClassColors[color_index]
end

---Custom bright colors
---@param color_index string
---@return string
function DP_CustomColors:CustomClassBrightColors(color_index)
  local customClassColors = {
    DRUID = "FFF88A2A",
    HUNTER = "FFB7D78B",
    MAGE = "FF5ECCEA",
    PALADIN = "FFF8AACD",
    PRIEST = "FFFFFFFF",
    ROGUE = "FFFFF783",
    SHAMAN = "FF1C7DDD",
    WARLOCK = "FFA3A5F5",
    WARRIOR = "FFCFB192",
    DEATHKNIGHT = "FFCE354E",
    EVOKER = "FF4AA291",
    MONK = "FF60FABA",
    DEMONHUNTER = "FFB848DD"
  };
  return customClassColors[color_index]
end

---Custom quality colors
---@param quality_index number
---@return string color
function DP_CustomColors:CustomQualityColors(quality_index)
  local customQualityColors = {
    [0] = "ff9D9D9D",
    [1] = "ffffffff",
    [2] = "ff1EFF00",
    [3] = "ff0070FF",
    [4] = "ffa335ee",
    [5] = "ffff8000",
    [6] = "ffE6CC80",
    [7] = "ffE6CC80",
    [8] = "ff00CCFF"
  };
  return customQualityColors[quality_index]
end

---Custom class colors
---@param color_index string
---@return string colorized_string
function DP_CustomColors:CustomFactionColors(color_index)
  local customFactionColors = {
    HORDE = "FFc74040",
    ALLIANCE = "FF00d1ff",
  };
  return customFactionColors[color_index]
end

---Custom colors
---@param color_index string
---@return string colorized_string
function DP_CustomColors:CustomColors(color_index)
  local customColors = {
    NAME = "FFFFF311",
    LEVEL = "FFFF9811",
    VALUE_LOW = "FF64e464",
    VALUE_MEDIUM = "ffe4a436",
    VALUE_HIGH = "ffe43434",
    VALUE_LOW_DEC = "FF459E45",
    VALUE_MEDIUM_DEC = "FFA3772A",
    VALUE_HIGH_DEC = "FF9F2323",
    UNDEFINED = "ffa1a1a1",
    UNDEFINED_DEC = "ff666666",
    ZERO = "FF991E15",
    SPELLID = "fff1f1f1",
    TEXT_VALUE = "FFc0c0c0",
    HIGHLIGHTED = "ffffcc00",
    DEFAULT_VALUE = "ffffcc00",
    ROWID = "FF91c1f1",
    ENABLED = "FF20E002",
    DISABLED = "FFE02000",
    EMPTY = "ff616191",
  };
  return customColors[color_index]
end

---Color by unit classification
---@param color_index string
---@return string
function DP_CustomColors:CustomUnitClassificationColors(color_index)
  local customUnitClassificationColors = {
    rare = "FF926BC9",
    rareelite = "FFA967BD",
    boss = "FFCA435E",
    worldboss = "FFCE885C",
    elite = "FFDB7AC0",
    normal = "FF84C19E"
  };
  return customUnitClassificationColors[color_index]
end

function DP_CustomColors:CustomTradeskillColors(color_index)
  local customTradeskillColors = {
    Enchanting = "FFBC78D7",
    Herbalism = "FF91C677",
    Skinning = "FFD69D7C",
    Mining = "FFD14E68",
    Fishing = "FF8AA5DF",
    Archaeology = "FFD6C97C",
  };
  return customTradeskillColors[color_index]
end

---Converts hex to rgb
---@param hex string
---@param normalized boolean
---@return table rgb
function DP_CustomColors:HexToRgb(hex, normalized)
  local result = {}
  hex = hex:gsub("#", "")
  local a = tonumber("0x" .. hex:sub(1, 2)) or 0
  local r = tonumber("0x" .. hex:sub(3, 4)) or 0
  local g = tonumber("0x" .. hex:sub(5, 6)) or 0
  local b = tonumber("0x" .. hex:sub(7, 8)) or 0
  if normalized then
    result = { r = tonumber(string.format("%.3f", r / 255)), g = tonumber(string.format("%.3f", g / 255)), b = tonumber(string.format("%.3f", b / 255)), a = tonumber(string.format("%.3f", a / 255)) }
  else
    result = { r = r, g = g, b = b, a = a }
  end
  return result
end

function DP_CustomColors:RgbToHex(rgbTable, default)
  if rgbTable == nil or rgbTable.red == nil or rgbTable.green == nil or rgbTable.blue == nil then
    local defaultColor = DP_CustomColors:HexToRgb(default, true)
    rgbTable = {
      red = defaultColor.r,
      green = defaultColor.g,
      blue = defaultColor.b,
      alpha = defaultColor.a,
    }
  end
  local r = rgbTable.red
  local g = rgbTable.green
  local b = rgbTable.blue
  local a = rgbTable.alpha
  local hex = string.format("ff%s%s%s", string.format("%x", (r * 255 * 0x1)), string.format("%x", (g * 255 * 0x1)), string.format("%x", (b * 255 * 0x1)))
  return hex
end

---Text colored by class
---@param className string
---@param classFilename string
---@return string colored_class
function DP_CustomColors:GetColoredClass(className, classFilename)
  --DisenchanterPlus:Debug("Class : " .. tostring(className) .. " " .. tostring(classFilename))
  if not class or not message then return "" end
  return "|c" .. DP_CustomColors:CustomClassColors(classFilename) .. className .. "|r"
end

---Text colored by name
---@param message string
---@return string colored_name
function DP_CustomColors:GetColoredName(message)
  if not message then return "" end
  return "|c" .. DP_CustomColors:CustomColors("NAME") .. message .. "|r"
end

---Text colored by level
---@param message string
---@return string colored_level
function DP_CustomColors:GetColoredLevel(message)
  if not message then return "" end
  return "|c" .. DP_CustomColors:CustomColors("LEVEL") .. message .. "|r"
end

---Text colored by faction
---@param faction string
---@param factionName string
---@return string colored_faction
function DP_CustomColors:GetColoredFaction(faction, factionName)
  if not faction or not factionName then return "" end
  local horde_color = DP_CustomColors:CustomFactionColors("HORDE")
  local alliance_color = DP_CustomColors:CustomFactionColors("ALLIANCE")
  local other_color = DP_CustomColors:CustomColors("UNDEFINED")
  local colored_faction = ""
  if factionName == "Alliance" then
    colored_faction = "|c" .. alliance_color .. faction .. "|r"
  elseif factionName == "Horde" then
    colored_faction = "|c" .. horde_color .. faction .. "|r"
  else
    colored_faction = "|c" .. other_color .. faction .. "|r"
  end
  return colored_faction
end

---Colorize string
---@param color string
---@param message string
---@return string colorized_string
function DP_CustomColors:Colorize(color, message)
  if not color or not message then return "" end
  return string.format("|c%s%s|r", color, message)
end

---Colorize by value
---@param message string
---@param value number
---@param maxValue number
---@return string message
function DP_CustomColors:ColorizeByValue(message, value, maxValue)
  local indexValue = tonumber(format("%.2f", maxValue / 3))
  if value < indexValue then
    return DP_CustomColors:Colorize(DP_CustomColors:CustomColors("VALUE_LOW"), message)
  elseif value >= indexValue and value < indexValue * 2 then
    return DP_CustomColors:Colorize(DP_CustomColors:CustomColors("VALUE_MEDIUM"), message)
  elseif value >= indexValue * 2 then
    return DP_CustomColors:Colorize(DP_CustomColors:CustomColors("VALUE_HIGH"), message)
  else
    return DP_CustomColors:Colorize(DP_CustomColors:CustomColors("UNDEFINED"), message)
  end
end

function DP_CustomColors:ColorizeDecimal(textValue, color1, color2)
  local percentageValues = {}
  local percentageIndex = 1
  for value in string.gmatch(textValue, "([^.]+)") do
    percentageValues[percentageIndex] = value
    percentageIndex = percentageIndex + 1
  end

  local separator = "|cffc1c1c1.|r"
  if percentageValues[2] == nil then separator = "" end
  return string.format("|c%s%s|r%s|c%s%s|r", color1, percentageValues[1], separator, color2, percentageValues[2] or "")
end
