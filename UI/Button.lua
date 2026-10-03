--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Button
    The visualizer: a movable icon that shows the spell the assisted combat
    system suggests, so the suggestion can sit anywhere on the screen.

    The suggestion and its range change without any event telling addons
    about them, so they are polled while the visibility rules allow the
    button. Those rules are evaluated on events.
------------------------------------------------------------------------------]]

local _, ns = ...

local Button = ns:NewModule("Button")
local Compat = ns.Compat
local Assist = ns.Assist

local EMPTY_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local BLIZZARD_BORDER = "Interface\\Buttons\\UI-Quickslot2"
local BLIZZARD_BORDER_SCALE = 64 / 36   -- the art is drawn for a 36 px button
local GLOW_TEXTURE = "Interface\\Buttons\\UI-ActionButton-Border"
local CROP = 0.08

-- Masks that give the icon its shape (made by tools\make-masks.ps1). The
-- square shape uses no mask.
local MEDIA = "Interface\\AddOns\\" .. ns.name .. "\\Media\\"
local SHAPE_MASKS = {
    rounded = MEDIA .. "Rounded",
    circle = MEDIA .. "Circle",
    soft = MEDIA .. "SoftCircle",
}
local SOFT_GLOW = MEDIA .. "SoftCircle"

-- Tints used by the default action buttons.
local COLOR_NORMAL = { 1, 1, 1 }
local COLOR_OUT_OF_RANGE = { 0.8, 0.1, 0.1 }
local COLOR_NO_POWER = { 0.5, 0.5, 1 }
local COLOR_UNUSABLE = { 0.4, 0.4, 0.4 }

local inCombat = false
local shown = false          -- the visibility the button is heading to
local fadeGoal = 0           -- the alpha the button is heading to
local lastSuggestion = nil   -- spell id or texture of the last suggestion

--------------------------------------------------------------------------------
-- Frame
--------------------------------------------------------------------------------

local frame = CreateFrame("Frame", "AssistantButtonVisualizerFrame", UIParent)
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:Hide()
Button.frame = frame

-- Thin border: a black shape behind the icon, one pixel larger.
local background = frame:CreateTexture(nil, "BACKGROUND")
background:SetColorTexture(0, 0, 0, 1)
background:SetPoint("TOPLEFT", -1, 1)
background:SetPoint("BOTTOMRIGHT", 1, -1)

local icon = frame:CreateTexture(nil, "ARTWORK")
icon:SetAllPoints()
frame.icon = icon

--- Creates a mask that covers `texture`, or nil on clients without masks.
local function CreateMask(texture)
    if not frame.CreateMaskTexture then
        return nil
    end
    local mask = frame:CreateMaskTexture()
    mask:SetAllPoints(texture)
    return mask
end

local iconMask = CreateMask(icon)
local backgroundMask = CreateMask(background)

-- Blizzard border: the frame of the default action buttons.
local blizzardBorder = frame:CreateTexture(nil, "OVERLAY")
blizzardBorder:SetTexture(BLIZZARD_BORDER)
blizzardBorder:SetPoint("CENTER")

-- Pulse shown when the suggestion changes.
local glow = frame:CreateTexture(nil, "OVERLAY", nil, 1)
glow:SetTexture(GLOW_TEXTURE)
glow:SetBlendMode("ADD")
glow:SetVertexColor(1, 0.85, 0.3)
glow:SetPoint("CENTER")
glow:SetAlpha(0)

local pulse = glow:CreateAnimationGroup()
local fadeIn = pulse:CreateAnimation("Alpha")
fadeIn:SetFromAlpha(0)
fadeIn:SetToAlpha(1)
fadeIn:SetDuration(0.12)
fadeIn:SetOrder(1)
local fadeOut = pulse:CreateAnimation("Alpha")
fadeOut:SetFromAlpha(1)
fadeOut:SetToAlpha(0)
fadeOut:SetDuration(0.35)
fadeOut:SetOrder(2)

