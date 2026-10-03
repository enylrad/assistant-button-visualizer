--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Mover
    Lets the player place the button, even when it is locked or hidden.

    - Retail and Forever: entering the game's Edit Mode turns the mover on and
      leaving it turns it off, like the default frames.
    - Every client: /abv move or the "Move" button in the options. Right click
      the button, press Escape or run the command again to finish.
------------------------------------------------------------------------------]]

local _, ns = ...

local Mover = ns:NewModule("Mover")
local Button = ns.Button
local L = ns.L

local frame = Button.frame

-- Edit Mode style selection: a blue tint and the addon name over the button.
local overlay = CreateFrame("Frame", "AssistantButtonVisualizerMover", frame)
overlay:SetAllPoints()
overlay:SetFrameLevel(frame:GetFrameLevel() + 5)
overlay:Hide()

local tint = overlay:CreateTexture(nil, "OVERLAY")
tint:SetAllPoints()
tint:SetColorTexture(0.25, 0.55, 1, 0.35)

local label = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
label:SetPoint("BOTTOM", overlay, "TOP", 0, 4)
label:SetText(ns.title)

local hint = overlay:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
hint:SetPoint("TOP", overlay, "BOTTOM", 0, -4)
hint:SetWidth(220)

-- Escape hides the special frames; hiding the overlay finishes moving.
tinsert(UISpecialFrames, overlay:GetName())

overlay:SetScript("OnHide", function()
    if Mover.active then
        Mover:Stop()
    end
end)

frame:HookScript("OnMouseUp", function(_, mouseButton)
    if mouseButton == "RightButton" and Mover.active and not Mover.fromEditMode then
        Mover:Stop()
    end
end)

--- Turns the mover on. `fromEditMode` marks that the game's Edit Mode owns
--- it, so only leaving Edit Mode finishes it.
function Mover:Start(fromEditMode)
    self.active = true
    self.fromEditMode = fromEditMode and true or false
    hint:SetText(fromEditMode and "" or L["MOVER_HINT"])
    Button:SetMoving(true)
    overlay:Show()
    ns:SendMessage("ABV_MOVER_CHANGED", true)
end

function Mover:Stop()
    if not self.active then
        return
    end
    self.active = false
    self.fromEditMode = false
    overlay:Hide()
    Button:SetMoving(false)
    ns:SendMessage("ABV_MOVER_CHANGED", false)
end

function Mover:Toggle()
    if self.active then
        self:Stop()
    else
        self:Start(false)
    end
end

--- Returns true when the client has the Edit Mode the mover follows.
function Mover:HasEditMode()
    return EventRegistry ~= nil and EditModeManagerFrame ~= nil
end

function Mover:OnLogin()
    if self:HasEditMode() then
        EventRegistry:RegisterCallback("EditMode.Enter", function()
            self:Start(true)
        end, self)
        EventRegistry:RegisterCallback("EditMode.Exit", function()
            self:Stop()
        end, self)
    end
    ns:RegisterMessage("ABV_LOCALE_CHANGED", function()
        if self.active and not self.fromEditMode then
            hint:SetText(L["MOVER_HINT"])
        end
    end)
end
