--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Compatibility layer
    Hides the API differences between client versions behind a small interface.

    The Assistant Button only exists in the mainline client (Midnight, 12.x),
    but several action bar functions moved into C_ActionBar over time and some
    combat values may come back as "secret" values that addon code cannot
    compare. Rule of thumb: always probe for an API instead of assuming it.
------------------------------------------------------------------------------]]

local ADDON_NAME, ns = ...

local Compat = {}
ns.Compat = Compat

local ActionBar = C_ActionBar or {}

local getActionTexture = ActionBar.GetActionTexture or _G.GetActionTexture
local getActionInfo = ActionBar.GetActionInfo or _G.GetActionInfo
local isActionInRange = ActionBar.IsActionInRange or _G.IsActionInRange
local isUsableAction = ActionBar.IsUsableAction or _G.IsUsableAction
local pickupAction = ActionBar.PickupAction or _G.PickupAction
local placeAction = ActionBar.PlaceAction or _G.PlaceAction

--- Reads a TOC metadata field of this addon.
function Compat.GetAddOnMetadata(field)
    local getter = (C_AddOns and C_AddOns.GetAddOnMetadata) or _G.GetAddOnMetadata
    return getter and getter(ADDON_NAME, field)
end

--- Returns true when the client hides the value from addon code. Secret values
--- can be handed to widgets but cannot be compared or tested.
function Compat.IsSecret(value)
    return _G.issecretvalue ~= nil and _G.issecretvalue(value) == true
end

--------------------------------------------------------------------------------
-- Action slots
--------------------------------------------------------------------------------

--- Returns the icon of an action slot, or nil when it is empty.
function Compat.GetActionTexture(slot)
    return getActionTexture and getActionTexture(slot)
end

--- Returns the type and id of what an action slot holds ("spell", 1229376).
function Compat.GetActionInfo(slot)
    if not getActionInfo then
        return nil
    end
    return getActionInfo(slot)
end

--- Returns true, false or nil (no range to check) for an action slot.
--- Secret values are reported as nil, so the button is never tinted wrongly.
function Compat.IsActionInRange(slot)
    if not isActionInRange then
        return nil
    end
    local ok, inRange = pcall(isActionInRange, slot)
    if not ok or Compat.IsSecret(inRange) then
        return nil
    end
    return inRange
end

--- Returns usable, notEnoughPower for an action slot. Unknown or secret
--- values are reported as usable.
function Compat.IsUsableAction(slot)
    if not isUsableAction then
        return true, false
    end
    local ok, usable, noPower = pcall(isUsableAction, slot)
    if not ok or Compat.IsSecret(usable) or Compat.IsSecret(noPower) then
        return true, false
    end
    return usable, noPower
end

--- Empties an action slot. Must not be called in combat.
function Compat.ClearAction(slot)
    if pickupAction then
        pickupAction(slot)
        ClearCursor()
    end
end

--- Places a spell into an action slot. Returns true when it was placed.
--- Must not be called in combat.
function Compat.PlaceSpell(spellID, slot)
    local pickupSpell = (C_Spell and C_Spell.PickupSpell) or _G.PickupSpell
    if not (pickupSpell and placeAction) then
        return false
    end
    pickupSpell(spellID)
    if not GetCursorInfo() then
        return false
    end
    placeAction(slot)
    ClearCursor()
    return true
end

--- Returns the spell id when the character knows the spell, otherwise nil.
function Compat.GetKnownSpellID(spellID)
    local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
    return info and info.spellID
end

--------------------------------------------------------------------------------
-- Player state
--------------------------------------------------------------------------------

--- Returns true while combat restrictions apply to protected actions.
function Compat.InCombatLockdown()
    return InCombatLockdown() == true
end
