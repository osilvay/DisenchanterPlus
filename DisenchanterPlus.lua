---@type DP_SettingsDefaults
local DP_SettingsDefaults = DP_ModuleLoader:ImportModule("DP_SettingsDefaults")

---@type DP_EventHandler
local DP_EventHandler = DP_ModuleLoader:ImportModule("DP_EventHandler");

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

local L = LibStub("AceLocale-3.0"):GetLocale("DisenchanterPlus")

DisenchanterPlus.DEBUG_CRITICAL = "|cff00f2e6[CRITICAL]|r"
DisenchanterPlus.DEBUG_ELEVATED = "|cffebf441[ELEVATED]|r"
DisenchanterPlus.DEBUG_INFO = "|cff00bc32[INFO]|r"
DisenchanterPlus.DEBUG_DEVELOP = "|cff7c83ff[DEVELOP]|r"
DisenchanterPlus.DEBUG_SPAM = "|cffff8484[SPAM]|r"
local AddonColor = "ffed6bff"
local AddonVersion = "1.0.1"

function DisenchanterPlus:OnInitialize()
  DisenchanterPlus.db = LibStub("AceDB-3.0"):New("DisenchanterPlusDB", DP_SettingsDefaults:Load(), true)
  DisenchanterPlus.key = UnitName("player") .. " - " .. GetRealmName()
  DisenchanterPlus.started = false
  DP_EventHandler:RegisterEarlyEvents()
end

---On enable addon
function DisenchanterPlus:OnEnable()
end

---Error message
function DisenchanterPlus:Error(message)
  DisenchanterPlus:Print("|cfffc8686[ERROR]|r " .. message)
end

---Warning message
function DisenchanterPlus:Warning(message)
  if DisenchanterPlus:IsDebugEnabled() then
    DisenchanterPlus:Print("|cfffcb986[WARNING]|r " .. message)
  end
end

---Info message
function DisenchanterPlus:Info(message)
  if DisenchanterPlus:IsDebugEnabled() then
    DisenchanterPlus:Print("|cff86f0fc[INFO]|r " .. message)
  end
end

---Debug message
function DisenchanterPlus:Debug(message)
  if DisenchanterPlus:IsDebugEnabled() then
    if message == nil then message = 'nil' end
    DisenchanterPlus:Print("|cfffcfc86[DEBUG]|r " .. message)
  end
end

---Log message
function DisenchanterPlus:Log(message)
  if DisenchanterPlus:IsDebugEnabled() then
    DisenchanterPlus:Print("|cffa1a1a1[LOG]|r " .. message)
  end
end

---Log message
function DisenchanterPlus:Time(message)
  if DisenchanterPlus:IsDebugEnabled() then
    DisenchanterPlus:Print(string.format("|cffb2fc86[TIME]|r %d : %s ", GetServerTime(), message))
  end
end

---Dump message
function DisenchanterPlus:Dump(message)
  if DisenchanterPlus:IsDebugEnabled() then
    if message == nil then
      DisenchanterPlus:Print("|cffb3b2b8[DUMP]|r nil")
    end
    DisenchanterPlus:Print("|cffb3b2b8[DUMP]|r " .. DP_CustomFunctions:Dump(message))
  end
end

---Check debug enabled
function DisenchanterPlus:IsDebugEnabled()
  if DisenchanterPlus.db.char.advanced.debug == nil then
    return false
  end
  return DisenchanterPlus.db.char.advanced.debug
end

---@param message string
---@return string string
function DisenchanterPlus:DP_i18n(message)
  return tostring(L[message])
end

---Prints message
---@param message string
function DisenchanterPlus:Print(message)
  print(string.format("|cffe1e1f1Disenchanter|r |c%sPlus|r: |cffe1d1d1%s|r", DisenchanterPlus:GetAddonColor(), message))
end

local cachedTitle
---Get addon version info
function DisenchanterPlus:GetAddonVersionInfo()
  if (not cachedTitle) then
    local _, title, _, _, _ = C_AddOns.GetAddOnInfo("DisenchanterPlus")
    cachedTitle = title
  end
  -- %d = digit, %p = punctuation character, %x = hexadecimal digits.
  local major, minor, patch, _ = string.match(cachedTitle, "(%d+)%p(%d+)%p(%d+)")
  return tonumber(major), tonumber(minor), tonumber(patch)
end

---Get addon version string
function DisenchanterPlus:GetAddonVersionString()
  local major, minor, patch = DisenchanterPlus:GetAddonVersionInfo()
  return "v" .. tostring(major) .. "." .. tostring(minor) .. "." .. tostring(patch)
end

---Return addon colored
---@param message? string
function DisenchanterPlus:MessageWithAddonColor(message)
  if message == nil then
    return AddonColor
  else
    return string.format("|c%s%s|r", AddonColor, message)
  end
end

---Gets addon color
function DisenchanterPlus:GetAddonColor()
  return AddonColor
end

function DisenchanterPlus:GetAddonVersion()
  return AddonVersion
end

function DisenchanterPlus:GetAddonColoredVersion()
  return string.format("|cff9191a1v%s|r", AddonVersion)
end

function DisenchanterPlus:GetAddonColoredName()
  return string.format("|cffe1e1e1Disenchanter|r |c%sPlus|r", DisenchanterPlus:GetAddonColor())
end
