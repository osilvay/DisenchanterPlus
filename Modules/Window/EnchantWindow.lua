---@class DP_EnchantWindow
local DP_EnchantWindow           = DP_ModuleLoader:CreateModule("DP_EnchantWindow")

---@type DP_CustomFunctions
local DP_CustomFunctions         = DP_ModuleLoader:ImportModule("DP_CustomFunctions")

---@type DP_CustomSounds
local DP_CustomSounds            = DP_ModuleLoader:ImportModule("DP_CustomSounds")

---@type DP_EnchantPatterns
local DP_EnchantPatterns         = DP_ModuleLoader:ImportModule("DP_EnchantPatterns")

---@type DP_DisenchantProcess
local DP_DisenchantProcess       = DP_ModuleLoader:ImportModule("DP_DisenchantProcess")

---@type DP_SlashCommands
local DP_SlashCommands           = DP_ModuleLoader:ImportModule("DP_SlashCommands")

---@type DP_MinimapIcon
local DP_MinimapIcon             = DP_ModuleLoader:ImportModule("DP_MinimapIcon")

---@type DP_BagsCheck
local DP_BagsCheck               = DP_ModuleLoader:ImportModule("DP_BagsCheck")

---@type DP_WelcomeWindow
local DP_WelcomeWindow           = DP_ModuleLoader:ImportModule("DP_WelcomeWindow")

---@type DP_EnchantProcess
local DP_EnchantProcess          = DP_ModuleLoader:ImportModule("DP_EnchantProcess")

---@type DP_CustomFrames
local DP_CustomFrames            = DP_ModuleLoader:ImportModule("DP_CustomFrames")

---@type DP_TradeSkillCheck
local DP_TradeSkillCheck         = DP_ModuleLoader:ImportModule("DP_TradeSkillCheck")

---@class EnchantLineText : FontString
---@field lineID number
---@field numAvailable number

local DEFAULT_DIALOG_BACKDROP    = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 24,
  edgeSize = 24,
  insets = {
    left = 4,
    right = 4,
    top = 4,
    bottom = 4,
  },
}
local CUSTOM_DIALOG_BACKDROP     = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  tile = true,
  edgeSize = 1,
  insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local emptySlot                  = "Interface/AddOns/DisenchanterPlus/Images/Inventory/INVTYPE_SLOT"
local unknownSlot                = "Interface/AddOns/DisenchanterPlus/Images/Inventory/Unknown"

local uncommonIcon               = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\uncommon:16:16|t" --2
local rareIcon                   = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\rare:16:16|t"     --3
local epicIcon                   = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\epic:16:16|t"     --4
local uncommonIconFill           = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\uncommon_fill:16:16|t"
local rareIconFill               = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\rare_fill:16:16|t"
local epicIconFill               = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Qualities\\epic_fill:16:16|t"

local optimal                    = "ffff8040"
local medium                     = "ffffff00"
local easy                       = "ff40c040"
local trivial                    = "ff808080"

local EnchanterPlusBaseFrame
local textFrameBgColorAlpha      = 0.80
local windowOpened               = false
local itemToDisenchant
local ignoreWindowOpened         = false
local enchantContainerLines      = {}
local itemContainerLines         = {}
local numLinesInEnchantContainer = 0
local numLinesInItemContainer    = 0
local enchantSelected            = nil
local lastEnchantCurrent         = nil
local itemSelected               = nil
local lastItemCurrent            = nil
local enchanting                 = false
local hiddenByCombat             = false
local showEquippedItems          = false
local updatingNativeSlots        = false

local function GetSelectedItem()
  local lines = EnchanterPlusBaseFrame.tabScrollContentFrame2.line
  return itemSelected and lines and lines[itemSelected]
end

local function MatchesEnchant(item, equipLocations)
  return equipLocations and (item.IsVellum or DP_CustomFunctions:TableHasValue(equipLocations, item.ItemEquipLoc))
end

local slotAliases = {
  INVTYPE_CHEST = { "CHESTSLOT", "INVTYPE_ROBE" },
  INVTYPE_ROBE = { "CHESTSLOT", "INVTYPE_CHEST" },
  INVTYPE_CLOAK = { "BACKSLOT" },
  INVTYPE_WRIST = { "WRISTSLOT" },
  INVTYPE_HAND = { "HANDSSLOT" },
  INVTYPE_FEET = { "FEETSLOT" },
  INVTYPE_WEAPON = { "MAINHANDSLOT", "SECONDARYHANDSLOT", "WEAPONS" },
  INVTYPE_2HWEAPON = { "MAINHANDSLOT", "INVTYPE_WEAPON", "WEAPONS" },
  INVTYPE_WEAPONMAINHAND = { "MAINHANDSLOT", "INVTYPE_WEAPON", "WEAPONS" },
  INVTYPE_WEAPONOFFHAND = { "SECONDARYHANDSLOT", "INVTYPE_WEAPON", "WEAPONS" },
  INVTYPE_SHIELD = { "SECONDARYHANDSLOT" },
  INVTYPE_HOLDABLE = { "SECONDARYHANDSLOT" },
}

local enchantSlotLabels = {
  INVTYPE_WEAPON = { "ENCHSLOT_WEAPON", "Weapon", "WEAPONS", "Weapons" },
  INVTYPE_2HWEAPON = { "ENCHSLOT_2HWEAPON", "2H Weapon" },
  INVTYPE_SHIELD = { "SHIELDSLOT", "Shield" },
}

local function FindSlotByLabel(labels, slots)
  for _, label in ipairs(labels or {}) do
    local slot = string.lower(_G[label] or label)
    if slots[slot] ~= nil then return slot end
  end
end

local function FindWeaponSlot(item, slots)
  if slots and item.ItemType == DisenchanterPlus:DP_i18n("Weapon") then
    return FindSlotByLabel(enchantSlotLabels.INVTYPE_WEAPON, slots)
  end
end

local function FindNativeSlot(equipLocation, slots, itemLink)
  if not slots or not equipLocation then return end

  -- The profession menu has weapon categories separate from the physical hand slots.
  local enchantSlot = FindSlotByLabel(enchantSlotLabels[equipLocation], slots)
  if enchantSlot then return enchantSlot end

  if itemLink and C_Item.GetItemInventoryTypeByID and C_Item.GetItemInventorySlotInfo then
    local inventoryType = C_Item.GetItemInventoryTypeByID(itemLink)
    local name = inventoryType and C_Item.GetItemInventorySlotInfo(inventoryType)
    if name and slots[string.lower(name)] ~= nil then
      return string.lower(name)
    end
  end
  local exactSlot = string.lower(_G[equipLocation] or equipLocation)
  if slots[exactSlot] ~= nil then return exactSlot end
  for _, key in ipairs(slotAliases[equipLocation] or {}) do
    local slot = string.lower(_G[key] or key)
    if slots[slot] then return slot end
  end
end

local function RefreshItemSource()
  itemSelected = nil
  lastItemCurrent = nil
  DP_TradeSkillCheck:ClearEnchantSlot()
  DP_EnchantWindow:DisableEnchantButton()
  DP_EnchantWindow:PopulateEnchantList()
  DP_EnchantWindow:PopulateItemList()
  DP_EnchantWindow:CheckReadyToEnchant()
end

