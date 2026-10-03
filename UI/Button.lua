--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Button
    The visualizer: a movable icon that mirrors the action slot holding the
    Assistant Button spell, so its suggestion can sit anywhere on the screen.

    The suggested spell changes without any event telling addons about it, so
    the icon is polled while the button is shown. Whether it is shown is
    driven by events.
------------------------------------------------------------------------------]]

local _, ns = ...

local Button = ns:NewModule("Button")
local Compat = ns.Compat

local UPDATE_INTERVAL = 0.1
local EMPTY_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local inCombat = false

--------------------------------------------------------------------------------
-- Frame
--------------------------------------------------------------------------------

local frame = CreateFrame("Frame", "AssistantButtonVisualizerFrame", UIParent)
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:Hide()
Button.frame = frame

local icon = frame:CreateTexture(nil, "ARTWORK")
icon:SetAllPoints()
frame.icon = icon

frame:SetScript("OnDragStart", function(self)
    if not ns.settings.locked then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint()
    local settings = ns.settings
    settings.point, settings.relativePoint = point, relativePoint
    settings.x, settings.y = ns.Round(x, 1), ns.Round(y, 1)
end)

--------------------------------------------------------------------------------
-- Appearance
--------------------------------------------------------------------------------

--- Mirrors the icon of the configured slot, or a placeholder when it is empty.
function Button:UpdateIcon()
    local texture = Compat.GetActionTexture(ns.settings.slot)
    icon:SetTexture(texture or EMPTY_ICON)
    icon:SetDesaturated(texture == nil)
end

local elapsedSinceUpdate = 0
frame:SetScript("OnUpdate", function(_, elapsed)
    elapsedSinceUpdate = elapsedSinceUpdate + elapsed
    if elapsedSinceUpdate >= UPDATE_INTERVAL then
        elapsedSinceUpdate = 0
        Button:UpdateIcon()
    end
end)

--- Returns true when the current visibility mode wants the button shown.
function Button:ShouldShow()
    if ns.settings.visibility == "COMBAT" then
        return inCombat
    end
    return true
end

--- Shows or hides the button and refreshes its icon.
function Button:UpdateVisibility()
    if self:ShouldShow() then
        self:UpdateIcon()
        frame:Show()
    else
        frame:Hide()
    end
end

function Button:ApplyPosition()
    local settings = ns.settings
    frame:ClearAllPoints()
    frame:SetPoint(settings.point, UIParent, settings.relativePoint, settings.x, settings.y)
end

--- Applies every saved setting to the frame.
function Button:ApplySettings()
    local settings = ns.settings
    frame:SetSize(settings.size, settings.size)
    frame:SetAlpha(settings.alpha)
    frame:EnableMouse(not settings.locked)
    self:UpdateVisibility()
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

function Button:OnLogin()
    inCombat = UnitAffectingCombat("player") == true
    self:ApplyPosition()
    self:ApplySettings()

    local function Refresh()
        self:UpdateVisibility()
    end
    ns:RegisterEvent("PLAYER_REGEN_DISABLED", function()
        inCombat = true
        Refresh()
    end)
    ns:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        inCombat = false
        Refresh()
    end)
    ns:RegisterEvent("PLAYER_ENTERING_WORLD", Refresh)
    ns:RegisterEvent("ACTIONBAR_SLOT_CHANGED", function(_, slot)
        if slot == 0 or slot == ns.settings.slot then
            Refresh()
        end
    end)

    ns:RegisterMessage("ABV_SETTINGS_CHANGED", function()
        self:ApplySettings()
    end)
    ns:RegisterMessage("ABV_SLOT_CHANGED", Refresh)
    ns:RegisterMessage("ABV_POSITION_CHANGED", function()
        self:ApplyPosition()
    end)
end
