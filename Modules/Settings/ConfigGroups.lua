---@class DP_ConfigGroups
local DP_ConfigGroups = DP_ModuleLoader:CreateModule("DP_ConfigGroups");

---@type DP_AdvancedGroup
local DP_AdvancedGroup = DP_ModuleLoader:ImportModule("DP_AdvancedGroup")

---@type DP_GeneralGroup
local DP_GeneralGroup = DP_ModuleLoader:ImportModule("DP_GeneralGroup")

---@type DP_DatabaseGroup
local DP_DatabaseGroup = DP_ModuleLoader:ImportModule("DP_DatabaseGroup")

---@type DP_TooltipGroup
local DP_TooltipGroup = DP_ModuleLoader:ImportModule("DP_TooltipGroup")

---@type DP_DisenchantGroup
local DP_DisenchantGroup = DP_ModuleLoader:ImportModule("DP_DisenchantGroup")

---Get
---@param key string
---@param method string
---@param order? number
---@return function|table
function DP_ConfigGroups:Get(key, method, order)
  if key == "advanced" then
    return DP_ConfigGroups:Method(DP_AdvancedGroup, method, order)
  elseif key == "general" then
    return DP_ConfigGroups:Method(DP_GeneralGroup, method, order)
  elseif key == "database" then
    return DP_ConfigGroups:Method(DP_DatabaseGroup, method, order)
  elseif key == "tooltips" then
    return DP_ConfigGroups:Method(DP_TooltipGroup, method, order)
  elseif key == "disenchant" then
    return DP_ConfigGroups:Method(DP_DisenchantGroup, method, order)
  end
  return {}
end

---Get method
---@param class any
---@param method string
---@param order? number
---@return function|table
function DP_ConfigGroups:Method(class, method, order)
  if method == "header" then
    return class:Header(order)
  elseif method == "config" then
    return class:Config(order)
  end
  return {}
end
