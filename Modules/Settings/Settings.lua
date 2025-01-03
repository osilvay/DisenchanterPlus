---@class DP_Settings
local DP_Settings = DP_ModuleLoader:CreateModule("DP_Settings")

---@type DP_CustomPopup
local DP_CustomPopup = DP_ModuleLoader:ImportModule("DP_CustomPopup");

---@type DP_CustomSounds
local DP_CustomSounds = DP_ModuleLoader:ImportModule("DP_CustomSounds");

---@type DP_DisenchantProcess
local DP_DisenchantProcess = DP_ModuleLoader:ImportModule("DP_DisenchantProcess");

---@type DP_DisenchantGroup
local DP_DisenchantGroup = DP_ModuleLoader:ImportModule("DP_DisenchantGroup");

---@type DP_EnchantProcess
local DP_EnchantProcess = DP_ModuleLoader:ImportModule("DP_EnchantProcess");

-- Forward declaration
DP_Settings.tabs = { ... }

---@type AceGUIFrame, AceGUIFrame
DisenchanterPlusSettingsFrame = nil

local LibStub = LibStub
local AceGUI = LibStub("AceGUI-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

function DP_Settings:Initialize()
  local optionsTable = DP_Settings._CreateSettingsTable()
  AceConfigRegistry:RegisterOptionsTable("DisenchanterPlus", optionsTable)
  AceConfigDialog:AddToBlizOptions("DisenchanterPlus", "DisenchanterPlus");
  if not DisenchanterPlusSettingsFrame then
    --DisenchanterPlus:Debug("Draw settings frame")
    DP_Settings:DrawSettingsFrame()
  end
end

function DP_Settings:DrawSettingsFrame()
  --DisenchanterPlus:Debug(DisenchanterPlus:DP_i18n("Creating settings frame"))
  ---@type AceGUIFrame, AceGUIFrame
  local disenchanterPlusSettingsFrame = AceGUI:Create("Frame");
  AceConfigDialog:SetDefaultSize("DisenchanterPlus", 600, 480)
  AceConfigDialog:Open("DisenchanterPlus", disenchanterPlusSettingsFrame) -- load the options into configFrame
  disenchanterPlusSettingsFrame:SetTitle(string.format("%s", DisenchanterPlus:GetAddonColoredName()))
  disenchanterPlusSettingsFrame:SetLayout("Fill")
  disenchanterPlusSettingsFrame:EnableResize(false)
  disenchanterPlusSettingsFrame:SetStatusText(string.format("%s %s", DisenchanterPlus:GetAddonColoredName(), DisenchanterPlus:GetAddonColoredVersion()))
  --disenchanterPlusSettingsFrame:Hide()
  disenchanterPlusSettingsFrame:SetCallback("OnShow", function(widget)
    --DisenchanterPlus:Debug("Showing settings...")
    DP_CustomSounds:PlayCustomSound("WindowOpen")
    DP_DisenchantGroup:CreateSessionIgnoreListItems(DP_DisenchantGroup:GetSessionIgnoreList())
  end)
  disenchanterPlusSettingsFrame:SetCallback("OnClose", function(widget)
    DP_CustomSounds:PlayCustomSound("WindowClose")
    if DP_CustomPopup:IsOpened() then
      DP_CustomPopup:CancelPopup()
    end
    if DP_EnchantProcess:IsCraftingWindowOpen() then
      DP_EnchantProcess:OpenEnchantWindow()
    end
    C_Timer.After(1, function()
      DP_DisenchantProcess:StartAutoDisenchant(true)
    end)
  end)
  DisenchanterPlusSettingsFrame = disenchanterPlusSettingsFrame;

  _G["DisenchanterPlusSettingsFrame"] = DisenchanterPlusSettingsFrame.frame
  table.insert(UISpecialFrames, "DisenchanterPlusSettingsFrame");
end

---@return table
DP_Settings._CreateSettingsTable = function()
  local general_tab = DP_Settings.tabs.general:Initialize(2)
  local enchant_tab = DP_Settings.tabs.enchant:Initialize(3)
  local disenchant_tab = DP_Settings.tabs.disenchant:Initialize(4)
  local tooltips_tab = DP_Settings.tabs.tooltips:Initialize(5)
  local keybindings_tab = DP_Settings.tabs.keybindings:Initialize(6)
  local advanced_tab = DP_Settings.tabs.advanced:Initialize(10)
  local maintenance_tab = DP_Settings.tabs.maintenance:Initialize(11)

  return {
    name = "DisenchanterPlus",
    handler = DisenchanterPlus,
    type = "group",
    childGroups = "tree",
    args = {
      general_tab = general_tab,
      enchant_tab = enchant_tab,
      disenchant_tab = disenchant_tab,
      tooltips_tab = tooltips_tab,
      keybindings_tab = keybindings_tab,
      advanced_tab = advanced_tab,
      maintenance_tab = maintenance_tab,
      --profiles_tab = LibStub("AceDBOptions-3.0"):GetOptionsTable(DisenchanterPlus.db),
    }
  }
end

-- Generic function to hide the config frame.
function DP_Settings:HideSettingsFrame()
  if DisenchanterPlusSettingsFrame and DisenchanterPlusSettingsFrame:IsShown() then
    DisenchanterPlusSettingsFrame:Hide();
  end
end

---Open the configuration window
function DP_Settings:OpenSettingsFrame()
  if not DisenchanterPlusSettingsFrame then
    --DisenchanterPlus:Debug("No settings frame")
    return
  end

  if not DisenchanterPlusSettingsFrame:IsShown() then
    --DP_CustomSounds:PlayCustomSound("WindowOpen")
    --GearScorePlus:Debug("Show settings frame")
    --AceConfigDialog:SelectGroup("DisenchanterPlus", "general_tab")
    --AceConfigRegistry:NotifyChange("DisenchanterPlus")
    DisenchanterPlusSettingsFrame:Show()
    DP_DisenchantProcess:CancelAutoDisenchant(true)
    --AceConfigDialog:Open("DisenchanterPlus")
    --DisenchanterPlusSettingsFrame:EnableResize(false)
  else
    --DisenchanterPlus:Debug("Hide Config frame")
    --DisenchanterPlusSettingsFrame:Hide()
    AceConfigDialog:Close("DisenchanterPlus")
  end
end

function DP_Settings:RefreshConfig()
  AceConfigRegistry:NotifyChange("DisenchanterPlus")
end

---Open settings with tab
---@param tabName string
---@param time? number
function DP_Settings:OpenSettingsTab(tabName, time)
  if time == nil then time = 0.1 end
  C_Timer.After(time, function()
    AceConfigDialog:SelectGroup("DisenchanterPlus", tabName)
  end)
end
