---@class DP_CustomSounds
local DP_CustomSounds = DP_ModuleLoader:CreateModule("DP_CustomSounds")

local disenchanterPlusSoundTable

---Play critical hit sound
---@param name string
function DP_CustomSounds:PlayCustomSound(name)
  C_Timer.After(0.1, function()
    PlaySoundFile(DP_CustomSounds:GetSoundFile(name), "Master")
  end)
end

---Return sound
---@param typeSelected string
---@return string file
function DP_CustomSounds:GetSoundFile(typeSelected)
  return disenchanterPlusSoundTable[typeSelected]
end

--https://wowpedia.fandom.com/wiki/PlaySoundFile_macros
disenchanterPlusSoundTable = {
  ["MoneyDialogClose"] = "Interface/Addons/DisenchanterPlus/Sounds/MoneyDialogClose.ogg",
  ["WindowClose"]      = "Interface/Addons/DisenchanterPlus/Sounds/CharacterSheetClose.ogg",
  ["WindowOpen"]       = "Interface/Addons/DisenchanterPlus/Sounds/CharacterSheetOpen.ogg",
}
