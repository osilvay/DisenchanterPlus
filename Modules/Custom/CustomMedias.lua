---@class DP_CustomMedias
local DP_CustomMedias = DP_ModuleLoader:CreateModule("DP_CustomMedias")

local disenchanterPlusIcons
local disenchanterPlusMedias

disenchanterPlusIcons = {
  ["accept"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/accept",
  ["accept_a"]      = "Interface/AddOns/DisenchanterPlus/Images/Icons/accept_a",
  ["back"]          = "Interface/AddOns/DisenchanterPlus/Images/Icons/back",
  ["back_a"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/back_a",
  ["cleanup"]       = "Interface/AddOns/DisenchanterPlus/Images/Icons/cleanup",
  ["cleanup_a"]     = "Interface/AddOns/DisenchanterPlus/Images/Icons/cleanup_a",
  ["close"]         = "Interface/AddOns/DisenchanterPlus/Images/Icons/close",
  ["close_a"]       = "Interface/AddOns/DisenchanterPlus/Images/Icons/close_a",
  ["cancel"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/cancel",
  ["cancel_a"]      = "Interface/AddOns/DisenchanterPlus/Images/Icons/cancel_a",
  ["cancel1"]       = "Interface/AddOns/DisenchanterPlus/Images/Icons/cancel1",
  ["cancel1_a"]     = "Interface/AddOns/DisenchanterPlus/Images/Icons/cancel1_a",
  ["color"]         = "Interface/AddOns/DisenchanterPlus/Images/Icons/color",
  ["color_a"]       = "Interface/AddOns/DisenchanterPlus/Images/Icons/color_a",
  ["consolidate"]   = "Interface/AddOns/DisenchanterPlus/Images/Icons/consolidate",
  ["consolidate_a"] = "Interface/AddOns/DisenchanterPlus/Images/Icons/consolidate_a",
  ["copy"]          = "Interface/AddOns/DisenchanterPlus/Images/Icons/copy",
  ["copy_a"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/copy_a",
  ["cut"]           = "Interface/AddOns/DisenchanterPlus/Images/Icons/cut",
  ["cut_a"]         = "Interface/AddOns/DisenchanterPlus/Images/Icons/cut_a",
  ["delete"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/delete",
  ["delete_a"]      = "Interface/AddOns/DisenchanterPlus/Images/Icons/delete_a",
  ["edit"]          = "Interface/AddOns/DisenchanterPlus/Images/Icons/edit",
  ["edit_a"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/edit_a",
  ["exit"]          = "Interface/AddOns/DisenchanterPlus/Images/Icons/exit",
  ["exit_a"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/exit_a",
  ["lock"]          = "Interface/AddOns/DisenchanterPlus/Images/Icons/lock",
  ["lock_a"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/lock_a",
  ["minus"]         = "Interface/AddOns/DisenchanterPlus/Images/Icons/minus",
  ["minus_a"]       = "Interface/AddOns/DisenchanterPlus/Images/Icons/minus_a",
  ["paste"]         = "Interface/AddOns/DisenchanterPlus/Images/Icons/paste",
  ["paste_a"]       = "Interface/AddOns/DisenchanterPlus/Images/Icons/paste_a",
  ["play"]          = "Interface/AddOns/DisenchanterPlus/Images/Icons/play",
  ["play_a"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/play_a",
  ["plus"]          = "Interface/AddOns/DisenchanterPlus/Images/Icons/plus",
  ["plus_a"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/plus_a",
  ["purge"]         = "Interface/AddOns/DisenchanterPlus/Images/Icons/purge",
  ["purge_a"]       = "Interface/AddOns/DisenchanterPlus/Images/Icons/purge_a",
  ["settings"]      = "Interface/AddOns/DisenchanterPlus/Images/Icons/settings",
  ["settings_a"]    = "Interface/AddOns/DisenchanterPlus/Images/Icons/settings_a",
  ["update"]        = "Interface/AddOns/DisenchanterPlus/Images/Icons/update",
  ["update_a"]      = "Interface/AddOns/DisenchanterPlus/Images/Icons/update_a",
  ["clean_list1"]   = "Interface/AddOns/DisenchanterPlus/Images/Icons/clean_list1",
  ["clean_list1_a"] = "Interface/AddOns/DisenchanterPlus/Images/Icons/clean_list1_a",

}

disenchanterPlusMedias = {
  ["disenchanterplus"] = "Interface/AddOns/DisenchanterPlus/Images/Menus/disenchanterplus",
  ["disenchanterplus_a"] = "Interface/AddOns/DisenchanterPlus/Images/Menus/disenchanterplus",
  ["Alliance_icon"] = "Interface/AddOns/DisenchanterPlus/Images/Factions/icon_alliance",
  ["Horde_icon"] = "Interface/AddOns/DisenchanterPlus/Images/Factions/icon_horde",
  ["alliance_flag"] = "Interface/AddOns/DisenchanterPlus/Images/Factions/flag_alliance",
  ["horde_flag"] = "Interface/AddOns/DisenchanterPlus/Images/Factions/flag_horde",
}

---Return icon
---@param typeSelected string
---@return string file
function DP_CustomMedias:GetIconFile(typeSelected)
  if typeSelected == nil or disenchanterPlusIcons[typeSelected] == nil then return "" end
  return disenchanterPlusIcons[typeSelected]
end

---Get media
---@param typeSelected any
---@return string
function DP_CustomMedias:GetMediaFile(typeSelected)
  if typeSelected == nil or disenchanterPlusMedias[typeSelected] == nil then return "" end
  return disenchanterPlusMedias[typeSelected]
end

---Return icon as link
---@param typeSelected any
---@param sizeX any
---@param sizeY any
---@return string
function DP_CustomMedias:GetIconFileAsLink(typeSelected, sizeX, sizeY)
  if typeSelected == nil or disenchanterPlusIcons[typeSelected] == nil then return "" end
  return string.format("|T%s:%s:%s|t", disenchanterPlusIcons[typeSelected], tostring(sizeX), tostring(sizeY))
end

---Return media as link
---@param typeSelected any
---@param sizeX any
---@param sizeY any
---@return string
function DP_CustomMedias:GetMediaFileAsLink(typeSelected, sizeX, sizeY)
  if typeSelected == nil or disenchanterPlusMedias[typeSelected] == nil then return "" end
  return string.format("|T%s:%s:%s|t", disenchanterPlusMedias[typeSelected], tostring(sizeX), tostring(sizeY))
end
