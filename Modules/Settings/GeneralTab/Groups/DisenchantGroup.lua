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

---@type DP_MinimapIcon
local DP_MinimapIcon = DP_ModuleLoader:ImportModule("DP_MinimapIcon")

local AceConfigDialog = LibStub("AceConfigDialog-3.0")

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
        disabled = function() return DisenchanterPlus.db.char.general.disableAll end,
        get = function()
          return DisenchanterPlus.db.char.general.autoDisenchantEnabled
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.autoDisenchantEnabled = value
          if value then
            C_Timer.After(0.1, function()
              DP_DisenchantProcess:StartAutoDisenchant(false)
              DP_MinimapIcon:UpdateIcon(DP_CustomMedias:GetMediaFile("disenchanterplus_running"))
            end)
          else
            C_Timer.After(0.1, function()
              DP_DisenchantProcess:CancelAutoDisenchant(false)
              DP_MinimapIcon:UpdateIcon(DP_CustomMedias:GetMediaFile("disenchanterplus_paused"))
            end)
          end
        end,
      },
      separator_1 = DP_CustomConfig:CreateSeparatorConfig(1.1),
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
      clearSessionIgnoredItems = {
        type = "execute",
        order = 6,
        name = DP_CustomMedias:GetIconFileAsLink("clean_list1_a", 16, 16) .. " " .. DisenchanterPlus:DP_i18n("Clean session list"),
        desc = DisenchanterPlus:DP_i18n("Clear the ignore list of this session."),
        width = "full",
        disabled = function() return (not DisenchanterPlus.db.char.general.autoDisenchantEnabled); end,
        func = function()
          DP_DisenchantProcess:EmptySessionIgnoredItemsList()
          DisenchanterPlus:Info(DisenchanterPlus:DP_i18n("Items in session list cleared."))
        end,
      },
      clearPermanentIgnoredItems = {
        type = "execute",
        order = 7,
        name = DP_CustomMedias:GetIconFileAsLink("cleanup_a", 16, 16) .. " " .. DisenchanterPlus:DP_i18n("Clean permanent list"),
        desc = DisenchanterPlus:DP_i18n("Clear the permanent ignore list."),
        width = "full",
        disabled = function() return (not DisenchanterPlus.db.char.general.autoDisenchantEnabled); end,
        func = function()
          DP_DisenchantProcess:EmptyPermanentIgnoredItemsList()
          DisenchanterPlus:Info(DisenchanterPlus:DP_i18n("Items in permanent ignore list cleared."))
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
function DP_DisenchantGroup:CreateSessionIgnoreListItems(sessionIgnoreList)
  local newSessionIgnoreList = {}
  --DisenchanterPlus:Dump(ignoreList)
  if DP_CustomFunctions:TableIsEmpty(sessionIgnoreList) then
    --sessionIgnoreList["0"] = string.format("|cffff3300%s|r", DisenchanterPlus:DP_i18n("Nothing hidden"))
  else
    for itemID, _ in pairs(sessionIgnoreList) do
      --DisenchanterPlus:Debug("ItemID = " .. itemID)
      local itemName, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
      newSessionIgnoreList[tostring(itemID)] = string.format("|T%d:0|t %s", itemIcon or 134400, itemLink or itemName or UNKNOWN)
    end
    --DisenchanterPlus:Dump(currentSessionIgnoreList)
  end
  AceConfigRegistry:NotifyChange("DisenchanterPlus")
  DP_DisenchantGroup:SaveSessionIgnoreList(newSessionIgnoreList)
end

---Create permanent ignore list
function DP_DisenchantGroup:CreatePermanentIgnoreListItems()
  local permanentIgnoreList = DP_DisenchantGroup:GetPermanentIgnoreList() or {}
  if DP_CustomFunctions:TableIsEmpty(permanentIgnoreList) then
    --permanentIgnoreList["0"] = string.format("|cffff3300%s|r", DisenchanterPlus:DP_i18n("Nothing hidden"))
  else
    for itemID, _ in pairs(permanentIgnoreList) do
      local itemName, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = C_Item.GetItemInfo(itemID)
      permanentIgnoreList[tostring(itemID)] = string.format("|T%d:0|t %s", itemIcon or 134400, itemLink or itemName or UNKNOWN)
    end
  end
  AceConfigRegistry:NotifyChange("DisenchanterPlus")
  DP_DisenchantGroup:SavePermanentIgnoreList(permanentIgnoreList)
end

---Remove item from permamant ignore list
---@param itemID string
function DP_DisenchantGroup:RemoveSessionIgnoreListItem(itemID)
  local ignoreList = DP_DisenchantGroup:GetSessionIgnoreList() or {}
  local newIgnoreList = {}
  --DisenchanterPlus:Debug("ItemID to remove = " .. itemID)
  for currentItemID, currentItemLink in pairs(ignoreList) do
    if currentItemID ~= itemID then
      --DisenchanterPlus:Debug("ItemID to include = " .. currentItemID)
      newIgnoreList[tostring(currentItemID)] = currentItemLink
    end
  end
  DP_DisenchantGroup:CreateSessionIgnoreListItems(newIgnoreList)
end

---Remove item from permamant ignore list
---@param itemID string
function DP_DisenchantGroup:RemovePermanentIgnoreListItem(itemID)
  local permanentIgnoreList = DP_DisenchantGroup:GetPermanentIgnoreList() or {}
  local newPermanentIgnoreList = {}
  for currentItemID, currentItemLink in pairs(permanentIgnoreList) do
    if currentItemID ~= itemID then
      newPermanentIgnoreList[tostring(currentItemID)] = currentItemLink
    end
  end
  DP_DisenchantGroup:SavePermanentIgnoreList(newPermanentIgnoreList)
  DP_DisenchantGroup:CreatePermanentIgnoreListItems()
end

---Get session ignore item list
---@return table
function DP_DisenchantGroup:GetSessionIgnoreList()
  return DisenchanterPlus.db.char.general.sessionIgnoredItems
end

function DP_DisenchantGroup:GetPermanentIgnoreList()
  return DisenchanterPlus.db.char.general.permanentIgnoredItems
end

function DP_DisenchantGroup:SaveSessionIgnoreList(sessionIgnoreList)
  sessionIgnoreList["0"] = nil
  DisenchanterPlus.db.char.general.sessionIgnoredItems = sessionIgnoreList
end

function DP_DisenchantGroup:SavePermanentIgnoreList(permanentIgnoreList)
  permanentIgnoreList["0"] = nil
  DisenchanterPlus.db.char.general.permanentIgnoredItems = permanentIgnoreList
end