function DP_EnchantWindow:CreateEnchantWindow()
  local xOffset = DisenchanterPlus.db.char.general.enchantFrameOffset.xOffset
  local yOffset = DisenchanterPlus.db.char.general.enchantFrameOffset.yOffset

  -- base frame ******************************************************************************************
  EnchanterPlusBaseFrame = CreateFrame("Frame", "EnchantWindow_BaseFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
  EnchanterPlusBaseFrame:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset)
  EnchanterPlusBaseFrame:SetFrameStrata("HIGH")
  EnchanterPlusBaseFrame:SetFrameLevel(1)
  EnchanterPlusBaseFrame:SetSize(624, 320)
  EnchanterPlusBaseFrame:SetMovable(true)
  EnchanterPlusBaseFrame:EnableMouse(true)
  EnchanterPlusBaseFrame:SetScript("OnMouseDown", DP_EnchantWindow.OnDragStart)
  EnchanterPlusBaseFrame:SetScript("OnMouseUp", DP_EnchantWindow.OnDragStop)

  EnchanterPlusBaseFrame:SetBackdrop(DEFAULT_DIALOG_BACKDROP)
  EnchanterPlusBaseFrame:SetBackdropColor(0, 0, 0, 0)
  EnchanterPlusBaseFrame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
  EnchanterPlusBaseFrame:SetScript("OnHide", function()
    -- La ventana tambien se puede ocultar con Escape (UISpecialFrames), no solo con CloseWindow.
    -- Si no se sincroniza el proceso, IsCraftingWindowOpen queda en true y la ventana no
    -- vuelve a abrirse hasta cerrar y reabrir la profesion.
    if windowOpened and not hiddenByCombat then
      windowOpened = false
      enchantSelected = nil
      lastEnchantCurrent = nil
      itemSelected = nil
      lastItemCurrent = nil
      DP_EnchantProcess:SetCraftingWindowOpen(false)
      DP_EnchantWindow:DisableEnchantButton()
    end

    -- Remover de UISpecialFrames cuando se oculta
    for i, frameName in ipairs(UISpecialFrames) do
      if frameName == "EnchantWindow_BaseFrame" then
        table.remove(UISpecialFrames, i)
        break
      end
    end
  end)

  local titleBar = CreateFrame("Frame", "EnchantWindow_BaseFrameTitleBackground", EnchanterPlusBaseFrame)
  titleBar:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, "TOPLEFT", 0, 0)
  titleBar:SetSize(624, 36)
  titleBar:SetMovable(false)
  titleBar:SetFrameStrata("HIGH")
  titleBar:SetFrameLevel(1)
  EnchanterPlusBaseFrame.titleBar = titleBar

  local titleBackground = EnchanterPlusBaseFrame:CreateTexture(nil, "BACKGROUND")
  titleBackground:SetDrawLayer("BACKGROUND", 2)
  titleBackground:SetHeight(36)
  titleBackground:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, 4, -4)
  titleBackground:SetPoint("BOTTOMRIGHT", EnchanterPlusBaseFrame, -4, 280)
  titleBackground:SetColorTexture(DisenchanterPlus:GetAddonColorDarkRGB():GetRGB())
  titleBackground:SetAlpha(0.8)
  EnchanterPlusBaseFrame.titleBackground = titleBackground

  local windowBackground = EnchanterPlusBaseFrame:CreateTexture(nil, "BACKGROUND")
  windowBackground:SetDrawLayer("BACKGROUND", 1)
  windowBackground:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, 4, -4)
  windowBackground:SetPoint("BOTTOMRIGHT", EnchanterPlusBaseFrame, -4, 4)
  windowBackground:SetColorTexture(DisenchanterPlus:GetAddonWindowBackgroundColorRGB():GetRGB())
  windowBackground:SetAlpha(0.8)
  EnchanterPlusBaseFrame.windowBackground = windowBackground

  -- texts
  local titleText = EnchanterPlusBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  titleText:SetTextColor(0.8, 0.8, 0.8)
  titleText:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, 20, -10)
  titleText:SetText(DisenchanterPlus:DP_i18n("Item enchanter"))
  EnchanterPlusBaseFrame.titleText = titleText

  local footText = EnchanterPlusBaseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  footText:SetTextColor(0.6, 0.6, 0.6)
  footText:SetPoint("BOTTOMLEFT", EnchanterPlusBaseFrame, 20, 20)
  footText:SetText("")
  EnchanterPlusBaseFrame.footText = footText

  -- settings button ******************************************************************************************
  local settingsButton = CreateFrame("Button", "EnchantWindow_SettingsButton", EnchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  settingsButton:SetSize(32, 26)
  settingsButton:SetPoint("TOPRIGHT", EnchanterPlusBaseFrame, -45, -8)
  settingsButton:SetFrameLevel(2)
  settingsButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Opens settings window."), 1, 0.82, 0, 1, true)
    settingsButton.text:SetTextColor(1, 1, 1)
    settingsButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\settings:14:14|t ") --.. DisenchanterPlus:DP_i18n("Settings")
  end)
  settingsButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    settingsButton.text:SetTextColor(0.6, 0.6, 0.6)
    settingsButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\settings_a:14:14|t ") -- .. DisenchanterPlus:DP_i18n("Settings"))
  end)
  settingsButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    DP_SlashCommands:OpenSettingsWindow()
    DP_EnchantWindow:CloseWindow()
  end)
  EnchanterPlusBaseFrame.settingsButton = settingsButton

  local settingsText = settingsButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local settingsString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\settings_a:14:14|t " -- .. DisenchanterPlus:DP_i18n("Settings")
  settingsText:SetPoint("CENTER", settingsButton, 2, 0)
  settingsText:SetJustifyH("CENTER")
  settingsText:SetText(settingsString)
  settingsText:SetTextColor(0.6, 0.6, 0.6)
  settingsButton.text = settingsText

  settingsButton:Hide()

  -- close button ******************************************************************************************
  local closeButton = CreateFrame("Button", "EnchantWindow_CloseButton", EnchanterPlusBaseFrame, BackdropTemplateMixin and "UIPanelButtonTemplate")
  closeButton:SetSize(32, 26)
  closeButton:SetPoint("TOPRIGHT", EnchanterPlusBaseFrame, -10, -8)
  closeButton:SetFrameLevel(2)
  closeButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Close window until next iteration."), 1, 0.82, 0, 1, true)
    closeButton.text:SetTextColor(1, 1, 1)
    closeButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close:14:14|t ") --.. DisenchanterPlus:DP_i18n("Settings")
  end)
  closeButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    closeButton.text:SetTextColor(0.6, 0.6, 0.6)
    closeButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_a:14:14|t ") -- .. DisenchanterPlus:DP_i18n("Settings"))
  end)
  closeButton:SetScript("OnClick", function(current)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    DP_EnchantWindow:CloseWindow()
  end)

  local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local closeString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_a:14:14|t " -- .. DisenchanterPlus:DP_i18n("Settings")
  closeText:SetPoint("CENTER", closeButton, 2, 0)
  closeText:SetJustifyH("CENTER")
  closeText:SetText(closeString)
  closeText:SetTextColor(0.6, 0.6, 0.6)
  closeButton.text = closeText

  EnchanterPlusBaseFrame.closeButton = closeButton
  closeButton:Show()

  -- yes button ******************************************************************************************
  local yesButton = CreateFrame("Button", "EnchantWindow_YesButton", EnchanterPlusBaseFrame, "SecureActionButtonTemplate")
  yesButton:SetEnabled(false)
  yesButton:SetSize(100, 26)
  yesButton:SetPoint("BOTTOMRIGHT", EnchanterPlusBaseFrame, -20, 20)
  yesButton:SetFrameLevel(2)

  local yesDummyButton = CreateFrame("Button", "EnchantWindow_YesDummyButton", EnchanterPlusBaseFrame, "UIPanelButtonTemplate")
  yesDummyButton:SetSize(100, 26)
  yesDummyButton:SetPoint("BOTTOMRIGHT", EnchanterPlusBaseFrame, -20, 20)
  yesDummyButton:Hide()

  local texture = yesButton:CreateTexture(nil, nil, "UIPanelButtonUpTexture")
  yesButton:SetNormalTexture(texture)
  yesButton:SetHighlightTexture(yesDummyButton:GetHighlightTexture())

  local disabledTexture = yesDummyButton:CreateTexture(nil, nil, "UIPanelButtonDisabledTexture")
  yesButton:SetDisabledTexture(disabledTexture)

  -- Registrar los dos eventos es lo mismo que hace el boton de desencantamiento (probado).
  -- El cliente decide cual de los dos ejecuta la accion segun el CVar
  -- "ActionButtonUseKeyDown", asi que registrar solo uno puede dejar el boton sin efecto.
  yesButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
  -- Accion segura "spell" + target-bag/target-slot: el cliente castea el encantamiento
  -- y despues usa el item seleccionado, igual que el boton de desencantamiento.
  yesButton:SetAttribute("type", "spell")
  yesButton:SetAttribute("spell", "")
  -- Manejador original del template (SecureActionButton_OnClick). En los clientes modernos
  -- el boton usa un OnClick propio y hay que poder volver a este al cambiar la seleccion.
  yesButton.secureOnClick = yesButton:GetScript("OnClick") or SecureActionButton_OnClick

  DP_EnchantWindow:UpdateKeybindings()

  yesButton:SetScript("OnEnter", function(current)
    local keybind = ""
    if DisenchanterPlus.db.char.general.confirmEnchant ~= nil then
      keybind = " |cffeeeeff" .. DisenchanterPlus.db.char.general.confirmEnchant .. "|r"
    end
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(DisenchanterPlus:DP_i18n("Proceed with the enchantment.") .. keybind, 1, 0.82, 0, 1, true)
    yesButton.text:SetTextColor(1, 1, 1)
    yesButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:14:14|t " .. DisenchanterPlus:DP_i18n("Enchant"))
  end)
  yesButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    yesButton.text:SetTextColor(0.6, 0.6, 0.6)
    yesButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:14:14|t " .. DisenchanterPlus:DP_i18n("Enchant"))
  end)
  yesButton:SetScript("PreClick", function(current)
    DisenchanterPlus:Debug("Boton Enchant pulsado (enchanting=" .. tostring(enchanting) .. ")")
    if not enchanting then
      -- No deshabilitar el boton aqui: el cliente puede ejecutar la accion segura en el
      -- evento de soltar el boton, y un boton deshabilitado no recibe ese evento (el clic
      -- se quedaba "sin hacer nada"). Se deshabilita un momento despues del clic.
      C_Timer.After(0.2, function()
        DP_EnchantWindow:DisableEnchantButton()
      end)
      C_Timer.After(5.5, function()
        enchanting = false
        DP_EnchantWindow:PopulateItemList()
        DP_EnchantWindow:PopulateEnchantList()
        DP_EnchantWindow:CheckReadyToEnchant()
      end)
      enchanting = true
    end
  end)
  EnchanterPlusBaseFrame.yesButton = yesButton

  local yesText = yesButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local yesString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:14:14|t " .. DisenchanterPlus:DP_i18n("Enchant")
  yesText:SetPoint("CENTER", yesButton, "CENTER")
  yesText:SetText(yesString)
  yesText:SetTextColor(0.6, 0.6, 0.6)
  yesButton.text = yesText

  -- craft buttons ******************************************************************************************
  DP_EnchantWindow:DrawCraftButton("EnchantWindow_CraftTrivialButton", "trivial", DisenchanterPlus:DP_i18n("Trivial"), "4", -80, -12)
  DP_EnchantWindow:DrawCraftButton("EnchantWindow_CraftEasyButton", "easy", DisenchanterPlus:DP_i18n("Easy"), "3", -105, -12)
  DP_EnchantWindow:DrawCraftButton("EnchantWindow_CraftMediumButton", "medium", DisenchanterPlus:DP_i18n("Medium"), "2", -130, -12)
  DP_EnchantWindow:DrawCraftButton("EnchantWindow_CraftOptimalButton", "optimal", DisenchanterPlus:DP_i18n("Optimal"), "1", -155, -12)

  -- custom buttons
  DP_CustomFrames:DrawCustomCleanButton("6", "EnchantWindow_RefreshButton", EnchanterPlusBaseFrame, "refresh", "refresh_a",
    DisenchanterPlus:DP_i18n("Refresh enchants"), -180, -10,
    function()
    end,
    function()
      enchantSelected = nil
      lastEnchantCurrent = nil
      RefreshItemSource()
    end
  )
  -- tab1 ******************************************************************************************
  local tab1Button = DP_CustomFrames:CreateTab(EnchanterPlusBaseFrame, "EnchantWindow_Tab1", 1, "", true, 302, 24)
  tab1Button:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, "TOPLEFT", 8, -38);

  EnchanterPlusBaseFrame.tab1Button = tab1Button
  tab1Button:Show()

  -- tab1 scroll frame
  local tabScrollFrame1 = CreateFrame("ScrollFrame", "EnchantWindow_TabScrollFrame1", EnchanterPlusBaseFrame, "UIPanelScrollFrameTemplate")
  tabScrollFrame1:SetPoint("TOPLEFT", EnchanterPlusBaseFrame, "TOPLEFT", 10, -65)
  tabScrollFrame1:SetSize(275, 205)

  local tabScrollContentFrame1 = CreateFrame("Frame", "EnchantWindow_EnchantList", EnchanterPlusBaseFrame)
  tabScrollContentFrame1:SetPoint("TOPLEFT", tabScrollFrame1, "TOPLEFT", 0, 0)
  tabScrollContentFrame1:SetSize(275, 205)
  tabScrollFrame1:SetScrollChild(tabScrollContentFrame1)
  EnchanterPlusBaseFrame.tabScrollContentFrame1 = tabScrollContentFrame1
  tabScrollFrame1:Show()

  local recipeFilters = {
    { key = "filterSkillUp", label = DisenchanterPlus:DP_i18n("Has Skill up") },
    { key = "filterWithoutMaterials", label = DisenchanterPlus:DP_i18n("Have Materials") },
  }
  local recipeLabel = DisenchanterPlus:DP_i18n("Enchants list")
  local updateFilterResetButton
  local function filtersAreDefault()
    return not (DP_TradeSkillCheck:GetRecipeFilter("filterSkillUp") or DP_TradeSkillCheck:GetRecipeFilter("filterWithoutMaterials"))
  end
  local function refreshRecipes(resetScroll)
    DP_EnchantWindow:DisableEnchantButton()
    DP_EnchantWindow:PopulateEnchantList()
    DP_EnchantWindow:PopulateItemList()
    DP_EnchantWindow:CheckReadyToEnchant()
    updateFilterResetButton()
    if resetScroll then tabScrollFrame1:SetVerticalScroll(0) end
  end
  local function toggleRecipeFilter(key)
    if InCombatLockdown() then return end
    DP_TradeSkillCheck:SetRecipeFilter(key, not DP_TradeSkillCheck:GetRecipeFilter(key))
    refreshRecipes(true)
  end
  local function clearRecipeFilters()
    if InCombatLockdown() then return end
    DP_TradeSkillCheck:SetRecipeFilter("filterSkillUp", false)
    DP_TradeSkillCheck:SetRecipeFilter("filterWithoutMaterials", false)
    refreshRecipes(true)
  end
  if WowStyle1FilterDropdownMixin then
    local dropdown = CreateFrame("DropdownButton", nil, tab1Button, "WowStyle1FilterDropdownTemplate")
    dropdown:SetPoint("CENTER", tab1Button, "CENTER", 0, 1)
    dropdown:SetText(recipeLabel)
    dropdown:SetIsDefaultCallback(filtersAreDefault)
    dropdown:SetDefaultCallback(clearRecipeFilters)
    updateFilterResetButton = function() dropdown:ValidateResetState() end
    dropdown:SetupMenu(function(_, root)
      for _, filter in ipairs(recipeFilters) do
        root:CreateCheckbox(filter.label, function(key)
          return DP_TradeSkillCheck:GetRecipeFilter(key)
        end, toggleRecipeFilter, filter.key)
      end
    end)
  else
    local dropdownButton = CreateFrame("Button", nil, tab1Button, "UIPanelButtonTemplate")
    dropdownButton:SetSize(144, 20)
    dropdownButton:SetPoint("CENTER", tab1Button)
    dropdownButton:SetText(recipeLabel)
    local arrow = dropdownButton:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    arrow:SetSize(14, 14)
    arrow:SetPoint("RIGHT", dropdownButton, -5, 0)
    local menu = CreateFrame("Frame", "EnchantWindow_RecipeFilterMenu", dropdownButton, "UIDropDownMenuTemplate")
    local reset = CreateFrame("Button", nil, dropdownButton, "UIPanelCloseButton")
    reset:SetSize(18, 18)
    reset:SetPoint("CENTER", dropdownButton, "TOPRIGHT", -3, 0)
    updateFilterResetButton = function() reset:SetShown(not filtersAreDefault()) end
    updateFilterResetButton()
    reset:SetScript("OnClick", clearRecipeFilters)
    UIDropDownMenu_Initialize(menu, function()
      for _, filter in ipairs(recipeFilters) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = filter.label
        info.checked = DP_TradeSkillCheck:GetRecipeFilter(filter.key)
        info.arg1 = filter.key
        info.func = function(_, key) toggleRecipeFilter(key) end
        UIDropDownMenu_AddButton(info)
      end
    end, "MENU")
    dropdownButton:SetScript("OnClick", function(button)
      ToggleDropDownMenu(1, nil, menu, button, 0, 0)
    end)
  end
  if DisenchanterPlus.IsForever then
    tab1Button:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
    tab1Button:RegisterEvent("PLAYER_REGEN_ENABLED")
    tab1Button:SetScript("OnEvent", function(button)
      if not updatingNativeSlots and button:IsVisible() and not InCombatLockdown()
          and DP_EnchantProcess:IsEnchantingProfessionOpen() then
        refreshRecipes()
      end
    end)
  end

  -- tab2 ******************************************************************************************
  local tab2Button = DP_CustomFrames:CreateTab(EnchanterPlusBaseFrame, "EnchantWindow_Tab2", 1, "", true, 302, 24)
  tab2Button:SetPoint("TOPRIGHT", EnchanterPlusBaseFrame, "TOPRIGHT", -8, -38);

  EnchanterPlusBaseFrame.tab2Button = tab2Button
  tab2Button:Show()

  -- tab1 scroll frame
  local tabScrollFrame2 = CreateFrame("ScrollFrame", "EnchantWindow_TabScrollFrame2", EnchanterPlusBaseFrame, "UIPanelScrollFrameTemplate")
  tabScrollFrame2:SetPoint("TOPRIGHT", EnchanterPlusBaseFrame, "TOPRIGHT", -30, -65)
  tabScrollFrame2:SetSize(275, 205)

  local tabScrollContentFrame2 = CreateFrame("Frame", "EnchantWindow_ItemList", EnchanterPlusBaseFrame)
  tabScrollContentFrame2:SetPoint("TOPLEFT", tabScrollFrame2, "TOPLEFT", 0, 0)
  tabScrollContentFrame2:SetSize(275, 205)
  tabScrollFrame2:SetScrollChild(tabScrollContentFrame2)
  EnchanterPlusBaseFrame.tabScrollContentFrame2 = tabScrollContentFrame2
  tabScrollFrame2:Show()

  local sourceLabels = {
    bags = DisenchanterPlus:DP_i18n("Items in bags"),
    equipped = DisenchanterPlus:DP_i18n("Items on me"),
  }
  local sourceOrder = { "bags", "equipped" }
  local function selectedSource()
    return showEquippedItems and "equipped" or "bags"
  end
  local function selectSource(value)
    if InCombatLockdown() then return end
    local equipped = value == "equipped"
    if showEquippedItems == equipped then return end
    showEquippedItems = equipped
    RefreshItemSource()
    tabScrollFrame2:SetVerticalScroll(0)
  end

  if WowStyle1FilterDropdownMixin then
    local dropdown = CreateFrame("DropdownButton", nil, tab2Button, "WowStyle1FilterDropdownTemplate")
    dropdown:SetPoint("CENTER", tab2Button, "CENTER", 0, 1)
    dropdown:SetText(sourceLabels[selectedSource()])
    dropdown:SetupMenu(function(_, root)
      for _, value in ipairs(sourceOrder) do
        root:CreateRadio(sourceLabels[value], function(source)
          return selectedSource() == source
        end, function(source)
          selectSource(source)
          dropdown:SetText(sourceLabels[selectedSource()])
        end, value)
      end
    end)
  else
    local dropdown = LibStub("AceGUI-3.0"):Create("Dropdown")
    dropdown:SetList(sourceLabels, sourceOrder)
    dropdown:SetValue(selectedSource())
    dropdown:SetWidth(160)
    dropdown.frame:SetParent(tab2Button)
    dropdown.frame:SetPoint("CENTER", tab2Button, "CENTER")
    dropdown:SetCallback("OnValueChanged", function(widget, _, value)
      selectSource(value)
      widget:SetValue(selectedSource())
    end)
    dropdown.frame:Show()
  end

  local itemsChanged = false
  local recipesChanged = false
  tab2Button:RegisterEvent("BAG_UPDATE_DELAYED")
  tab2Button:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
  tab2Button:RegisterEvent("PLAYER_REGEN_ENABLED")
  tab2Button:SetScript("OnEvent", function(button, event)
    if not button:IsVisible() then return end
    if (showEquippedItems and event == "PLAYER_EQUIPMENT_CHANGED")
        or (not showEquippedItems and event == "BAG_UPDATE_DELAYED") then
      itemsChanged = true
    end
    if not DisenchanterPlus.IsForever and event == "BAG_UPDATE_DELAYED" then
      recipesChanged = true
    end
    if InCombatLockdown() or not (itemsChanged or recipesChanged) then return end

    local rebuildItems, rebuildRecipes = itemsChanged, recipesChanged
    itemsChanged, recipesChanged = false, false
    if rebuildItems and showEquippedItems then
      RefreshItemSource()
    else
      if rebuildRecipes then DP_EnchantWindow:PopulateEnchantList() end
      if rebuildItems then DP_EnchantWindow:PopulateItemList() end
      DP_EnchantWindow:CheckReadyToEnchant()
    end
  end)

  EnchanterPlusBaseFrame:Hide()

  DP_EnchantWindow:PopulateEnchantList()

  return EnchanterPlusBaseFrame
