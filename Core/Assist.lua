--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Assist
    Tells the button which spell the assisted combat system suggests.

    Sources (global setting `source`):
      api   asks C_AssistedCombat for the next spell. Nothing is placed on the
            action bars. Used whenever the client offers the API.
      slot  the method of 1.x: keeps the Assistant Button spell in an action
            slot and mirrors that slot's icon. A fallback for clients where
            the API is missing or does not work.

    Action slots cannot be changed in combat, so slot work requested then is
    run when combat ends.
------------------------------------------------------------------------------]]

local _, ns = ...

local Assist = ns:NewModule("Assist")
local Compat = ns.Compat
local L = ns.L

local DEFAULT_INTERVAL = 0.1
local LOGIN_DELAY = 2   -- the spellbook is not ready right at login
local CHANGE_DELAY = 1  -- let talent and specialization changes settle

-- Slot work deferred until combat ends.
local pending = { clear = nil, install = false, force = false }

--------------------------------------------------------------------------------
-- Source
--------------------------------------------------------------------------------

--- Returns the source in use: the saved one, or "slot" when the client has no
--- assisted combat API.
function Assist:GetSource()
    if ns.global.source == "api" and Compat.HasAssistedCombat() then
        return "api"
    end
    return "slot"
end

--- Seconds between two reads of the suggestion. Follows the client setting
--- that paces the Assistant Button itself, when there is one.
function Assist:GetInterval()
    local value = GetCVar and tonumber(GetCVar("assistedCombatIconUpdateRate") or "")
    if value and value > 0 then
        return ns.Clamp(value, 0.05, 1)
    end
    return DEFAULT_INTERVAL
end

--- Returns texture, spellID of the current suggestion; both nil when there is
--- none. With the slot source the spell id is nil: the slot holds the
--- Assistant Button spell, not the suggested one. Either value may be secret.
function Assist:GetSuggestion()
    if self:GetSource() == "api" then
        local spellID = Compat.GetNextCastSpell()
        if not Compat.IsSecret(spellID) and spellID == nil then
            return nil, nil
        end
        return Compat.GetSpellTexture(spellID), spellID
    end
    return Compat.GetActionTexture(ns.global.slot), nil
end

--------------------------------------------------------------------------------
-- Action slot (slot source and the clean-up of 1.x)
--------------------------------------------------------------------------------

--- Returns true when the slot holds the Assistant Button spell.
local function HoldsAssistantSpell(slot)
    local actionType, id = Compat.GetActionInfo(slot)
    return actionType == "spell" and id == Compat.GetAssistantSpell()
end

--- Empties a slot that holds the Assistant Button spell. Anything else the
--- player placed there is never touched.
local function ClearSlot(slot)
    if HoldsAssistantSpell(slot) then
        Compat.ClearAction(slot)
        ns:Print(L["CLEARED_OLD_SLOT"], slot)
    end
end

--- Places the Assistant Button spell in the configured slot (slot source).
--- Without `force` a slot that already holds a spell is left alone: the spell
--- changes its id with forms and stances, and replacing it plays a sound.
function Assist:Install(force)
    if self:GetSource() ~= "slot" then
        return false
    end
    if Compat.InCombatLockdown() then
        pending.install = true
        pending.force = pending.force or force or false
        return false
    end
    local slot = ns.global.slot
    if not force and Compat.GetActionInfo(slot) == "spell" then
        return false
    end
    local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(Compat.GetAssistantSpell())
    local spellID = info and info.spellID
    local pickupSpell = (C_Spell and C_Spell.PickupSpell) or _G.PickupSpell
    if not (spellID and pickupSpell) then
        if force then
            ns:Print(L["ERROR_INVALID_SPELL"])
        end
        return false
    end
    pickupSpell(spellID)
    if GetCursorInfo() and Compat.PlaceAction(slot) then
        ClearCursor()
        ns:Print(L["SPELL_INSTALLED"], slot)
        return true
    end
    ClearCursor()
    return false
end

local function RunWhenOutOfCombat(clearSlot, install)
    if Compat.InCombatLockdown() then
        pending.clear = pending.clear or clearSlot
        pending.install = pending.install or install
        return
    end
    if clearSlot then
        ClearSlot(clearSlot)
    end
    if install then
        Assist:Install(false)
    end
end

--- Moves the slot source to another action slot.
function Assist:SetSlot(slot)
    local oldSlot = ns.global.slot
    if slot == oldSlot then
        return
    end
    ns.global.slot = slot
    ns:SendMessage("ABV_SOURCE_CHANGED")
    if self:GetSource() == "slot" then
        if Compat.InCombatLockdown() then
            ns:Print(L["SLOT_CHANGED_PENDING"], slot)
        end
        RunWhenOutOfCombat(oldSlot, true)
    end
end

--- Switches between the API and the action slot.
function Assist:SetSource(source)
    if source == ns.global.source then
        return
    end
    ns.global.source = source
    if self:GetSource() == "slot" then
        RunWhenOutOfCombat(nil, true)
    else
        -- The slot is not needed any more.
        RunWhenOutOfCombat(ns.global.slot, false)
    end
    ns:SendMessage("ABV_SOURCE_CHANGED")
end

local function RunPending()
    local clear, install, force = pending.clear, pending.install, pending.force
    pending.clear, pending.install, pending.force = nil, false, false
    if clear and not (Assist:GetSource() == "slot" and clear == ns.global.slot) then
        ClearSlot(clear)
    end
    if install then
        Assist:Install(force)
    end
end

local function InstallLater(delay)
    C_Timer.After(delay, function()
        Assist:Install(false)
    end)
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

function Assist:OnLogin()
    ns:RegisterEvent("PLAYER_REGEN_ENABLED", RunPending)

    if self:GetSource() == "api" then
        -- 2.0 no longer needs the spell that 1.x left in an action slot.
        local legacySlot = ns.Database.legacySlot
        if legacySlot then
            C_Timer.After(LOGIN_DELAY, function()
                RunWhenOutOfCombat(legacySlot, false)
            end)
        end
    else
        if not Compat.HasAssistedCombat() and ns.global.source == "api" then
            ns:Print(L["API_MISSING"])
        end
        InstallLater(LOGIN_DELAY)
    end

    ns:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function(_, unit)
        if unit == nil or unit == "player" then
            InstallLater(CHANGE_DELAY)
        end
    end)
    ns:RegisterEvent("TRAIT_CONFIG_UPDATED", function()
        InstallLater(CHANGE_DELAY)
    end)
end
