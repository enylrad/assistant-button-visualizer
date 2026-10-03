--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Installer
    Keeps the Assistant Button spell in the configured action slot, so the
    visualizer can mirror it. Action slots cannot be changed in combat, so any
    change requested then is run when combat ends.
------------------------------------------------------------------------------]]

local _, ns = ...

local Installer = ns:NewModule("Installer")
local Compat = ns.Compat
local L = ns.L

-- The Assistant Button ("Single-Button Assistant") spell.
Installer.SPELL_ID = 1229376

local LOGIN_DELAY = 2   -- the spellbook is not ready right at login
local CHANGE_DELAY = 1  -- let talent and specialization changes settle

-- Work deferred until combat ends: a slot to clear and an install to run.
local pending = { clear = nil, install = false, force = false }

--- Places the spell in the configured slot. Without `force` a slot that
--- already holds a spell is left alone: the assistant spell changes its id
--- with forms and stances, and replacing it plays a sound every time.
--- @param force boolean|nil replace whatever the slot holds
--- @return boolean placed
function Installer:Install(force)
    if Compat.InCombatLockdown() then
        pending.install = true
        pending.force = pending.force or force or false
        return false
    end

    local slot = ns.settings.slot
    local actionType = Compat.GetActionInfo(slot)
    if not force and actionType == "spell" then
        return false
    end

    local spellID = Compat.GetKnownSpellID(self.SPELL_ID)
    if not spellID then
        if force then
            ns:Print(L["ERROR_INVALID_SPELL"])
        end
        return false
    end

    if Compat.PlaceSpell(spellID, slot) then
        ns:Print(L["SPELL_INSTALLED"], slot)
        return true
    end
    return false
end

--- Empties a slot the addon used before. Only spells are removed, so an
--- action the player placed there afterwards is never lost.
local function ClearSlot(slot)
    if Compat.GetActionInfo(slot) == "spell" then
        Compat.ClearAction(slot)
        ns:Print(L["CLEARED_OLD_SLOT"], slot)
    end
end

--- Moves the spell to another action slot.
function Installer:SetSlot(slot)
    local oldSlot = ns.settings.slot
    if slot == oldSlot then
        return
    end
    ns.settings.slot = slot
    ns:SendMessage("ABV_SLOT_CHANGED", slot, oldSlot)

    if Compat.InCombatLockdown() then
        pending.clear = pending.clear or oldSlot
        pending.install = true
        ns:Print(L["SLOT_CHANGED_PENDING"], slot)
        return
    end
    ClearSlot(oldSlot)
    self:Install(false)
end

--- Runs the work that was requested during combat.
local function RunPending()
    if pending.clear and pending.clear ~= ns.settings.slot then
        ClearSlot(pending.clear)
    end
    local install, force = pending.install, pending.force
    pending.clear, pending.install, pending.force = nil, false, false
    if install then
        Installer:Install(force)
    end
end

local function InstallLater(delay)
    C_Timer.After(delay, function()
        Installer:Install(false)
    end)
end

function Installer:OnLogin()
    InstallLater(LOGIN_DELAY)
    ns:RegisterEvent("PLAYER_REGEN_ENABLED", RunPending)
    ns:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function(_, unit)
        if unit == nil or unit == "player" then
            InstallLater(CHANGE_DELAY)
        end
    end)
    ns:RegisterEvent("TRAIT_CONFIG_UPDATED", function()
        InstallLater(CHANGE_DELAY)
    end)
end