end

---Open auto enchant window
function DP_EnchantWindow:OpenWindow()
  if not EnchanterPlusBaseFrame then
    EnchanterPlusBaseFrame = DP_EnchantWindow:CreateEnchantWindow()
  end

  --DisenchanterPlus:Debug(tostring(windowOpened))
  -- Permitir abrir si no está visible (en lugar de solo verificar windowOpened)
  if not EnchanterPlusBaseFrame:IsVisible() then
    C_Timer.After(0.2, function()
      -- Si la profesion se cerro antes de que se mostrara la ventana, no mostrarla.
      if not DP_EnchantProcess:IsCraftingWindowOpen() then return end
      EnchanterPlusBaseFrame:SetBackdropColor(0, 0, 0, textFrameBgColorAlpha)
      EnchanterPlusBaseFrame:Show()
      EnchanterPlusBaseFrame.settingsButton:Show()
      DP_EnchantWindow:PopulateItemList()
      -- Agregar a UISpecialFrames solo si no está ya
      local isInUISpecialFrames = false
      for _, frameName in ipairs(UISpecialFrames) do
        if frameName == "EnchantWindow_BaseFrame" then
          isInUISpecialFrames = true
          break
        end
      end
      if not isInUISpecialFrames then
        table.insert(UISpecialFrames, "EnchantWindow_BaseFrame")
      end
      windowOpened = true
      DP_WelcomeWindow:ShowIfNeeded("enchant")
    end)
  end
