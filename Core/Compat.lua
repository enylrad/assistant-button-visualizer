--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Compatibility layer
    Hides the API differences between game flavors behind a small interface.

    Supported flavors:
      retail   Midnight and later (mainline client, 12.x)
      forever  WoW: Forever ("Camelot"): runs the mainline UI and API but
               reports a 1.x build and the mainline WOW_PROJECT_ID
      era      Classic Era / Anniversary realms (legacy classic API)
      classic  Classic progression realms (TBC, Mists...)

    Some combat values may come back as "secret" values on Midnight, which
    addon code can hand to widgets but cannot compare. Rule of thumb: always
    probe for an API instead of branching on the flavor.
------------------------------------------------------------------------------]]

local ADDON_NAME, ns = ...

local Compat = {}
ns.Compat = Compat

--------------------------------------------------------------------------------
-- Flavor detection
--------------------------------------------------------------------------------

local _, _, _, interfaceVersion = GetBuildInfo()
Compat.interfaceVersion = interfaceVersion or 0

local function DetectFlavor()
    local projectID = WOW_PROJECT_ID
    local foreverID = _G.WOW_PROJECT_CAMELOT or _G.WOW_PROJECT_FOREVER
    if foreverID and projectID == foreverID then
        return "forever"
    end
    if projectID == WOW_PROJECT_MAINLINE then
        -- Forever shares the mainline project id but ships a 1.x build.
        if Compat.interfaceVersion < 20000 then
            return "forever"
        end
        return "retail"
    end
    if WOW_PROJECT_CLASSIC and projectID == WOW_PROJECT_CLASSIC then
        return "era"
    end
    return "classic"
end

Compat.flavor = DetectFlavor()
Compat.isMainlineAPI = Compat.flavor == "retail" or Compat.flavor == "forever"

--------------------------------------------------------------------------------
-- Generic helpers
--------------------------------------------------------------------------------

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

--- Returns true while combat restrictions apply to protected actions.
function Compat.InCombatLockdown()
    return InCombatLockdown() == true
end

--- Returns a key that identifies the character: "Name-Realm".
function Compat.GetCharacterKey()
    local name = UnitName("player") or "?"
    local realm = GetRealmName and GetRealmName() or ""
    return name .. "-" .. realm
end

--- Returns the name of the active specialization, or nil on clients without
--- specializations (Vanilla and TBC).
function Compat.GetSpecName()
    if not GetSpecialization then
        return nil
    end
    local index = GetSpecialization()
    if not index then
        return nil
    end
    if GetSpecializationInfo then
        local _, name = GetSpecializationInfo(index)
        if name and name ~= "" then
            return name
        end
    end
    return tostring(index)
end

--------------------------------------------------------------------------------
-- Assisted combat
--------------------------------------------------------------------------------

local AssistedCombat = C_AssistedCombat

--- Returns true when the client offers the assisted combat suggestions.
function Compat.HasAssistedCombat()
    return AssistedCombat ~= nil and AssistedCombat.GetNextCastSpell ~= nil
end

--- Returns the spell the assisted combat system suggests casting next. The
--- value may be secret: it can only be handed to the spell functions below.
function Compat.GetNextCastSpell()
    if not Compat.HasAssistedCombat() then
        return nil
    end
    local ok, spellID = pcall(AssistedCombat.GetNextCastSpell, false)
    if ok then
        return spellID
    end
    return nil
end

--- Returns the id of the Assistant Button spell itself.
function Compat.GetAssistantSpell()
    local spellID = AssistedCombat and AssistedCombat.GetActionSpell and AssistedCombat.GetActionSpell()
    if spellID and not Compat.IsSecret(spellID) then
        return spellID
    end
    return 1229376
end

--------------------------------------------------------------------------------
-- Spells
--------------------------------------------------------------------------------

local getSpellTexture = (C_Spell and C_Spell.GetSpellTexture) or _G.GetSpellTexture
local isSpellInRange = C_Spell and C_Spell.IsSpellInRange
local isUsableSpell = (C_Spell and C_Spell.IsSpellUsable) or _G.IsUsableSpell

--- Returns the icon of a spell.
function Compat.GetSpellTexture(spellID)
    if not getSpellTexture then
        return nil
    end
    local ok, texture = pcall(getSpellTexture, spellID)
    if ok then
        return texture
    end
    return nil
end

--- Returns true, false or nil (no range to check) for a spell on the target.
--- Secret values are reported as nil, so the button is never tinted wrongly.
function Compat.IsSpellInRange(spellID)
    local ok, inRange
    if isSpellInRange then
        ok, inRange = pcall(isSpellInRange, spellID, "target")
    elseif _G.IsSpellInRange and GetSpellInfo then
        -- Classic clients check the range by name and answer 1, 0 or nil.
        local name = GetSpellInfo(spellID)
        if not name then
            return nil
        end
        ok, inRange = pcall(_G.IsSpellInRange, name, "target")
    else
        return nil
    end
    if not ok or Compat.IsSecret(inRange) or inRange == nil then
        return nil
    end
    return inRange == true or inRange == 1
end

--- Returns usable, notEnoughPower for a spell. Unknown or secret values are
--- reported as usable.
function Compat.IsSpellUsable(spellID)
    if not isUsableSpell then
        return true, false
    end
    local ok, usable, noPower = pcall(isUsableSpell, spellID)
    if not ok or Compat.IsSecret(usable) or Compat.IsSecret(noPower) then
        return true, false
    end
    return usable and true or false, noPower and true or false
end

--------------------------------------------------------------------------------
-- Action slots (only used to clean up the slot of 1.x)
--------------------------------------------------------------------------------

local ActionBar = C_ActionBar or {}
local getActionInfo = ActionBar.GetActionInfo or _G.GetActionInfo
local pickupAction = ActionBar.PickupAction or _G.PickupAction

--- Returns the type and id of what an action slot holds ("spell", 1229376).
function Compat.GetActionInfo(slot)
    if not getActionInfo then
        return nil
    end
    return getActionInfo(slot)
end

--- Empties an action slot. Must not be called in combat.
function Compat.ClearAction(slot)
    if pickupAction then
        pickupAction(slot)
        ClearCursor()
    end
end
