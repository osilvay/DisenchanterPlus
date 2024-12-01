---@class DP_KeybindingGroup
local DP_KeybindingGroup = DP_ModuleLoader:CreateModule("DP_KeybindingGroup");

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---Header
---@param order? number
---@return table
function DP_KeybindingGroup:Header(order)
  return DP_CustomConfig:CreateHeaderConfig(DisenchanterPlus:DP_i18n("Keybinding"), order or 1, DisenchanterPlus:GetAddonColor())
end

---Config
---@param order? number
---@return table
function DP_KeybindingGroup:Config(order)
  return {
    type = "group",
    order = order,
    inline = true,
    name = "",
    args = {
      keybindingEnabled = {
        type = "toggle",
        order = 1,
        name = DisenchanterPlus:DP_i18n("Enable"),
        desc = DisenchanterPlus:DP_i18n("Enable use keybinding."),
        width = "full",
        disabled = function() return DisenchanterPlus.db.char.general.disableAll end,
        get = function()
          return DisenchanterPlus.db.char.general.keybindingEnabled
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.keybindingEnabled = value
        end,
      },
      acceptDisenchant = {
        type = "keybinding",
        order = 2,
        name = DisenchanterPlus:DP_i18n("Accept disenchant"),
        desc = DisenchanterPlus:DP_i18n("Accept current item disenchant"),
        width = "full",
        disabled = function() return not DisenchanterPlus.db.char.general.keybindingEnabled end,
        get = function(info)
          return DisenchanterPlus.db.char.general.acceptDisenchant
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.acceptDisenchant = value
          local oldAction = GetBindingAction(value)
          if (oldAction ~= "" and oldAction ~= "DISENCHANTER_PLUS_ACCEPT_DISENCHANT") then
            DisenchanterPlus:Print(string.format(DisenchanterPlus:DP_i18n("Action |cffff3300%s|r is no longer assigned."), GetBindingText(value, "BINDING_NAME_")))
          else
            DisenchanterPlus:Print(DisenchanterPlus:DP_i18n("Keyboard configured correctly."))
          end
          SetBinding(value, "DISENCHANTER_PLUS_ACCEPT_DISENCHANT")
          SaveBindings(GetCurrentBindingSet())
        end,
      },
    }
  }
end
