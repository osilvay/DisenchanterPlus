---@class DP_CustomSounds
local DP_CustomSounds = DP_ModuleLoader:CreateModule("DP_CustomSounds")

local playerCensusPlusSoundTable

---Play critical hit sound
function DP_CustomSounds:PlayCriticalHit()
  C_Timer.After(0.5, function()
    PlaySoundFile(DP_CustomSounds:GetSoundFile("HitCritDefault"), "Master")
  end)
end

---Play normal hit sound
function DP_CustomSounds:PlayNormalHit()
  C_Timer.After(0.5, function()
    PlaySoundFile(DP_CustomSounds:GetSoundFile("HitDefault"), "Master")
  end)
end

---Play critical heal sound
function DP_CustomSounds:PlayCriticalHeal()
  C_Timer.After(0.5, function()
    PlaySoundFile(DP_CustomSounds:GetSoundFile("HitCritDefault"), "Master")
  end)
end

---Play normal heal sound
function DP_CustomSounds:PlayNormalHeal()
  C_Timer.After(0.5, function()
    PlaySoundFile(DP_CustomSounds:GetSoundFile("HitDefault"), "Master")
  end)
end

---Return sound
---@param typeSelected string
---@return string file
function DP_CustomSounds:GetSoundFile(typeSelected)
  return playerCensusPlusSoundTable[typeSelected]
end

--https://wowpedia.fandom.com/wiki/PlaySoundFile_macros
playerCensusPlusSoundTable = {
  ["HitCritDefault"] = "Sound/Interface/LevelUp.ogg",
  ["HitDefault"]     = "Sound/Interface/AuctionWindowOpen.ogg",
  ["Window Close"]   = "Sound/Interface/AuctionWindowClose.ogg",
  ["Window Open"]    = "Sound/Interface/AuctionWindowOpen.ogg",
}
