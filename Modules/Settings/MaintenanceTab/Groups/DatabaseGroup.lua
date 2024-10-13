---@class DP_DatabaseGroup
local DP_DatabaseGroup = DP_ModuleLoader:CreateModule("DP_DatabaseGroup");

---@type DP_CustomConfig
local DP_CustomConfig = DP_ModuleLoader:ImportModule("DP_CustomConfig")

---@type DP_Database
local DP_Database = DP_ModuleLoader:ImportModule("DP_Database")

---@type DP_CustomFrames
local DP_CustomFrames = DP_ModuleLoader:ImportModule("DP_CustomFrames")

---@type DP_CustomPopup
local DP_CustomPopup = DP_ModuleLoader:ImportModule("DP_CustomPopup")

---@type DP_CustomMedias
local DP_CustomMedias = DP_ModuleLoader:ImportModule("DP_CustomMedias")

function DP_DatabaseGroup:Header()
  return DP_CustomConfig:CreateHeaderConfig(DisenchanterPlus:DP_i18n("Database"), 88, DisenchanterPlus:GetAddonColor())
end

function DP_DatabaseGroup:Config()
  return {
    type = "group",
    order = 89,
    inline = true,
    name = "",
    args = {
      executeUpdateDb = {
        type = "execute",
        order = 1,
        name = DP_CustomMedias:GetIconFileAsLink("update_a", 16, 16) .. " " .. DisenchanterPlus:DP_i18n("Update"),
        desc = DisenchanterPlus:DP_i18n("Update database manually."),
        width = 1,
        disabled = false,
        func = function()
          DP_Database:UpdateDatabase()
        end,
      },
      consolidateDb = {
        type = "execute",
        order = 2,
        name = DP_CustomMedias:GetIconFileAsLink("consolidate_a", 16, 16) .. " " .. DisenchanterPlus:DP_i18n("Consolidate"),
        desc = DisenchanterPlus:DP_i18n("Consolidate players and items in database."),
        width = 1,
        disabled = false,
        func = function()
          DP_CustomPopup:CreatePopup(
            DisenchanterPlus:DP_i18n("Consolidate database"),
            DisenchanterPlus:DP_i18n("Are you sure you want to consolidate the database?") .. "\n\n" .. " |cffff3300" .. DisenchanterPlus:DP_i18n("This operation can not be undone...") .. "|r",
            function()
              DP_Database:ConsolidateDatabase()
            end)
        end,
      },
      cleanUpDb = {
        type = "execute",
        order = 3,
        name = DP_CustomMedias:GetIconFileAsLink("cleanup_a", 16, 16) .. " " .. DisenchanterPlus:DP_i18n("Clean up"),
        desc = DisenchanterPlus:DP_i18n("Clean up all database by removing old data."),
        width = 1,
        disabled = false,
        func = function()
          DP_CustomPopup:CreatePopup(
            DisenchanterPlus:DP_i18n("Clean up database"),
            DisenchanterPlus:DP_i18n("Are you sure you want to clean up database?") .. "\n\n" .. " |cffff3300" .. DisenchanterPlus:DP_i18n("This operation can not be undone...") .. "|r",
            function()
              DP_Database:CleanDatabase()
            end)
        end,
      },
      purgeDb = {
        type = "execute",
        order = 4,
        name = DP_CustomMedias:GetIconFileAsLink("purge_a", 16, 16) .. " " .. DisenchanterPlus:DP_i18n("Purge"),
        desc = DisenchanterPlus:DP_i18n("Purge all database entries."),
        width = 1,
        disabled = false,
        func = function()
          DP_CustomPopup:CreatePopup(
            DisenchanterPlus:DP_i18n("Purge database"),
            DisenchanterPlus:DP_i18n("Are you sure you want to purge entire database?") .. "\n\n" .. " |cffff3300" .. DisenchanterPlus:DP_i18n("This operation can not be undone...") .. "|r",
            function()
              DP_Database:PurgeDatabase()
            end)
        end,
      },
    }
  }
end
