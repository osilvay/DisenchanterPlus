---@class DP_WelcomeWindow
local DP_WelcomeWindow = DP_ModuleLoader:CreateModule("DP_WelcomeWindow")

local DEFAULT_DIALOG_BACKDROP = {
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

local FRAME_WIDTH = 540
local FRAME_HEIGHT = 430
local TEXT_WIDTH = 450
local textFrameBgColorAlpha = 0.85

local frames = {}
local shownThisSession = {
  enchant = false,
  disenchant = false,
}

local windowTitles = {
  enchant = "Enchanting",
  disenchant = "Disenchant",
}

local windowFrameNames = {
  enchant = "DisenchanterPlus_Welcome_Enchant",
  disenchant = "DisenchanterPlus_Welcome_Disenchant",
}

local windowMainFrameNames = {
  enchant = "EnchantWindow_BaseFrame",
  disenchant = "DisenchanterPlus_AutoDisenchant",
}

local hookedParents = {}

---Get translated text
---@param key string
---@return string
local function t(key)
  return DisenchanterPlus:DP_i18n(key)
end

---Format text with the addon color
---@param text string
---@return string
local function header(text)
  return string.format("|c%s%s|r", DisenchanterPlus:GetAddonColor(), text)
end

---Format text as a gold bullet
---@param text string
---@return string
local function bullet(text)
  return string.format("|cffffd100-|r %s", text)
end

---Build the welcome text for the given window
---@param kind string
---@return string
local function BuildContent(kind)
  local lines = {}

  lines[#lines + 1] = header(t("How does it work?"))
  lines[#lines + 1] = bullet(t("Open the Enchanting profession window; this window opens automatically."))

  if kind == "enchant" then
    lines[#lines + 1] = bullet(t("The Enchant list tab shows your recipes and the Items in bags tab shows the items you can enchant."))
    lines[#lines + 1] = bullet(t("Select a recipe and an item, then press Enchant to apply it."))
    lines[#lines + 1] = bullet(t("You can also use the keybind configured in the Keybindings tab."))
    lines[#lines + 1] = ""

    lines[#lines + 1] = header(t("Filters"))
    lines[#lines + 1] = bullet(t("Optimal, Medium, Easy and Trivial filter the recipes by difficulty."))
    lines[#lines + 1] = bullet(t("Use the Enchants list menu to filter recipes by skill gain or available materials."))
    lines[#lines + 1] = ""

    lines[#lines + 1] = header(t("Good to know"))
    lines[#lines + 1] = bullet(t("Use Refresh enchants after learning new recipes."))
    lines[#lines + 1] = bullet(t("Replacing an existing enchant is confirmed automatically."))
    lines[#lines + 1] = bullet(t("Enchanting vellums are supported too."))
  else
    lines[#lines + 1] = bullet(t("The addon scans your bags and lists the disenchantable items."))
    lines[#lines + 1] = bullet(t("Press Proceed to disenchant the selected items one by one."))
    lines[#lines + 1] = bullet(t("Press Cancel to skip the current item for this session."))
    lines[#lines + 1] = ""

    lines[#lines + 1] = header(t("Filters"))
    lines[#lines + 1] = bullet(t("Uncommon, Rare and Epic filter the items by quality."))
    lines[#lines + 1] = ""

    lines[#lines + 1] = header(t("Good to know"))
    lines[#lines + 1] = bullet(t("Use Pause and Play to stop or resume the process."))
    lines[#lines + 1] = bullet(t("Ignore adds the item to the permanent ignore list. The ignored list button shows the skipped items."))
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = "|cff919191" .. t("You can hide this screen with the checkbox below or in Settings > General.") .. "|r"

  return table.concat(lines, "\n")
end

---Resize the scroll child to fit the text
---@param frame table
local function UpdateScrollHeight(frame)
  local textHeight = frame.bodyText:GetStringHeight() or 0
  frame.scrollChild:SetHeight(math.max(textHeight + 10, 10))
end

---Remove the frame from UISpecialFrames
---@param frameName string
local function RemoveFromUISpecialFrames(frameName)
  for i, name in ipairs(UISpecialFrames) do
    if name == frameName then
      table.remove(UISpecialFrames, i)
      break
    end
  end
end

---Add the frame to UISpecialFrames only once
---@param frameName string
local function AddToUISpecialFrames(frameName)
  for _, name in ipairs(UISpecialFrames) do
    if name == frameName then return end
  end
  table.insert(UISpecialFrames, frameName)
end

---Create the welcome frame for the given window
---@param kind string
---@return table
function DP_WelcomeWindow:CreateWelcomeFrame(kind)
  local frameName = windowFrameNames[kind]

  local frame = CreateFrame("Frame", frameName, UIParent, BackdropTemplateMixin and "BackdropTemplate")
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(10)
  frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetClampedToScreen(true)
  frame:SetScript("OnMouseDown", function(self)
    self:StartMoving()
  end)
  frame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
  end)
  frame:SetBackdrop(DEFAULT_DIALOG_BACKDROP)
  frame:SetBackdropColor(0, 0, 0, textFrameBgColorAlpha)
  frame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)

  local windowBackground = frame:CreateTexture(nil, "BACKGROUND")
  windowBackground:SetDrawLayer("BACKGROUND", 1)
  windowBackground:SetPoint("TOPLEFT", frame, 4, -4)
  windowBackground:SetPoint("BOTTOMRIGHT", frame, -4, 4)
  windowBackground:SetColorTexture(DisenchanterPlus:GetAddonWindowBackgroundColorRGB():GetRGB())
  windowBackground:SetAlpha(0.8)
  frame.windowBackground = windowBackground

  -- title
  local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  titleText:SetPoint("TOPLEFT", frame, 20, -12)
  titleText:SetText(DisenchanterPlus:GetAddonColoredName())
  frame.titleText = titleText

  local subtitleText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  subtitleText:SetPoint("TOPLEFT", frame, 20, -34)
  subtitleText:SetTextColor(0.8, 0.8, 0.8)
  subtitleText:SetText(string.format("%s - %s", t("Welcome screen"), t(windowTitles[kind])))
  frame.subtitleText = subtitleText

  -- scrollable content
  local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -60)
  scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -44, 56)
  frame.scrollFrame = scrollFrame

  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetSize(TEXT_WIDTH, 10)
  scrollFrame:SetScrollChild(scrollChild)
  frame.scrollChild = scrollChild

  local bodyText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  bodyText:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
  bodyText:SetWidth(TEXT_WIDTH)
  bodyText:SetJustifyH("LEFT")
  bodyText:SetJustifyV("TOP")
  if bodyText.SetSpacing then
    bodyText:SetSpacing(4)
  end
  bodyText:SetText(BuildContent(kind))
  frame.bodyText = bodyText

  -- hide welcome screen checkbox
  local checkButton = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
  checkButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 22, 20)
  checkButton:SetSize(26, 26)
  checkButton:SetScript("OnClick", function(self)
    DisenchanterPlus.db.char.general.hideWelcomeScreen = self:GetChecked() and true or false
    if self:GetChecked() then
      DP_WelcomeWindow:CloseWindow(kind)
    end
  end)
  frame.checkButton = checkButton

  local checkText = checkButton.Text
  if not checkText then
    checkText = checkButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    checkText:SetPoint("LEFT", checkButton, "RIGHT", 0, 0)
  end
  checkText:SetText(t("Hide welcome screen"))
  checkText:SetTextColor(1, 1, 1)

  -- close button
  local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  closeButton:SetSize(110, 26)
  closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -24, 18)
  closeButton:SetText(t("Close"))
  closeButton:SetScript("OnClick", function()
    DP_WelcomeWindow:CloseWindow(kind)
  end)
  frame.closeButton = closeButton

  frame:SetScript("OnShow", function(self)
    UpdateScrollHeight(self)
  end)
  frame:SetScript("OnHide", function()
    RemoveFromUISpecialFrames(frameName)
    -- Restore the main window so Escape keeps closing it as usual.
    local mainFrameName = windowMainFrameNames[kind]
    local mainFrame = _G[mainFrameName]
    if mainFrame and mainFrame:IsVisible() then
      AddToUISpecialFrames(mainFrameName)
    end
  end)

  frame:Hide()
  return frame
end

---Show the welcome frame for the given window once per session
---@param kind string
function DP_WelcomeWindow:ShowIfNeeded(kind)
  if kind ~= "enchant" and kind ~= "disenchant" then return end
  if shownThisSession[kind] then return end
  if DisenchanterPlus.db == nil or DisenchanterPlus.db.char == nil or DisenchanterPlus.db.char.general == nil then return end
  if DisenchanterPlus.db.char.general.hideWelcomeScreen then return end
  if InCombatLockdown() or UnitAffectingCombat("player") then return end

  shownThisSession[kind] = true

  if not frames[kind] then
    frames[kind] = DP_WelcomeWindow:CreateWelcomeFrame(kind)
  end

  local frame = frames[kind]
  frame.checkButton:SetChecked(false)

  -- Keep only the welcome frame in UISpecialFrames while it is open, so Escape
  -- closes the welcome screen instead of the main window behind it.
  local mainFrameName = windowMainFrameNames[kind]
  local mainFrame = _G[mainFrameName]
  if mainFrame then
    RemoveFromUISpecialFrames(mainFrameName)
    if not hookedParents[kind] then
      mainFrame:HookScript("OnHide", function()
        DP_WelcomeWindow:CloseWindow(kind)
      end)
      hookedParents[kind] = true
    end
  end

  AddToUISpecialFrames(windowFrameNames[kind])

  frame:Show()
  UpdateScrollHeight(frame)
end

---Close the welcome frame for the given window
---@param kind string
function DP_WelcomeWindow:CloseWindow(kind)
  local frame = frames[kind]
  if frame == nil then return end
  RemoveFromUISpecialFrames(windowFrameNames[kind])
  frame:Hide()
end

---Close any open welcome frame
function DP_WelcomeWindow:CloseAll()
  for kind in pairs(frames) do
    DP_WelcomeWindow:CloseWindow(kind)
  end
end