end

function DP_EnchantWindow:IsWindowOpened()
  return windowOpened
end

---Is an enchant being cast from this window (used to auto confirm replacement dialogs)
---@return boolean
function DP_EnchantWindow:IsEnchanting()
  return enchanting
end

---Close window
function DP_EnchantWindow:CloseWindow()
  if InCombatLockdown() or UnitAffectingCombat("player") or EnchanterPlusBaseFrame == nil then return end
  if EnchanterPlusBaseFrame == nil then return end

  if lastEnchantCurrent then
    lastEnchantCurrent.text:SetTextColor(1, 1, 1, 0.1)
    lastEnchantCurrent.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
    if EnchanterPlusBaseFrame.tabScrollContentFrame1.line and EnchanterPlusBaseFrame.tabScrollContentFrame1.line[lastEnchantCurrent.lineID] then
      EnchanterPlusBaseFrame.tabScrollContentFrame1.line[lastEnchantCurrent.lineID]:SetBackdropColor(1, 1, 1, 0)
    end
    enchantSelected = nil
    lastEnchantCurrent = nil
    itemSelected = nil
    lastItemCurrent = nil
    DP_EnchantWindow:PopulateItemList()
  end
  DP_EnchantProcess:SetCraftingWindowOpen(false)
  DP_EnchantWindow:DisableEnchantButton()
  for i, frameName in ipairs(UISpecialFrames) do
    if frameName == "EnchantWindow_BaseFrame" then
      table.remove(UISpecialFrames, i)
      break
    end
  end
  EnchanterPlusBaseFrame:Hide()
  windowOpened = false
end

---Drag start
function DP_EnchantWindow.OnDragStart()
  if InCombatLockdown() or UnitAffectingCombat("player") then return end
  EnchanterPlusBaseFrame:StartMoving()
end

---Hide the window during combat, returns true if it was visible
---@return boolean
function DP_EnchantWindow:HideForCombat()
  if not EnchanterPlusBaseFrame or not EnchanterPlusBaseFrame:IsVisible() then return false end
  hiddenByCombat = true
  EnchanterPlusBaseFrame:Hide()
  return true
end

---Show the window again after combat, or close it if the profession was closed meanwhile
function DP_EnchantWindow:ShowAfterCombat()
  if not hiddenByCombat then return end
  hiddenByCombat = false
  if not DP_EnchantProcess:IsCraftingWindowOpen() then
    DP_EnchantWindow:CloseWindow()
    return
  end
  EnchanterPlusBaseFrame:Show()
  EnchanterPlusBaseFrame.settingsButton:Show()
  table.insert(UISpecialFrames, "EnchantWindow_BaseFrame")
end

---Drag stop
function DP_EnchantWindow.OnDragStop()
  if InCombatLockdown() or UnitAffectingCombat("player") then return end
  local frameX = EnchanterPlusBaseFrame:GetCenter()
  local xLeft, yTop, xRight, yBottom = EnchanterPlusBaseFrame:GetLeft(), EnchanterPlusBaseFrame:GetTop(), EnchanterPlusBaseFrame:GetRight(), EnchanterPlusBaseFrame:GetBottom()
  local xSize, ySize = EnchanterPlusBaseFrame:GetSize()
  local screenWidth = GetScreenWidth()
  local xcreenHeight = GetScreenHeight()
  local xPositionFromCenter = -((screenWidth / 2) - xLeft) + (xSize / 2)
  local yPositionFromCenter = -((xcreenHeight / 2) - yTop) - (ySize / 2)
  DisenchanterPlus.db.char.general.enchantFrameOffset.xOffset = tonumber(string.format("%.1f", xPositionFromCenter))
  DisenchanterPlus.db.char.general.enchantFrameOffset.yOffset = tonumber(string.format("%.1f", yPositionFromCenter))
  EnchanterPlusBaseFrame:StopMovingOrSizing()
end

function DP_EnchantWindow:DisableButtons()
  if not EnchanterPlusBaseFrame or not EnchanterPlusBaseFrame.yesButton then return end
  EnchanterPlusBaseFrame.yesButton:SetEnabled(false)
end

function DP_EnchantWindow:EnableButtons()
  if not EnchanterPlusBaseFrame or not EnchanterPlusBaseFrame.yesButton then return end
  DP_EnchantWindow:CheckReadyToEnchant()
end

---Run the "confirm enchant" keybind by clicking the secure action button
function DP_EnchantWindow:RunKeybindConfirmEnchant()
  if not EnchanterPlusBaseFrame or not EnchanterPlusBaseFrame.yesButton then return end
  if EnchanterPlusBaseFrame.yesButton:IsEnabled() then
    EnchanterPlusBaseFrame.yesButton:Click("LeftButton")
  end
end

