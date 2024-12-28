---@class DP_DisenchanterPlusEvents
local DP_DisenchanterPlusEvents = DP_ModuleLoader:CreateModule("DP_DisenchanterPlusEvents")
local _DP_DisenchanterPlusEvents = {}

---@type DP_LootProcess
local DP_LootProcess = DP_ModuleLoader:ImportModule("DP_LootProcess")

---@type DP_DisenchantProcess
local DP_DisenchantProcess = DP_ModuleLoader:ImportModule("DP_DisenchantProcess")

---@type DP_EnchantProcess
local DP_EnchantProcess = DP_ModuleLoader:ImportModule("DP_EnchantProcess")

function DP_DisenchanterPlusEvents:Initialize()
  DisenchanterPlus:RegisterEvent("UNIT_SPELLCAST_SENT", _DP_DisenchanterPlusEvents.UnitSpellCastSent)
  DisenchanterPlus:RegisterEvent("UNIT_SPELLCAST_START", _DP_DisenchanterPlusEvents.UnitSpellCastStart)
  DisenchanterPlus:RegisterEvent("UNIT_SPELLCAST_STOP", _DP_DisenchanterPlusEvents.UnitSpellCastStop)
  DisenchanterPlus:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", _DP_DisenchanterPlusEvents.UnitSpellCastSucceeded)
  DisenchanterPlus:RegisterEvent("UNIT_SPELLCAST_FAILED", _DP_DisenchanterPlusEvents.UnitSpellCastFailed)
  DisenchanterPlus:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", _DP_DisenchanterPlusEvents.UnitSpellCastInterrupted)
  DisenchanterPlus:RegisterEvent("LOOT_READY", _DP_DisenchanterPlusEvents.LootReady)
  DisenchanterPlus:RegisterEvent("LOOT_CLOSED", _DP_DisenchanterPlusEvents.LootClosed)
  DisenchanterPlus:RegisterEvent("BAG_UPDATE", _DP_DisenchanterPlusEvents.BagUpdate)
  DisenchanterPlus:RegisterEvent("ITEM_LOCKED", _DP_DisenchanterPlusEvents.ItemLocked)
  DisenchanterPlus:RegisterEvent("PLAYER_REGEN_DISABLED", _DP_DisenchanterPlusEvents.PlayerRegenDisabled)
  DisenchanterPlus:RegisterEvent("PLAYER_REGEN_ENABLED", _DP_DisenchanterPlusEvents.PlayerRegenEnabled)

  if DisenchanterPlus.IsClassic or DisenchanterPlus.IsHardcore or DisenchanterPlus.IsEra or DisenchanterPlus.IsEraSeasonal then
    -- classic_era
    DisenchanterPlus:RegisterEvent("CRAFT_SHOW", _DP_DisenchanterPlusEvents.CraftShow)
    DisenchanterPlus:RegisterEvent("CRAFT_CLOSE", _DP_DisenchanterPlusEvents.CraftClose)
  elseif DisenchanterPlus.IsCataclysm then
    -- cataclysm
    DisenchanterPlus:RegisterEvent("TRADE_SKILL_SHOW", _DP_DisenchanterPlusEvents.CraftShow)
    DisenchanterPlus:RegisterEvent("TRADE_SKILL_CLOSE", _DP_DisenchanterPlusEvents.CraftClose)
  end
  DP_LootProcess:Initialize()
  DP_DisenchantProcess:Initialize()
end

function _DP_DisenchanterPlusEvents.UnitSpellCastSent(_, unit, target, castGUID, spellID)
  DP_DisenchantProcess:UnitSpellCastSent(unit, target, castGUID, spellID)
end

function _DP_DisenchanterPlusEvents.UnitSpellCastStart(_, unitTarget, castGUID, spellID)
  DP_DisenchantProcess:UnitSpellCastStart(unitTarget, castGUID, spellID)
end

function _DP_DisenchanterPlusEvents.UnitSpellCastStop(_, unitTarget, castGUID, spellID)
  DP_DisenchantProcess:UnitSpellCastStop(unitTarget, castGUID, spellID)
end

function _DP_DisenchanterPlusEvents.UnitSpellCastSucceeded(_, unitTarget, castGUID, spellID)
  DP_LootProcess:UnitSpellCastSucceeded(unitTarget, castGUID, spellID)
  DP_EnchantProcess:UnitSpellCastSucceeded(unitTarget, castGUID, spellID)
end

function _DP_DisenchanterPlusEvents.UnitSpellCastFailed(_, unitTarget, castGUID, spellID)
  DP_DisenchantProcess:UnitSpellCastFailed(unitTarget, castGUID, spellID)
end

function _DP_DisenchanterPlusEvents.UnitSpellCastInterrupted(_, unitTarget, castGUID, spellID)
  DP_DisenchantProcess:UnitSpellCastInterrupted(unitTarget, castGUID, spellID)
end

function _DP_DisenchanterPlusEvents.LootReady(_)
  DP_LootProcess:LootReady()
end

function _DP_DisenchanterPlusEvents.LootClosed(_)
  DP_LootProcess:LootClosed()
  DP_DisenchantProcess:LootClosed()
end

function _DP_DisenchanterPlusEvents.BagUpdate(_, bagIndex)
  DP_DisenchantProcess:BagUpdate(bagIndex)
end

function _DP_DisenchanterPlusEvents.ItemLocked(_, bagOrSlotIndex, slotIndex)
  DP_LootProcess:ItemLocked(bagOrSlotIndex, slotIndex)
end

function _DP_DisenchanterPlusEvents.PlayerRegenDisabled(_)
  DP_DisenchantProcess:PlayerRegenDisabled()
end

function _DP_DisenchanterPlusEvents.PlayerRegenEnabled(_)
  DP_DisenchantProcess:PlayerRegenEnabled()
end

function _DP_DisenchanterPlusEvents.CraftShow(_)
  DP_EnchantProcess:CraftShow()
end

function _DP_DisenchanterPlusEvents.CraftClose(_)
  DP_EnchantProcess:CraftClose()
end
