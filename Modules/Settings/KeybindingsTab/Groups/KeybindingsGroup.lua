---@class DP_KeybindingsGroup
local DP_KeybindingsGroup = DP_ModuleLoader:CreateModule("DP_KeybindingsGroup");

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---@type DP_DisenchantWindow
local DP_DisenchantWindow = DP_ModuleLoader:ImportModule("DP_DisenchantWindow")

---@type DP_EnchantWindow
local DP_EnchantWindow = DP_ModuleLoader:ImportModule("DP_EnchantWindow")

---Header
---@param order? number
---@return table
function DP_KeybindingsGroup:Header(order)
  return DP_CustomConfig:CreateHeaderConfig(DisenchanterPlus:DP_i18n("Keybinding"), order or 1, DisenchanterPlus:GetAddonColor())
end

---Config
---@param order? number
---@return table
function DP_KeybindingsGroup:Config(order)
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
        desc = DisenchanterPlus:DP_i18n("Accept current item disenchant."),
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
          DP_DisenchantWindow:UpdateKeybindings()
        end,
      },
      cancelDisenchant = {
        type = "keybinding",
        order = 3,
        name = DisenchanterPlus:DP_i18n("Cancel disenchant"),
        desc = DisenchanterPlus:DP_i18n("Ignore this item during this session."),
        width = "full",
        disabled = function() return not DisenchanterPlus.db.char.general.keybindingEnabled end,
        get = function(info)
          return DisenchanterPlus.db.char.general.cancelDisenchant
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.cancelDisenchant = value
          local oldAction = GetBindingAction(value)
          if (oldAction ~= "" and oldAction ~= "DISENCHANTER_PLUS_CANCEL_DISENCHANT") then
            DisenchanterPlus:Print(string.format(DisenchanterPlus:DP_i18n("Action |cffff3300%s|r is no longer assigned."), GetBindingText(value, "BINDING_NAME_")))
          else
            DisenchanterPlus:Print(DisenchanterPlus:DP_i18n("Keyboard configured correctly."))
          end
          SetBinding(value, "DISENCHANTER_PLUS_CANCEL_DISENCHANT")
          SaveBindings(GetCurrentBindingSet())
          DP_DisenchantWindow:UpdateKeybindings()
        end,
      },
      ignoreDisenchant = {
        type = "keybinding",
        order = 4,
        name = DisenchanterPlus:DP_i18n("Ignore item"),
        desc = DisenchanterPlus:DP_i18n("Ignore this item permanently."),
        width = "full",
        disabled = function() return not DisenchanterPlus.db.char.general.keybindingEnabled end,
        get = function(info)
          return DisenchanterPlus.db.char.general.ignoreDisenchant
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.ignoreDisenchant = value
          local oldAction = GetBindingAction(value)
          if (oldAction ~= "" and oldAction ~= "DISENCHANTER_PLUS_IGNORE_DISENCHANT") then
            DisenchanterPlus:Print(string.format(DisenchanterPlus:DP_i18n("Action |cffff3300%s|r is no longer assigned."), GetBindingText(value, "BINDING_NAME_")))
          else
            DisenchanterPlus:Print(DisenchanterPlus:DP_i18n("Keyboard configured correctly."))
          end
          SetBinding(value, "DISENCHANTER_PLUS_IGNORE_DISENCHANT")
          SaveBindings(GetCurrentBindingSet())
          DP_DisenchantWindow:UpdateKeybindings()
        end,
      },
      confirmEnchant = {
        type = "keybinding",
        order = 5,
        name = DisenchanterPlus:DP_i18n("Confirm enchant"),
        desc = DisenchanterPlus:DP_i18n("Confirm enchant in selected item."),
        width = "full",
        disabled = function() return not DisenchanterPlus.db.char.general.keybindingEnabled end,
        get = function(info)
          return DisenchanterPlus.db.char.general.confirmEnchant
        end,
        set = function(info, value)
          DisenchanterPlus.db.char.general.confirmEnchant = value
          local oldAction = GetBindingAction(value)
          if (oldAction ~= "" and oldAction ~= "DISENCHANTER_PLUS_CONFIRM_ENCHANT") then
            DisenchanterPlus:Print(string.format(DisenchanterPlus:DP_i18n("Action |cffff3300%s|r is no longer assigned."), GetBindingText(value, "BINDING_NAME_")))
          else
            DisenchanterPlus:Print(DisenchanterPlus:DP_i18n("Keyboard configured correctly."))
          end
          SetBinding(value, "DISENCHANTER_PLUS_CONFIRM_ENCHANT")
          SaveBindings(GetCurrentBindingSet())
          DP_EnchantWindow:UpdateKeybindings()
        end,
      },
    }
  }
end