---Populate enchant list
function DP_EnchantWindow:PopulateEnchantList()
  DP_TradeSkillCheck:ApplyPendingRecipeFilters()
  local existingLines = EnchanterPlusBaseFrame.tabScrollContentFrame1.line
  local selectedRecipe = enchantSelected and existingLines and existingLines[enchantSelected]
  local selectedRecipeID = selectedRecipe and selectedRecipe.index
  local selectedItem = GetSelectedItem()
  enchantSelected = nil
  lastEnchantCurrent = nil
  local itemNum = 1
  local offsetV = 24
  local tradeSkillLines, nativeFiltersApplied = DP_EnchantProcess:GetTradeSkillLines()
  local filterWithoutMaterials = not nativeFiltersApplied and DP_TradeSkillCheck:GetRecipeFilter("filterWithoutMaterials")
  local filterSkillUp = not nativeFiltersApplied and DP_TradeSkillCheck:GetRecipeFilter("filterSkillUp")
  EnchanterPlusBaseFrame.tabScrollContentFrame1.line = {}

  -- filter craft types
  local craftTypesIndex = {}
  craftTypesIndex["1"] = "optimal"
  craftTypesIndex["2"] = "medium"
  craftTypesIndex["3"] = "easy"
  craftTypesIndex["4"] = "trivial"

  local craftTypes = DisenchanterPlus.db.char.general.enchantCraftType or {}
  local craftTypesList = {}

  for k, craftTypesValue in pairs(craftTypes) do
    if craftTypesValue then
      table.insert(craftTypesList, craftTypesIndex[k])
    end
  end

  -- filter exclusions
  local enchantExclusions = DP_EnchantPatterns:GetEnchantExclusions()

  -- draw
  if numLinesInEnchantContainer > 0 then
    for i = 1, numLinesInEnchantContainer, 1 do
      enchantContainerLines[tostring(i)]:Hide()
      enchantContainerLines[tostring(i)].acceptEnchantButton.text:SetTextColor(1, 1, 1, 0.1)
      enchantContainerLines[tostring(i)].acceptEnchantButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t")
    end
  end

  --DisenchanterPlus:Dump(enchantExclusions)
  local totalEnchants = 0
  local enchantsByCraftType = 0
  local enchantsByMaterials = 0

  for _, lineInfo in ipairs(tradeSkillLines) do
    totalEnchants = totalEnchants + 1
    local filterByCraftType = DP_CustomFunctions:TableHasValue(craftTypesList, lineInfo.CraftType)
    local filtarByExclusion = DP_CustomFunctions:TableHasValue(enchantExclusions, string.lower(lineInfo.CraftName))
    --DisenchanterPlus:Debug(string.format("%s = %s", lineInfo.CraftName, tostring(filtarByExclusion)))
    local filterByNumAvailable = not filterWithoutMaterials or (lineInfo.NumAvailable or 0) > 0
    local matchesItem = nativeFiltersApplied or not selectedItem or MatchesEnchant(selectedItem.itemData,
      DP_EnchantWindow:GetEquipLocationFromEnchant(lineInfo.CraftName))
    local matchesSkillUp = not filterSkillUp or lineInfo.CanSkillUp

    if filterByCraftType then
      enchantsByCraftType = enchantsByCraftType + 1
      if filterByNumAvailable then
        enchantsByMaterials = enchantsByMaterials + 1
      end
    end

    if filterByCraftType and not filtarByExclusion and filterByNumAvailable and matchesItem and matchesSkillUp then
      if enchantContainerLines[tostring(itemNum)] == nil then
        local enchantLineFrame = CreateFrame("Frame", "EnchantWindow_EnchantLine" .. itemNum, EnchanterPlusBaseFrame.tabScrollContentFrame1, BackdropTemplateMixin and "BackdropTemplate")
        enchantLineFrame.enchantCorrect = false
        enchantLineFrame.enchant = lineInfo.CraftName
        enchantLineFrame.index = lineInfo.Index

        enchantLineFrame:SetPoint("TOPLEFT", EnchanterPlusBaseFrame.tabScrollContentFrame1, "TOPLEFT", 0, -(offsetV * (itemNum - 1)))
        enchantLineFrame:SetSize(310, 32)
        enchantLineFrame:SetBackdrop(CUSTOM_DIALOG_BACKDROP)
        enchantLineFrame:SetBackdropColor(1, 1, 1, 0)
        enchantLineFrame:EnableMouse(true)

        -- select button
        local acceptEnchantButton = CreateFrame("Button", "EnchantWindow_SelectButton" .. itemNum, enchantLineFrame, BackdropTemplateMixin and "BackdropTemplate")
        acceptEnchantButton.lineID = itemNum
        acceptEnchantButton.numAvailable = lineInfo.NumAvailable or 0
        acceptEnchantButton.craftType = lineInfo.CraftType
        acceptEnchantButton.craftName = lineInfo.CraftName
        acceptEnchantButton.craftDescription = lineInfo.CraftDescription
        acceptEnchantButton.reagents = lineInfo.Reagents

        acceptEnchantButton:SetSize(32, 32)
        acceptEnchantButton:SetPoint("RIGHT", enchantLineFrame, -40, 0)
        acceptEnchantButton:SetScript("OnEnter", function(current)
          GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
          GameTooltip:SetWidth(140)

          local name = string.format("|c%s%s|r", DP_EnchantWindow:GetColorByCraftType(current.craftType), current.craftName)
          GameTooltip:AddLine(name, 1, 1, 1, true)
          GameTooltip:AddLine(current.craftDescription, 0.8, 0.8, 0.8, true)
          GameTooltip:AddLine("\n")
          GameTooltip:AddLine(DisenchanterPlus:DP_i18n("Reagents") .. ":", 1, 0.8, 0, true)

          local reagents = current.reagents or {}
          for _, reagent in pairs(reagents) do
            local reagentLeftLine = string.format(" + |T%d:0|t |cffe1e1e1%s|r", reagent.Texture or 134400, reagent.Name)
            local reagentRightLine = string.format("|cff91c1f1x|r |cff6191f1%d|r", reagent.Count)
            GameTooltip:AddLine(reagentLeftLine .. " " .. reagentRightLine)
          end
          GameTooltip:Show()
          if enchantSelected ~= current.lineID then
            current.text:SetTextColor(1, 1, 1, 0.6)
            current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
            if EnchanterPlusBaseFrame.tabScrollContentFrame1.line and EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID] then
              EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]:SetBackdropColor(1, 1, 1, 0.3)
            end
          end
        end)
        acceptEnchantButton:SetScript("OnLeave", function(current)
          GameTooltip:Hide()
          if enchantSelected ~= current.lineID then
            current.text:SetTextColor(1, 1, 1, 0.1)
            current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t")
            if EnchanterPlusBaseFrame.tabScrollContentFrame1.line and EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID] then
              EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]:SetBackdropColor(1, 1, 1, 0)
            end
          end
        end)
        acceptEnchantButton:SetScript("OnClick", function(current)
          if showEquippedItems and InCombatLockdown() then return end
          if enchantSelected ~= current.lineID then
            if lastEnchantCurrent then
              lastEnchantCurrent.text:SetTextColor(1, 1, 1, 0.1)
              lastEnchantCurrent.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
              if EnchanterPlusBaseFrame.tabScrollContentFrame1.line and EnchanterPlusBaseFrame.tabScrollContentFrame1.line[lastEnchantCurrent.lineID] then
                EnchanterPlusBaseFrame.tabScrollContentFrame1.line[lastEnchantCurrent.lineID]:SetBackdropColor(1, 1, 1, 0)
              end
            end
            current.text:SetTextColor(1, 1, 1, 1)
            if EnchanterPlusBaseFrame.tabScrollContentFrame1.line and EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID] then
              EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]:SetBackdropColor(1, 1, 1, 0.6)
            end
            enchantSelected = current.lineID
            lastEnchantCurrent = current
            -- Al cambiar de encantamiento el macro del boton "Enchant" todavia apunta al
            -- encantamiento/item anterior: hay que deshabilitarlo hasta elegir un item.
            DP_EnchantWindow:DisableEnchantButton()
            if current.numAvailable and current.numAvailable > 0 then
              current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_c:24:24|t")
            else
              current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\close_c:24:24|t")
            end
          else
            current.text:SetTextColor(1, 1, 1, 0.1)
            current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
            if EnchanterPlusBaseFrame.tabScrollContentFrame1.line and EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID] then
              EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]:SetBackdropColor(1, 1, 1, 0)
            end
            enchantSelected = nil
            lastEnchantCurrent = nil
            DP_EnchantWindow:DisableEnchantButton()
          end
          DP_EnchantWindow:PopulateItemList()
          DP_EnchantWindow:CheckReadyToEnchant()
        end)
        acceptEnchantButton:SetBackdrop({
          bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
          tile = true,
          edgeSize = 2,
          insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        acceptEnchantButton:SetBackdropColor(0, 0, 0, 0)
        enchantLineFrame.acceptEnchantButton = acceptEnchantButton

        local acceptEnchantText = acceptEnchantButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        local acceptEnchantString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t"
        acceptEnchantText:SetPoint("CENTER", acceptEnchantButton, "CENTER")
        acceptEnchantText:SetTextColor(1, 1, 1, 0.1)
        acceptEnchantText:SetText(acceptEnchantString)
        acceptEnchantButton.text = acceptEnchantText

        -- clickeable text button (invisible overlay)
        local enchantTextButton = CreateFrame("Button", "EnchantWindow_TextButton" .. itemNum, enchantLineFrame)
        enchantTextButton.lineID = itemNum
        enchantTextButton:SetSize(240, 32)
        enchantTextButton:SetPoint("LEFT", enchantLineFrame, 10, 0)
        enchantTextButton:SetScript("OnClick", function(current)
          if EnchanterPlusBaseFrame.tabScrollContentFrame1.line and EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID] then
            EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID].acceptEnchantButton:Click()
          end
        end)
        enchantLineFrame.enchantTextButton = enchantTextButton

        -- enchant text
        local enchantLineText = enchantLineFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        ---@cast enchantLineText EnchantLineText
        enchantLineText.lineID = itemNum
        enchantLineText.numAvailable = lineInfo.NumAvailable or 0

        enchantLineText:SetSize(240, 32)
        enchantLineText:SetPoint("LEFT", enchantLineFrame, 10, 0)

        local fontPath, _, outline = GameFontNormal:GetFont()
        enchantLineText:SetFont(fontPath, 15, outline or "")

        enchantLineText:SetText(string.format("|c%s%s %s|r",
          DP_EnchantWindow:GetColorByCraftType(lineInfo.CraftType),
          (lineInfo.NumAvailable and lineInfo.NumAvailable > 0) and "[" .. lineInfo.NumAvailable .. "]" or "-",
          lineInfo.CraftName))
        enchantLineText:SetJustifyH("LEFT")
        enchantLineText:SetMaxLines(1)
        enchantLineText:SetScript("OnEnter", function(current)
          if enchantSelected ~= current.lineID then
            if EnchanterPlusBaseFrame.tabScrollContentFrame1.line and EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID] then
              local tabFrame = EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]
              tabFrame.acceptEnchantButton.text:SetTextColor(1, 1, 1, 0.6)
              tabFrame.acceptEnchantButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
              tabFrame:SetBackdropColor(1, 1, 1, 0.3)
            end
          end
        end)
        enchantLineText:SetScript("OnLeave", function(current)
          if enchantSelected ~= current.lineID then
            if EnchanterPlusBaseFrame.tabScrollContentFrame1.line and EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID] then
              local tabFrame = EnchanterPlusBaseFrame.tabScrollContentFrame1.line[current.lineID]
              tabFrame.acceptEnchantButton.text:SetTextColor(1, 1, 1, 0.1)
              tabFrame.acceptEnchantButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
              tabFrame:SetBackdropColor(1, 1, 1, 0.0)
            end
          end
        end)
        enchantLineFrame.enchantLineText = enchantLineText
        EnchanterPlusBaseFrame.tabScrollContentFrame1.line[itemNum] = enchantLineFrame
        enchantContainerLines[tostring(itemNum)] = enchantLineFrame
      else
        local enchantLineFrame = enchantContainerLines[tostring(itemNum)]
        enchantLineFrame.enchantCorrect = false
        enchantLineFrame.enchant = lineInfo.CraftName
        enchantLineFrame.index = lineInfo.Index

        local acceptEnchantButton = enchantLineFrame.acceptEnchantButton
        acceptEnchantButton.lineID = itemNum
        acceptEnchantButton.numAvailable = lineInfo.NumAvailable or 0
        acceptEnchantButton.craftType = lineInfo.CraftType
        acceptEnchantButton.craftName = lineInfo.CraftName
        acceptEnchantButton.craftDescription = lineInfo.CraftDescription
        acceptEnchantButton.reagents = lineInfo.Reagents

        local enchantTextButton = enchantLineFrame.enchantTextButton
        enchantTextButton.lineID = itemNum

        enchantLineFrame:SetBackdropColor(1, 1, 1, 0)

        local enchantLineText = enchantLineFrame.enchantLineText
        enchantLineText.lineID = itemNum
        enchantLineText.numAvailable = lineInfo.NumAvailable or 0

        enchantLineText:SetText(string.format("|c%s%s %s|r",
          DP_EnchantWindow:GetColorByCraftType(lineInfo.CraftType),
          (lineInfo.NumAvailable and lineInfo.NumAvailable > 0) and "[" .. lineInfo.NumAvailable .. "]" or "-",
          lineInfo.CraftName))

        EnchanterPlusBaseFrame.tabScrollContentFrame1.line[itemNum] = enchantLineFrame
        enchantContainerLines[tostring(itemNum)] = enchantLineFrame
        enchantLineFrame:Show()
      end
      if selectedRecipeID and selectedRecipeID == lineInfo.Index then
        local line = EnchanterPlusBaseFrame.tabScrollContentFrame1.line[itemNum]
        lastEnchantCurrent = line.acceptEnchantButton
        enchantSelected = itemNum
        local icon = lastEnchantCurrent.numAvailable > 0 and "accept_c" or "close_c"
        lastEnchantCurrent.text:SetTextColor(1, 1, 1, 1)
        lastEnchantCurrent.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\" .. icon .. ":24:24|t")
        line:SetBackdropColor(1, 1, 1, 0.6)
      end
      itemNum = itemNum + 1
    end
  end
  EnchanterPlusBaseFrame.tabScrollContentFrame1:Show()
  numLinesInEnchantContainer = DP_CustomFunctions:TableLength(EnchanterPlusBaseFrame.tabScrollContentFrame1.line)

  -- El scroll child debe crecer con las filas; si no, las listas largas no se pueden scrollear.
  local enchantListHeight = offsetV * math.max(numLinesInEnchantContainer - 1, 0) + 32 + 8
  EnchanterPlusBaseFrame.tabScrollContentFrame1:SetHeight(math.max(205, enchantListHeight))

  if selectedRecipeID and not enchantSelected then
    DP_EnchantWindow:DisableEnchantButton()
    DP_EnchantWindow:PopulateItemList()
  end

  if numLinesInEnchantContainer == 0 then
    -- Distinguish an empty profession list from a list emptied by the active filters.
    if totalEnchants == 0 and not nativeFiltersApplied then
      EnchanterPlusBaseFrame.footText:SetText("|cffff0a30" .. DisenchanterPlus:DP_i18n("You need to open the enchanting tradeskill book and click refresh.") .. "|r")
    elseif #craftTypesList == 0 then
      EnchanterPlusBaseFrame.footText:SetText("|cffff650a" .. DisenchanterPlus:DP_i18n("No enchantment difficulty is selected in the filters.") .. "|r")
    elseif totalEnchants > 0 and enchantsByCraftType == 0 then
      EnchanterPlusBaseFrame.footText:SetText("|cffff650a" .. DisenchanterPlus:DP_i18n("No enchantments match the selected difficulty filters.") .. "|r")
    elseif filterWithoutMaterials and enchantsByMaterials == 0 then
      EnchanterPlusBaseFrame.footText:SetText("|cffff650a" .. DisenchanterPlus:DP_i18n("No enchantments can be crafted with the materials you have.") .. "|r")
    else
      EnchanterPlusBaseFrame.footText:SetText("|cffff650a" .. DisenchanterPlus:DP_i18n("No enchantments match the selected filters.") .. "|r")
    end
  elseif lastEnchantCurrent and not itemSelected then
    EnchanterPlusBaseFrame.footText:SetText("|cffffc700" .. DisenchanterPlus:DP_i18n("Select an item from the right list.") .. "|r")
  else
    EnchanterPlusBaseFrame.footText:SetText("|cffffc700" .. DisenchanterPlus:DP_i18n("Select an enchantment from the left list.") .. "|r")
  end
