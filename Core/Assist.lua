--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Assist
    Tells the button which spell the assisted combat system suggests, asking
    C_AssistedCombat for the next spell. Nothing is placed on the action bars.

    Versions 1.x kept the Assistant Button spell in an action slot and
    mirrored it. That spell is removed from the slot once, after updating.
------------------------------------------------------------------------------]]

local _, ns = ...

local Assist = ns:NewModule("Assist")
local Compat = ns.Compat
local L = ns.L

local DEFAULT_INTERVAL = 0.1
local LOGIN_DELAY = 2   -- the action bars are not ready right at login

-- Slot of 1.x waiting for combat to end before it is emptied.
local pendingClear = nil

--- Returns true when the client offers the assisted combat suggestions.
function Assist:IsAvailable()
    return Compat.HasAssistedCombat()
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
--- none. Either value may be secret.
function Assist:GetSuggestion()
    local spellID = Compat.GetNextCastSpell()
    if not Compat.IsSecret(spellID) and spellID == nil then
        return nil, nil
    end
    return Compat.GetSpellTexture(spellID), spellID
end

--------------------------------------------------------------------------------
-- Clean-up of 1.x
--------------------------------------------------------------------------------

--- Empties the slot when it holds the Assistant Button spell. Anything else
--- the player placed there is never touched. Waits for combat to end.
local function ClearLegacySlot(slot)
    if Compat.InCombatLockdown() then
        pendingClear = slot
        return
    end
    pendingClear = nil
    local actionType, id = Compat.GetActionInfo(slot)
    if actionType == "spell" and id == Compat.GetAssistantSpell() then
        Compat.ClearAction(slot)
        ns:Print(L["CLEARED_OLD_SLOT"], slot)
    end
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

function Assist:OnLogin()
    if not self:IsAvailable() then
        ns:Print(L["API_MISSING"])
        return
    end

    local legacySlot = ns.Database.legacySlot
    if legacySlot then
        ns:RegisterEvent("PLAYER_REGEN_ENABLED", function()
            if pendingClear then
                ClearLegacySlot(pendingClear)
            end
        end)
        C_Timer.After(LOGIN_DELAY, function()
            ClearLegacySlot(legacySlot)
        end)
    end
end
