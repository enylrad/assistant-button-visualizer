--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Options panel
    Registered in the game's AddOns settings. Tunes how the button looks, when
    it is shown and which action slot holds the Assistant Button spell.

    Built with stock Blizzard templates of the mainline UI.
------------------------------------------------------------------------------]]

local _, ns = ...

local Options = ns:NewModule("Options")
local Database = ns.Database
local Installer = ns.Installer
local L = ns.L

local CONTENT_WIDTH = 560

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function Notify()
    ns:SendMessage("ABV_SETTINGS_CHANGED")
end

-- Font strings whose text follows the active locale: { fontString, key }.
local localizedTexts = {}

local function SetLocalizedText(fontString, key)
    localizedTexts[#localizedTexts + 1] = { fontString, key }
    fontString:SetText(L[key])
end

local function CreateText(parent, template, key)
    local text = parent:CreateFontString(nil, "ARTWORK", template or "GameFontHighlight")
    text:SetJustifyH("LEFT")
    if key then
        SetLocalizedText(text, key)
    end
    return text
end

local function CreateButton(parent, width, key, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 22)
    if key then
        SetLocalizedText(button:GetFontString(), key)
    end
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateCheckbox(parent, key, getValue, setValue)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetSize(26, 26)
    local label = checkbox.Text or checkbox.text
    if label then
        label:SetFontObject("GameFontHighlight")
        SetLocalizedText(label, key)
    end
    checkbox:SetScript("OnClick", function(self)
        setValue(self:GetChecked() and true or false)
    end)
    checkbox.Refresh = function(self)
        self:SetChecked(getValue())
    end
    return checkbox
end

--- Creates a dropdown. `buildOptions` returns a list of { value, label } and
--- is evaluated every time the menu is generated.
local function CreateDropdown(parent, width, buildOptions, getValue, setValue)
    local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(width)
    dropdown:SetupMenu(function(_, root)
        for _, option in ipairs(buildOptions()) do
            root:CreateRadio(option.label,
                function(value) return getValue() == value end,
                function(value) setValue(value) end,
                option.value)
        end
    end)
    return dropdown
end

--- Creates a captioned slider with stepper arrows and its value on the right.
local function CreateSlider(parent, key, minValue, maxValue, step, format, getValue, setValue)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(260, 40)
    local caption = CreateText(holder, "GameFontNormal", key)
    caption:SetPoint("TOPLEFT")

    local slider = CreateFrame("Frame", nil, holder, "MinimalSliderWithSteppersTemplate")
    slider:SetPoint("BOTTOMLEFT", 0, 0)
    slider:SetPoint("BOTTOMRIGHT", -44, 0)
    slider:SetHeight(20)

    local mixin = MinimalSliderWithSteppersMixin
    local steps = math.max(1, math.floor((maxValue - minValue) / step + 0.5))
    slider:Init(getValue(), minValue, maxValue, steps, {
        [mixin.Label.Right] = format,
    })

    local updating = false
    slider:RegisterCallback(mixin.Event.OnValueChanged, function(_, value)
        if not updating then
            setValue(ns.Round(ns.Round(value / step) * step, 2))
        end
    end, holder)

    holder.Refresh = function()
        updating = true
        slider:SetValue(getValue())
        updating = false
    end
    return holder
end

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

local function VisibilityOptions()
    local options = {}
    for _, mode in ipairs(Database.VISIBILITY_MODES) do
        options[#options + 1] = { value = mode, label = L["VISIBILITY_" .. mode] }
    end
    return options
end

local function LocaleOptions()
    local options = {}
    for _, code in ipairs(ns.AVAILABLE_LOCALES) do
        options[#options + 1] = { value = code, label = L["LOCALE_" .. code] }
    end
    return options
end

function Options:BuildPanel(panel)
    local widgets = {}
    self.widgets = widgets
    local x = 16

    local title = CreateText(panel, "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", x, -16)
    title:SetText(ns.coloredTitle)

    local version = CreateText(panel, "GameFontDisable")
    version:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 8, 2)
    version:SetText("v" .. (ns.Compat.GetAddOnMetadata("Version") or "?"))

    local subtitle = CreateText(panel, "GameFontHighlightSmall", "OPTIONS_SUBTITLE")
    subtitle:SetPoint("TOPLEFT", x, -46)
    subtitle:SetWidth(CONTENT_WIDTH)
    subtitle:SetWordWrap(true)

    ------------------------------------------------------------------ Display
    widgets.locked = CreateCheckbox(panel, "OPT_LOCK",
        function() return ns.settings.locked end,
        function(value) ns.settings.locked = value; Notify() end)
    widgets.locked:SetPoint("TOPLEFT", x - 4, -80)

    widgets.colorByState = CreateCheckbox(panel, "OPT_COLOR_BY_STATE",
        function() return ns.settings.colorByState end,
        function(value) ns.settings.colorByState = value; Notify() end)
    widgets.colorByState:SetPoint("TOPLEFT", x - 4, -128)

    widgets.hideMounted = CreateCheckbox(panel, "OPT_HIDE_MOUNTED",
        function() return ns.settings.hideMounted end,
        function(value) ns.settings.hideMounted = value; Notify() end)
    widgets.hideMounted:SetPoint("TOPLEFT", x - 4, -104)

    local visibilityCaption = CreateText(panel, "GameFontNormal", "OPT_VISIBILITY")
    visibilityCaption:SetPoint("TOPLEFT", x, -168)
    widgets.visibility = CreateDropdown(panel, 200, VisibilityOptions,
        function() return ns.settings.visibility end,
        function(value) ns.settings.visibility = value; Notify() end)
    widgets.visibility:SetPoint("TOPLEFT", x, -186)

    local languageCaption = CreateText(panel, "GameFontNormal", "OPT_LANGUAGE")
    languageCaption:SetPoint("TOPLEFT", x + 300, -168)
    widgets.language = CreateDropdown(panel, 200, LocaleOptions,
        function() return ns.settings.locale end,
        function(value)
            ns.settings.locale = value
            ns:SetLocale(value)
        end)
    widgets.language:SetPoint("TOPLEFT", x + 300, -186)

    widgets.alpha = CreateSlider(panel, "OPT_OPACITY", 0.1, 1, 0.05,
        function(value) return ("%d%%"):format(ns.Round(value * 100)) end,
        function() return ns.settings.alpha end,
        function(value) ns.settings.alpha = value; Notify() end)
    widgets.alpha:SetPoint("TOPLEFT", x, -230)

    widgets.size = CreateSlider(panel, "OPT_SIZE", Database.MIN_SIZE, Database.MAX_SIZE, 1,
        function(value) return tostring(ns.Round(value)) end,
        function() return ns.settings.size end,
        function(value) ns.settings.size = value; Notify() end)
    widgets.size:SetPoint("TOPLEFT", x + 300, -230)

    ------------------------------------------------------------------ Slot
    -- The slot is staged and applied with a button: moving the slider would
    -- otherwise clear and fill every slot it passes over.
    widgets.slot = CreateSlider(panel, "OPT_SLOT", Database.MIN_SLOT, Database.MAX_SLOT, 1,
        function(value) return tostring(ns.Round(value)) end,
        function() return self.pendingSlot or ns.settings.slot end,
        function(value)
            self.pendingSlot = value
            if widgets.apply then
                widgets.apply:SetEnabled(value ~= ns.settings.slot)
            end
        end)
    widgets.slot:SetPoint("TOPLEFT", x, -294)

    widgets.apply = CreateButton(panel, 100, "OPT_APPLY", function()
        local slot = self.pendingSlot
        self.pendingSlot = nil
        if slot and slot ~= ns.settings.slot then
            Installer:SetSlot(slot)
            ns:Print(L["APPLIED_NEW_SLOT"], slot)
        end
        self:Refresh()
    end)
    widgets.apply:SetPoint("BOTTOMLEFT", widgets.slot, "BOTTOMRIGHT", 10, -1)

    local slotHelp = CreateText(panel, "GameFontDisableSmall", "OPT_SLOT_HELP")
    slotHelp:SetPoint("TOPLEFT", x, -342)
    slotHelp:SetWidth(CONTENT_WIDTH)
    slotHelp:SetWordWrap(true)

    ------------------------------------------------------------------ Actions
    widgets.install = CreateButton(panel, 180, "OPT_INSTALL", function()
        Installer:Install(true)
    end)
    widgets.install:SetPoint("TOPLEFT", x, -398)

    widgets.resetPosition = CreateButton(panel, 180, "OPT_RESET_POSITION", function()
        Database:ResetPosition()
        ns:Print(L["POSITION_RESET"])
    end)
    widgets.resetPosition:SetPoint("LEFT", widgets.install, "RIGHT", 10, 0)
end

function Options:Refresh()
    local widgets = self.widgets
    if not widgets then
        return
    end
    for _, entry in ipairs(localizedTexts) do
        entry[1]:SetText(L[entry[2]])
    end
    widgets.locked:Refresh()
    widgets.colorByState:Refresh()
    widgets.hideMounted:Refresh()
    widgets.visibility:GenerateMenu()
    widgets.language:GenerateMenu()
    widgets.alpha:Refresh()
    widgets.size:Refresh()
    widgets.slot:Refresh()
    widgets.apply:SetEnabled(self.pendingSlot ~= nil and self.pendingSlot ~= ns.settings.slot)
end

function Options:OnInitialize()
    local panel = CreateFrame("Frame")
    panel.name = ns.title
    panel:Hide()
    panel:SetScript("OnShow", function()
        if not self.widgets then
            self:BuildPanel(panel)
        end
        self:Refresh()
    end)
    panel:SetScript("OnHide", function()
        -- An unapplied slot is discarded when the panel closes.
        self.pendingSlot = nil
    end)
    self.panel = panel

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, ns.title)
        Settings.RegisterAddOnCategory(category)
        self.category = category
    end

    local function RefreshIfShown()
        if panel:IsShown() then
            self:Refresh()
        end
    end
    ns:RegisterMessage("ABV_SETTINGS_CHANGED", RefreshIfShown)
    ns:RegisterMessage("ABV_LOCALE_CHANGED", RefreshIfShown)
end

--- Opens the game settings on this addon's page.
function Options:Open()
    if self.category and Settings and Settings.OpenToCategory then
        local id = self.category.GetID and self.category:GetID() or self.category.ID
        Settings.OpenToCategory(id)
    end
end