end

---Get color by craft type
---@param craftType string
---@return string
function DP_EnchantWindow:GetColorByCraftType(craftType)
  if craftType == nil or craftType == "trivial" then
    return trivial
  elseif craftType == "easy" then
    return easy
  elseif craftType == "medium" then
    return medium
  elseif craftType == "optimal" then
    return optimal
  else
    return trivial
  end
end

---Get equip location from enchant
---@param enchant string
---@return table|nil
function DP_EnchantWindow:GetEquipLocationFromEnchant(enchant)
  local equipoLocations = DP_EnchantPatterns:GetEquipLocationsForEnchantTypes()
  --DisenchanterPlus:Dump(equipoLocations)
  for pattern, equipLocation in pairs(equipoLocations) do
    local search = string.find(string.lower(enchant), pattern)
    if search then
      --DisenchanterPlus:Dump(equipLocation)
      return equipLocation
    end
  end
  return nil
end

local function GetEquippedEnchantItems()
  local items = {}
  local qualities = DisenchanterPlus.db.char.general.enchantItemQuality or {}
  for slot = INVSLOT_FIRST_EQUIPPED or 1, INVSLOT_LAST_EQUIPPED or 19 do
    local link = GetInventoryItemLink("player", slot)
    if link then
      local name, _, quality, _, _, itemType, _, _, equipLocation = C_Item.GetItemInfo(link)
      if qualities[tostring(quality)]
          and (itemType == DisenchanterPlus:DP_i18n("Armor") or itemType == DisenchanterPlus:DP_i18n("Weapon")) then
        table.insert(items, {
          ItemID = GetInventoryItemID("player", slot),
          ItemName = name,
          ItemLink = link,
          ItemType = itemType,
          ItemEquipLoc = equipLocation,
          EquippedSlot = slot,
        })
      end
    end
  end
  return items
end