frame:SetScript("OnDragStart", function(self)
    if Button.moving or not ns.settings.locked then
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
-- Suggestion
--------------------------------------------------------------------------------

--- Returns true when the value can be tested (it is not a secret value).
local function IsPlain(value)
    return not Compat.IsSecret(value)
end

--- Tints the icon red out of range, blue without enough power and grey when
--- the spell cannot be used, like the default action buttons.
local function UpdateColor(spellID)
    local color = COLOR_NORMAL
    if ns.settings.colorByState and (Compat.IsSecret(spellID) or spellID ~= nil) then
        local usable, noPower = Compat.IsSpellUsable(spellID)
        if Compat.IsSpellInRange(spellID) == false then
            color = COLOR_OUT_OF_RANGE
        elseif noPower then
            color = COLOR_NO_POWER
        elseif not usable then
            color = COLOR_UNUSABLE
        end
    end
    icon:SetVertexColor(color[1], color[2], color[3])
end

--- Plays the pulse when the suggestion changed. Secret values cannot be
--- compared, so they never pulse.
local function CheckChange(spellID, texture)
    local key = spellID
    if not IsPlain(key) or key == nil then
        key = nil
        if IsPlain(texture) then
            key = texture
        end
    end
    if key ~= nil and key ~= lastSuggestion then
        if lastSuggestion ~= nil and ns.settings.glow then
            pulse:Stop()
            pulse:Play()
        end
        lastSuggestion = key
    end
end

--- Reads the suggestion and draws it. Returns true when there is one.
function Button:UpdateSuggestion()
    local texture, spellID = Assist:GetSuggestion()
    local hasSuggestion = Compat.IsSecret(texture) or texture ~= nil
    if hasSuggestion then
        icon:SetTexture(texture)
        icon:SetDesaturated(false)
        UpdateColor(spellID)
        CheckChange(spellID, texture)
    else
        icon:SetTexture(EMPTY_ICON)
        icon:SetDesaturated(true)
        icon:SetVertexColor(1, 1, 1)
    end
    return hasSuggestion
end

--------------------------------------------------------------------------------
-- Visibility
--------------------------------------------------------------------------------

--- Returns true when the player targets something alive that can be attacked.
local function HasHostileTarget()
    if not UnitExists("target") or UnitIsDeadOrGhost("target") then
        return false
    end
    local canAttack = UnitCanAttack("player", "target")
    return IsPlain(canAttack) and canAttack == true
end

-- Visibility modes: return true when the button may be shown.
local VISIBILITY_TESTS = {
    ALWAYS = function() return true end,
    COMBAT = function() return inCombat end,
    HOSTILE = HasHostileTarget,
    INSTANCE = function() return IsInInstance() == true end,
}

--- Returns true when the visibility rules allow the button. Whether there is
--- a suggestion to show is checked separately, while polling.
function Button:IsAllowed()
    if self.moving then
        return true
    end
    local settings = ns.settings
    if settings.hideMounted and IsMounted() and not inCombat then
        return false
    end
    local test = VISIBILITY_TESTS[settings.visibility] or VISIBILITY_TESTS.ALWAYS
    return test()
end

local function TargetAlpha()
    if Button.moving then
        return 1
    end
    local settings = ns.settings
    return inCombat and settings.alphaCombat or settings.alphaOutOfCombat
end

local function StopFade()
    if UIFrameFadeRemoveFrame then
        UIFrameFadeRemoveFrame(frame)
    end
end

--- Fades the button to `alpha`, then hides it when `hide` is set.
local function FadeTo(alpha, hide)
    StopFade()
    local duration = Button.moving and 0 or ns.settings.fade
    if duration <= 0 or not UIFrameFade then
        frame:SetAlpha(alpha)
        if hide then
            frame:Hide()
        end
        return
    end
    UIFrameFade(frame, {
        mode = alpha >= frame:GetAlpha() and "IN" or "OUT",
        timeToFade = duration,
        startAlpha = frame:GetAlpha(),
        endAlpha = alpha,
        finishedFunc = hide and function()
            if not shown then
                frame:Hide()
            end
        end or nil,
    })
end

--- Shows or hides the button with the configured fade.
--- Called on every poll, so a fade only starts when the goal changes.
local function SetShown(visible)
    local alpha = visible and TargetAlpha() or 0
    if visible == shown and alpha == fadeGoal then
        return
    end
    shown = visible
    fadeGoal = alpha
    if visible then
        if not frame:IsShown() then
            frame:SetAlpha(0)
            frame:Show()
        end
        FadeTo(TargetAlpha())
    elseif frame:IsShown() then
        FadeTo(0, true)
    end
end

--- Evaluates every rule and shows the button accordingly.
function Button:Update()
    if not self:IsAllowed() or not (self.moving or Assist:IsAvailable()) then
        self.poller:Hide()
        SetShown(false)
        return
    end
    self.poller:Show()
    local hasSuggestion = self:UpdateSuggestion()
    SetShown(hasSuggestion or self.moving or not ns.settings.hideWithoutSuggestion)
end

-- Polls the suggestion while the rules allow the button, even when it is
-- hidden because there is nothing to suggest.
local poller = CreateFrame("Frame")
poller:Hide()
Button.poller = poller
local elapsedSinceUpdate = 0
poller:SetScript("OnUpdate", function(_, elapsed)
    elapsedSinceUpdate = elapsedSinceUpdate + elapsed
    if elapsedSinceUpdate >= Button.interval then
        elapsedSinceUpdate = 0
        local hasSuggestion = Button:UpdateSuggestion()
        SetShown(hasSuggestion or Button.moving or not ns.settings.hideWithoutSuggestion)
    end
end)
Button.interval = 0.1

--------------------------------------------------------------------------------
-- Appearance
--------------------------------------------------------------------------------

function Button:ApplyPosition()
    local settings = ns.settings
    frame:ClearAllPoints()
    frame:SetPoint(settings.point, UIParent, settings.relativePoint, settings.x, settings.y)
end

--- Puts a mask with the given file on a texture, or takes it off (nil).
local function SetMask(texture, mask, file)
    if not mask then
        return
    end
    if texture.maskFile then
        texture:RemoveMaskTexture(mask)
        texture.maskFile = nil
    end
    if file then
        mask:SetTexture(file, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        texture:AddMaskTexture(mask)
        texture.maskFile = file
    end
end

--- Applies the look of the active profile.
function Button:ApplyStyle()
    local settings = ns.settings
    local size = settings.size
    frame:SetSize(size, size)

    if settings.cropIcon then
        icon:SetTexCoord(CROP, 1 - CROP, CROP, 1 - CROP)
    else
        icon:SetTexCoord(0, 1, 0, 1)
    end

    -- Without mask support every shape falls back to the square.
    local shape = iconMask and settings.shape or "square"
    local maskFile = SHAPE_MASKS[shape]
    SetMask(icon, iconMask, maskFile)
    SetMask(background, backgroundMask, maskFile)

    -- The action button frame only fits a square: other shapes get the thin
    -- border instead. The soft circle fades out, so it has no border at all.
    local border = settings.border
    if shape ~= "square" and border == "blizzard" then
        border = "thin"
    end
    if shape == "soft" then
        border = "none"
    end
    background:SetShown(border == "thin")
    blizzardBorder:SetShown(border == "blizzard")
    blizzardBorder:SetSize(size * BLIZZARD_BORDER_SCALE, size * BLIZZARD_BORDER_SCALE)

    -- Round shapes get a round flash. It covers the icon instead of ringing
    -- it, so it is dimmer.
    if shape == "square" then
        glow:SetTexture(GLOW_TEXTURE)
        glow:SetVertexColor(1, 0.85, 0.3)
        glow:SetSize(size * 1.9, size * 1.9)
    else
        glow:SetTexture(SOFT_GLOW)
        glow:SetVertexColor(0.6, 0.5, 0.2)
        glow:SetSize(size * 1.5, size * 1.5)
    end
end

--- Applies every setting of the active profile to the frame.
function Button:ApplySettings()
    self.interval = Assist:GetInterval()
    self:ApplyStyle()
    frame:EnableMouse(self.moving or not ns.settings.locked)
    self:Update()
end

--- Lets the button be dragged and keeps it visible (used by the mover).
function Button:SetMoving(moving)
    self.moving = moving and true or false
    self:ApplySettings()
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

function Button:OnLogin()
    inCombat = UnitAffectingCombat("player") == true
    self:ApplyPosition()
    self:ApplySettings()

    local function Update()
        self:Update()
    end
    ns:RegisterEvent("PLAYER_REGEN_DISABLED", function()
        inCombat = true
        Update()
    end)
    ns:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        inCombat = false
        Update()
    end)
    ns:RegisterEvent("PLAYER_ENTERING_WORLD", Update)
    ns:RegisterEvent("PLAYER_TARGET_CHANGED", Update)
    ns:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", Update)
    ns:RegisterEvent("UNIT_FLAGS", function(_, unit)
        if unit == "target" then
            Update()
        end
    end)

    ns:RegisterMessage("ABV_SETTINGS_CHANGED", function()
        self:ApplySettings()
    end)
    ns:RegisterMessage("ABV_PROFILE_CHANGED", function()
        self:ApplyPosition()
        self:ApplySettings()
    end)
    ns:RegisterMessage("ABV_POSITION_CHANGED", function()
        self:ApplyPosition()
    end)
end
