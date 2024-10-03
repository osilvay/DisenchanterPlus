---@class DP_DisenchantGroup
local DP_DisenchantGroup = DP_ModuleLoader:CreateModule("DP_DisenchantGroup");

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---@type DP_CustomMedias
local DP_CustomMedias = DP_ModuleLoader:ImportModule("DP_CustomMedias")

---@type DP_CustomColors
local DP_CustomColors = DP_ModuleLoader:ImportModule("DP_CustomColors")

---@type DP_CustomFunctions
local DP_CustomFunctions = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_DisenchantProcess
local DP_DisenchantProcess = DP_ModuleLoader:ImportModule("DP_DisenchantProcess")

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local currentPermanentIgnoreList = {}
local currentSessionIgnoreList = {}

---Header
---@param order? number
---@return table
function DP_DisenchantGroup:Header(order)
  return DP_CustomConfig:CreateHeaderConfig(DisenchanterPlus:DP_i18n("Disenchant"), order or 1, DisenchanterPlus:GetAddonColor())
end

---Config
---@param order? number
---@return table
function DP_DisenchantGroup:Config(order)
  return {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      autoDisenchantEnabled = {
        type = "toggle",
        order = 1,
        name = DisenchanterPlus:DP_i18n("Enable"),
        desc = DisenchanterPlus:DP_i18n("Enable auto disenchant items."),
        width = "full",
        disabled = false,
        get = function()
          return DisenchanterPlus.db.char.general.autoDisenchantEnabled
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.autoDisenchantEnabled = value
          if value then
            C_Timer.After(0.1, function()
              DP_DisenchantProcess:StartAutoDisenchant()
            end)
          else
            C_Timer.After(0.1, function()
              DP_DisenchantProcess:CancelAutoDisenchant()
            end)
          end
        end,
      },
      autoDisenchantDbTimeout = {
        type = "range",
        order = 2,
        name = DisenchanterPlus:DP_i18n("Auto disenchant update time"),
        desc = DisenchanterPlus:DP_i18n("Sets how often the auto disenchant is executed (in seconds)."),
        width = "full",
        min = 5,
        max = 30,
        step = 1,
        disabled = function() return (not DisenchanterPlus.db.char.general.autoDisenchantEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.autoDisenchantDbTimeout end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.autoDisenchantDbTimeout = value
          C_Timer.After(0.1, function()
            DP_DisenchantProcess:CancelAutoDisenchant(true)
          end)
          C_Timer.After(0.2, function()
            DP_DisenchantProcess:StartAutoDisenchant(true)
          end)
        end,
      },
      onlySoulbound = {
        type = "toggle",
        order = 3,
        name = DisenchanterPlus:DP_i18n("Only soulbound items"),
        desc = DisenchanterPlus:DP_i18n("Enable only disenchant soulbound items."),
        width = "full",
        disabled = function() return (not DisenchanterPlus.db.char.general.autoDisenchantEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.onlySoulbound end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.onlySoulbound = value
        end,
      },
      itemQuality = {
        type = "multiselect",
        order = 4,
        width = "full",
        name = DisenchanterPlus:DP_i18n("Item qualities"),
        desc = DisenchanterPlus:DP_i18n("Only disenchant these item qualities."),
        values = DP_DisenchantGroup:ItemQualityDropdownConfig(),
        disabled = function() return (not DisenchanterPlus.db.char.general.autoDisenchantEnabled); end,
        get = function(info, entry)
          return DisenchanterPlus.db.char.general[info[#info]][entry]
        end,
        set = function(info, entry, value)
          DisenchanterPlus.db.char.general[info[#info]][entry] = value
        end,
      },
      sessionIgnoredItems = {
        type = "select",
        order = 4.1,
        width = "full",
        name = DisenchanterPlus:DP_i18n("Remove from session ignore list"),
        values = function()
          --DisenchanterPlus:Dump(DP_DisenchantProcess:GetSessionIgnoredItems())
          DP_DisenchantGroup:CreateSessionIgnoreListItems(DP_DisenchantProcess:GetSessionIgnoredItems())
          return currentSessionIgnoreList or {}
        end,
        confirm = function(info, value)
          if value == "0" then return end
          return DisenchanterPlus:DP_i18n("Are you sure you want to remove this ignored item?") .. "\n\n" .. currentSessionIgnoreList[value] ..
              "\n\n|cffff3300" .. DisenchanterPlus:DP_i18n("This operation can not be undone...") .. "|r"
        end,
        disabled = function() return (not DisenchanterPlus.db.char.general.autoDisenchantEnabled); end,
        get = function()
          DP_DisenchantGroup:CreateSessionIgnoreListItems(DP_DisenchantProcess:GetSessionIgnoredItems())
          return DisenchanterPlus.db.char.general.sessionIgnoredItems
        end,
        set = function(info, value)
          if currentSessionIgnoreList[value] == nil or value == "0" then return end
          DP_DisenchantGroup:RemoveSessionIgnoreListItem(value)
        end,
      },
      permanentIgnoredItems = {
        type = "select",
        order = 4.2,
        width = "full",
        name = "|cffff9900" .. DisenchanterPlus:DP_i18n("Remove from permanent ignore list") .. "|r",
        values = function()
          return DP_DisenchantGroup:CreatePermanentIgnoreListItems() or {}
        end,
        confirm = function(info, value)
          if value == "0" then return end
          return DisenchanterPlus:DP_i18n("Are you sure you want to remove this ignored item?") .. "\n\n" .. currentPermanentIgnoreList[value] ..
              "\n\n|cffff3300" .. DisenchanterPlus:DP_i18n("This operation can not be undone...") .. "|r"
        end,
        disabled = function() return (not DisenchanterPlus.db.char.general.autoDisenchantEnabled); end,
        get = function() return DisenchanterPlus.db.char.general.permanentIgnoredItems end,
        set = function(info, value)
          if currentPermanentIgnoreList[value] == nil or value == "0" then return end
          DP_DisenchantGroup:RemovePermanentIgnoreListItem(value)
        end,
      },
      clearSessionIgnoredItems = {
        type = "execute",
        order = 5.1,
        name = DP_CustomMedias:GetIconFileAsLink("clean_list1_a", 16, 16) .. " " .. DisenchanterPlus:DP_i18n("Clear"),
        desc = DisenchanterPlus:DP_i18n("Clear the ignore list of this session."),
        width = 1,
        disabled = function() return (not DisenchanterPlus.db.char.general.autoDisenchantEnabled); end,
        func = function()
          DP_DisenchantProcess:EmptySessionIgnoredItemsList()
        end,
      },
    }
  }
end

---Item quality dropdown
function DP_DisenchantGroup:ItemQualityDropdownConfig()
  return {
    ["2"] = "|c" .. DP_CustomColors:CustomQualityColors(2) .. DisenchanterPlus:DP_i18n("Uncommon") .. "|r",
    ["3"] = "|c" .. DP_CustomColors:CustomQualityColors(3) .. DisenchanterPlus:DP_i18n("Rare") .. "|r",
    ["4"] = "|c" .. DP_CustomColors:CustomQualityColors(4) .. DisenchanterPlus:DP_i18n("Epic") .. "|r",
  }
end

---Create session ignore list
function DP_DisenchantGroup:CreateSessionIgnoreListItems(ignoreList)
  currentSessionIgnoreList = {}
  --DisenchanterPlus:Dump(ignoreList)
  if DP_CustomFunctions:TableIsEmpty(ignoreList) then
    currentSessionIgnoreList["0"] = string.format("|cffff3300%s|r", DisenchanterPlus:DP_i18n("Nothing hidden"))
  else
    for _, itemID in pairs(ignoreList) do
      --DisenchanterPlus:Debug("ItemID = " .. itemID)
      local itemName, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
      currentSessionIgnoreList[itemID] = string.format("|T%d:0|t %s", itemIcon or 134400, itemLink or itemName or UNKNOWN)
    end
    --DisenchanterPlus:Dump(currentSessionIgnoreList)
  end
  --AceConfigDialog:SelectGroup("DisenchanterPlus", "advanced_tab")
  --AceConfigRegistry:NotifyChange("DisenchanterPlus")
  DisenchanterPlus.db.char.general.sessionIgnoredItems = currentSessionIgnoreList
end

---Create permanent ignore list
function DP_DisenchantGroup:CreatePermanentIgnoreListItems()
  local r = {}
  local ignoreList = DisenchanterPlus.db.char.general.permanentIgnoredItems or {}
  if DP_CustomFunctions:TableIsEmpty(ignoreList) then
    r["0"] = string.format("|cffff3300%s|r", DisenchanterPlus:DP_i18n("Nothing hidden"))
  else
    for _, itemID in pairs(ignoreList) do
      local itemName, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
      r[itemID] = string.format("|T%d:0|t %s", itemIcon or 134400, itemLink or itemName or UNKNOWN)
    end
  end
  return r
end

---Remove item from permamant ignore list
---@param itemID any
function DP_DisenchantGroup:RemoveSessionIgnoreListItem(itemID)
  local ignoreList = currentSessionIgnoreList or {}
  local newIgnoreList = {}
  DisenchanterPlus:Debug("ItemID to remove = " .. itemID)
  for currentItemID, _ in pairs(ignoreList) do
    if currentItemID ~= itemID then
      DisenchanterPlus:Debug("ItemID to include = " .. currentItemID)
      table.insert(newIgnoreList, currentItemID)
    end
  end
  DP_DisenchantProcess:UpdateSessionIgnoredItems(newIgnoreList)
  DP_DisenchantGroup:CreateSessionIgnoreListItems(newIgnoreList)
end

---Remove item from permamant ignore list
---@param itemID any
function DP_DisenchantGroup:RemovePermanentIgnoreListItem(itemID)
  local ignoreList = DisenchanterPlus.db.char.general.permanentIgnoredItems or {}
  local newIgnoreList = {}
  for _, currentItemID in pairs(ignoreList) do
    if currentItemID ~= itemID then
      table.insert(newIgnoreList, currentItemID)
    end
  end
  DisenchanterPlus.db.char.general.permanentIgnoredItems = newIgnoreList
  DP_DisenchantGroup:CreatePermanentIgnoreListItems()
end

---Get session ignore item list
---@return table
function DP_DisenchantGroup:GetSessionIgnoreListItem()
  return currentSessionIgnoreList
end