---Populate item list
function DP_EnchantWindow:PopulateItemList()
  local selectedItem = GetSelectedItem()
  local previousItem = selectedItem and selectedItem.itemData
  itemSelected = nil
  lastItemCurrent = nil
  local itemNum = 1
  local offsetV = 24
  local items = showEquippedItems and GetEquippedEnchantItems() or DP_BagsCheck:GetItemsInBags()
  EnchanterPlusBaseFrame.tabScrollContentFrame2.line = {}

  if numLinesInItemContainer > 0 then
    for i = 1, numLinesInItemContainer, 1 do
      itemContainerLines[tostring(i)]:Hide()
    end
  end
  local equipLocations
  if lastEnchantCurrent then
    equipLocations = DP_EnchantWindow:GetEquipLocationFromEnchant(lastEnchantCurrent.craftName)
  else
    equipLocations = {}
    for _, locations in pairs(DP_EnchantPatterns:GetEquipLocationsForEnchantTypes()) do
      for _, equipLocation in ipairs(locations) do
        table.insert(equipLocations, equipLocation)
      end
    end
  end
  local nativeSlots = DP_TradeSkillCheck:GetEnchantSlotFilters()
  for i = #items, 1, -1 do
    local item = items[i]
    local matchesSlot = item.IsVellum or not nativeSlots
        or nativeSlots[FindNativeSlot(item.ItemEquipLoc, nativeSlots, item.ItemLink)]
        or nativeSlots[FindWeaponSlot(item, nativeSlots)]
    if not MatchesEnchant(item, equipLocations) or not matchesSlot then
      table.remove(items, i)
    end
  end

  if DP_CustomFunctions:TableIsEmpty(items) then
    EnchanterPlusBaseFrame.tabScrollContentFrame2:SetHeight(205)
    if previousItem then DP_EnchantWindow:PopulateEnchantList() end
    if lastEnchantCurrent then
      EnchanterPlusBaseFrame.footText:SetText("|cffff650a" .. DisenchanterPlus:DP_i18n("There are no items for this enchantment.") .. "|r")
    end
    return
  end

  for _, lineInfo in ipairs(items) do
    if itemContainerLines[tostring(itemNum)] == nil then
      local itemLineFrame = CreateFrame("Frame", "EnchantWindow_ItemLine" .. itemNum, EnchanterPlusBaseFrame.tabScrollContentFrame2, BackdropTemplateMixin and "BackdropTemplate")
      itemLineFrame.itemCorrect = false
      itemLineFrame.itemID = lineInfo.ItemID
      itemLineFrame.itemName = lineInfo.ItemName
      itemLineFrame.itemBag = lineInfo.BagIndex
      itemLineFrame.itemSlot = lineInfo.Slot
      itemLineFrame.equippedSlot = lineInfo.EquippedSlot

      itemLineFrame:SetPoint("TOPLEFT", EnchanterPlusBaseFrame.tabScrollContentFrame2, "TOPLEFT", 0, -(offsetV * (itemNum - 1)))
      itemLineFrame:SetSize(310, 32)
      itemLineFrame:SetBackdrop(CUSTOM_DIALOG_BACKDROP)
      itemLineFrame:SetBackdropColor(1, 1, 1, 0)
      itemLineFrame:EnableMouse(true)

      -- select button ***************************************************************************************************************************************
      local acceptItemButton = CreateFrame("Button", "EnchantWindow_SelectItemButton" .. itemNum, itemLineFrame, BackdropTemplateMixin and "BackdropTemplate")
      acceptItemButton.lineID = itemNum

      acceptItemButton:SetSize(32, 32)
      acceptItemButton:SetPoint("RIGHT", itemLineFrame, -40, 0)
      acceptItemButton:SetScript("OnEnter", function(current)
        GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
        GameTooltip:SetText(DisenchanterPlus:DP_i18n("Select"), 1, 0.82, 0, 1, true)
        if itemSelected ~= current.lineID then
          current.text:SetTextColor(1, 1, 1, 0.6)
          current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
          EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]:SetBackdropColor(1, 1, 1, 0.3)
        end
      end)
      acceptItemButton:SetScript("OnLeave", function(current)
        GameTooltip:Hide()
        if itemSelected ~= current.lineID then
          current.text:SetTextColor(1, 1, 1, 0.1)
          current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t")
          EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]:SetBackdropColor(1, 1, 1, 0)
        end
      end)
      acceptItemButton:SetScript("OnClick", function(current)
        if showEquippedItems and InCombatLockdown() then return end
        if itemSelected ~= current.lineID then
          local item = EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID].itemData
          local slots, indices = DP_TradeSkillCheck:GetEnchantSlotFilters(true)
          local slot = FindNativeSlot(item.ItemEquipLoc, slots, item.ItemLink)
          local weaponSlot = FindWeaponSlot(item, slots)
          if lastItemCurrent then
            lastItemCurrent.text:SetTextColor(1, 1, 1, 0.1)
            lastItemCurrent.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
            EnchanterPlusBaseFrame.tabScrollContentFrame2.line[lastItemCurrent.lineID]:SetBackdropColor(1, 1, 1, 0)
          end
          current.text:SetTextColor(1, 1, 1, 1)
          current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_c:24:24|t")
          EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]:SetBackdropColor(1, 1, 1, 0.6)
          itemSelected = current.lineID
          lastItemCurrent = current
          updatingNativeSlots = true
          local changed = DP_TradeSkillCheck:SelectEnchantSlots(slot and indices[slot], weaponSlot and indices[weaponSlot])
          updatingNativeSlots = false
          if changed then
            DP_EnchantWindow:PopulateItemList()
          end
        else
          current.text:SetTextColor(1, 1, 1, 0.1)
          current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
          EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]:SetBackdropColor(1, 1, 1, 0)
          itemSelected = nil
          lastItemCurrent = nil
          DP_EnchantWindow:DisableEnchantButton()
          if DP_TradeSkillCheck:ClearEnchantSlot() then
            DP_EnchantWindow:PopulateItemList()
          end
        end
        DP_EnchantWindow:PopulateEnchantList()
        DP_EnchantWindow:CheckReadyToEnchant()
      end)
      acceptItemButton:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        edgeSize = 2,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
      })
      acceptItemButton:SetBackdropColor(0, 0, 0, 0)
      itemLineFrame.acceptItemButton = acceptItemButton

      -- button text ***************************************************************************************************************************************
      local acceptItemText = acceptItemButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      local acceptItemString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t"
      acceptItemText:SetPoint("CENTER", acceptItemButton, "CENTER")
      acceptItemText:SetText(acceptItemString)
      acceptItemText:SetTextColor(1, 1, 1, 0.1)
      acceptItemButton.text = acceptItemText

      -- clickeable item text button (invisible overlay)
      local itemTextButton = CreateFrame("Button", "EnchantWindow_ItemTextButton" .. itemNum, itemLineFrame)
      itemTextButton.lineID = itemNum
      itemTextButton:SetSize(240, 32)
      itemTextButton:SetPoint("LEFT", itemLineFrame, 10, 0)
      itemTextButton:SetScript("OnClick", function(current)
        if EnchanterPlusBaseFrame.tabScrollContentFrame2.line and EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID] then
          EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID].acceptItemButton:Click()
        end
      end)
      itemLineFrame.itemTextButton = itemTextButton

      -- item text
      local itemLineText = itemLineFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      ---@cast itemLineText EnchantLineText
      itemLineText.lineID = itemNum

      itemLineText:SetSize(240, 32)
      itemLineText:SetPoint("LEFT", itemLineFrame, 10, 0)

      local fontPath, _, outline = GameFontNormal:GetFont()
      itemLineText:SetFont(fontPath, 15, outline or "")

      itemLineText:SetText(string.format("%s", lineInfo.ItemLink))
      itemLineText:SetJustifyH("LEFT")
      itemLineText:SetMaxLines(1)
      itemLineText:SetScript("OnEnter", function(current)
        if itemSelected ~= current.lineID then
          local tabFrame = EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]
          tabFrame.acceptItemButton.text:SetTextColor(1, 1, 1, 0.6)
          tabFrame.acceptItemButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept:24:24|t")
          tabFrame:SetBackdropColor(1, 1, 1, 0.3)
        end
      end)
      itemLineText:SetScript("OnLeave", function(current)
        if itemSelected ~= current.lineID then
          local tabFrame = EnchanterPlusBaseFrame.tabScrollContentFrame2.line[current.lineID]
          tabFrame.acceptItemButton.text:SetTextColor(1, 1, 1, 0.1)
          tabFrame.acceptItemButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t")
          tabFrame:SetBackdropColor(1, 1, 1, 0.0)
        end
      end)
      itemLineFrame.itemLineText = itemLineText
      EnchanterPlusBaseFrame.tabScrollContentFrame2.line[itemNum] = itemLineFrame
      itemContainerLines[tostring(itemNum)] = itemLineFrame
    else
      local itemLineFrame = itemContainerLines[tostring(itemNum)]
      itemLineFrame:SetBackdropColor(1, 1, 1, 0)
      itemLineFrame.itemCorrect = false
      itemLineFrame.itemID = lineInfo.ItemID
      itemLineFrame.itemName = lineInfo.ItemName
      itemLineFrame.itemBag = lineInfo.BagIndex
      itemLineFrame.itemSlot = lineInfo.Slot
      itemLineFrame.equippedSlot = lineInfo.EquippedSlot

      local acceptItemButton = itemLineFrame.acceptItemButton
      acceptItemButton.text:SetTextColor(1, 1, 1, 0.1)
      acceptItemButton.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_a:24:24|t")
      acceptItemButton.lineID = itemNum
      acceptItemButton.numAvailable = lineInfo.NumAvailable or 0

      local itemTextButton = itemLineFrame.itemTextButton
      itemTextButton.lineID = itemNum

      local itemLineText = itemLineFrame.itemLineText
      itemLineText.lineID = itemNum
      itemLineText:SetText(string.format("%s", lineInfo.ItemLink))

      EnchanterPlusBaseFrame.tabScrollContentFrame2.line[itemNum] = itemLineFrame
      itemContainerLines[tostring(itemNum)] = itemLineFrame

      itemLineFrame:Show()
    end
    local line = EnchanterPlusBaseFrame.tabScrollContentFrame2.line[itemNum]
    line.itemData = lineInfo
    if previousItem and previousItem.ItemLink == lineInfo.ItemLink
        and previousItem.BagIndex == lineInfo.BagIndex and previousItem.Slot == lineInfo.Slot
        and previousItem.EquippedSlot == lineInfo.EquippedSlot then
      itemSelected = itemNum
      lastItemCurrent = line.acceptItemButton
      lastItemCurrent.text:SetTextColor(1, 1, 1, 1)
      lastItemCurrent.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\Icons\\accept_c:24:24|t")
      line:SetBackdropColor(1, 1, 1, 0.6)
    end
    itemNum = itemNum + 1
  end

  EnchanterPlusBaseFrame.tabScrollContentFrame2:Show()
  numLinesInItemContainer = DP_CustomFunctions:TableLength(EnchanterPlusBaseFrame.tabScrollContentFrame2.line)

  -- El scroll child debe crecer con las filas; si no, las listas largas no se pueden scrollear.
  local itemListHeight = offsetV * math.max(numLinesInItemContainer - 1, 0) + 32 + 8
  EnchanterPlusBaseFrame.tabScrollContentFrame2:SetHeight(math.max(205, itemListHeight))

  if previousItem and not itemSelected then DP_EnchantWindow:PopulateEnchantList() end
  if lastEnchantCurrent and not itemSelected then
    EnchanterPlusBaseFrame.footText:SetText("|cffffc700" .. DisenchanterPlus:DP_i18n("Select an item from the right list.") .. "|r")
  end
end

---Get enchant and item selected
---@return string|nil
---@return string|nil
function DP_EnchantWindow:CheckReadyToEnchant()
  if showEquippedItems and InCombatLockdown() then return end
  if enchanting then return end
  if lastEnchantCurrent and lastEnchantCurrent.numAvailable <= 0 then
    DP_EnchantWindow:DisableEnchantButton()
    EnchanterPlusBaseFrame.footText:SetText("|cffff0a30" .. DisenchanterPlus:DP_i18n("You don't have any materials for that enchantment.") .. "|r")
    return
  end
  if not lastEnchantCurrent or not lastItemCurrent then
    DP_EnchantWindow:DisableEnchantButton()
    return
  end

  if not (EnchanterPlusBaseFrame.tabScrollContentFrame1.line and EnchanterPlusBaseFrame.tabScrollContentFrame1.line[lastEnchantCurrent.lineID] and
        EnchanterPlusBaseFrame.tabScrollContentFrame2.line and EnchanterPlusBaseFrame.tabScrollContentFrame2.line[lastItemCurrent.lineID]) then
    DP_EnchantWindow:DisableEnchantButton()
    return
  end

  local enchantLine = EnchanterPlusBaseFrame.tabScrollContentFrame1.line[lastEnchantCurrent.lineID]
  local enchant = enchantLine.enchant
  local recipeID = enchantLine.index
  local itemInfo = EnchanterPlusBaseFrame.tabScrollContentFrame2.line[lastItemCurrent.lineID]
  if not MatchesEnchant(itemInfo.itemData, DP_EnchantWindow:GetEquipLocationFromEnchant(enchant)) then
    DP_EnchantWindow:DisableEnchantButton()
    return
  end
  local itemName = itemInfo.itemName

  local yesButton = EnchanterPlusBaseFrame.yesButton
  if not yesButton then return end

  -- Hay dos formas de aplicar el encantamiento y el boton tiene que usar la que soporta el
  -- cliente en el que esta corriendo el addon:
  --   * Clasico: el encantamiento es un hechizo del libro; se castea y despues se usa el item.
  --     Se hace con una accion segura (type="spell" + target-bag/target-slot, igual que el
  --     boton de desencantamiento).
  --   * Cliente moderno (UI de profesiones con C_TradeSkillUI): el encantamiento no es un
  --     hechizo casteable desde el addon; se aplica con C_TradeSkillUI.CraftEnchant, que es
  --     exactamente lo que hace el boton "Crear" de la ventana de profesion.
  -- La confirmacion de "reemplazar encantamiento" la resuelve DP_EnchantProcess aceptando
  -- el popup en el mismo frame en que el cliente lo muestra.
  if DP_EnchantWindow:ShouldUseCraftEnchant(recipeID) then
    -- Con un OnClick propio basta un evento: si se registran los dos, CraftEnchant se
    -- llamaria dos veces por clic.
    yesButton:RegisterForClicks("LeftButtonUp")
    yesButton:SetScript("OnClick", function()
      DP_EnchantWindow:CraftEnchantOnItem(recipeID, itemInfo.itemBag, itemInfo.itemSlot, itemInfo.equippedSlot)
    end)
    yesButton:SetAttribute("type", nil)
    yesButton:SetAttribute("spell", nil)
    yesButton:SetAttribute("macrotext", nil)
    yesButton:SetAttribute("target-bag", nil)
    yesButton:SetAttribute("target-slot", nil)
    yesButton:SetAttribute("target-item", nil)
    DisenchanterPlus:Debug(string.format("Enchant button: CraftEnchant(recipeID=%s, bag=%s, slot=%s)",
      tostring(recipeID), tostring(itemInfo.itemBag), tostring(itemInfo.itemSlot)))
  elseif itemInfo.equippedSlot then
    yesButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
    yesButton:SetScript("OnClick", yesButton.secureOnClick)
    yesButton:SetAttribute("type", "macro")
    yesButton:SetAttribute("macrotext", string.format("/cast [nocombat] %s\n/use [nocombat] %d\n", enchant, itemInfo.equippedSlot))
    yesButton:SetAttribute("spell", nil)
    yesButton:SetAttribute("target-bag", nil)
    yesButton:SetAttribute("target-slot", nil)
    yesButton:SetAttribute("target-item", nil)
  elseif itemInfo.itemBag ~= nil and itemInfo.itemSlot ~= nil then
    yesButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
    yesButton:SetScript("OnClick", yesButton.secureOnClick)
    yesButton:SetAttribute("type", "spell")
    yesButton:SetAttribute("spell", enchant)
    yesButton:SetAttribute("target-bag", itemInfo.itemBag)
    yesButton:SetAttribute("target-slot", itemInfo.itemSlot)
    yesButton:SetAttribute("target-item", nil)
    yesButton:SetAttribute("macrotext", nil)
    DisenchanterPlus:Debug(string.format("Enchant button: spell=%s, bag=%s, slot=%s", tostring(enchant), tostring(itemInfo.itemBag), tostring(itemInfo.itemSlot)))
  else
    -- Respaldo por si la lista no guardo la posicion en bolsa: se usa el nombre del item.
    -- (El nombre puede ser ambiguo, por eso el camino normal usa target-bag/target-slot.)
    yesButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
    yesButton:SetScript("OnClick", yesButton.secureOnClick)
    yesButton:SetAttribute("type", "macro")
    yesButton:SetAttribute("macrotext", string.format("/cast %s\n/use %s\n", enchant, itemName))
    yesButton:SetAttribute("target-bag", nil)
    yesButton:SetAttribute("target-slot", nil)
    yesButton:SetAttribute("target-item", nil)
    DisenchanterPlus:Debug(string.format("Enchant button: sin bolsa/slot, macro /cast %s + /use %s", tostring(enchant), tostring(itemName)))
  end

  local selectedItem = lastItemCurrent
  C_Timer.After(0.2, function()
    if enchanting or lastItemCurrent ~= selectedItem or not lastEnchantCurrent or lastEnchantCurrent.numAvailable <= 0 then return end
    DP_EnchantWindow:EnableEnchantButton()
    local footText = "|cff1cee1c" .. DisenchanterPlus:DP_i18n("You can start to enchant.") .. "|r"
    EnchanterPlusBaseFrame.footText:SetText(footText)
  end)
end

---Does this client apply enchants through the profession API instead of casting a spell?
---En los clientes modernos (UI de profesiones) la receta no se castea: se aplica con
---C_TradeSkillUI.CraftEnchant, igual que el boton "Crear" de la ventana de profesion.
---@param recipeID number|nil
---@return boolean
function DP_EnchantWindow:ShouldUseCraftEnchant(recipeID)
  if not DisenchanterPlus.IsForever then return false end
  if type(C_TradeSkillUI) ~= "table" or type(C_TradeSkillUI.CraftEnchant) ~= "function" then return false end
  if type(recipeID) ~= "number" then return false end
  return true
end

---Apply an enchant through the profession API
---@param recipeID number|nil
---@param bag number|nil
---@param slot number|nil
---@param equippedSlot number|nil
function DP_EnchantWindow:CraftEnchantOnItem(recipeID, bag, slot, equippedSlot)
  if type(recipeID) ~= "number" or not ItemLocation then return end

  local itemLocation
  if equippedSlot then
    if InCombatLockdown() or not ItemLocation.CreateFromEquipmentSlot then return end
    itemLocation = ItemLocation:CreateFromEquipmentSlot(equippedSlot)
  elseif bag ~= nil and slot ~= nil and ItemLocation.CreateFromBagAndSlot then
    itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
  end
  if not itemLocation or not itemLocation:IsValid() then
    DisenchanterPlus:Debug("CraftEnchant: posicion de item invalida")
    return
  end

  local ok, err = pcall(C_TradeSkillUI.CraftEnchant, recipeID, 1, nil, itemLocation)
  DisenchanterPlus:Debug(string.format("CraftEnchant(%s, 1, nil, bag=%s slot=%s) -> ok=%s err=%s",
    tostring(recipeID), tostring(bag), tostring(slot), tostring(ok), tostring(err or "")))
  if not ok then
    DisenchanterPlus:Print("|cffff4040CraftEnchant: " .. tostring(err) .. "|r")
  end
end

---Enable enchant button
function DP_EnchantWindow:EnableEnchantButton()
  if not EnchanterPlusBaseFrame or not EnchanterPlusBaseFrame.yesButton then return end
  if not lastItemCurrent or not lastEnchantCurrent then return end
  EnchanterPlusBaseFrame.yesButton:SetEnabled(true)
end

---Disable enchant button
function DP_EnchantWindow:DisableEnchantButton()
  if not EnchanterPlusBaseFrame or not EnchanterPlusBaseFrame.yesButton then return end
  EnchanterPlusBaseFrame.yesButton:SetEnabled(false)
end

---Update key bindings
function DP_EnchantWindow:UpdateKeybindings()
  if DisenchanterPlus.db.char.general.confirmEnchant ~= nil then
    SetBindingClick(DisenchanterPlus.db.char.general.confirmEnchant, "EnchantWindow_YesButton", "LeftButton")
  end
end

---Draw craft button
---@param name string
---@param icon string
---@param tooltipText string
---@param craftIndex string
---@param x number
---@param y number
function DP_EnchantWindow:DrawCraftButton(name, icon, tooltipText, craftIndex, x, y)
  if not EnchanterPlusBaseFrame.craftButton then
    EnchanterPlusBaseFrame.craftButton = {}
  end

  local craftButton = CreateFrame("Button", name, EnchanterPlusBaseFrame, BackdropTemplateMixin and "BackdropTemplate")
  craftButton.craftIndex = craftIndex
  craftButton:SetSize(32, 22)
  craftButton:SetPoint("TOPRIGHT", EnchanterPlusBaseFrame, x, y)
  craftButton:SetFrameLevel(2)
  craftButton:SetScript("OnEnter", function(current)
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(tooltipText, 1, 0.82, 0, 1, true)
    current.text:SetText("|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. "_fill:16:16|t ") --.. DisenchanterPlus:DP_i18n("Settings")
    current:SetAlpha(0.8)
  end)
  craftButton:SetScript("OnLeave", function(current)
    GameTooltip:Hide()
    local craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. ":16:16|t "
    if DP_EnchantWindow:CheckCraftTypeStatus(current.craftIndex) then
      craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. "_fill:16:16|t "
    end
    current.text:SetText(craftString)
    current:SetAlpha(0.6)
  end)
  craftButton:SetScript("OnClick", function(current)
    DP_EnchantWindow:ClickCraftTypeButton(craftIndex, icon)
  end)
  craftButton:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    edgeSize = 2,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  craftButton:SetBackdropColor(0.0, 0.0, 0.0, 0.0)
  craftButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
  craftButton:SetAlpha(0.6)

  local craftText = craftButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. ":16:16|t "
  if DP_EnchantWindow:CheckCraftTypeStatus(craftIndex) then
    craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. "_fill:16:16|t "
  end

  craftText:SetPoint("CENTER", craftButton, 2, 0)
  craftText:SetJustifyH("CENTER")
  craftText:SetText(craftString)
  craftButton.text = craftText

  EnchanterPlusBaseFrame.craftButton[craftIndex] = craftButton
  craftButton:Show()
end

---Chceck craft type
---@param craftIndex string
---@return boolean
function DP_EnchantWindow:CheckCraftTypeStatus(craftIndex)
  if DisenchanterPlus.db.char.general.enchantCraftType[craftIndex] == nil or DisenchanterPlus.db.char.general.enchantCraftType[craftIndex] == true then
    return true
  else
    return false
  end
end

---Click craft button
---@param craftIndex string
---@param icon string
function DP_EnchantWindow:ClickCraftTypeButton(craftIndex, icon)
  if DP_EnchantWindow:CheckCraftTypeStatus(craftIndex) then
    DisenchanterPlus.db.char.general.enchantCraftType[craftIndex] = false
  else
    DisenchanterPlus.db.char.general.enchantCraftType[craftIndex] = true
  end
  DP_CustomSounds:PlayCustomSound("ChatScrollButton")
  DP_EnchantWindow:RedrawCraftButton(craftIndex, icon)
end

---Redraw craft button
---@param craftIndex string
---@param icon string
function DP_EnchantWindow:RedrawCraftButton(craftIndex, icon)
  local craftButton = EnchanterPlusBaseFrame.craftButton[craftIndex]
  if craftButton then
    local craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. ":16:16|t "
    if DP_EnchantWindow:CheckCraftTypeStatus(craftIndex) then
      craftString = "|TInterface\\AddOns\\DisenchanterPlus\\Images\\CraftTypes\\" .. icon .. "_fill:16:16|t "
    end
    craftButton.text:SetText(craftString)
    C_Timer.After(0.1, function()
      enchantSelected = nil
      lastEnchantCurrent = nil
      RefreshItemSource()
    end)
  end
end
